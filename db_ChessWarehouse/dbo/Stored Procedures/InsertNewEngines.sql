CREATE PROCEDURE [dbo].[InsertNewEngines]

AS

INSERT INTO dim.Engines (EngineName)

SELECT DISTINCT
stg.EngineName

FROM stage.Moves stg
LEFT JOIN dim.Engines eng ON stg.EngineName = eng.EngineName

WHERE eng.EngineID IS NULL