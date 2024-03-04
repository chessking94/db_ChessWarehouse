CREATE VIEW rpt.vwOpponentSummary

AS

SELECT
s.SourceName,
'White' AS Opp_Color,
wp.LastName AS Opp_LastName,
wp.FirstName AS Opp_FirstName,
SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed, 
ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score

FROM lake.Games g
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players wp ON
	g.WhitePlayerID = wp.PlayerID
JOIN dim.Players bp ON
    g.BlackPlayerID = bp.PlayerID
LEFT JOIN (
	SELECT
	wp.PlayerID,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	AVG(m.CP_Loss) AS Me_ACPL,
	ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL,
	100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves m
	JOIN stat.MoveScores ms ON
		m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Players wp ON
		g.WhitePlayerID = wp.PlayerID
	JOIN dim.Players bp ON
		g.BlackPlayerID = bp.PlayerID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE c.Color = 'Black'
	AND bp.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
	wp.PlayerID
) me ON wp.PlayerID = me.PlayerID
LEFT JOIN (
	SELECT
	wp.PlayerID,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	AVG(m.CP_Loss) AS Opp_ACPL,
	ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL,
	100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves m
	JOIN stat.MoveScores ms ON
		m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Players wp ON
		g.WhitePlayerID = wp.PlayerID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
	wp.PlayerID
) opp ON
	wp.PlayerID = opp.PlayerID

WHERE bp.SelfFlag = 1

GROUP BY
s.SourceName,
wp.LastName,
wp.FirstName,
me.MovesAnalyzed,
opp.MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score


UNION


SELECT
s.SourceName,
'Black' AS OpponentColor,
bp.LastName AS Opp_LastName,
bp.FirstName AS Opp_FirstName,
SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed, 
ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score

FROM lake.Games g
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players wp ON
    g.WhitePlayerID = wp.PlayerID
JOIN dim.Players bp ON
	g.BlackPlayerID = bp.PlayerID
LEFT JOIN (
	SELECT
	bp.PlayerID,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	AVG(m.CP_Loss) AS Me_ACPL,
	ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL,
	100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves m
	JOIN stat.MoveScores ms ON
		m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Players wp ON
		g.WhitePlayerID = wp.PlayerID
	JOIN dim.Players bp ON
		g.BlackPlayerID = bp.PlayerID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE c.Color = 'White'
	AND wp.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
	bp.PlayerID
) me ON bp.PlayerID = me.PlayerID
LEFT JOIN (
	SELECT
	bp.PlayerID,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	AVG(m.CP_Loss) AS Opp_ACPL,
	ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL,
	100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves m
	JOIN stat.MoveScores ms ON
		m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Players bp ON
		g.BlackPlayerID = bp.PlayerID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
	bp.PlayerID
) opp ON
	bp.PlayerID = opp.PlayerID

WHERE wp.SelfFlag = 1

GROUP BY
s.SourceName,
bp.LastName,
bp.FirstName,
me.MovesAnalyzed,
opp.MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score


UNION


SELECT
s.SourceName,
'All' AS Opp_Color,
CASE WHEN wp.SelfFlag = 1 THEN bp.LastName ELSE wp.LastName END AS Opp_LastName,
CASE WHEN wp.SelfFlag = 1 THEN bp.FirstName ELSE wp.FirstName END AS Opp_FirstName,
SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 0) OR (bp.SelfFlag = 1 AND g.Result = 1) THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed,
ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score

FROM lake.Games g
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players wp ON
	g.WhitePlayerID = wp.PlayerID
JOIN dim.Players bp ON
	g.BlackPlayerID = bp.PlayerID
LEFT JOIN (
	SELECT
	CASE WHEN c.Color = 'White' THEN bp.PlayerID ELSE wp.PlayerID END AS PlayerID,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	AVG(m.CP_Loss) AS Me_ACPL,
	ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL,
	100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

	FROM lake.Moves m
	JOIN stat.MoveScores ms ON
		m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Players wp ON
		g.WhitePlayerID = wp.PlayerID
	JOIN dim.Players bp ON
		g.BlackPlayerID = bp.PlayerID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE m.MoveScored = 1

	GROUP BY
	CASE WHEN c.Color = 'White' THEN bp.PlayerID ELSE wp.PlayerID END
) me ON
	(CASE WHEN wp.SelfFlag = 1 THEN bp.PlayerID ELSE wp.PlayerID END) = me.PlayerID
LEFT JOIN (
	SELECT
	CASE WHEN c.Color = 'White' THEN wp.PlayerID ELSE bp.PlayerID END AS PlayerID,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	AVG(m.CP_Loss) AS Opp_ACPL,
	ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL,
	100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

	FROM lake.Moves m
	JOIN stat.MoveScores ms ON
		m.GameID = ms.GameID
		AND m.ColorID = ms.ColorID
		AND m.MoveNumber = ms.MoveNumber
		AND ms.ScoreID = 1
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Players wp ON
		g.WhitePlayerID = wp.PlayerID
	JOIN dim.Players bp ON
		g.BlackPlayerID = bp.PlayerID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE m.MoveScored = 1

	GROUP BY
	CASE WHEN c.Color = 'White' THEN wp.PlayerID ELSE bp.PlayerID END
) opp ON
	(CASE WHEN wp.SelfFlag = 1 THEN bp.PlayerID ELSE wp.PlayerID END) = opp.PlayerID

WHERE wp.SelfFlag = 1
OR bp.SelfFlag = 1

GROUP BY
s.SourceName,
CASE WHEN wp.SelfFlag = 1 THEN bp.LastName ELSE wp.LastName END,
CASE WHEN wp.SelfFlag = 1 THEN bp.FirstName ELSE wp.FirstName END,
me.MovesAnalyzed,
opp.MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score
