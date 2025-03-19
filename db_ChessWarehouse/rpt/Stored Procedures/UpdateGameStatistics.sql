CREATE PROCEDURE [rpt].[UpdateGameStatistics]

AS

BEGIN
	TRUNCATE TABLE rpt.GameStatistics

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
