CREATE PROCEDURE [dbo].[FormatLichessEvals]

AS

--update ToMove to ColorID
----benchmarked this, most efficient to update all at once
UPDATE stg
SET stg.ToMove = (CASE WHEN stg.ToMove = 'w' THEN 1 WHEN stg.ToMove = 'b' THEN 2 ELSE stg.ToMove END)
FROM stage.LichessEvaluations stg

--perform error checking
UPDATE stg
SET stg.Errors = (ISNULL(stg.Errors + '|', '') + 'ToMove')
FROM stage.LichessEvaluations stg
LEFT JOIN dim.Colors c ON stg.ToMove = c.ColorID
WHERE c.ColorID IS NULL
