CREATE PROCEDURE [dbo].[InsertNewEngines]

AS

BEGIN
	INSERT INTO dim.Engines (EngineName)

	SELECT DISTINCT
		stg.EngineName

	FROM stage.Moves AS stg
	LEFT JOIN dim.Engines AS eng ON stg.EngineName = eng.EngineName

	WHERE stg.EngineName IS NOT NULL
	AND eng.EngineID IS NULL
END
