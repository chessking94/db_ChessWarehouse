CREATE PROCEDURE [dbo].[UpdateMoveScores_ScoreID_3] (
	@FileID INT = NULL
)

AS

/*
	*** Score Name = EvaluationGroupComparison ***
	This score compares the difficulty of playing similarly evaluated positions (per T5) by the source/time control/rating.
	The more difficult the position is to play (per the T1-T5 percentages logged in fact.EvaluationSplits), the greater the move score can be.
		A benefit of this method is that positions with multiple similarly evaluated top moves will assumed to be more likely to be played, and thus
		less difficult to find and be allocated less importance.
	After subtracting the probability of playing one of the top 5 moves (depending on if T1-T5 is played) from 1, the result is then scaled by a messy function.
	I honestly have no idea how I came up with this function anymore, except that it somewhat looks like a compacted normal distribution and weights positions
		where the historical win rate closer to 50% as more.
*/

BEGIN
	-- precompute evaluation group assignments in a temp table, this eliminates nested loop joins
	CREATE TABLE #MoveEvalGroups (
		GameID INT NOT NULL
		,MoveNumber SMALLINT NOT NULL
		,ColorID TINYINT NOT NULL
		,EG1_ID TINYINT NOT NULL
		,EG2_ID TINYINT NOT NULL
		,EG3_ID TINYINT NOT NULL
		,EG4_ID TINYINT NOT NULL
		,EG5_ID TINYINT NOT NULL
		,PRIMARY KEY (GameID, MoveNumber, ColorID)
		,INDEX IX_MoveEvalGroups_EGColumns (EG1_ID, EG2_ID, EG3_ID, EG4_ID, EG5_ID)
	)

	-- Step 1: Assign evaluation group IDs once, outside the main join
	-- Instead of 5 LEFT JOINs on ranges, use a hash (cross) join
	INSERT INTO #MoveEvalGroups
	SELECT
		m.GameID
		,m.MoveNumber
		,m.ColorID
		,ISNULL(MAX(CASE WHEN m.T1_Eval_POV >= eg.LBound AND m.T1_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END), 0) AS EG1_ID
		,ISNULL(MAX(CASE WHEN m.T2_Eval_POV >= eg.LBound AND m.T2_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END), 0) AS EG2_ID
		,ISNULL(MAX(CASE WHEN m.T3_Eval_POV >= eg.LBound AND m.T3_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END), 0) AS EG3_ID
		,ISNULL(MAX(CASE WHEN m.T4_Eval_POV >= eg.LBound AND m.T4_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END), 0) AS EG4_ID
		,ISNULL(MAX(CASE WHEN m.T5_Eval_POV >= eg.LBound AND m.T5_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END), 0) AS EG5_ID

	FROM lake.Moves AS m WITH (INDEX(IDX_LMoves_MoveScored))
	CROSS JOIN dim.EvaluationGroups AS eg

	WHERE m.MoveScored = 1

	GROUP BY m.GameID, m.MoveNumber, m.ColorID

	--use statistics to improve cardinality estimates
	CREATE STATISTICS stat_MoveEvalGroups_Cardinality 
	ON #MoveEvalGroups (GameID)

	UPDATE STATISTICS #MoveEvalGroups

	-- Step 2: Materialize the normalized data into another temp table
	CREATE TABLE #NormalizedData (
		GameID INT NOT NULL
		,MoveNumber SMALLINT NOT NULL
		,ColorID TINYINT NOT NULL
		,Move_Rank TINYINT NULL
		,ScACPL DECIMAL(5,2) NULL
		,LookupSourceID TINYINT NULL
		,LookupTimeControlID TINYINT NULL
		,LookupRatingID SMALLINT NULL
		,EG1_ID TINYINT NULL
		,EG2_ID TINYINT NULL
		,EG3_ID TINYINT NULL
		,EG4_ID TINYINT NULL
		,EG5_ID TINYINT NULL
		,PRIMARY KEY (GameID, MoveNumber, ColorID)
	)

	INSERT INTO #NormalizedData
	SELECT
		ms.GameID
		,ms.MoveNumber
		,ms.ColorID
		,m.Move_Rank
		,m.ScACPL
		,CAST((CASE g.SourceID WHEN 1 THEN 3 WHEN 2 THEN 4 ELSE g.SourceID END) AS TINYINT)
		,CAST((CASE WHEN g.SourceID = 1 THEN 5 ELSE td.TimeControlID END) AS TINYINT)
		,CAST((CASE WHEN g.SourceID = 2 AND r.RatingID < 2200 THEN 2200 ELSE r.RatingID END) AS SMALLINT)
		,mev.EG1_ID
		,mev.EG2_ID
		,mev.EG3_ID
		,mev.EG4_ID
		,mev.EG5_ID

	FROM stat.MoveScores AS ms
	INNER JOIN #MoveEvalGroups AS mev ON ms.GameID = mev.GameID
		AND ms.MoveNumber = mev.MoveNumber
		AND ms.ColorID = mev.ColorID
	INNER JOIN lake.Moves AS m ON ms.GameID = m.GameID
		AND ms.MoveNumber = m.MoveNumber
		AND ms.ColorID = m.ColorID
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.Ratings AS r ON (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) >= r.RatingID
		AND (CASE WHEN c.Color = 'White' THEN g.WhiteElo ELSE g.BlackElo END) <= r.RatingUpperBound
	INNER JOIN FileHistory AS fh ON g.FileID = fh.FileID

	WHERE ms.ScoreID = 3
	AND (fh.FileID = @FileID OR @FileID IS NULL)

	OPTION (RECOMPILE)  --to avoid parameter sniffing issues

	UPDATE STATISTICS #NormalizedData

	-- Step 3: Now run the UPDATE against the known cardinalities
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
	INNER JOIN fact.EvaluationSplits AS sp ON nd.LookupSourceID = sp.SourceID
		AND nd.LookupTimeControlID = sp.TimeControlID
		AND nd.LookupRatingID = sp.RatingID
		AND nd.EG1_ID = sp.EvaluationGroupID_T1
		AND nd.EG2_ID = sp.EvaluationGroupID_T2
		AND nd.EG3_ID = sp.EvaluationGroupID_T3
		AND nd.EG4_ID = sp.EvaluationGroupID_T4
		AND nd.EG5_ID = sp.EvaluationGroupID_T5

	OPTION (RECOMPILE)

	DROP TABLE IF EXISTS #NormalizedData
	DROP TABLE IF EXISTS #MoveEvalGroups
END
