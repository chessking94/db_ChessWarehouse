﻿CREATE PROCEDURE [rpt].[UpdateGameSummary]

AS

BEGIN
	TRUNCATE TABLE rpt.GameSummary

	INSERT INTO rpt.GameSummary (
		GameID
		,SourceName
		,SelfWhiteFlag
		,SelfFlagBlack
		,SiteName
		,SiteGameID
		,WhiteLast
		,WhiteFirst
		,WhiteElo
		,BlackLast
		,BlackFirst
		,BlackElo
		,ECO
		,GameDate
		,EventName
		,RoundNum
		,TimeControlDetail
		,TimeControlName
		,Result
		,Moves
		,Book_Moves
		,Tablebase_Moves
		,White_CPL_Moves
		,White_CPL_1
		,White_CPL_2
		,White_CPL_3
		,White_CPL_4
		,White_CPL_5
		,White_CPL_6
		,White_CPL_7
		,White_CPL_8
		,Black_CPL_Moves
		,Black_CPL_1
		,Black_CPL_2
		,Black_CPL_3
		,Black_CPL_4
		,Black_CPL_5
		,Black_CPL_6
		,Black_CPL_7
		,Black_CPL_8
		,White_MovesAnalyzed
		,White_T1
		,White_T2
		,White_T3
		,White_T4
		,White_T5
		,Black_MovesAnalyzed
		,Black_T1
		,Black_T2
		,Black_T3
		,Black_T4
		,Black_T5
		,White_ACPL
		,Black_ACPL
		,White_SDCPL
		,Black_SDCPL
		,White_Score
		,Black_Score
		,White_ROI
		,Black_ROI
	)

	SELECT
		GameID
		,SourceName
		,SelfWhiteFlag
		,SelfFlagBlack
		,SiteName
		,SiteGameID
		,WhiteLast
		,WhiteFirst
		,WhiteElo
		,BlackLast
		,BlackFirst
		,BlackElo
		,ECO
		,GameDate
		,EventName
		,RoundNum
		,TimeControlDetail
		,TimeControlName
		,Result
		,Moves
		,Book_Moves
		,Tablebase_Moves
		,White_CPL_Moves
		,White_CPL_1
		,White_CPL_2
		,White_CPL_3
		,White_CPL_4
		,White_CPL_5
		,White_CPL_6
		,White_CPL_7
		,White_CPL_8
		,Black_CPL_Moves
		,Black_CPL_1
		,Black_CPL_2
		,Black_CPL_3
		,Black_CPL_4
		,Black_CPL_5
		,Black_CPL_6
		,Black_CPL_7
		,Black_CPL_8
		,White_MovesAnalyzed
		,White_T1
		,White_T2
		,White_T3
		,White_T4
		,White_T5
		,Black_MovesAnalyzed
		,Black_T1
		,Black_T2
		,Black_T3
		,Black_T4
		,Black_T5
		,White_ACPL
		,Black_ACPL
		,White_SDCPL
		,Black_SDCPL
		,White_Score
		,Black_Score
		,White_ROI
		,Black_ROI

	FROM rpt.vwGameSummary
END
