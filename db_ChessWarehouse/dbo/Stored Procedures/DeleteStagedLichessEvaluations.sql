CREATE PROCEDURE [dbo].[DeleteStagedLichessEvaluations] (@errors int)

AS

TRUNCATE TABLE stage.BulkInsertLichessEvaluations
TRUNCATE TABLE stage.LichessEvaluations

IF @errors > 0
BEGIN
	DELETE FROM stage.LichessEvaluations WHERE Errors IS NULL
END
ELSE
BEGIN
	TRUNCATE TABLE stage.LichessEvaluations
END
