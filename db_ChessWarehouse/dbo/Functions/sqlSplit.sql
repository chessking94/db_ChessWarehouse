CREATE FUNCTION [dbo].[sqlSplit] (@CharacterExpression varchar(8000), @Delimiter char(1), @Position int)

RETURNS varchar(8000)

AS

BEGIN
	IF @Position < 1 RETURN NULL
	IF LEN(@Delimiter) <> 1 RETURN NULL

	DECLARE @Start integer
	SET @Start = 1
	WHILE @Position > 1
	BEGIN
		SET @Start = ISNULL(CHARINDEX(@Delimiter, @CharacterExpression, @Start), 0)
		IF @Start = 0 RETURN NULL
		SET @Position = @Position - 1
		SET @Start = @Start + 1
	END

	DECLARE @End int
	SET @End = ISNULL(CHARINDEX(@Delimiter, @CharacterExpression, @Start), 0)
	IF @End = 0 SET @End = LEN(@CharacterExpression) + 1

	RETURN SUBSTRING(@CharacterExpression, @Start, @End - @Start)
END
