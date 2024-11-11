
CREATE PROCEDURE [dbo].[LoadGameData] (
	@piFileName VARCHAR(100) = NULL  --the base name, i.e. MyFile.game
)

AS

DECLARE @filetypeid SMALLINT = 1 --hard code file type; one proc, one type
DECLARE @dir VARCHAR(200)
DECLARE @ext VARCHAR(10)
DECLARE @cmd VARCHAR(500)
DECLARE @err_msg nVARCHAR(100)

DECLARE @file_ct INT
DECLARE @filename VARCHAR(100)
DECLARE @dte DATETIME
DECLARE @fhid INT
DECLARE @rec_ct INT
DECLARE @fld VARCHAR(20)
DECLARE @err_ct INT

--get a listing of files to import; use file type ID to differentiate temp tables across procs
IF (OBJECT_ID('tempdb..#directory1') IS NOT NULL) DROP TABLE #directory1
CREATE TABLE #directory1 (content VARCHAR(1000))

IF (OBJECT_ID('tempdb..#pendingfiles1') IS NOT NULL) DROP TABLE #pendingfiles1
CREATE TABLE #pendingfiles1 (filename VARCHAR(200))

SET @dir = dbo.GetSettingValue('FileProcessing Directory')
IF RIGHT(@dir, 1) <> '\' SET @dir = @dir + '\'
SET @dir = @dir + @@SERVERNAME + '\Import\GameData\'

SET @cmd = 'DIR "' + @dir + '"'

INSERT INTO #directory1
EXEC master.dbo.xp_cmdshell @cmd

IF @piFileName IS NULL
BEGIN
	SELECT @ext = FileExtension FROM FileTypes WHERE FileTypeID = @filetypeid
	INSERT INTO #pendingfiles1
	SELECT LTRIM(RTRIM(SUBSTRING(content, 40, LEN(content)))) FROM #directory1 WHERE (CASE WHEN content LIKE '%.%' THEN REVERSE(LEFT(REVERSE(content), CHARINDEX('.', REVERSE(content)) - 1)) ELSE NULL END) = @ext
END

ELSE

BEGIN
	DECLARE @FilePath VARCHAR(200) = @dir + @piFileName
	DECLARE @FileExists INT = 0
    EXEC master.dbo.xp_fileexist @FilePath, @FileExists OUTPUT

    IF @FileExists = 1
	BEGIN
		INSERT INTO #pendingfiles1
		SELECT @piFileName
	END
END

SELECT @file_ct = COUNT(filename) FROM #pendingfiles1
IF @file_ct = 0
BEGIN
	SET @err_msg = 'No files found to import'
	RAISERROR(@err_msg, 1, 1)
	RETURN -1
END

EXEC dbo.DeleteStagedGameData @errors = 0
SET @err_msg = NULL

--all good, begin file processing loop
WHILE @file_ct > 0
BEGIN
	SELECT TOP 1 @filename = filename FROM #pendingfiles1
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
	IF @err_ct > 0 SET @err_msg = 'Unable to validate Game record(s)'

	IF @err_msg IS NULL
	BEGIN
		--stage and preprocess move data
		EXEC dbo.StageMoves
		EXEC dbo.FormatMoveData

		SELECT @err_ct = COUNT(Errors) FROM stage.Moves WHERE Errors IS NOT NULL
		IF @err_ct > 0 SET @err_msg = 'Unable to validate Move record(s)'

		IF @err_msg IS NULL
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

	IF @err_msg IS NULL
	BEGIN
		SET @cmd = 'MOVE "' + @dir + + @filename + '" "' + @dir + 'Archive\' + @filename + '"'
		EXEC master.dbo.xp_cmdshell @cmd
	END

	DELETE FROM #pendingfiles1 WHERE filename = @filename
	SELECT @file_ct = COUNT(filename) FROM #pendingfiles1
END

DROP TABLE #directory1
DROP TABLE #pendingfiles1

IF @err_msg IS NOT NULL
BEGIN
	RAISERROR(@err_msg, 16, 1)
END
