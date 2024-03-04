CREATE VIEW rpt.vwRatingSummary

AS

SELECT
s.SourceName,
'White' AS MyColor,
br.RatingID,
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
JOIN dim.Ratings br ON
	g.BlackElo >= br.RatingID AND
	g.BlackElo <= br.RatingUpperBound
LEFT JOIN (
	SELECT
	br.RatingID,
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
	JOIN dim.Players p ON
		g.WhitePlayerID = p.PlayerID
	JOIN dim.Ratings br ON
		g.BlackElo >= br.RatingID AND
		g.BlackElo <= br.RatingUpperBound
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
	br.RatingID
) me ON
	br.RatingID = me.RatingID
LEFT JOIN (
	SELECT
	br.RatingID,
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
	JOIN dim.Players p ON
		g.WhitePlayerID = p.PlayerID
	JOIN dim.Ratings br ON
		g.BlackElo >= br.RatingID AND
		g.BlackElo <= br.RatingUpperBound
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
	br.RatingID
) opp ON
	br.RatingID = opp.RatingID

WHERE p.SelfFlag = 1

GROUP BY
s.SourceName,
br.RatingID,
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
wr.RatingID,
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
JOIN dim.Ratings wr ON
	g.WhiteElo >= wr.RatingID AND
	g.WhiteElo <= wr.RatingUpperBound
LEFT JOIN (
	SELECT
	wr.RatingID,
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
	JOIN dim.Players p ON
		g.BlackPlayerID = p.PlayerID
	JOIN dim.Ratings wr ON
		g.WhiteElo >= wr.RatingID AND
		g.WhiteElo <= wr.RatingUpperBound
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
	wr.RatingID
) me ON
	wr.RatingID = me.RatingID
LEFT JOIN (
	SELECT
	wr.RatingID,
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
	JOIN dim.Players p ON
		g.BlackPlayerID = p.PlayerID
	JOIN dim.Ratings wr ON
		g.WhiteElo >= wr.RatingID AND
		g.WhiteElo <= wr.RatingUpperBound
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
	wr.RatingID
) opp ON
	wr.RatingID = opp.RatingID

WHERE p.SelfFlag = 1

GROUP BY
s.SourceName,
wr.RatingID,
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
CASE WHEN wp.SelfFlag = 1 THEN br.RatingID ELSE wr.RatingID END AS RatingID,
SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) AS Wins,
SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 0) OR (bp.SelfFlag = 1 AND g.Result = 1) THEN 1 ELSE 0 END) AS Losses,
SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws,
COUNT(g.GameID) AS TotalGames,
(SUM(CASE WHEN (wp.SelfFlag = 1 AND g.Result = 1) OR (bp.SelfFlag = 1 AND g.Result = 0) THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score,
AVG(NULLIF(CASE WHEN g.WhitePlayerID = 1 THEN g.BlackElo ELSE g.WhiteElo END, 0)) AS AvgRating,
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
JOIN dim.Ratings wr ON
	g.WhiteElo >= wr.RatingID AND
	g.WhiteElo <= wr.RatingUpperBound
JOIN dim.Ratings br ON
	g.BlackElo >= br.RatingID AND
	g.BlackElo <= br.RatingUpperBound
LEFT JOIN (
	SELECT
	CASE WHEN c.Color = 'White' THEN br.RatingID ELSE wr.RatingID END AS RatingID,
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
	JOIN dim.Ratings wr ON
		g.WhiteElo >= wr.RatingID AND
		g.WhiteElo <= wr.RatingUpperBound
	JOIN dim.Ratings br ON
		g.BlackElo >= br.RatingID AND
		g.BlackElo <= br.RatingUpperBound

	WHERE p.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
	CASE WHEN c.Color = 'White' THEN br.RatingID ELSE wr.RatingID END
) me ON
	(CASE WHEN wp.SelfFlag = 1 THEN br.RatingID ELSE wr.RatingID END) = me.RatingID
LEFT JOIN (
	SELECT
	CASE WHEN c.Color = 'White' THEN wr.RatingID ELSE br.RatingID END AS RatingID,
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
	JOIN dim.Ratings wr ON
		g.WhiteElo >= wr.RatingID AND
		g.WhiteElo <= wr.RatingUpperBound
	JOIN dim.Ratings br ON
		g.BlackElo >= br.RatingID AND
		g.BlackElo <= br.RatingUpperBound

	WHERE p.SelfFlag <> 1
	AND m.MoveScored = 1

	GROUP BY
	CASE WHEN c.Color = 'White' THEN wr.RatingID ELSE br.RatingID END
) opp ON
	(CASE WHEN wp.SelfFlag = 1 THEN br.RatingID ELSE wr.RatingID END) = opp.RatingID

WHERE wp.SelfFlag = 1
OR bp.SelfFlag = 1

GROUP BY
s.SourceName,
CASE WHEN wp.SelfFlag = 1 THEN br.RatingID ELSE wr.RatingID END,
me.MovesAnalyzed,
opp.MovesAnalyzed,
me.Me_ACPL,
opp.Opp_ACPL,
me.Me_SDCPL,
opp.Opp_SDCPL,
me.Me_Score,
opp.Opp_Score
