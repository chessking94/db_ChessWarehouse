CREATE TABLE [dbo].[Settings] (
    [ID]          SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (40)  NULL,
    [Value]       VARCHAR (100) NULL,
    [Description] VARCHAR (100) NULL,
    CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UC_Settings_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

