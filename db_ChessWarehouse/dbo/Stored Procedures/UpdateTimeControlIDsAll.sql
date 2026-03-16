CREATE PROCEDURE [dbo].[UpdateTimeControlIDsAll]

AS

BEGIN
	UPDATE dim.TimeControlDetail SET TimeControlID = dbo.GetTimeControlID(TimeControlDetail)
END
