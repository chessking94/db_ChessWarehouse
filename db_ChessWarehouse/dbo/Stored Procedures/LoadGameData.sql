
CREATE PROCEDURE [dbo].[LoadGameData]

AS

DECLARE @filetypeid smallint = 1 --hard code file type; one proc, one type
DECLARE @dir varchar(200)
DECLARE @ext varchar(10)
DECLARE @cmd varchar(500)
DECLARE @err_msg int = -1

DECLARE @file_ct int
DECLARE @filename varchar(100)
DECLARE @dte datetime
DECLARE @fhid int
DECLARE @rec_ct int
DECLARE @fld varchar(20)
DECLARE @err_ct int

--get a listing of files to import
IF (OBJECT_ID('tempdb..#directory') IS NOT NULL) DROP TABLE #directory
CREATE TABLE #directory (content varchar(1000))

IF (OBJECT_ID('tempdb..#pendingfiles') IS NOT NULL) DROP TABLE #pendingfiles
CREATE TABLE #pendingfiles (filename varchar(200))

SET @dir = dbo.GetSettingValue('FileProcessing Directory')
IF RIGHT(@dir, 1) <> '\' SET @dir = @dir + '\'
SET @dir = @dir + @@SERVERNAME + '\Import\GameData\'

SET @cmd = 'DIR "' + @dir + '"'

INSERT INTO #directory
EXEC master.dbo.xp_cmdshell @cmd

SELECT @ext = FileExtension FROM FileTypes WHERE FileTypeID = @filetypeid
INSERT INTO #pendingfiles
SELECT LTRIM(RTRIM(SUBSTRING(content, 40, LEN(content)))) FROM #directory WHERE (CASE WHEN content LIKE '%.%' THEN REVERSE(LEFT(REVERSE(content), CHARINDEX('.', REVERSE(content)) - 1)) ELSE NULL END) = @ext

SELECT @file_ct = COUNT(filename) FROM #pendingfiles
IF @file_ct = 0
BEGIN
	RAISERROR('No files found to import', 1, 1)
	RETURN @err_msg
END

EXEC dbo.DeleteStagedGameData @errors = 0
SET @err_msg = 0

--all good, begin file processing loop
WHILE @file_ct > 0
BEGIN
	SELECT TOP 1 @filename = filename FROM #pendingfiles
	SET @dte = GETDATE()

	TRUNCATE TABLE stage.BulkInsertGameData
	SET @cmd = 'BULK INSERT stage.BulkInsertGameData FROM ''' + @dir + @filename + ''' WITH (FIELDTERMINATOR = ''\t'', ROWTERMINATOR = ''\n'')'
	EXECUTE (@cmd)

	SELECT @rec_ct = COUNT(RecordKey) FROM stage.BulkInsertGameData

	--log file record
	INSERT INTO FileHistory (FileTypeID, Filename, DateStarted, Records)
	SELECT @filetypeid, @filename, @dte, @rec_ct

	SET @fhid = @@IDENTITY

	--stage and preprocess game data
	EXEC dbo.StageGames @fileid = @fhid
	EXEC dbo.FormatGameData

	--check staged games for duplicates
	EXEC dbo.DupCheckStagedGames

	SELECT @err_ct = COUNT(Errors) FROM stage.Games WHERE Errors IS NOT NULL
	IF @err_ct > 0 SET @err_msg = 50001

	IF @err_msg = 0
	BEGIN
		--stage and preprocess move data
		EXEC dbo.StageMoves
		EXEC dbo.FormatMoveData

		SELECT @err_ct = COUNT(Errors) FROM stage.Moves WHERE Errors IS NOT NULL
		IF @err_ct > 0 SET @err_msg = 50002

		IF @err_msg = 0
		BEGIN
			--stage new dimension data
			EXEC dbo.InsertNewEvents
			EXEC dbo.InsertNewPlayers
			EXEC dbo.InsertNewTimeControls
			EXEC dbo.InsertNewEngines

			--add new key values to staged game data
			EXEC dbo.UpdateStagedGameKeys

			--create new game records
			EXEC dbo.InsertNewGames

			--add new key values to staged move data
			EXEC dbo.UpdateStagedMoveKeys

			--create new move records
			EXEC dbo.InsertNewMoves

			--update move scores
			EXEC dbo.UpdateMoveScores @fhid

			--update game data
			EXEC dbo.UpdateGameData @fhid
		END
	END

	EXEC dbo.DeleteStagedGameData @errors = @err_ct

	UPDATE FileHistory
	SET DateCompleted = GETDATE(), Errors = @err_ct
	WHERE FileID = @fhid

	IF @err_msg = 0
	BEGIN
		SET @cmd = 'MOVE "' + @dir + + @filename + '" "' + @dir + 'Archive\' + @filename + '"'
		EXEC master.dbo.xp_cmdshell @cmd
	END

	DELETE FROM #pendingfiles WHERE filename = @filename
	SELECT @file_ct = COUNT(filename) FROM #pendingfiles
END

DROP TABLE #directory
DROP TABLE #pendingfiles

IF @err_msg > 0
BEGIN
	RAISERROR(@err_msg, 16, 1)
END
