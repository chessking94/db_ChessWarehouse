CREATE VIEW [rpt].[vwRatingSummary]

AS

SELECT
	s.SourceName
	,'White' AS MyColor
	,g.BlackRatingID AS RatingID
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
		,g.BlackRatingID AS RatingID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = dbo.GetSettingValue('Default Score')
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,g.BlackRatingID
) me ON s.SourceID = me.SourceID
	AND g.BlackRatingID = me.RatingID
LEFT JOIN (
	SELECT
		s.SourceID
		,g.BlackRatingID AS RatingID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = dbo.GetSettingValue('Default Score')
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,g.BlackRatingID
) opp ON s.SourceID = opp.SourceID
	AND g.BlackRatingID = opp.RatingID

WHERE p.SelfFlag = 1

GROUP BY
	s.SourceName
	,g.BlackRatingID
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
	,g.WhiteRatingID AS RatingID
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
		,g.WhiteRatingID AS RatingID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = dbo.GetSettingValue('Default Score')
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,g.WhiteRatingID
) me ON s.SourceID = me.SourceID
	AND g.WhiteRatingID = me.RatingID
LEFT JOIN (
	SELECT
		s.SourceID
		,g.WhiteRatingID AS RatingID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = dbo.GetSettingValue('Default Score')
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,g.WhiteRatingID
) opp ON s.SourceID = opp.SourceID
	AND g.WhiteRatingID = opp.RatingID

WHERE p.SelfFlag = 1

GROUP BY
	s.SourceName
	,g.WhiteRatingID
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
	,CASE WHEN wp.SelfFlag = 1 THEN g.BlackRatingID ELSE g.WhiteRatingID END AS RatingID
	,SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) AS Wins
	,SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 0) OR (bp.SelfFlag = 1 AND g.Result = 1) THEN 1 ELSE 0 END) AS Losses
	,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
	,COUNT(g.GameID) AS TotalGames
	,(SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
	,AVG(NULLIF(CASE WHEN g.WhitePlayerID = 1 THEN g.BlackElo ELSE g.WhiteElo END, 0)) AS AvgRating
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
		,CASE WHEN c.Color = 'White' THEN g.BlackRatingID ELSE g.WhiteRatingID END AS RatingID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Me_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = dbo.GetSettingValue('Default Score')
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.Players AS p ON (CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID

	WHERE p.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,CASE WHEN c.Color = 'White' THEN g.BlackRatingID ELSE g.WhiteRatingID END
) me ON s.SourceID = me.SourceID
	AND (CASE WHEN wp.SelfFlag = 1 THEN g.BlackRatingID ELSE g.WhiteRatingID END) = me.RatingID
LEFT JOIN (
	SELECT
		s.SourceID
		,CASE WHEN c.Color = 'White' THEN g.WhiteRatingID ELSE g.BlackRatingID END AS RatingID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS Opp_ACPL
		,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
		,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves AS m
	INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = dbo.GetSettingValue('Default Score')
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.Players AS p ON (CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID

	WHERE p.SelfFlag <> 1
	AND m.MoveScored = 1

	GROUP BY
		s.SourceID
		,CASE WHEN c.Color = 'White' THEN g.WhiteRatingID ELSE g.BlackRatingID END
) opp ON s.SourceID = opp.SourceID
	AND (CASE WHEN wp.SelfFlag = 1 THEN g.BlackRatingID ELSE g.WhiteRatingID END) = opp.RatingID

WHERE wp.SelfFlag = 1
OR bp.SelfFlag = 1

GROUP BY
	s.SourceName
	,CASE WHEN wp.SelfFlag = 1 THEN g.BlackRatingID ELSE g.WhiteRatingID END
	,me.MovesAnalyzed
	,opp.MovesAnalyzed
	,me.Me_ACPL
	,opp.Opp_ACPL
	,me.Me_SDCPL
	,opp.Opp_SDCPL
	,me.Me_Score
	,opp.Opp_Score
