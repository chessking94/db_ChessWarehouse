CREATE VIEW rpt.vwTimeControlSummary

AS

SELECT
s.SourceName,
'White' AS MyColor,
tc.TimeControlID,
tc.TimeControlName,
SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
AVG(NULLIF(g.BlackElo, 0)) AS AvgRating,
dbo.GetPerfRating(AVG(NULLIF(g.BlackElo, 0)), (SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating,
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
JOIN dim.Players p ON
	g.WhitePlayerID = p.PlayerID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON
	td.TimeControlID = tc.TimeControlID
LEFT JOIN (
	SELECT
    s.SourceID,
	td.TimeControlID,
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
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.WhitePlayerID = p.PlayerID
	JOIN dim.TimeControlDetail td ON
		g.TimeControlDetailID = td.TimeControlDetailID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
    s.SourceID,
	td.TimeControlID
) me ON
    s.SourceID = me.SourceID
	AND tc.TimeControlID = me.TimeControlID
LEFT JOIN (
	SELECT
    s.SourceID,
	td.TimeControlID,
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
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.WhitePlayerID = p.PlayerID
	JOIN dim.TimeControlDetail td ON
		g.TimeControlDetailID = td.TimeControlDetailID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
    s.SourceID,
	td.TimeControlID
) opp ON
    s.SourceID = opp.SourceID
	AND tc.TimeControlID = opp.TimeControlID

WHERE p.SelfFlag = 1

GROUP BY
s.SourceName,
tc.TimeControlName,
tc.TimeControlID,
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
'Black' AS MyColor,
tc.TimeControlID,
tc.TimeControlName,
SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
AVG(NULLIF(g.WhiteElo, 0)) AS AvgRating,
dbo.GetPerfRating(AVG(NULLIF(g.WhiteElo, 0)), (SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating,
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
JOIN dim.Players p ON
	g.BlackPlayerID = p.PlayerID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON
	td.TimeControlID = tc.TimeControlID
LEFT JOIN (
	SELECT
    s.SourceID,
	td.TimeControlID,
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
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.BlackPlayerID = p.PlayerID
	JOIN dim.TimeControlDetail td ON
		g.TimeControlDetailID = td.TimeControlDetailID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
    s.SourceID,
	td.TimeControlID
) me ON
    s.SourceID = me.SourceID
	AND tc.TimeControlID = me.TimeControlID
LEFT JOIN (
	SELECT
    s.SourceID,
	td.TimeControlID,
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
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.BlackPlayerID = p.PlayerID
	JOIN dim.TimeControlDetail td ON
		g.TimeControlDetailID = td.TimeControlDetailID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
    s.SourceID,
	td.TimeControlID
) opp ON
    s.SourceID = opp.SourceID
	AND tc.TimeControlID = opp.TimeControlID

WHERE p.SelfFlag = 1

GROUP BY
s.SourceName,
tc.TimeControlName,
tc.TimeControlID,
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
'All' AS MyColor,
tc.TimeControlID,
tc.TimeControlName,
SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 0) OR (bp.SelfFlag = 1 AND g.Result = 1) THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
AVG(NULLIF(CASE WHEN wp.SelfFlag = 1 THEN g.BlackElo ELSE g.WhiteElo END, 0)) AS AvgRating,
dbo.GetPerfRating(AVG(NULLIF(CASE WHEN wp.SelfFlag = 1 THEN g.BlackElo ELSE g.WhiteElo END, 0)), (SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating,
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
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON
	td.TimeControlID = tc.TimeControlID
LEFT JOIN (
	SELECT
	s.SourceID,
	td.TimeControlID,
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
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		(CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID
    JOIN dim.TimeControlDetail td ON
        g.TimeControlDetailID = td.TimeControlDetailID

	WHERE p.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
	s.SourceID,
	td.TimeControlID
) me ON
	s.SourceID = me.SourceID
	AND tc.TimeControlID = me.TimeControlID
LEFT JOIN (
	SELECT
	s.SourceID,
	td.TimeControlID,
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
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		(CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID
    JOIN dim.TimeControlDetail td ON
		g.TimeControlDetailID = td.TimeControlDetailID

	WHERE p.SelfFlag <> 1
	AND m.MoveScored = 1

	GROUP BY
	s.SourceID,
	td.TimeControlID
) opp ON
	s.SourceID = opp.SourceID
	AND tc.TimeControlID = opp.TimeControlID

WHERE wp.SelfFlag = 1
OR bp.SelfFlag = 1

GROUP BY
s.SourceName,
tc.TimeControlID,
tc.TimeControlName,
me.MovesAnalyzed,
opp.MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score
GO
