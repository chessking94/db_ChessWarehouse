CREATE VIEW rpt.vwGameStatistics

AS

SELECT
1 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 0.00' AS Statistic,
a.CPL_1 AS White,
b.CPL_1 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
2 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 0.01-0.09' AS Statistic,
a.CPL_2 AS White,
b.CPL_2 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
3 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 0.10-0.24' AS Statistic,
a.CPL_3 AS White,
b.CPL_3 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
4 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 0.26-0.49' AS Statistic,
a.CPL_4 AS White,
b.CPL_4 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
5 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 0.50-0.99' AS Statistic,
a.CPL_5 AS White,
b.CPL_5 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
6 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 1.00-1.99' AS Statistic,
a.CPL_6 AS White,
b.CPL_6 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
7 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 2.00-4.99' AS Statistic,
a.CPL_7 AS White,
b.CPL_7 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
8 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'CPL: 5.00+' AS Statistic,
a.CPL_8 AS White,
b.CPL_8 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
9 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'Moves Analyzed' AS Statistic,
a.MovesAnalyzed AS White,
b.MovesAnalyzed AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
10 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'ACPL' AS Statistic,
a.ACPL AS White,
b.ACPL AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
11 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'SDCPL' AS Statistic,
a.SDCPL AS White,
b.SDCPL AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
12 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'T1' AS Statistic,
a.T1 AS White,
b.T1 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
13 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'T2' AS Statistic,
a.T2 AS White,
b.T2 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
14 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'T3' AS Statistic,
a.T3 AS White,
b.T3 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
15 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'T4' AS Statistic,
a.T4 AS White,
b.T4 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
16 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'T5' AS Statistic,
a.T5 AS White,
b.T5 AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
17 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'Accuracy Score' AS Statistic,
a.Score AS White,
b.Score AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1


UNION


SELECT
18 AS Row_Count,
g.GameID,
s.SourceName,
g.SiteGameID AS GameNumber,
'ROI' AS Statistic,
a.ROI AS White,
b.ROI AS Black

FROM fact.Game a
JOIN fact.Game b ON
	a.GameID = b.GameID AND
	a.ColorID <> b.ColorID
JOIN lake.Games g ON
	a.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players p ON
	a.PlayerID = p.PlayerID

WHERE a.ColorID = 1
