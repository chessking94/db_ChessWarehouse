CREATE PROCEDURE dbo.InsertNewMoves

AS

BEGIN
	INSERT INTO lake.Moves (
		GameID
		,MoveNumber
		,ColorID
		,IsTheory
		,IsTablebase
		,EngineID
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
		GameID
		,MoveNumber
		,Color AS ColorID
		,IsTheory
		,IsTablebase
		,EngineName AS EngineID
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

	FROM stage.Moves
END
