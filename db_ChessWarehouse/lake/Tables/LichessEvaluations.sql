CREATE TABLE [lake].[LichessEvaluations]
(
    [EvaluationID] INT NOT NULL IDENTITY(1,1),
	[FEN] VARCHAR(92) NOT NULL, 
    [ColorID] TINYINT NOT NULL,
    [KNodes] INT NULL, 
    [Depth] SMALLINT NULL, 
    [Evaluation] INT NULL, 
    [Mate] SMALLINT NULL, 
    [Line] VARCHAR(60) NULL,
    [FileID] INT NOT NULL,
    CONSTRAINT [PK_LichessEvaluations] PRIMARY KEY CLUSTERED ([EvaluationID] ASC),
    CONSTRAINT [FK_LEvals_ColorID] FOREIGN KEY ([ColorID]) REFERENCES [dim].[Colors] ([ColorID]),
    CONSTRAINT [FK_LEvals_FileID] FOREIGN KEY ([FileID]) REFERENCES  [dbo].[FileHistory] ([FileID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_LEvals_ColorID]
    ON [lake].[LichessEvaluations]([ColorID] ASC);


   GO
CREATE NONCLUSTERED INDEX [IDX_LEvals_FEN]
    ON [lake].[LichessEvaluations]([FEN] ASC);