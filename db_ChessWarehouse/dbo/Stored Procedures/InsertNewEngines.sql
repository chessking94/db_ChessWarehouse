CREATE PROCEDURE [dbo].[InsertNewEngines]

AS

INSERT INTO dim.Engines (EngineName)

SELECT DISTINCT
stg.EngineName

FROM stage.Moves stg
LEFT JOIN dim.Engines eng ON stg.EngineName = eng.EngineName

WHERE stg.EngineName IS NOT NULL
AND eng.EngineID IS NULL
