CREATE TABLE [stage].[BulkInsertLichessEvaluations]
(
	[FEN] VARCHAR(92) NULL,
    [ToMove] CHAR(1) NULL,
    [KNodes] VARCHAR(20) NULL, 
    [Depth] VARCHAR(10) NULL, 
    [Evaluation] VARCHAR(10) NULL, 
    [Mate] VARCHAR(10) NULL, 
    [Line] VARCHAR(60) NULL
)
