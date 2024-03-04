CREATE VIEW rpt.vwGameSummary

AS

SELECT
g.GameID,
s.SourceName,
wp.SelfFlag AS SelfWhiteFlag,
bp.SelfFlag AS SelfFlagBlack,
st.SiteName,
g.SiteGameID,
wp.LastName AS WhiteLast,
wp.FirstName AS WhiteFirst,
NULLIF(g.WhiteElo, 0) AS WhiteElo,
bp.LastName AS BlackLast,
bp.FirstName AS BlackFirst,
NULLIF(g.BlackElo, 0) AS BlackElo,
e.ECO_Code AS ECO,
g.GameDate,
ev.EventName,
g.RoundNum,
td.TimeControlDetail,
tc.TimeControlName,
g.Result,
MAX(m.MoveNumber) AS Moves,
CEILING(SUM(m.IsTheory*1)/2.0) AS Book_Moves,
CEILING(SUM(m.IsTablebase*1)/2.0) AS Tablebase_Moves,
wg.CPL_Moves AS White_CPL_Moves,
wg.CPL_1 AS White_CPL_1,
wg.CPL_2 AS White_CPL_2,
wg.CPL_3 AS White_CPL_3,
wg.CPL_4 AS White_CPL_4,
wg.CPL_5 AS White_CPL_5,
wg.CPL_6 AS White_CPL_6,
wg.CPL_7 AS White_CPL_7,
wg.CPL_8 AS White_CPL_8,
bg.CPL_Moves AS Black_CPL_Moves,
bg.CPL_1 AS Black_CPL_1,
bg.CPL_2 AS Black_CPL_2,
bg.CPL_3 AS Black_CPL_3,
bg.CPL_4 AS Black_CPL_4,
bg.CPL_5 AS Black_CPL_5,
bg.CPL_6 AS Black_CPL_6,
bg.CPL_7 AS Black_CPL_7,
bg.CPL_8 AS Black_CPL_8,
ISNULL(wg.MovesAnalyzed, 0) AS White_MovesAnalyzed,
wg.T1 AS White_T1,
wg.T2 AS White_T2,
wg.T3 AS White_T3,
wg.T4 AS White_T4,
wg.T5 AS White_T5,
ISNULL(bg.MovesAnalyzed, 0) AS Black_MovesAnalyzed,
bg.T1 AS Black_T1,
bg.T2 AS Black_T2,
bg.T3 AS Black_T3,
bg.T4 AS Black_T4,
bg.T5 AS Black_T5,
wg.ACPL AS White_ACPL,
bg.ACPL AS Black_ACPL,
wg.SDCPL AS White_SDCPL,
bg.SDCPL AS Black_SDCPL,
wg.Score AS White_Score,
bg.Score AS Black_Score,
wg.ROI AS White_ROI,
bg.ROI AS Black_ROI

FROM lake.Moves m
--TODO: Consider adding join to stat.MoveScores, may kill performance. TBD
JOIN lake.Games g ON
	m.GameID = g.GameID
JOIN dim.Sources s ON
	g.SourceID = s.SourceID
JOIN dim.Players wp ON
	g.WhitePlayerID = wp.PlayerID
JOIN dim.Players bp ON
	g.BlackPlayerID = bp.PlayerID
JOIN dim.ECO e ON
	g.ECOID = e.ECOID
JOIN dim.Events ev ON
	g.SourceID = ev.SourceID
	AND g.EventID = ev.EventID
LEFT JOIN dim.TimeControlDetail td ON
	g.TimeControlDetailID = td.TimeControlDetailID
JOIN dim.TimeControls tc ON
	td.TimeControlID = tc.TimeControlID
LEFT JOIN dim.Sites st ON
	g.SiteID = st.SiteID
LEFT JOIN fact.Game wg ON
	g.GameID = wg.GameID AND
	wg.ColorID = 1
LEFT JOIN fact.Game bg ON
	g.GameID = bg.GameID AND
	bg.ColorID = 2

GROUP BY
g.GameID,
s.SourceName,
wp.SelfFlag,
bp.SelfFlag,
st.SiteName,
g.SiteGameID,
wp.LastName,
wp.FirstName,
g.WhiteElo,
bp.LastName,
bp.FirstName,
g.BlackElo,
e.ECO_Code,
g.GameDate,
ev.EventName,
g.RoundNum,
td.TimeControlDetail,
tc.TimeControlName,
g.Result,
wg.CPL_Moves,
wg.CPL_1,
wg.CPL_2,
wg.CPL_3,
wg.CPL_4,
wg.CPL_5,
wg.CPL_6,
wg.CPL_7,
wg.CPL_8,
bg.CPL_Moves,
bg.CPL_1,
bg.CPL_2,
bg.CPL_3,
bg.CPL_4,
bg.CPL_5,
bg.CPL_6,
bg.CPL_7,
bg.CPL_8,
wg.MovesAnalyzed,
wg.T1,
wg.T2,
wg.T3,
wg.T4,
wg.T5,
bg.MovesAnalyzed,
bg.T1,
bg.T2,
bg.T3,
bg.T4,
bg.T5,
wg.ACPL,
bg.ACPL,
wg.SDCPL,
bg.SDCPL,
wg.Score,
bg.Score,
wg.ROI,
bg.ROI
