CREATE TABLE [doc].[RecordLayouts] (
    [FileTypeID]    SMALLINT     NOT NULL,
    [RecordKey]     VARCHAR (3)  NOT NULL,
    [FieldPosition] SMALLINT     NOT NULL,
    [FieldName]     VARCHAR (26) NOT NULL,
    CONSTRAINT [PK_RecordLayouts] PRIMARY KEY CLUSTERED ([FileTypeID] ASC, [RecordKey] ASC, [FieldPosition] ASC),
    CONSTRAINT [FK_RecordLayouts_FileTypeRecordKey] FOREIGN KEY ([FileTypeID], [RecordKey]) REFERENCES [doc].[Records] ([FileTypeID], [RecordKey]),
    CONSTRAINT [UC_RecordLayouts] UNIQUE NONCLUSTERED ([FileTypeID] ASC, [RecordKey] ASC, [FieldPosition] ASC)
);

