CREATE TABLE [dbo].[FileTypes] (
    [FileTypeID]    SMALLINT      IDENTITY (1, 1) NOT NULL,
    [FileType]      VARCHAR (100) NOT NULL,
    [FileExtension] VARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_FileTypes] PRIMARY KEY CLUSTERED ([FileTypeID] ASC)
);

