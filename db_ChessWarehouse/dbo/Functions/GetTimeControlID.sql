CREATE FUNCTION [dbo].[GetTimeControlID] (@TimeControlDetail varchar(15))

RETURNS tinyint

BEGIN
	DECLARE @rtnval tinyint
	DECLARE @sec int

	--check if correspondence first
	IF CHARINDEX('/', @TimeControlDetail) > 0
	BEGIN
		SELECT @rtnval = TimeControlID FROM dim.TimeControls WHERE TimeControlName = 'Correspondence'
	END

	--not correspondence, parse time control to determine where it falls
	IF @rtnval IS NULL
	BEGIN
		/*
			Using a multiplier of 40 instead of the standard 60 since it works better with the TimeControlName classifications and is average game length
			120+1 -> Bullet when 40 is used, 120+1 -> Blitz when 60 is used
		*/
		SET @sec = CAST(LEFT(@TimeControlDetail, CHARINDEX('+', @TimeControlDetail) - 1) AS int) + 40*(CAST(SUBSTRING(@TimeControlDetail, CHARINDEX('+', @TimeControlDetail) + 1, LEN(@TimeControlDetail)) AS int))
		SELECT @rtnval = TimeControlID FROM dim.TimeControls WHERE @sec >= MinSeconds and @sec <= MaxSeconds
	END

	RETURN @rtnval
END
