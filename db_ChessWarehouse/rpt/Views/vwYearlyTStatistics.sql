CREATE VIEW rpt.vwYearlyTStatistics

AS

SELECT
s.SourceName,
'White' AS MyColor,
YEAR(g.GameDate) AS Year,
COUNT(g.GameID) AS Games,
ISNULL(me.Me_MovesAnalyzed, 0) AS Me_MovesAnalyzed,
me.Me_T1,
me.Me_T2,
me.Me_T3,
me.Me_T4,
me.Me_T5,
ISNULL(opp.Opp_MovesAnalyzed, 0) AS Opp_MovesAnalyzed,
opp.Opp_T1,
opp.Opp_T2,
opp.Opp_T3,
opp.Opp_T4,
opp.Opp_T5

FROM lake.Games g
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	g.WhitePlayerID = p.PlayerID
LEFT JOIN (
	SELECT
	s.SourceName,
	YEAR(g.GameDate) AS Year,
	COUNT(m.MoveNumber) AS Me_MovesAnalyzed,
	1.00*SUM(CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T1,
	1.00*SUM(CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T2,
	1.00*SUM(CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T3,
	1.00*SUM(CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T4,
	1.00*SUM(CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T5

	FROM lake.Moves m
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.WhitePlayerID = p.PlayerID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
	s.SourceName,
	YEAR(g.GameDate)
) me ON
	s.SourceName = me.SourceName
	AND YEAR(g.GameDate) = me.Year
LEFT JOIN (
	SELECT
	s.SourceName,
	YEAR(g.GameDate) AS Year,
	COUNT(m.MoveNumber) AS Opp_MovesAnalyzed,
	1.00*SUM(CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T1,
	1.00*SUM(CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T2,
	1.00*SUM(CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T3,
	1.00*SUM(CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T4,
	1.00*SUM(CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T5

	FROM lake.Moves m
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.WhitePlayerID = p.PlayerID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
	s.SourceName,
	YEAR(g.GameDate)
) opp ON
	s.SourceName = opp.SourceName
	AND YEAR(g.GameDate) = opp.Year

WHERE p.SelfFlag = 1

GROUP BY
s.SourceName,
YEAR(g.GameDate),
me.Me_MovesAnalyzed,
me.Me_T1,
me.Me_T2,
me.Me_T3,
me.Me_T4,
me.Me_T5,
opp.Opp_MovesAnalyzed,
opp.Opp_T1,
opp.Opp_T2,
opp.Opp_T3,
opp.Opp_T4,
opp.Opp_T5


UNION


SELECT
s.SourceName,
'Black' AS MyColor,
YEAR(g.GameDate) AS Year,
COUNT(g.GameID) AS Games,
ISNULL(me.Me_MovesAnalyzed, 0) AS Me_MovesAnalyzed,
me.Me_T1,
me.Me_T2,
me.Me_T3,
me.Me_T4,
me.Me_T5,
ISNULL(opp.Opp_MovesAnalyzed, 0) AS Opp_MovesAnalyzed,
opp.Opp_T1,
opp.Opp_T2,
opp.Opp_T3,
opp.Opp_T4,
opp.Opp_T5

FROM lake.Games g
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	g.BlackPlayerID = p.PlayerID
LEFT JOIN (
	SELECT
	s.SourceName,
	YEAR(g.GameDate) AS Year,
	COUNT(m.MoveNumber) AS Me_MovesAnalyzed,
	1.00*SUM(CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T1,
	1.00*SUM(CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T2,
	1.00*SUM(CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T3,
	1.00*SUM(CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T4,
	1.00*SUM(CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T5

	FROM lake.Moves m
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.BlackPlayerID = p.PlayerID

	WHERE p.SelfFlag = 1
	AND c.Color = 'Black'
	AND m.MoveScored = 1

	GROUP BY
	s.SourceName,
	YEAR(g.GameDate)
) me ON
	s.SourceName = me.SourceName
	AND YEAR(g.GameDate) = me.Year
LEFT JOIN (
	SELECT
	s.SourceName,
	YEAR(g.GameDate) AS Year,
	COUNT(m.MoveNumber) AS Opp_MovesAnalyzed,
	1.00*SUM(CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T1,
	1.00*SUM(CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T2,
	1.00*SUM(CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T3,
	1.00*SUM(CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T4,
	1.00*SUM(CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T5

	FROM lake.Moves m
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		g.BlackPlayerID = p.PlayerID

	WHERE p.SelfFlag = 1
	AND c.Color = 'White'
	AND m.MoveScored = 1

	GROUP BY
	s.SourceName,
	YEAR(g.GameDate)
) opp ON
	s.SourceName = opp.SourceName
	AND YEAR(g.GameDate) = opp.Year

WHERE p.SelfFlag = 1

GROUP BY
s.SourceName,
YEAR(g.GameDate),
me.Me_MovesAnalyzed,
me.Me_T1,
me.Me_T2,
me.Me_T3,
me.Me_T4,
me.Me_T5,
opp.Opp_MovesAnalyzed,
opp.Opp_T1,
opp.Opp_T2,
opp.Opp_T3,
opp.Opp_T4,
opp.Opp_T5


UNION


SELECT
s.SourceName,
'All' AS MyColor,
YEAR(g.GameDate) AS Year,
COUNT(g.GameID) AS Games,
ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed,
me.Me_T1,
me.Me_T2,
me.Me_T3,
me.Me_T4,
me.Me_T5,
ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed,
opp.Opp_T1,
opp.Opp_T2,
opp.Opp_T3,
opp.Opp_T4,
opp.Opp_T5

FROM lake.Games g
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players wp ON
    g.WhitePlayerID = wp.PlayerID
JOIN dim.Players bp ON
    g.BlackPlayerID = bp.PlayerID
LEFT JOIN (
	SELECT
	s.SourceName,
	YEAR(g.GameDate) AS Year,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	1.00*SUM(CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T1,
	1.00*SUM(CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T2,
	1.00*SUM(CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T3,
	1.00*SUM(CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T4,
	1.00*SUM(CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Me_T5

	FROM lake.Moves m
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		(CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID

	WHERE p.SelfFlag = 1
	AND m.MoveScored = 1

	GROUP BY
	s.SourceName,
	YEAR(g.GameDate)
) me ON
	s.SourceName = me.SourceName
	AND YEAR(g.GameDate) = me.Year
LEFT JOIN (
	SELECT
	s.SourceName,
	YEAR(g.GameDate) AS Year,
	COUNT(m.MoveNumber) AS MovesAnalyzed,
	1.00*SUM(CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T1,
	1.00*SUM(CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T2,
	1.00*SUM(CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T3,
	1.00*SUM(CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T4,
	1.00*SUM(CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END)/COUNT(m.MoveNumber) AS Opp_T5

	FROM lake.Moves m
	JOIN lake.Games g ON
		m.GameID = g.GameID
	JOIN dim.Sources s ON
		g.SourceID = s.SourceID
	JOIN dim.Colors c ON
		m.ColorID = c.ColorID
	JOIN dim.Players p ON
		(CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END) = p.PlayerID

	WHERE p.SelfFlag <> 1
	AND m.MoveScored = 1

	GROUP BY
	s.SourceName,
	YEAR(g.GameDate)
) opp ON
	s.SourceName = opp.SourceName
	AND YEAR(g.GameDate) = opp.Year

WHERE wp.SelfFlag = 1
OR bp.SelfFlag = 1

GROUP BY
s.SourceName,
YEAR(g.GameDate),
me.MovesAnalyzed,
me.Me_T1,
me.Me_T2,
me.Me_T3,
me.Me_T4,
me.Me_T5,
opp.MovesAnalyzed,
opp.Opp_T1,
opp.Opp_T2,
opp.Opp_T3,
opp.Opp_T4,
opp.Opp_T5
