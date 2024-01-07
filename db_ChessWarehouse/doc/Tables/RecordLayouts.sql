CREATE TABLE [doc].[RecordLayouts] (
    [RecordKey]     VARCHAR (3)  NOT NULL,
    [FieldPosition] SMALLINT     NOT NULL,
    [FieldName]     VARCHAR (26) NOT NULL,
    CONSTRAINT [PK_RecordLayouts] PRIMARY KEY CLUSTERED ([RecordKey] ASC, [FieldPosition] ASC),
    CONSTRAINT [FK_RecordLayouts_RecordKey] FOREIGN KEY ([RecordKey]) REFERENCES [doc].[Records] ([RecordKey]),
    CONSTRAINT [UC_RecordLayouts] UNIQUE NONCLUSTERED ([RecordKey] ASC, [FieldPosition] ASC)
);

