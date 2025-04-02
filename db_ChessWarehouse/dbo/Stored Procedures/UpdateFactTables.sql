CREATE PROCEDURE [dbo].[UpdateFactTables] (
	@piFileID INT = NULL
)

AS

BEGIN
	EXEC dbo.InsertEventFacts @piFileID = @piFileID
	EXEC dbo.UpdateEventFacts

	EXEC dbo.InsertGameFacts @piFileID = @piFileID
	EXEC dbo.UpdateGameFacts

	--only update evaluation tables if completing a full recalc, no way to specify updates for just the new file
	IF @piFileID IS NULL
	BEGIN
		EXEC dbo.InsertEvaluationFacts
		EXEC dbo.InsertEvaluationSplits
		EXEC dbo.UpdateEvaluationFacts
	END
END
