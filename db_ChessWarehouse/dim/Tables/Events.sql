CREATE TABLE [dim].[Events] (
    [EventID]    INT           IDENTITY (1, 1) NOT NULL,
    [SourceID]   TINYINT       NOT NULL,
    [EventName]  VARCHAR (100) NOT NULL,
    [EventRated] BIT           NOT NULL,
    CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_Events_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [UC_Events_SourceEvent] UNIQUE NONCLUSTERED ([SourceID] ASC, [EventName] ASC)
);

