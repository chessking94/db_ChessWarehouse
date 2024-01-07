CREATE TABLE [dim].[TimeControls] (
    [TimeControlID]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [TimeControlName] VARCHAR (15) NOT NULL,
    [MinSeconds]      INT          NULL,
    [MaxSeconds]      INT          NULL,
    CONSTRAINT [PK_TC] PRIMARY KEY CLUSTERED ([TimeControlID] ASC),
    CONSTRAINT [UC_TimeControls_TimeControlName] UNIQUE NONCLUSTERED ([TimeControlName] ASC)
);

