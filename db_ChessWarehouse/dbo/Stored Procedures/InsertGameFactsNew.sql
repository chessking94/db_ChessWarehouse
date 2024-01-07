CREATE PROCEDURE [dbo].[InsertGameFactsNew]

AS

--fact.Game
INSERT INTO fact.Game (
	SourceID,
	GameID,
	TimeControlID,
	PlayerID,
	ColorID,
	RatingID,
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
	T5,
	Score
)

SELECT
g.SourceID,
g.GameID,
td.TimeControlID,
CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END AS PlayerID,
m.ColorID,
r.RatingID,
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
1.00*SUM(CASE WHEN m.MoveScored = 0 THEN NULL ELSE (CASE WHEN m.Move_Rank <= 5 THEN 1 ELSE 0 END) END)/SUM(CASE WHEN m.MoveScored = 1 THEN 1 ELSE 0 END) AS T5,
100*SUM(CASE WHEN (m.MoveScored = 0 OR ms.MaxScoreValue = 0) THEN NULL ELSE ms.ScoreValue END)/SUM(CASE WHEN (m.MoveScored = 0 OR ms.MaxScoreValue = 0) THEN NULL ELSE ms.MaxScoreValue END) AS Score

FROM lake.Moves m
JOIN stat.MoveScores ms ON
	m.GameID = ms.GameID AND
	m.MoveNumber = ms.MoveNumber AND
	m.ColorID = ms.ColorID
JOIN lake.Games g ON
	m.GameID = g.GameID
JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.Colors c ON
	m.ColorID = c.ColorID
JOIN dim.Ratings r ON
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID AND
	(CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound
LEFT JOIN dim.CPLossGroups cp ON
	m.CP_Loss >= cp.LBound AND
	m.CP_Loss <= cp.UBound
LEFT JOIN fact.Game fg ON
	g.SourceID = fg.SourceID AND
	g.GameID = fg.GameID AND
	m.ColorID = fg.ColorID

WHERE fg.GameID IS NULL
AND ms.ScoreID = dbo.GetSettingValue('Default Score')

GROUP BY
g.SourceID,
g.GameID,
td.TimeControlID,
CASE WHEN c.Color = 'White' THEN g.WhitePlayerID ELSE g.BlackPlayerID END,
m.ColorID,
r.RatingID


--fact.GameScores --> THIS DOESN'T WORK
INSERT INTO fact.GameScores (
	SourceID,
	GameID,
	ColorID,
	ScoreID,
	Score
)

SELECT
g.SourceID,
g.GameID,
m.ColorID,
ms.ScoreID,
100*SUM(CASE WHEN (m.MoveScored = 0 OR ms.MaxScoreValue = 0) THEN NULL ELSE ms.ScoreValue END)/SUM(CASE WHEN (m.MoveScored = 0 OR ms.MaxScoreValue = 0) THEN NULL ELSE ms.MaxScoreValue END) AS Score

FROM lake.Moves m
JOIN stat.MoveScores ms ON
	m.GameID = ms.GameID AND
	m.MoveNumber = ms.MoveNumber AND
	m.ColorID = ms.ColorID
JOIN lake.Games g ON
	m.GameID = g.GameID
LEFT JOIN fact.GameScores fgs ON
	g.SourceID = fgs.SourceID AND
	g.GameID = fgs.GameID AND
	m.ColorID = fgs.ColorID AND
	ms.ScoreID = fgs.ScoreID

WHERE fgs.ScoreID IS NULL

GROUP BY
g.SourceID,
g.GameID,
m.ColorID,
ms.ScoreID