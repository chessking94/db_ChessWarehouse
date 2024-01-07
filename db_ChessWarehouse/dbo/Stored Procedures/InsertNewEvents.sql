CREATE PROCEDURE dbo.InsertNewEvents

AS

--stage
INSERT INTO stage.Events (SourceID, EventName)
SELECT DISTINCT SourceName, EventName FROM stage.Games

UPDATE stg
SET stg.EventID = prod.EventID
FROM stage.Events stg
JOIN dim.Events prod ON stg.SourceID = prod.SourceID AND stg.EventName = prod.EventName


--insert
INSERT INTO dim.Events (SourceID, EventName)
SELECT SourceID, EventName FROM stage.Events WHERE EventID IS NULL

UPDATE stg
SET stg.EventID = prod.EventID
FROM stage.Events stg
JOIN dim.Events prod ON stg.SourceID = prod.SourceID AND stg.EventName = prod.EventName
WHERE stg.EventID IS NULL