CREATE TABLE [lake].[Moves] (
	[GameID] INT NOT NULL
	,[MoveNumber] SMALLINT NOT NULL
	,[ColorID] TINYINT NOT NULL
	,[IsTheory] BIT NULL
	,[IsTablebase] BIT NULL
	,[EngineID] TINYINT NULL
	,[Depth] TINYINT NULL
	,[Clock] INT NULL
	,[TimeSpent] INT NULL
	,[FEN] VARCHAR(92) NOT NULL
	,[PhaseID] TINYINT NOT NULL
	,[Move] VARCHAR(10) NOT NULL
	,[Move_Eval] VARCHAR(7) NULL
	,[T1] VARCHAR(10) NULL
	,[T1_Eval] VARCHAR(7) NULL
	,[T2] VARCHAR(10) NULL
	,[T2_Eval] VARCHAR(7) NULL
	,[T3] VARCHAR(10) NULL
	,[T3_Eval] VARCHAR(7) NULL
	,[T4] VARCHAR(10) NULL
	,[T4_Eval] VARCHAR(7) NULL
	,[T5] VARCHAR(10) NULL
	,[T5_Eval] VARCHAR(7) NULL
	,[T6] VARCHAR(10) NULL
	,[T6_Eval] VARCHAR(7) NULL
	,[T7] VARCHAR(10) NULL
	,[T7_Eval] VARCHAR(7) NULL
	,[T8] VARCHAR(10) NULL
	,[T8_Eval] VARCHAR(7) NULL
	,[T9] VARCHAR(10) NULL
	,[T9_Eval] VARCHAR(7) NULL
	,[T10] VARCHAR(10) NULL
	,[T10_Eval] VARCHAR(7) NULL
	,[Move_Rank] TINYINT NULL
	,[CP_Loss] DECIMAL(5,2) NULL
	,[ScACPL] AS (CASE WHEN [CP_Loss] IS NULL OR LEFT([T1_Eval], 1) = '#' THEN NULL ELSE CONVERT(DECIMAL(5,2), [CP_Loss])/(1 + ABS(CONVERT(DECIMAL(5,2), [T1_Eval]))) END) PERSISTED
	,[MoveScored] BIT CONSTRAINT [DF_LMoves_MoveScored] DEFAULT (0) NOT NULL
	,[TraceKey] CHAR(1) COLLATE Latin1_General_CS_AS NULL  --this needs to be case-sensitive!
	,[MovesAnalyzed] TINYINT NULL
	,[Move_Eval_POV] AS (CASE WHEN [Move_Eval] LIKE '#%' THEN NULL ELSE CAST(CONVERT(DECIMAL(5,2), [Move_Eval])*ISNULL(NULLIF(CONVERT(SMALLINT, [ColorID]), 2), -1) AS DECIMAL(5,2)) END) PERSISTED
	,[T1_Eval_POV] AS (CASE WHEN [T1_Eval] LIKE '#%' THEN NULL ELSE CAST(CONVERT(DECIMAL(5,2), [T1_Eval])*ISNULL(NULLIF(CONVERT(SMALLINT, [ColorID]), 2), -1) AS DECIMAL(5,2)) END) PERSISTED
	,[T2_Eval_POV] AS (CASE WHEN [T2_Eval] LIKE '#%' THEN NULL ELSE CAST(CONVERT(DECIMAL(5,2), [T2_Eval])*ISNULL(NULLIF(CONVERT(SMALLINT, [ColorID]), 2), -1) AS DECIMAL(5,2)) END) PERSISTED
	,[T3_Eval_POV] AS (CASE WHEN [T3_Eval] LIKE '#%' THEN NULL ELSE CAST(CONVERT(DECIMAL(5,2), [T3_Eval])*ISNULL(NULLIF(CONVERT(SMALLINT, [ColorID]), 2), -1) AS DECIMAL(5,2)) END) PERSISTED
	,[T4_Eval_POV] AS (CASE WHEN [T4_Eval] LIKE '#%' THEN NULL ELSE CAST(CONVERT(DECIMAL(5,2), [T4_Eval])*ISNULL(NULLIF(CONVERT(SMALLINT, [ColorID]), 2), -1) AS DECIMAL(5,2)) END) PERSISTED
	,[T5_Eval_POV] AS (CASE WHEN [T5_Eval] LIKE '#%' THEN NULL ELSE CAST(CONVERT(DECIMAL(5,2), [T5_Eval])*ISNULL(NULLIF(CONVERT(SMALLINT, [ColorID]), 2), -1) AS DECIMAL(5,2)) END) PERSISTED
	,[T1_EvaluationGroupID] TINYINT NULL
	,[T2_EvaluationGroupID] TINYINT NULL
	,[T3_EvaluationGroupID] TINYINT NULL
	,[T4_EvaluationGroupID] TINYINT NULL
	,[T5_EvaluationGroupID] TINYINT NULL
	,[Complexity] DECIMAL(10,9) NULL
	,CONSTRAINT [PK_LMoves] PRIMARY KEY CLUSTERED ([GameID] ASC, [MoveNumber] ASC, [ColorID] ASC)
	,CONSTRAINT [FK_LMoves_ColorID] FOREIGN KEY ([ColorID]) REFERENCES [dim].[Colors] ([ColorID])
	,CONSTRAINT [FK_LMoves_EngineID] FOREIGN KEY ([EngineID]) REFERENCES [dim].[Engines] ([EngineID])
	,CONSTRAINT [FK_LMoves_GameID] FOREIGN KEY ([GameID]) REFERENCES [lake].[Games] ([GameID]) ON DELETE CASCADE
	,CONSTRAINT [FK_LMoves_PhaseID] FOREIGN KEY ([PhaseID]) REFERENCES [dim].[Phases] ([PhaseID])
	,CONSTRAINT [FK_LMoves_Traces] FOREIGN KEY ([TraceKey]) REFERENCES [dim].[Traces] ([TraceKey])
	,CONSTRAINT [FK_LMoves_T1EvaluationGroupID] FOREIGN KEY ([T1_EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_LMoves_T2EvaluationGroupID] FOREIGN KEY ([T2_EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_LMoves_T3EvaluationGroupID] FOREIGN KEY ([T3_EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_LMoves_T4EvaluationGroupID] FOREIGN KEY ([T4_EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
	,CONSTRAINT [FK_LMoves_T5EvaluationGroupID] FOREIGN KEY ([T5_EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_ColorID] ON [lake].[Moves]([ColorID] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_CPLoss] ON [lake].[Moves]([CP_Loss] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_EngineID] ON [lake].[Moves]([EngineID] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_Evals] ON [lake].[Moves]([MoveScored]) INCLUDE ([T1_Eval_POV], [T2_Eval_POV], [T3_Eval_POV], [T4_Eval_POV], [T5_Eval_POV]);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_T1MoveEvals] ON [lake].[Moves] ([MoveScored]) INCLUDE ([T1_Eval_POV], [Move_Eval_POV]);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_GameID] ON [lake].[Moves]([GameID] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_IsTT] ON [lake].[Moves]([IsTheory] ASC, [IsTablebase] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_PhaseID] ON [lake].[Moves]([PhaseID] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_MoveScored] ON [lake].[Moves] (GameID, MoveNumber, ColorID) WHERE MoveScored = 1;

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_TraceKey] ON [lake].[Moves]([TraceKey] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_TnEvaluationGroupID] ON [lake].[Moves] ([T1_EvaluationGroupID], [T2_EvaluationGroupID], [T3_EvaluationGroupID], [T4_EvaluationGroupID], [T5_EvaluationGroupID]);

GO
CREATE TRIGGER [lake].trg_InsertMoveScores ON lake.Moves

AFTER INSERT

AS

BEGIN
	--update Tn evaluation group ID's
	WITH EvalMatch AS (
		SELECT 
			i.GameID
			,i.MoveNumber
			,i.ColorID
			,MAX(CASE WHEN m.T1_Eval_POV >= eg.LBound AND m.T1_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END) AS T1_EvaluationGroupID
			,MAX(CASE WHEN m.T2_Eval_POV >= eg.LBound AND m.T2_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END) AS T2_EvaluationGroupID
			,MAX(CASE WHEN m.T3_Eval_POV >= eg.LBound AND m.T3_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END) AS T3_EvaluationGroupID
			,MAX(CASE WHEN m.T4_Eval_POV >= eg.LBound AND m.T4_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END) AS T4_EvaluationGroupID
			,MAX(CASE WHEN m.T5_Eval_POV >= eg.LBound AND m.T5_Eval_POV <= eg.UBound THEN eg.EvaluationGroupID END) AS T5_EvaluationGroupID

		FROM inserted AS i
		INNER JOIN lake.Moves AS m ON i.GameID = m.GameID
			AND i.MoveNumber = m.MoveNumber
			AND i.ColorID = m.ColorID
		CROSS JOIN dim.EvaluationGroups AS eg

		GROUP BY i.GameID, i.MoveNumber, i.ColorID
	)

	UPDATE m
	SET m.T1_EvaluationGroupID = ISNULL(em.T1_EvaluationGroupID, 0),
		m.T2_EvaluationGroupID = ISNULL(em.T2_EvaluationGroupID, 0),
		m.T3_EvaluationGroupID = ISNULL(em.T3_EvaluationGroupID, 0),
		m.T4_EvaluationGroupID = ISNULL(em.T4_EvaluationGroupID, 0),
		m.T5_EvaluationGroupID = ISNULL(em.T5_EvaluationGroupID, 0)
	FROM inserted AS i
	INNER JOIN lake.Moves AS m ON i.GameID = m.GameID
		AND i.MoveNumber = m.MoveNumber
		AND i.ColorID = m.ColorID
	INNER JOIN EvalMatch AS em ON i.GameID = em.GameID
		AND i.MoveNumber = em.MoveNumber
		AND i.ColorID = em.ColorID


	--insert default move score records
	INSERT INTO stat.MoveScores (
		ScoreID
		,GameID
		,MoveNumber
		,ColorID
	)

	SELECT
		sc.ScoreID
		,i.GameID
		,i.MoveNumber
		,i.ColorID

	FROM inserted AS i
	CROSS JOIN dim.Scores AS sc

	WHERE sc.ScoreActive = 1
END
