CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_3] (
	@FileID INT = NULL
)

AS

/*
	*** Score Name = EvaluationGroupComparison ***
	This score compares the difficulty of playing similarly evaluated positions (per T5) by the source/time control/rating.
	The more difficult the position is to play (per the T1-T5 percentages logged in fact.EvaluationSplitsRating), the greater the move score can be.
		A benefit of this method is that positions with multiple similarly evaluated top moves will assumed to be more likely to be played, and thus
		less difficult to find and be allocated less importance.
	After subtracting the probability of playing one of the top 5 moves (depending on if T1-T5 is played) from 1, the result is then scaled by a messy function.
	I honestly have no idea how I came up with the scaling function anymore, except that it somewhat looks like a compacted normal distribution and weights positions
		where the historical win rate closer to 50% as more. The function maximum is y = 1 and has x-intercepts of 0 and 1.
*/

BEGIN
	-- Step 1: Materialize the normalized data into another temp table
	CREATE TABLE #NormalizedData (
		GameID INT NOT NULL
		,MoveNumber SMALLINT NOT NULL
		,ColorID TINYINT NOT NULL
		,Move_Rank TINYINT NULL
		,ScACPL DECIMAL(5,2) NULL
		,LookupSourceID TINYINT NULL
		,LookupTimeControlID TINYINT NULL
		,LookupRatingID SMALLINT NULL
		,T1_EvaluationGroupID TINYINT NULL
		,T2_EvaluationGroupID TINYINT NULL
		,T3_EvaluationGroupID TINYINT NULL
		,T4_EvaluationGroupID TINYINT NULL
		,T5_EvaluationGroupID TINYINT NULL
		,PRIMARY KEY (GameID, MoveNumber, ColorID)
	)

	INSERT INTO #NormalizedData
	SELECT
		m.GameID
		,m.MoveNumber
		,m.ColorID
		,m.Move_Rank
		,m.ScACPL
		,CAST((CASE g.SourceID WHEN 1 THEN 3 WHEN 2 THEN 4 ELSE g.SourceID END) AS TINYINT)
		,CAST((CASE WHEN g.SourceID = 1 THEN 5 ELSE td.TimeControlID END) AS TINYINT)
		,CAST((CASE WHEN g.SourceID = 2 AND r.RatingID < 2200 THEN 2200 ELSE r.RatingID END) AS SMALLINT)
		,m.T1_EvaluationGroupID
		,m.T2_EvaluationGroupID
		,m.T3_EvaluationGroupID
		,m.T4_EvaluationGroupID
		,m.T5_EvaluationGroupID

	FROM lake.Moves AS m
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		AND (g.FileID = @FileID OR @FileID IS NULL)
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.Ratings AS r ON (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID
		AND (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound

	OPTION (RECOMPILE)  --to avoid parameter sniffing issues

	UPDATE STATISTICS #NormalizedData

	-- Step 2: Now run the UPDATE against the known cardinalities
	UPDATE ms
	SET ms.ScoreValue = (
			(1 - (
			CASE nd.Move_Rank 
				WHEN 1 THEN sp.T1
				WHEN 2 THEN sp.T2
				WHEN 3 THEN sp.T3
				WHEN 4 THEN sp.T4
				WHEN 5 THEN sp.T5
				ELSE (CASE WHEN sp.T1 IS NULL THEN NULL 
					WHEN (sp.ScACPL IS NULL OR ISNULL(sp.ScSDCPL, 0) = 0) THEN 1 
					ELSE (sp.T5 + ((1-sp.T5)/(1+EXP(-((nd.ScACPL-sp.ScACPL)/sp.ScSDCPL))))) 
				END)
			END)) * sp.ScalingFactor
		)
		,ms.MaxScoreValue = (1 - sp.T1) * sp.ScalingFactor

	FROM stat.MoveScores AS ms
	INNER JOIN #NormalizedData AS nd ON ms.GameID = nd.GameID
		AND ms.MoveNumber = nd.MoveNumber
		AND ms.ColorID = nd.ColorID
	INNER JOIN fact.EvaluationSplitsRating AS sp ON nd.LookupSourceID = sp.SourceID
		AND nd.LookupTimeControlID = sp.TimeControlID
		AND nd.LookupRatingID = sp.RatingID
		AND nd.T1_EvaluationGroupID = sp.EvaluationGroupID_T1
		AND nd.T2_EvaluationGroupID = sp.EvaluationGroupID_T2
		AND nd.T3_EvaluationGroupID = sp.EvaluationGroupID_T3
		AND nd.T4_EvaluationGroupID = sp.EvaluationGroupID_T4
		AND nd.T5_EvaluationGroupID = sp.EvaluationGroupID_T5

	OPTION (RECOMPILE)

	DROP TABLE IF EXISTS #NormalizedData
END
