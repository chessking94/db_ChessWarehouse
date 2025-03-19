CREATE PROCEDURE [rpt].[UpdateGameStatistics]

AS

BEGIN
	DELETE FROM rpt.GameStatistics

	INSERT INTO rpt.GameStatistics (
		Row_Count
		,GameID
		,SourceName
		,GameNumber
		,Statistic
		,White
		,Black
	)

	SELECT
		Row_Count
		,GameID
		,SourceName
		,GameNumber
		,Statistic
		,White
		,Black

	FROM rpt.vwGameStatistics
END
