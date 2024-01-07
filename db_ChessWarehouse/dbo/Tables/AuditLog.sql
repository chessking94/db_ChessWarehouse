CREATE TABLE [dbo].[AuditLog] (
    [LogId]        INT           IDENTITY (1, 1) NOT NULL,
    [DatabaseName] VARCHAR (256) NOT NULL,
    [EventType]    VARCHAR (50)  NOT NULL,
    [ObjectName]   VARCHAR (256) NOT NULL,
    [ObjectType]   VARCHAR (25)  NOT NULL,
    [SqlCommand]   VARCHAR (MAX) NOT NULL,
    [EventDate]    DATETIME      CONSTRAINT [DF_AuditLog_EventDate] DEFAULT (getdate()) NOT NULL,
    [LoginName]    VARCHAR (256) NOT NULL,
    CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED ([LogId] ASC)
);

