CREATE TABLE [dim].[TimeControlDetail] (
    [TimeControlDetailID] SMALLINT     IDENTITY (1, 1) NOT NULL,
    [TimeControlDetail]   VARCHAR (15) NOT NULL,
    [TimeControlID]       TINYINT      NOT NULL,
    [Seconds]             AS           (case when charindex('+',[TimeControlDetail])>(0) then CONVERT([smallint],left([TimeControlDetail],charindex('+',[TimeControlDetail])-(1)))  end) PERSISTED,
    [Increment]           AS           (case when charindex('+',[TimeControlDetail])>(0) then CONVERT([smallint],substring([TimeControlDetail],charindex('+',[TimeControlDetail])+(1),len([TimeControlDetail])))  end) PERSISTED,
    CONSTRAINT [PK_TimeControlDetail] PRIMARY KEY CLUSTERED ([TimeControlDetailID] ASC),
    CONSTRAINT [FK_TimeControlDetail_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID]),
    CONSTRAINT [UC_TimeControlDetail_TimeControlDetail] UNIQUE NONCLUSTERED ([TimeControlDetail] ASC)
);

