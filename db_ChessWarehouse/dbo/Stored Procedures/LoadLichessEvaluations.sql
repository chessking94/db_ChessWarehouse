CREATE PROCEDURE [dbo].[LoadLichessEvaluations]

AS

DECLARE @filetypeid smallint = 2 --hard code file type; one proc, one type
DECLARE @dir varchar(200)
DECLARE @ext varchar(10)
DECLARE @cmd varchar(500)
DECLARE @err_msg nvarchar(100)

DECLARE @file_ct int
DECLARE @filename varchar(100)
DECLARE @dte datetime
DECLARE @fhid int
DECLARE @rec_ct int
DECLARE @fld varchar(20)
DECLARE @err_ct int

--get a listing of files to import; use file type ID to differentiate temp tables across procs
IF (OBJECT_ID('tempdb..#directory2') IS NOT NULL) DROP TABLE #directory2
CREATE TABLE #directory2 (content varchar(1000))

IF (OBJECT_ID('tempdb..#pendingfiles') IS NOT NULL) DROP TABLE #pendingfiles2
CREATE TABLE #pendingfiles2 (filename varchar(200))

SET @dir = dbo.GetSettingValue('FileProcessing Directory')
IF RIGHT(@dir, 1) <> '\' SET @dir = @dir + '\'
SET @dir = @dir + @@SERVERNAME + '\Import\LichessEvaluations\'

SET @cmd = 'DIR "' + @dir + '"'

INSERT INTO #directory2
EXEC master.dbo.xp_cmdshell @cmd

SELECT @ext = FileExtension FROM FileTypes WHERE FileTypeID = @filetypeid
INSERT INTO #pendingfiles2
SELECT LTRIM(RTRIM(SUBSTRING(content, 40, LEN(content)))) FROM #directory2 WHERE (CASE WHEN content LIKE '%.%' THEN REVERSE(LEFT(REVERSE(content), CHARINDEX('.', REVERSE(content)) - 1)) ELSE NULL END) = @ext

SELECT @file_ct = COUNT(filename) FROM #pendingfiles2
IF @file_ct = 0
BEGIN
	SET @err_msg = 'No files found to import'
	RAISERROR(@err_msg, 1, 1)
	RETURN @err_msg
END

EXEC dbo.DeleteStagedLichessEvaluations @errors = 0
SET @err_msg = NULL
TRUNCATE TABLE lake.LichessEvaluations

--all good, begin file processing loop
WHILE @file_ct > 0
BEGIN
	SELECT TOP 1 @filename = filename FROM #pendingfiles2
	SET @dte = GETDATE()

	TRUNCATE TABLE stage.BulkInsertLichessEvaluations
	SET @cmd = 'BULK INSERT stage.BulkInsertLichessEvaluations FROM ''' + @dir + @filename + ''' WITH (FIELDTERMINATOR = ''\t'', ROWTERMINATOR = ''\n'')'
	EXECUTE (@cmd)

	SELECT @rec_ct = COUNT(FEN) FROM stage.BulkInsertLichessEvaluations

	--log file record
	INSERT INTO FileHistory (FileTypeID, Filename, DateStarted, Records)
	SELECT @filetypeid, @filename, @dte, @rec_ct

	SET @fhid = @@IDENTITY

	--stage and preprocess game data
	EXEC dbo.StageLichessEvals @fileid = @fhid
	EXEC dbo.FormatLichessEvals

	SELECT @err_ct = COUNT(Errors) FROM stage.LichessEvaluations WHERE Errors IS NOT NULL
	IF @err_ct > 0 SET @err_msg = 'Unable to validate Evaluation(s)'

	IF @err_msg IS NULL
	BEGIN
		--finally insert new records
		EXEC dbo.InsertLichessEvaluations
	END

	EXEC dbo.DeleteStagedLichessEvaluations @errors = @err_ct

	UPDATE FileHistory
	SET DateCompleted = GETDATE(), Errors = @err_ct
	WHERE FileID = @fhid

	IF @err_msg IS NULL
	BEGIN
		SET @cmd = 'MOVE "' + @dir + + @filename + '" "' + @dir + 'Archive\' + @filename + '"'
		EXEC master.dbo.xp_cmdshell @cmd
	END

	DELETE FROM #pendingfiles2 WHERE filename = @filename
	SELECT @file_ct = COUNT(filename) FROM #pendingfiles2
END

DROP TABLE #directory2
DROP TABLE #pendingfiles2

IF @err_msg IS NOT NULL
BEGIN
	RAISERROR(@err_msg, 16, 1) --TODO: does this need to change?
END
