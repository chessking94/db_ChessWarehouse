CREATE PROCEDURE [dbo].[InsertEventFacts] (
	@piFileID INT = NULL
)

AS

--fact.Event
CREATE TABLE #Events (EventID INT)
	
INSERT INTO #Events
SELECT DISTINCT eventID FROM lake.Games WHERE FileID = @piFileID

IF @piFileID IS NULL
BEGIN
	DELETE FROM fact.Event
END

ELSE
BEGIN
	DELETE fe
	FROM fact.Event fe
	JOIN #Events e ON fe.EventID = e.EventID
END


INSERT INTO fact.Event (
	EventID,
	SourceID,
	TimeControlID,
	PlayerID,
	RatingID,
	GameCount,
	CPL_Moves,
	CPL_1,
	CPL_2,
	CPL_3,
	CPL_4,
	CPL_5,
	CPL_6,
	CPL_7,
	CPL_8,
	MovesAnalyzed,
	ACPL,
	SDCPL,
	ScACPL,
	ScSDCPL,
	T1,
	T2,
	T3,
	T4,
	T5
)

SELECT
g.EventID,
g.SourceID,
td.TimeControlID,
CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END AS PlayerID,
r.RatingID,
COUNT(DISTINCT g.GameID) AS GameCount,
SUM(CASE WHEN m.CP_Loss IS NOT NULL THEN 1 ELSE 0 END) AS CPL_Moves,
SUM(CASE WHEN cp.CPLossGroupID = 1 THEN 1 ELSE 0 END) AS CPL_1,
SUM(CASE WHEN cp.CPLossGroupID = 2 THEN 1 ELSE 0 END) AS CPL_2,
SUM(CASE WHEN cp.CPLossGroupID = 3 THEN 1 ELSE 0 END) AS CPL_3,
SUM(CASE WHEN cp.CPLossGroupID = 4 THEN 1 ELSE 0 END) AS CPL_4,
SUM(CASE WHEN cp.CPLossGroupID = 5 THEN 1 ELSE 0 END) AS CPL_5,
SUM(CASE WHEN cp.CPLossGroupID = 6 THEN 1 ELSE 0 END) AS CPL_6,
SUM(CASE WHEN cp.CPLossGroupID = 7 THEN 1 ELSE 0 END) AS CPL_7,
SUM(CASE WHEN cp.CPLossGroupID = 8 THEN 1 ELSE 0 END) AS CPL_8,
SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS MovesAnalyzed,
AVG(CASE WHEN m.MoveScored = 1 THEN m.CP_Loss ELSE NULL END) AS ACPL,
CASE WHEN (SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END)) = 0 THEN NULL ELSE ISNULL(STDEV(CASE WHEN m.MoveScored = 1 THEN m.CP_Loss ELSE NULL END), 0) END AS SDCPL,
AVG(CASE WHEN m.MoveScored = 1 THEN m.ScACPL ELSE NULL END) AS ScACPL,
CASE WHEN (SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END)) = 0 THEN NULL ELSE ISNULL(STDEV(CASE WHEN m.MoveScored = 1 THEN m.ScACPL ELSE NULL END), 0) END AS ScSDCPL,
1.00*SUM(CASE WHEN m.MoveScored = 0 THEN NULL ELSE (CASE WHEN m.Move_Rank <= 1 THEN 1 ELSE 0 END) END)/SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS T1,
1.00*SUM(CASE WHEN m.MoveScored = 0 THEN NULL ELSE (CASE WHEN m.Move_Rank <= 2 THEN 1 ELSE 0 END) END)/SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS T2,
1.00*SUM(CASE WHEN m.MoveScored = 0 THEN NULL ELSE (CASE WHEN m.Move_Rank <= 3 THEN 1 ELSE 0 END) END)/SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS T3,
1.00*SUM(CASE WHEN m.MoveScored = 0 THEN NULL ELSE (CASE WHEN m.Move_Rank <= 4 THEN 1 ELSE 0 END) END)/SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS T4,
1.00*SUM(CASE WHEN m.MoveScored = 0 THEN NULL ELSE (CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END) END)/SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS T5

FROM lake.Moves m
JOIN lake.Games g ON
	m.GameID = g.GameID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.Colors c ON
	m.ColorID = c.ColorID
JOIN dim.Ratings r ON
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID
	AND (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound
JOIN dbo.FileHistory fh ON
	g.FileID = fh.FileID
LEFT JOIN dim.CPLossGroups cp ON
	m.CP_Loss >= cp.LBound
	AND m.CP_Loss <= cp.UBound

WHERE g.SourceID NOT IN (2, 4)
AND (ISNULL(@piFileID, -1) = -1 OR g.EventID IN (SELECT EventID FROM #Events))

GROUP BY
g.EventID,
g.SourceID,
td.TimeControlID,
CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END,
r.RatingID


--fact.EventScores
INSERT INTO fact.EventScores (
	EventID,
	SourceID,
	TimeControlID,
	PlayerID,
	ScoreID,
	Score
)

SELECT
g.EventID,
g.SourceID,
td.TimeControlID,
CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END AS PlayerID,
ms.ScoreID,
100*SUM(CASE WHEN (m.MoveScored = 0 OR ms.MaxScoreValue = 0) THEN NULL ELSE ms.ScoreValue END)/SUM(CASE WHEN (m.MoveScored = 0 OR ms.MaxScoreValue = 0) THEN NULL ELSE ms.MaxScoreValue END) AS Score

FROM lake.Moves m
JOIN stat.MoveScores ms ON
	m.GameID = ms.GameID
	AND m.MoveNumber = ms.MoveNumber
	AND	m.ColorID = ms.ColorID
JOIN lake.Games g ON
	m.GameID = g.GameID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.Colors c ON
	m.ColorID = c.ColorID
JOIN dbo.FileHistory fh ON
	g.FileID = fh.FileID

WHERE g.SourceID NOT IN (2, 4)
AND (ISNULL(@piFileID, -1) = -1 OR g.EventID IN (SELECT EventID FROM #Events))

GROUP BY
g.EventID,
g.SourceID,
td.TimeControlID,
CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END,
ms.ScoreID


DROP TABLE #Events
