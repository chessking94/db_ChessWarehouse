CREATE PROCEDURE [dbo].[InsertEvaluationSplits]

AS

BEGIN
	TRUNCATE TABLE fact.EvaluationSplits

	INSERT INTO fact.EvaluationSplits (
		SourceID
		,TimeControlID
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
		,m.T1_EvaluationGroupID
		,m.T2_EvaluationGroupID
		,m.T3_EvaluationGroupID
		,m.T4_EvaluationGroupID
		,m.T5_EvaluationGroupID
		,COUNT(m.MoveNumber) AS MovesAnalyzed
		,AVG(CASE when m.CP_Loss = 0 THEN NULL ELSE m.CP_Loss END) AS ACPL
		,STDEV(CASE when m.CP_Loss = 0 THEN NULL ELSE m.CP_Loss END) AS SDCPL
		,AVG(CASE when m.ScACPL = 0 THEN NULL ELSE m.ScACPL END) AS ScACPL
		,STDEV(CASE when m.ScACPL = 0 THEN NULL ELSE m.ScACPL END) AS ScSDCPL
		,AVG(CASE WHEN m.Move_Rank <= 1 THEN 1.00 ELSE 0.00 END) AS T1
		,AVG(CASE WHEN m.Move_Rank <= 2 THEN 1.00 ELSE 0.00 END) AS T2
		,AVG(CASE WHEN m.Move_Rank <= 3 THEN 1.00 ELSE 0.00 END) AS T3
		,AVG(CASE WHEN m.Move_Rank <= 4 THEN 1.00 ELSE 0.00 END) AS T4
		,AVG(CASE WHEN m.Move_Rank <= 5 THEN 1.00 ELSE 0.00 END) AS T5
		,AVG(CASE WHEN m.ColorID = 1 THEN g.Result ELSE (CASE g.Result WHEN 1 THEN 0 WHEN 0 THEN 1 ELSE 0.5 END) END) AS WinPcnt  --win percentage from the perspective of the to-move player

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
		,tc.TimeControlID
		,m.T1_EvaluationGroupID
		,m.T2_EvaluationGroupID
		,m.T3_EvaluationGroupID
		,m.T4_EvaluationGroupID
		,m.T5_EvaluationGroupID
END
