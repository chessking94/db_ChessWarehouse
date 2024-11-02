CREATE TABLE [dbo].[UsernameXRef] (
    [PlayerID]         INT          IDENTITY (1, 1) NOT NULL,
    [LastName]         VARCHAR (30) NULL,
    [FirstName]        VARCHAR (30) NULL,
    [Username]         VARCHAR (50) NULL,
    [Source]           VARCHAR (15) NULL,
    [SelfFlag]         BIT          NULL,
    [DownloadFlag]     BIT          NULL,
    [LastActiveOnline] DATETIME     NULL,
    [UserStatus]       VARCHAR (10) NULL,
    [BulletRating]     INT          NULL,
    [BlitzRating]      INT          NULL,
    [RapidRating]      INT          NULL,
    [DailyRating]      INT          NULL,
    [BulletGames]      INT          NULL,
    [BlitzGames]       INT          NULL,
    [RapidGames]       INT          NULL,
    [DailyGames]       INT          NULL,
    [Note]             VARCHAR (50) NULL,
    [TotalGames]       AS           (((isnull([BulletGames],(0))+isnull([BlitzGames],(0)))+isnull([RapidGames],(0)))+isnull([DailyGames],(0))),
    CONSTRAINT [PK_UsernameXRef] PRIMARY KEY CLUSTERED ([PlayerID] ASC),
    CONSTRAINT [CK_UsernameXRef_UserStatus] CHECK ([UserStatus]='DNE' OR [UserStatus]='Closed' OR [UserStatus]='Open')
);


GO
CREATE NONCLUSTERED INDEX [IDX_UsernameXRef_SourceDownload]
    ON [dbo].[UsernameXRef]([Source] ASC, [DownloadFlag] ASC);

