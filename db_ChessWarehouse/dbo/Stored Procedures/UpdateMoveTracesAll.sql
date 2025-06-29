CREATE PROCEDURE UpdateMoveTracesAll

AS

--THIS PROCEDURE DOES A LOT AND WILL TAKE SOME TIME TO RUN, YOU HAVE BEEN WARNED

--update lake.Moves.TraceKey
DECLARE @ForcedMoveThreshold DECIMAL(5,2) = CAST(dbo.GetSettingValue(1) AS decimal(5,2))

;WITH cte AS (
	SELECT
	GameID,
	MoveNumber,
	ColorID,
	ROW_NUMBER() OVER (PARTITION BY GameID, ColorID, LEFT(FEN, CHARINDEX(' ', FEN) - 1) ORDER BY MoveNumber) AS Position_Count

	FROM lake.Moves
)

UPDATE m
SET m.TraceKey = (
	CASE
		WHEN m.IsTheory = 1 THEN 'b'  --book moves
		WHEN m.IsTablebase = 1 THEN 't'  --tablebase moves
		WHEN ISNULL(ABS(m.T1_Eval_POV), 100) > CAST(s.Value AS decimal(5,2)) AND ISNULL(ABS(m.Move_Eval_POV), 100) > CAST(s.Value AS decimal(5,2)) THEN 'e'  --eval is considered clearly winning; both are are to allow really bad blunders to be scored
		WHEN cte.Position_Count > 1 THEN 'r'  --repeated positions
		WHEN m.T2_Eval IS NULL OR (ABS((CASE WHEN LEFT(m.T1_Eval, 1) = '#' THEN 100 ELSE CAST(m.T1_Eval AS decimal(5,2)) END) - (CASE WHEN LEFT(m.T2_Eval, 1) = '#' THEN 100 ELSE CAST(m.T2_Eval AS decimal(5,2)) END)) > @ForcedMoveThreshold AND m.Move_Rank = 1) THEN 'f'  --forced moves
		WHEN m.Move_Rank = 1 THEN 'M'  --eval matches
		ELSE '0'  --move must have been subpar
	END
)

FROM lake.Moves m
JOIN dim.Colors c ON
    m.ColorID = c.ColorID
CROSS JOIN Settings s
JOIN cte ON
	m.GameID = cte.GameID AND
	m.MoveNumber = cte.MoveNumber AND
	m.ColorID = cte.ColorID

WHERE s.ID = 3

--update lake.Moves.MoveScored
UPDATE m
SET m.MoveScored = t.Scored

FROM lake.Moves m
JOIN dim.Traces t ON
	m.TraceKey = t.TraceKey
JOIN lake.Games g ON
	m.GameID = g.GameID

--recalculate scores
EXEC dbo.UpdateMoveScoresAll

--recalculate fact tables
EXEC dbo.InsertEventFacts
EXEC dbo.InsertGameFacts
EXEC dbo.InsertEvaluationFacts
EXEC dbo.InsertEvaluationSplits

--recalculate z-scores
EXEC dbo.UpdateEventFacts
EXEC dbo.UpdateGameFacts
EXEC dbo.UpdateEvaluationFacts

--recalculate rpt schema
EXEC rpt.UpdateECOSummary
EXEC rpt.UpdateEventSummary
EXEC rpt.UpdateGameStatistics
EXEC rpt.UpdateGameSummary
EXEC rpt.UpdateOpponentSummary
EXEC rpt.UpdateRatingSummary
EXEC rpt.UpdateRoundSummary
EXEC rpt.UpdateTimeControlSummary
EXEC rpt.UpdateYearlyRoundStatistics
EXEC rpt.UpdateYearlySummary
EXEC rpt.UpdateYearlyTimeControlStatistics
EXEC rpt.UpdateYearlyTStatistics
