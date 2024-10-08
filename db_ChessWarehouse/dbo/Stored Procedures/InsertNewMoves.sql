﻿CREATE PROCEDURE dbo.InsertNewMoves

AS

INSERT INTO lake.Moves (
	GameID,
	MoveNumber,
	ColorID,
	IsTheory,
	IsTablebase,
	EngineID,
	Depth,
	Clock,
	TimeSpent,
	FEN,
	PhaseID,
	Move,
	Move_Eval,
	Move_Rank,
	CP_Loss,
	T1,
	T1_Eval,
	T2,
	T2_Eval,
	T3,
	T3_Eval,
	T4,
	T4_Eval,
	T5,
	T5_Eval,
	T6,
	T6_Eval,
	T7,
	T7_Eval,
	T8,
	T8_Eval,
	T9,
	T9_Eval,
	T10,
	T10_Eval,
	T11,
	T11_Eval,
	T12,
	T12_Eval,
	T13,
	T13_Eval,
	T14,
	T14_Eval,
	T15,
	T15_Eval,
	T16,
	T16_Eval,
	T17,
	T17_Eval,
	T18,
	T18_Eval,
	T19,
	T19_Eval,
	T20,
	T20_Eval,
	T21,
	T21_Eval,
	T22,
	T22_Eval,
	T23,
	T23_Eval,
	T24,
	T24_Eval,
	T25,
	T25_Eval,
	T26,
	T26_Eval,
	T27,
	T27_Eval,
	T28,
	T28_Eval,
	T29,
	T29_Eval,
	T30,
	T30_Eval,
	T31,
	T31_Eval,
	T32,
	T32_Eval
)

SELECT
GameID,
MoveNumber,
Color AS ColorID,
IsTheory,
IsTablebase,
EngineName AS EngineID,
Depth,
Clock,
TimeSpent,
FEN,
PhaseID,
Move,
Move_Eval,
Move_Rank,
CP_Loss,
T1,
T1_Eval,
T2,
T2_Eval,
T3,
T3_Eval,
T4,
T4_Eval,
T5,
T5_Eval,
T6,
T6_Eval,
T7,
T7_Eval,
T8,
T8_Eval,
T9,
T9_Eval,
T10,
T10_Eval,
T11,
T11_Eval,
T12,
T12_Eval,
T13,
T13_Eval,
T14,
T14_Eval,
T15,
T15_Eval,
T16,
T16_Eval,
T17,
T17_Eval,
T18,
T18_Eval,
T19,
T19_Eval,
T20,
T20_Eval,
T21,
T21_Eval,
T22,
T22_Eval,
T23,
T23_Eval,
T24,
T24_Eval,
T25,
T25_Eval,
T26,
T26_Eval,
T27,
T27_Eval,
T28,
T28_Eval,
T29,
T29_Eval,
T30,
T30_Eval,
T31,
T31_Eval,
T32,
T32_Eval

FROM stage.Moves
