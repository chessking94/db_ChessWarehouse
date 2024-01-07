CREATE TABLE [dbo].[DownloadLog] (
    [DownloadID]      INT          IDENTITY (1, 1) NOT NULL,
    [DownloadDate]    DATETIME     CONSTRAINT [DF_DownloadLog_DownloadDate] DEFAULT (getdate()) NOT NULL,
    [DownloadStatus]  VARCHAR (10) CONSTRAINT [DF_DownloadLog_DownloadStatus] DEFAULT ('Incomplete') NOT NULL,
    [DownloadSeconds] SMALLINT     NULL,
    [DownloadGames]   INT          CONSTRAINT [DF_DownloadLog_DownloadGames] DEFAULT ((0)) NOT NULL,
    [Player]          VARCHAR (50) NULL,
    [Site]            VARCHAR (9)  NULL,
    [TimeControl]     VARCHAR (14) NULL,
    [Color]           VARCHAR (5)  NULL,
    [StartDate]       DATE         NULL,
    [EndDate]         DATE         NULL,
    [OutPath]         VARCHAR (75) NULL,
    CONSTRAINT [PK_DownloadLog] PRIMARY KEY CLUSTERED ([DownloadID] ASC)
);

