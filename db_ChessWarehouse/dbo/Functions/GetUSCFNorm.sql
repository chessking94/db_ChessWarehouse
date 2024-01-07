CREATE function [dbo].[GetUSCFNorm] (@PlayerID int, @EventID varchar(50))
RETURNS varchar(30)

AS

BEGIN
	DECLARE @norm varchar(30)
	SET @norm = 'No norm earned'

	DECLARE @gamecount int
	SELECT @gamecount = COUNT(GameID) FROM lake.Games WHERE EventID = @EventID AND (WhitePlayerID = @PlayerID OR BlackPlayerID = @PlayerID)
	IF @gamecount = 0
	BEGIN
		SET @norm = 'No event with that name!'
		RETURN @norm
	END
	ELSE IF @gamecount <= 3
	BEGIN
		SET @norm = 'Not enough games'
		RETURN @norm
	END

	DECLARE @score decimal(6,4)
	DECLARE @ctr int
	DECLARE @rounds int
	DECLARE @fourth decimal(6,4)
	DECLARE @third decimal(6,4)
	DECLARE @second decimal(6,4)
	DECLARE @first decimal(6,4)
	DECLARE @cmaster decimal(6,4)
	DECLARE @master decimal(6,4)
	DECLARE @smaster decimal(6,4)
	DECLARE @elo int

	SELECT @score = SUM(CASE WHEN Result = 0.5 THEN 0.5 WHEN ((WhitePlayerID = @PlayerID AND Result = 1) OR (BlackPlayerID = @PlayerID AND Result = 0)) THEN 1 ELSE 0 END) FROM lake.Games WHERE EventID = @EventID
--	SET @rounds = (SELECT MAX(ROUND(CONVERT(decimal, RoundNum), 0)) FROM EEHGames WHERE Tournament = @Tournament)
	SELECT @rounds = MAX(RoundNum) FROM lake.Games WHERE EventID = @EventID
	SET @fourth = 0.00
	SET @third = 0.00
	SET @second = 0.00
	SET @first = 0.00
	SET @cmaster = 0.00
	SET @master = 0.00
	SET @smaster = 0.00

	SET @ctr = 1
	WHILE @ctr <= @rounds
	BEGIN
		SELECT TOP 1 @elo = (CASE WHEN WhitePlayerID = @PlayerID THEN BlackElo ELSE WhiteElo END) FROM lake.Games WHERE EventID = @EventID AND RoundNum = @ctr AND (WhitePlayerID = @PlayerID OR BlackElo = @PlayerID)

		--4th category
		IF 1200 - @elo < -400
		BEGIN
			SET @fourth = @fourth
		END
		ELSE IF 1200 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @fourth = @fourth + (0.5 + (1200 - @elo)/800.0)
		END
		ELSE IF 1200 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @fourth = @fourth + (0.5 + (1200 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @fourth = @fourth + 1
		END

		--3rd category
		IF 1400 - @elo < -400
		BEGIN
			SET @third = @third
		END
		ELSE IF 1400 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @third = @third + (0.5 + (1400 - @elo)/800.0)
		END
		ELSE IF 1400 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @third = @third + (0.5 + (1400 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @third = @third + 1
		END

		--2nd category
		IF 1600 - @elo < -400
		BEGIN
			SET @second = @second
		END
		ELSE IF 1600 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @second = @second + (0.5 + (1600 - @elo)/800.0)
		END
		ELSE IF 1600 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @second = @second + (0.5 + (1600 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @second = @second + 1
		END

		--1st category
		IF 1800 - @elo < -400
		BEGIN
			SET @first = @first
		END
		ELSE IF 1800 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @first = @first + (0.5 + (1800 - @elo)/800.0)
		END
		ELSE IF 1800 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @first = @first + (0.5 + (1800 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @first = @first + 1
		END

		--candidate master
		IF 2000 - @elo < -400
		BEGIN
			SET @cmaster = @cmaster
		END
		ELSE IF 2000 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @cmaster = @cmaster + (0.5 + (2000 - @elo)/800.0)
		END
		ELSE IF 2000 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @cmaster = @cmaster + (0.5 + (2000 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @cmaster = @cmaster + 1
		END

		--master
		IF 2200 - @elo < -400
		BEGIN
			SET @master = @master
		END
		ELSE IF 2200 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @master = @master + (0.5 + (2200 - @elo)/800.0)
		END
		ELSE IF 2200 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @master = @master + (0.5 + (2200 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @master = @master + 1
		END

		--senior master
		IF 2400 - @elo < -400
		BEGIN
			SET @smaster = @smaster
		END
		ELSE IF 2400 - @elo BETWEEN -400 AND -1
		BEGIN
			SET @smaster = @smaster + (0.5 + (2400 - @elo)/800.0)
		END
		ELSE IF 2400 - @elo BETWEEN 0 AND 199
		BEGIN
			SET @smaster = @smaster + (0.5 + (2400 - @elo)/400.0)
		END
		ELSE
		BEGIN
			SET @smaster = @smaster + 1
		END

		SET @ctr = @ctr + 1
	END

	--determine norm
	IF @score - @fourth > 1 BEGIN SET @norm = '4' END
	IF @score - @third > 1 BEGIN SET @norm = '3' END
	IF @score - @second > 1 BEGIN SET @norm = '2' END
	IF @score - @first > 1 BEGIN SET @norm = '1' END
	IF @score - @cmaster > 1 BEGIN SET @norm = 'C' END
	IF @score - @master > 1 BEGIN SET @norm = 'M' END
	IF @score - @smaster > 1 BEGIN SET @norm = 'S' END

	RETURN @norm
END
