CREATE FUNCTION [dbo].[GetSettingValue] (@Key VARCHAR(40))

RETURNS VARCHAR(100)

BEGIN
	DECLARE @rtnval VARCHAR(100) = NULL

	--use table key first
	IF ISNUMERIC(@Key) = 1 SELECT @rtnval = Value FROM Settings WHERE ID = @Key

	--if no hits, try using name instead
	IF @rtnval IS NULL SELECT @rtnval = Value FROM Settings WHERE Name = @Key

	RETURN @rtnval
END