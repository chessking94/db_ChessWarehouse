CREATE PROCEDURE [dbo].[LoadLichessEvaluations] (
	@piFileName VARCHAR(100),  --the base name, i.e. MyFile.game
	@poErrorMessage NVARCHAR(MAX) = NULL OUTPUT  --description of resulting error, if one occurred
)

AS

/*
	This procedure accepts a filename (expectation is just the name 'MyFile.game', not the full path 'D:\SERVER\Import\LichessEvaluations\MyFile.game')
	and loads it. While this could be called directly, the intent is for it to be called from an external application that
	validates the existence of the file and any other logic necessary. This is a "dumb proc" and simply does what it is told with
	minimal validation apart from the data itself. The expectation is the external application will also archive the file
	after processing in a clean-up method.
*/

DECLARE @filetypeid SMALLINT = 2 --hard code file type; one proc, one type
DECLARE @dir VARCHAR(200)
DECLARE @cmd VARCHAR(500)
DECLARE @fhid INT
DECLARE @err_ct INT

BEGIN TRY
	--confirm the file hasn't been processed before; assume it has if there is an entry with 0 errors in the history
	IF EXISTS (SELECT FileID FROM dbo.FileHistory WHERE FileTypeID = @filetypeid AND Filename = @piFileName AND Errors = 0)
	BEGIN
		SET @poErrorMessage = 'File previously processed'
		--;THROW 50000, @poErrorMessage, 1
		RETURN -1
	END

	--reaching here means file hasn't been processed before, continue
	SET @dir = dbo.GetSettingValue('FileProcessing Directory')
	IF RIGHT(@dir, 1) <> '\' SET @dir = @dir + '\'
	SET @dir = @dir + 'Import\' + (SELECT REPLACE(FileType, ' ', '') FROM dbo.FileTypes WHERE FileTypeID = @filetypeid) + '\'

	EXEC dbo.DeleteStagedLichessEvaluations @errors = 0
	TRUNCATE TABLE lake.LichessEvaluations

	TRUNCATE TABLE stage.BulkInsertLichessEvaluations
	SET @cmd = 'BULK INSERT stage.BulkInsertLichessEvaluations FROM ''' + @dir + @piFileName + ''' WITH (BATCHSIZE = 5000, FIELDTERMINATOR = ''\t'', ROWTERMINATOR = ''\n'', TABLOCK)'
	EXECUTE (@cmd)

	--log file record
	INSERT INTO dbo.FileHistory (FileTypeID, Filename, DateStarted, Records)
	SELECT @filetypeid, @piFileName, GETDATE(), (SELECT COUNT(FEN) FROM stage.BulkInsertLichessEvaluations)

	SET @fhid = @@IDENTITY

	--stage and preprocess game data
	EXEC dbo.StageLichessEvals @fileid = @fhid
	EXEC dbo.FormatLichessEvals

	SELECT @err_ct = COUNT(Errors) FROM stage.LichessEvaluations WHERE Errors IS NOT NULL
	IF @err_ct > 0 SET @poErrorMessage = 'Unable to validate Evaluation(s)'

	IF @poErrorMessage IS NULL
	BEGIN
		--finally insert new records
		EXEC dbo.InsertLichessEvaluations
	END

	EXEC dbo.DeleteStagedLichessEvaluations @errors = @err_ct

	UPDATE dbo.FileHistory
	SET DateCompleted = GETDATE(), Errors = @err_ct, ErrorMessage = @poErrorMessage
	WHERE FileID = @fhid

	IF @poErrorMessage IS NOT NULL
	BEGIN
		--;THROW 50000, @poErrorMessage, 1
		RETURN -1
	END

	RETURN 0
END TRY

BEGIN CATCH
	SET @poErrorMessage = '[' + CAST(ERROR_LINE() AS VARCHAR) + '] ' + ERROR_MESSAGE()
	IF @fhid IS NOT NULL
	BEGIN
		UPDATE dbo.FileHistory
		SET DateCompleted = GETDATE(), Errors = ISNULL(NULLIF(@err_ct, 0), -1), ErrorMessage = @poErrorMessage
		WHERE FileID = @fhid
	END

	--;THROW 50000, @poErrorMessage, 1
	RETURN -1
END CATCH