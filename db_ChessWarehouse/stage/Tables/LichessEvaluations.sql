CREATE TABLE [stage].[LichessEvaluations]
(
    [ID] BIGINT IDENTITY(1,1) NOT NULL,
    [Errors] VARCHAR(100) NULL,
	[FEN] VARCHAR(92) NULL, 
    [ToMove] CHAR(1) NULL,
    [KNodes] INT NULL, 
    [Depth] SMALLINT NULL, 
    [Evaluation] SMALLINT NULL, 
    [Mate] VARCHAR(10) NULL, 
    [Line] VARCHAR(60) NULL,
    [FileID] INT ,
    CONSTRAINT [PK_LichessEvaluationsStage] PRIMARY KEY CLUSTERED ([ID] ASC)
)
