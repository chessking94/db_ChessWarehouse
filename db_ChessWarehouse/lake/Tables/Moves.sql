CREATE TABLE [lake].[Moves] (
    [GameID]        INT            NOT NULL,
    [MoveNumber]    SMALLINT       NOT NULL,
    [ColorID]       TINYINT        NOT NULL,
    [IsTheory]      BIT            NOT NULL,
    [IsTablebase]   BIT            NOT NULL,
    [EngineID]      TINYINT        NOT NULL,
    [Depth]         TINYINT        NOT NULL,
    [Clock]         INT            NULL,
    [TimeSpent]     INT            NULL,
    [FEN]           VARCHAR (92)   NOT NULL,
    [PhaseID]       TINYINT        NOT NULL,
    [Move]          VARCHAR (10)   NOT NULL,
    [Move_Eval]     VARCHAR (7)    NOT NULL,
    [Move_Rank]     TINYINT        NOT NULL,
    [T1_Eval_POV]   AS             (case when [T1_Eval] like '#%' then NULL else CONVERT([decimal](5,2),[T1_Eval])*isnull(nullif(CONVERT([smallint],[ColorID]),(2)),(-1)) end) PERSISTED,
    [Move_Eval_POV] AS             (case when [Move_Eval] like '#%' then NULL else CONVERT([decimal](5,2),[Move_Eval])*isnull(nullif(CONVERT([smallint],[ColorID]),(2)),(-1)) end) PERSISTED,
    [CP_Loss]       DECIMAL (5, 2) NULL,
    [T1]            VARCHAR (10)   NOT NULL,
    [T1_Eval]       VARCHAR (7)    NOT NULL,
    [T2]            VARCHAR (10)   NULL,
    [T2_Eval]       VARCHAR (7)    NULL,
    [T3]            VARCHAR (10)   NULL,
    [T3_Eval]       VARCHAR (7)    NULL,
    [T4]            VARCHAR (10)   NULL,
    [T4_Eval]       VARCHAR (7)    NULL,
    [T5]            VARCHAR (10)   NULL,
    [T5_Eval]       VARCHAR (7)    NULL,
    [T6]            VARCHAR (10)   NULL,
    [T6_Eval]       VARCHAR (7)    NULL,
    [T7]            VARCHAR (10)   NULL,
    [T7_Eval]       VARCHAR (7)    NULL,
    [T8]            VARCHAR (10)   NULL,
    [T8_Eval]       VARCHAR (7)    NULL,
    [T9]            VARCHAR (10)   NULL,
    [T9_Eval]       VARCHAR (7)    NULL,
    [T10]           VARCHAR (10)   NULL,
    [T10_Eval]      VARCHAR (7)    NULL,
    [T11]           VARCHAR (10)   NULL,
    [T11_Eval]      VARCHAR (7)    NULL,
    [T12]           VARCHAR (10)   NULL,
    [T12_Eval]      VARCHAR (7)    NULL,
    [T13]           VARCHAR (10)   NULL,
    [T13_Eval]      VARCHAR (7)    NULL,
    [T14]           VARCHAR (10)   NULL,
    [T14_Eval]      VARCHAR (7)    NULL,
    [T15]           VARCHAR (10)   NULL,
    [T15_Eval]      VARCHAR (7)    NULL,
    [T16]           VARCHAR (10)   NULL,
    [T16_Eval]      VARCHAR (7)    NULL,
    [T17]           VARCHAR (10)   NULL,
    [T17_Eval]      VARCHAR (7)    NULL,
    [T18]           VARCHAR (10)   NULL,
    [T18_Eval]      VARCHAR (7)    NULL,
    [T19]           VARCHAR (10)   NULL,
    [T19_Eval]      VARCHAR (7)    NULL,
    [T20]           VARCHAR (10)   NULL,
    [T20_Eval]      VARCHAR (7)    NULL,
    [T21]           VARCHAR (10)   NULL,
    [T21_Eval]      VARCHAR (7)    NULL,
    [T22]           VARCHAR (10)   NULL,
    [T22_Eval]      VARCHAR (7)    NULL,
    [T23]           VARCHAR (10)   NULL,
    [T23_Eval]      VARCHAR (7)    NULL,
    [T24]           VARCHAR (10)   NULL,
    [T24_Eval]      VARCHAR (7)    NULL,
    [T25]           VARCHAR (10)   NULL,
    [T25_Eval]      VARCHAR (7)    NULL,
    [T26]           VARCHAR (10)   NULL,
    [T26_Eval]      VARCHAR (7)    NULL,
    [T27]           VARCHAR (10)   NULL,
    [T27_Eval]      VARCHAR (7)    NULL,
    [T28]           VARCHAR (10)   NULL,
    [T28_Eval]      VARCHAR (7)    NULL,
    [T29]           VARCHAR (10)   NULL,
    [T29_Eval]      VARCHAR (7)    NULL,
    [T30]           VARCHAR (10)   NULL,
    [T30_Eval]      VARCHAR (7)    NULL,
    [T31]           VARCHAR (10)   NULL,
    [T31_Eval]      VARCHAR (7)    NULL,
    [T32]           VARCHAR (10)   NULL,
    [T32_Eval]      VARCHAR (7)    NULL,
    [ScACPL]        AS             (case when [CP_Loss] IS NULL OR left([T1_Eval],(1))='#' then NULL else CONVERT([decimal](5,2),[CP_Loss])/((1)+abs(CONVERT([decimal](5,2),[T1_Eval]))) end) PERSISTED,
    [MoveScored]    BIT            CONSTRAINT [DF_LMoves_MoveScored] DEFAULT ((0)) NOT NULL,
    [TraceKey]      CHAR (1)       COLLATE Latin1_General_CS_AS NULL,
    [MovesAnalyzed] TINYINT        NULL,
    [T2_Eval_POV]   AS             (case when [T2_Eval] like '#%' then NULL else CONVERT([decimal](5,2),[T2_Eval])*isnull(nullif(CONVERT([smallint],[ColorID]),(2)),(-1)) end) PERSISTED,
    [T3_Eval_POV]   AS             (case when [T3_Eval] like '#%' then NULL else CONVERT([decimal](5,2),[T3_Eval])*isnull(nullif(CONVERT([smallint],[ColorID]),(2)),(-1)) end) PERSISTED,
    [T4_Eval_POV]   AS             (case when [T4_Eval] like '#%' then NULL else CONVERT([decimal](5,2),[T4_Eval])*isnull(nullif(CONVERT([smallint],[ColorID]),(2)),(-1)) end) PERSISTED,
    [T5_Eval_POV]   AS             (case when [T5_Eval] like '#%' then NULL else CONVERT([decimal](5,2),[T5_Eval])*isnull(nullif(CONVERT([smallint],[ColorID]),(2)),(-1)) end) PERSISTED,
    CONSTRAINT [PK_LMoves] PRIMARY KEY CLUSTERED ([GameID] ASC, [MoveNumber] ASC, [ColorID] ASC),
    CONSTRAINT [FK_LMoves_ColorID] FOREIGN KEY ([ColorID]) REFERENCES [dim].[Colors] ([ColorID]),
    CONSTRAINT [FK_LMoves_EngineID] FOREIGN KEY ([EngineID]) REFERENCES [dim].[Engines] ([EngineID]),
    CONSTRAINT [FK_LMoves_GameID] FOREIGN KEY ([GameID]) REFERENCES [lake].[Games] ([GameID]) ON DELETE CASCADE,
    CONSTRAINT [FK_LMoves_PhaseID] FOREIGN KEY ([PhaseID]) REFERENCES [dim].[Phases] ([PhaseID]),
    CONSTRAINT [FK_LMoves_Traces] FOREIGN KEY ([TraceKey]) REFERENCES [dim].[Traces] ([TraceKey])
);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_ColorID]
    ON [lake].[Moves]([ColorID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_CPLoss]
    ON [lake].[Moves]([CP_Loss] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_EngineID]
    ON [lake].[Moves]([EngineID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_Evals]
    ON [lake].[Moves]([T1_Eval_POV] ASC, [T2_Eval_POV] ASC, [T3_Eval_POV] ASC, [T4_Eval_POV] ASC, [T5_Eval_POV] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_GameID]
    ON [lake].[Moves]([GameID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_IsTT]
    ON [lake].[Moves]([IsTheory] ASC, [IsTablebase] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_PhaseID]
    ON [lake].[Moves]([PhaseID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_MoveScored]
    ON [lake].[Moves]([MoveScored] ASC)
    INCLUDE([Move_Rank], [CP_Loss], [ScACPL]);


GO
CREATE NONCLUSTERED INDEX [IDX_LMoves_TraceKey]
    ON [lake].[Moves]([TraceKey] ASC);


GO
CREATE TRIGGER [lake].trg_InsertMoveScores ON lake.Moves

AFTER INSERT

AS

INSERT INTO stat.MoveScores (
	ScoreID,
	GameID,
	MoveNumber,
	ColorID
)

SELECT
sc.ScoreID,
i.GameID,
i.MoveNumber,
i.ColorID

FROM inserted i
CROSS JOIN dim.Scores sc
WHERE sc.ScoreActive = 1
