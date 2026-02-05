CREATE TABLE [doc].[Records] (
    [FileTypeID]  SMALLINT    NOT NULL,
    [RecordKey]  VARCHAR (3)  NOT NULL,
    [RecordName] VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_Records] PRIMARY KEY CLUSTERED ([FileTypeID] ASC, [RecordKey] ASC),
    CONSTRAINT [FK_Records_FileTypeID] FOREIGN KEY ([FileTypeID]) REFERENCES [dbo].[FileTypes] ([FileTypeID])
);

