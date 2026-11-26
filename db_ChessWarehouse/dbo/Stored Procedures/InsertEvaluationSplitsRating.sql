CREATE PROCEDURE [dbo].[InsertEvaluationSplitsRating]

AS

BEGIN
	TRUNCATE TABLE fact.EvaluationSplitsRating

	INSERT INTO fact.EvaluationSplitsRating (
		SourceID
		,TimeControlID
		,RatingID
		,EvaluationGroupID_T1
		,EvaluationGroupID_T2
		,EvaluationGroupID_T3
		,EvaluationGroupID_T4
		,EvaluationGroupID_T5
		,MovesAnalyzed
		,ACPL
		,SDCPL
		,ScACPL
		,ScSDCPL
		,T1
		,T2
		,T3
		,T4
		,T5
		,WinPercentage
	)

	SELECT
		g.SourceID
		,tc.TimeControlID
		,CASE WHEN c.Color = 'White' THEN g.WhiteRatingID ELSE g.BlackRatingID END AS RatingID
		,m.T1_EvaluationGroupID AS EvaluationGroupID_T1
		,ISNULL(m.T2_EvaluationGroupID, 0) AS EvaluationGroupID_T2
		,ISNULL(m.T3_EvaluationGroupID, 0) AS EvaluationGroupID_T3
		,ISNULL(m.T4_EvaluationGroupID, 0) AS EvaluationGroupID_T4
		,ISNULL(m.T5_EvaluationGroupID, 0) AS EvaluationGroupID_T5
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(m.CP_Loss) AS ACPL
		,STDEV(m.CP_Loss) AS SDCPL
		,AVG(m.ScACPL) AS ScACPL
		,STDEV(m.ScACPL) AS ScSDCPL
		,AVG(CASE WHEN m.Move_Rank <= 1 THEN 1.00 ELSE 0.00 END) AS T1
		,AVG(CASE WHEN m.Move_Rank <= 2 THEN 1.00 ELSE 0.00 END) AS T2
		,AVG(CASE WHEN m.Move_Rank <= 3 THEN 1.00 ELSE 0.00 END) AS T3
		,AVG(CASE WHEN m.Move_Rank <= 4 THEN 1.00 ELSE 0.00 END) AS T4
		,AVG(CASE WHEN m.Move_Rank <= 5 THEN 1.00 ELSE 0.00 END) AS T5
		,AVG(CASE WHEN c.Color = 'White' THEN g.Result ELSE (CASE g.Result WHEN 1 THEN 0 WHEN 0 THEN 1 ELSE 0.5 END) END) AS WinPcnt

	FROM lake.Moves AS m
	INNER JOIN lake.Games AS g ON m.GameID = g.GameID
	INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
	INNER JOIN dim.TimeControlDetail AS td ON g.TimeControlDetailID = td.TimeControlDetailID
	INNER JOIN dim.TimeControls AS tc ON td.TimeControlID = tc.TimeControlID

	WHERE g.SourceID IN (3, 4)
	AND (CASE WHEN c.Color = 'White' THEN g.WhiteBerserk ELSE g.BlackBerserk END) = 0
	AND m.MoveScored = 1

	GROUP BY
		g.SourceID
		,CASE WHEN c.Color = 'White' THEN g.WhiteRatingID ELSE g.BlackRatingID END
		,tc.TimeControlID
		,m.T1_EvaluationGroupID
		,ISNULL(m.T2_EvaluationGroupID, 0)
		,ISNULL(m.T3_EvaluationGroupID, 0)
		,ISNULL(m.T4_EvaluationGroupID, 0)
		,ISNULL(m.T5_EvaluationGroupID, 0)
END
