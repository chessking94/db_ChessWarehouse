CREATE PROCEDURE UpdateMoveTracesAll

AS

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
		WHEN m.IsTheory = 1 THEN 'b'
		WHEN m.IsTablebase = 1 THEN 't'
		WHEN m.T1_Eval_POV IS NULL OR ABS(m.T1_Eval_POV) > CAST(s.Value AS decimal(5,2)) THEN 'e'
		WHEN cte.Position_Count > 1 THEN 'r'
		WHEN m.T2_Eval IS NULL OR (ABS(CAST(m.T1_Eval AS decimal(5,2)) - (CASE WHEN LEFT(m.T2_Eval, 1) = '#' THEN 100 ELSE CAST(m.T2_Eval AS decimal(5,2)) END)) > 2.00 AND m.Move_Rank = 1) THEN 'f'
		WHEN m.Move_Rank = 1 THEN 'M'
		ELSE '0'
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