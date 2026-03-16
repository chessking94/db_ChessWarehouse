CREATE VIEW [rpt].[vwYearlySummary]

AS

SELECT
	s.SourceName
	,'White' AS MyColor
	,YEAR(g.GameDate) AS Year
	,SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Wins
	,SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Losses
	,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
	,COUNT(g.GameID) AS TotalGames
	,(SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
	,AVG(NULLIF(g.BlackElo, 0)) AS AvgRating
	,dbo.GetPerfRating(AVG(NULLIF(g.BlackElo, 0)), (SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
	,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
	,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score

FROM lake.Games AS g
INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
LEFT JOIN (
	SELECT
		s.SourceID
		,YEAR(g.GameDate) AS Year
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,YEAR(g.GameDate)
) AS me ON s.SourceID = me.SourceID
	AND YEAR(g.GameDate) = me.Year
LEFT JOIN (
	SELECT
		s.SourceID
		,YEAR(g.GameDate) AS Year
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,YEAR(g.GameDate)
) AS opp ON s.SourceID = opp.SourceID
	AND YEAR(g.GameDate) = opp.Year

WHERE p.SelfFlag = 1

GROUP BY
	s.SourceName
	,YEAR(g.GameDate)
	,me.MovesAnalyzed
	,opp.MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score


UNION


SELECT
	s.SourceName
	,'White' AS MyColor
	,NULL AS Year
	,SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Wins
	,SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Losses
	,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
	,COUNT(g.GameID) AS TotalGames
	,(SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
	,AVG(NULLIF(g.BlackElo, 0)) AS AvgRating
	,dbo.GetPerfRating(AVG(NULLIF(g.BlackElo, 0)), (SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
	,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
	,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score

FROM lake.Games AS g
INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
LEFT JOIN (
	SELECT
		s.SourceID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
) AS me ON s.SourceID = me.SourceID
LEFT JOIN (
	SELECT
		s.SourceID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
) AS opp ON s.SourceID = opp.SourceID

WHERE p.SelfFlag = 1

GROUP BY
	s.SourceName
	,me.MovesAnalyzed
	,opp.MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score


UNION


SELECT
	s.SourceName
	,'Black' AS MyColor
	,YEAR(g.GameDate) AS Year
	,SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Wins
	,SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Losses
	,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
	,COUNT(g.GameID) AS TotalGames
	,(SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
	,AVG(NULLIF(g.WhiteElo, 0)) AS AvgRating
	,dbo.GetPerfRating(AVG(NULLIF(g.WhiteElo, 0)), (SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
	,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
	,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score

FROM lake.Games AS g
INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
LEFT JOIN (
	SELECT
		s.SourceID
		,YEAR(g.GameDate) AS Year
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,YEAR(g.GameDate)
) AS me ON s.SourceID = me.SourceID
	AND YEAR(g.GameDate) = me.Year
LEFT JOIN (
	SELECT
		s.SourceID
		,YEAR(g.GameDate) AS Year
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,YEAR(g.GameDate)
) AS opp ON s.SourceID = opp.SourceID
	AND YEAR(g.GameDate) = opp.Year

WHERE p.SelfFlag = 1

GROUP BY
	s.SourceName
	,YEAR(g.GameDate)
	,me.MovesAnalyzed
	,opp.MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score


UNION


SELECT
	s.SourceName
	,'Black' AS MyColor
	,NULL AS Year
	,SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Wins
	,SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Losses
	,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
	,COUNT(g.GameID) AS TotalGames
	,(SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
	,AVG(NULLIF(g.WhiteElo, 0)) AS AvgRating
	,dbo.GetPerfRating(AVG(NULLIF(g.WhiteElo, 0)), (SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
	,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
	,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score

FROM lake.Games AS g
INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
LEFT JOIN (
	SELECT
		s.SourceID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
) AS me ON s.SourceID = me.SourceID
LEFT JOIN (
	SELECT
		s.SourceID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
) AS opp ON s.SourceID = opp.SourceID

WHERE p.SelfFlag = 1

GROUP BY
	s.SourceName
	,me.MovesAnalyzed
	,opp.MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score


UNION


SELECT
	s.SourceName
	,'All' AS MyColor
	,YEAR(g.GameDate) AS Year
	,SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) AS Wins
	,SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 0) OR (bp.SelfFlag = 1 AND g.Result = 1) THEN 1 ELSE 0 END) AS Losses
	,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
	,COUNT(g.GameID) AS TotalGames
	,(SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
	,AVG(NULLIF(CASE WHEN wp.SelfFlag = 1 THEN g.BlackElo ELSE g.WhiteElo END, 0)) AS AvgRating
	,dbo.GetPerfRating(AVG(NULLIF(CASE WHEN wp.SelfFlag = 1 THEN g.BlackElo ELSE g.WhiteElo END, 0)), (SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
	,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
	,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score

FROM lake.Games AS g
INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
INNER JOIN dim.Players AS wp ON g.WhitePlayerID = wp.PlayerID
INNER JOIN dim.Players AS bp ON g.BlackPlayerID = bp.PlayerID
LEFT JOIN (
	SELECT
		s.SourceID
		,YEAR(g.GameDate) AS Year
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.Players AS p ON (CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID

	WHERE p.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,YEAR(g.GameDate)
) AS me ON s.SourceID = me.SourceID
	AND YEAR(g.GameDate) = me.Year
LEFT JOIN (
	SELECT
		s.SourceID
		,YEAR(g.GameDate) AS Year
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.Players AS p ON (CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID

	WHERE p.SelfFlag <> 1
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,YEAR(g.GameDate)
) AS opp ON s.SourceID = opp.SourceID
	AND YEAR(g.GameDate) = opp.Year

WHERE wp.SelfFlag = 1
OR bp.SelfFlag = 1

GROUP BY
	s.SourceName
	,YEAR(g.GameDate)
	,me.MovesAnalyzed
	,opp.MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score
