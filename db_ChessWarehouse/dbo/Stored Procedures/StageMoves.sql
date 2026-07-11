CREATE PROCEDURE [dbo].[StageMoves]

AS

BEGIN
	TRUNCATE TABLE stage.Moves

	INSERT INTO stage.Moves (
		SiteGameID
		,MoveNumber
		,Color
		,IsTheory
		,IsTablebase
		,EngineName
		,Depth
		,Clock
		,TimeSpent
		,FEN
		,PhaseID
		,Move
		,Move_Eval
		,Move_Rank
		,CP_Loss
		,T1
		,T1_Eval
		,T2
		,T2_Eval
		,T3
		,T3_Eval
		,T4
		,T4_Eval
		,T5
		,T5_Eval
		,T6
		,T6_Eval
		,T7
		,T7_Eval
		,T8
		,T8_Eval
		,T9
		,T9_Eval
		,T10
		,T10_Eval
	)

	SELECT
		Field1 AS SiteGameID
		,Field2 AS MoveNumber
		,Field3 AS Color
		,Field4 AS IsTheory
		,Field5 AS IsTablebase
		,Field6 AS EngineName
		,Field7 AS Depth
		,Field8 AS Clock
		,Field9 AS TimeSpent
		,Field10 AS FEN
		,Field11 AS PhaseID
		,Field12 AS Move
		,Field13 AS Move_Eval
		,Field14 AS Move_Rank
		,Field15 AS CP_Loss
		,Field16 AS T1
		,Field17 AS T1_Eval
		,Field18 AS T2
		,Field19 AS T2_Eval
		,Field20 AS T3
		,Field21 AS T3_Eval
		,Field22 AS T4
		,Field23 AS T4_Eval
		,Field24 AS T5
		,Field25 AS T5_Eval
		,Field26 AS T6
		,Field27 AS T6_Eval
		,Field28 AS T7
		,Field29 AS T7_Eval
		,Field30 AS T8
		,Field31 AS T8_Eval
		,Field32 AS T9
		,Field33 AS T9_Eval
		,Field34 AS T10
		,Field35 AS T10_Eval

	FROM stage.BulkInsertGameData

	WHERE RecordKey = 'M'
END
