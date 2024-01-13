CREATE TABLE [stage].[LichessEvaluations]
(
    [Errors] VARCHAR(100) NULL,
	[FEN] VARCHAR(92) NULL, 
    [ToMove] CHAR(1) NULL,
    [KNodes] INT NULL, 
    [Depth] SMALLINT NULL, 
    [Evaluation] SMALLINT NULL, 
    [Mate] VARCHAR(10) NULL, 
    [Line] VARCHAR(50) NULL,
    [FileID] INT NULL
)
