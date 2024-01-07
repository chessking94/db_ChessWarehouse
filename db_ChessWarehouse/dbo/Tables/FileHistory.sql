CREATE TABLE [dbo].[FileHistory] (
    [FileID]        INT           IDENTITY (1, 1) NOT NULL,
    [FileTypeID]    SMALLINT      NOT NULL,
    [Filename]      VARCHAR (100) NOT NULL,
    [DateStarted]   DATETIME      CONSTRAINT [DF_FileHistory_DateStarted] DEFAULT (getdate()) NOT NULL,
    [DateCompleted] DATETIME      NULL,
    [Records]       INT           NULL,
    [Errors]        INT           NULL,
    CONSTRAINT [PK_FileHistory] PRIMARY KEY CLUSTERED ([FileID] ASC),
    CONSTRAINT [FK_FileHistory_FileTypes] FOREIGN KEY ([FileTypeID]) REFERENCES [dbo].[FileTypes] ([FileTypeID])
);

