CREATE PROCEDURE UpdateTimeControlIDsAll

AS

UPDATE dim.TimeControlDetail SET TimeControlID = dbo.GetTimeControlID(TimeControlDetail)