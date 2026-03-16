CREATE PROCEDURE [dbo].[FormatMoveData]

AS

BEGIN
	UPDATE m
	SET m.Color = c.ColorID
		,m.Errors = (CASE WHEN c.ColorID IS NULL THEN 'Color' ELSE NULL END)
	FROM stage.Moves AS m
	LEFT JOIN dim.Colors AS c ON m.Color = c.Color

	UPDATE m
	SET m.PhaseID = p.PhaseID
		,m.Errors = (CASE WHEN p.PhaseID IS NULL THEN ISNULL(m.Errors + '|', '') + 'PhaseID' ELSE m.Errors END)
	FROM stage.Moves AS m
	LEFT JOIN dim.Phases AS p ON m.PhaseID = p.PhaseID
END
