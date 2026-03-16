CREATE VIEW [rpt].[vwECOSummary]

AS

SELECT
	LEFT(e.ECO_Code, 1) AS ECO_Group
	,s.SourceName
	,'White' AS MyColor
	,e.Opening_Name
	,e.ECO_Code
	,a.Wins
	,a.Losses
	,a.Draws
	,a.TotalGames
	,a.Score
	,a.AvgRating
	,a.PerfRating
	,a.Me_MovesAnalyzed
	,a.Opp_MovesAnalyzed
	,a.Me_ACPL
	,a.Opp_ACPL
	,a.Me_SDCPL
	,a.Opp_SDCPL
	,a.Me_Score
	,a.Opp_Score

FROM dim.ECO AS e
CROSS JOIN dim.Sources AS s
LEFT JOIN (
	SELECT
		s.SourceID
		,e.ECOID
		,SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Wins
		,SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Losses
		,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
		,COUNT(g.GameID) AS TotalGames
		,(SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
		,AVG(NULLIF(g.BlackElo, 0)) AS AvgRating
		,dbo.GetPerfRating(AVG(NULLIF(g.BlackElo, 0)), (SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
		,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
		,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
		,me.Me_ACPL
		,opp.Opp_ACPL
		,me.Me_SDCPL
		,opp.Opp_SDCPL
		,me.Me_Score
		,opp.Opp_Score

	FROM lake.Games AS g
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.ECO e ON g.ECOID = e.ECOID
	INNER JOIN dim.Players p ON g.WhitePlayerID = p.PlayerID
	LEFT JOIN (
		SELECT
			s.SourceID
			,e.ECOID
			,COUNT(m.MoveNumber) AS MovesAnalyzed
			,AVG(m.CP_Loss) AS Me_ACPL
			,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
			,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

		FROM lake.Moves AS m
		INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
			AND m.ColorID = ms.ColorID
			AND m.MoveNumber = ms.MoveNumber
			AND ms.ScoreID = 1
		INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
		INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
		INNER JOIN dim.ECO AS e ON g.ECOID = e.ECOID
		INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID

		WHERE p.SelfFlag = 1
		AND c.Color = 'White'
		AND m.MoveScored = 1

		GROUP BY
			s.SourceID
			,e.ECOID
	) AS me ON s.SourceID = me.SourceID
		AND e.ECOID = me.ECOID
	LEFT JOIN (
		SELECT
			s.SourceID
			,e.ECOID
			,COUNT(m.MoveNumber) AS MovesAnalyzed
			,AVG(m.CP_Loss) AS Opp_ACPL
			,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
			,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

		FROM lake.Moves AS m
		INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
			AND m.ColorID = ms.ColorID
			AND m.MoveNumber = ms.MoveNumber
			AND ms.ScoreID = 1
		INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
		INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
		INNER JOIN dim.ECO AS e ON g.ECOID = e.ECOID
		INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID

		WHERE p.SelfFlag = 1
		AND c.Color = 'Black'
		AND m.MoveScored = 1

		GROUP BY
			s.SourceID
			,e.ECOID
	) AS opp ON s.SourceID = opp.SourceID
		AND e.ECOID = opp.ECOID

	WHERE p.SelfFlag = 1

	GROUP BY
		s.SourceID
		,e.ECOID
		,me.MovesAnalyzed
		,opp.MovesAnalyzed
		,me.Me_ACPL
		,opp.Opp_ACPL
		,me.Me_SDCPL
		,opp.Opp_SDCPL
		,me.Me_Score
		,opp.Opp_Score
) AS a ON e.ECOID = a.ECOID
	AND s.SourceID = a.SourceID

WHERE s.PersonalFlag = 1


UNION


SELECT
	LEFT(e.ECO_Code, 1) AS ECO_Group
	,s.SourceName
	,'Black' AS MyColor
	,e.Opening_Name
	,e.ECO_Code
	,a.Wins
	,a.Losses
	,a.Draws
	,a.TotalGames
	,a.Score
	,a.AvgRating
	,a.PerfRating
	,a.Me_MovesAnalyzed
	,a.Opp_MovesAnalyzed
	,a.Me_ACPL
	,a.Opp_ACPL
	,a.Me_SDCPL
	,a.Opp_SDCPL
	,a.Me_Score
	,a.Opp_Score

FROM dim.ECO AS e
CROSS JOIN dim.Sources AS s
LEFT JOIN (
	SELECT
		s.SourceID
		,e.ECOID
		,SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) AS Wins
		,SUM(CASE WHEN g.Result = 1 THEN 1 ELSE 0 END) AS Losses
		,SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END) AS Draws
		,COUNT(g.GameID) AS TotalGames
		,(SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID) AS Score
		,AVG(NULLIF(g.BlackElo, 0)) AS AvgRating
		,dbo.GetPerfRating(AVG(NULLIF(g.BlackElo, 0)), (SUM(CASE WHEN g.Result = 0 THEN 1 ELSE 0 END) + 0.5*SUM(CASE WHEN g.Result = 0.5 THEN 1 ELSE 0 END))/COUNT(g.GameID)) AS PerfRating
		,ISNULL(me.MovesAnalyzed, 0) AS Me_MovesAnalyzed
		,ISNULL(opp.MovesAnalyzed, 0) AS Opp_MovesAnalyzed
		,me.Me_ACPL
		,opp.Opp_ACPL
		,me.Me_SDCPL
		,opp.Opp_SDCPL
		,me.Me_Score
		,opp.Opp_Score

	FROM lake.Games AS g
	INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
	INNER JOIN dim.ECO AS e ON g.ECOID = e.ECOID
	INNER JOIN dim.Players AS p ON g.BlackPlayerID = p.PlayerID
	LEFT JOIN (
		SELECT
			s.SourceID
			,e.ECOID
			,COUNT(m.MoveNumber) AS MovesAnalyzed
			,AVG(m.CP_Loss) AS Me_ACPL
			,ISNULL(STDEV(m.CP_Loss), 0) AS Me_SDCPL
			,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Me_Score

		FROM lake.Moves AS m
		INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
			AND m.ColorID = ms.ColorID
			AND m.MoveNumber = ms.MoveNumber
			AND ms.ScoreID = 1
		INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
		INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
		INNER JOIN dim.ECO AS e ON g.ECOID = e.ECOID
		INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID

		WHERE p.SelfFlag = 1
		AND c.Color = 'Black'
		AND m.MoveScored = 1

		GROUP BY
			s.SourceID
			,e.ECOID
	) AS me ON s.SourceID = me.SourceID
		AND e.ECOID = me.ECOID
	LEFT JOIN (
		SELECT
			s.SourceID
			,e.ECOID
			,COUNT(m.MoveNumber) AS MovesAnalyzed
			,AVG(m.CP_Loss) AS Opp_ACPL
			,ISNULL(STDEV(m.CP_Loss), 0) AS Opp_SDCPL
			,100*SUM(ms.ScoreValue)/SUM(ms.MaxScoreValue) AS Opp_Score

		FROM lake.Moves AS m
		INNER JOIN stat.MoveScores AS ms ON m.GameID = ms.GameID
			AND m.ColorID = ms.ColorID
			AND m.MoveNumber = ms.MoveNumber
			AND ms.ScoreID = 1
		INNER JOIN lake.Games AS g ON m.GameID = g.GameID
		INNER JOIN dim.Sources AS s ON g.SourceID = s.SourceID
		INNER JOIN dim.Colors AS c ON m.ColorID = c.ColorID
		INNER JOIN dim.ECO AS e ON g.ECOID = e.ECOID
		INNER JOIN dim.Players AS p ON g.WhitePlayerID = p.PlayerID

		WHERE p.SelfFlag = 1
		AND c.Color = 'White'
		AND m.MoveScored = 1

		GROUP BY
			s.SourceID
			,e.ECOID
	) AS opp ON s.SourceID = opp.SourceID
		AND e.ECOID = opp.ECOID

	WHERE p.SelfFlag = 1

	GROUP BY
		s.SourceID
		,e.ECOID
		,me.MovesAnalyzed
		,opp.MovesAnalyzed
		,me.Me_ACPL
		,opp.Opp_ACPL
		,me.Me_SDCPL
		,opp.Opp_SDCPL
		,me.Me_Score
		,opp.Opp_Score
) AS a ON e.ECOID = a.ECOID
	AND s.SourceID = a.SourceID

WHERE s.PersonalFlag = 1
