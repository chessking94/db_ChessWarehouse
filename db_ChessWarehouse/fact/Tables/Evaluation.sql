﻿CREATE TABLE [fact].[Evaluation] (
    [SourceID]          TINYINT        NOT NULL,
    [EvaluationGroupID] TINYINT        NOT NULL,
    [TimeControlID]     TINYINT        NOT NULL,
    [RatingID]          SMALLINT       NOT NULL,
    [CalculationDate]   DATETIME       CONSTRAINT [DF_FEvaluation_CalculationDate] DEFAULT (getdate()) NOT NULL,
    [CPL_Moves]         INT            NOT NULL,
    [CPL_1]             INT            NOT NULL,
    [CPL_2]             INT            NOT NULL,
    [CPL_3]             INT            NOT NULL,
    [CPL_4]             INT            NOT NULL,
    [CPL_5]             INT            NOT NULL,
    [CPL_6]             INT            NOT NULL,
    [CPL_7]             INT            NOT NULL,
    [CPL_8]             INT            NOT NULL,
    [MovesAnalzyed]     INT            NOT NULL,
    [ACPL]              DECIMAL (9, 6) NULL,
    [SDCPL]             DECIMAL (9, 6) NULL,
    [ScACPL]            DECIMAL (9, 6) NULL,
    [ScSDCPL]           DECIMAL (9, 6) NULL,
    [T1]                DECIMAL (7, 6) NULL,
    [T2]                DECIMAL (7, 6) NULL,
    [T3]                DECIMAL (7, 6) NULL,
    [T4]                DECIMAL (7, 6) NULL,
    [T5]                DECIMAL (7, 6) NULL,
    [Score]             DECIMAL (7, 4) NULL,
    [ACPL_Z]            DECIMAL (9, 6) NULL,
    [SDCPL_Z]           DECIMAL (9, 6) NULL,
    [ScACPL_Z]          DECIMAL (9, 6) NULL,
    [ScSDCPL_Z]         DECIMAL (9, 6) NULL,
    [T1_Z]              DECIMAL (9, 6) NULL,
    [T2_Z]              DECIMAL (9, 6) NULL,
    [T3_Z]              DECIMAL (9, 6) NULL,
    [T4_Z]              DECIMAL (9, 6) NULL,
    [T5_Z]              DECIMAL (9, 6) NULL,
    [Score_Z]           DECIMAL (9, 6) NULL,
    [Composite_Z]       DECIMAL (9, 6) NULL,
    [ROI]               AS             ((5)*[Composite_Z]+(50)),
    CONSTRAINT [PK_FEvaluation] PRIMARY KEY CLUSTERED ([SourceID] ASC, [EvaluationGroupID] ASC, [TimeControlID] ASC, [RatingID] ASC),
    CONSTRAINT [FK_Evaluation_EvaluationGroupID] FOREIGN KEY ([EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID])
);

