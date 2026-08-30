CREATE TABLE [dbo].[UsernameXRef] (
	[PlayerID] INT IDENTITY(1,1) NOT NULL
	,[LastName] VARCHAR(30) NULL
	,[FirstName] VARCHAR(30) NULL
	,[Username] VARCHAR(50) NULL
	,[Source] VARCHAR(15) NULL
	,[SelfFlag] BIT NULL
	,[DownloadFlag] BIT NULL
	,[LastUpdated] DATETIME NULL
	,[LastActiveOnline] DATETIME NULL
	,[UserStatus] VARCHAR(10) NULL
	,[BulletRating] INT NULL
	,[BlitzRating] INT NULL
	,[RapidRating] INT NULL
	,[DailyRating] INT NULL
	,[BulletGames] INT NULL
	,[BlitzGames] INT NULL
	,[RapidGames] INT NULL
	,[DailyGames] INT NULL
	,[Note] VARCHAR(50) NULL
	,[TotalGames] AS (ISNULL([BulletGames], 0) + ISNULL([BlitzGames], 0) + ISNULL([RapidGames], 0) + ISNULL([DailyGames], 0))
	,CONSTRAINT [PK_UsernameXRef] PRIMARY KEY CLUSTERED ([PlayerID] ASC)
	,CONSTRAINT [CK_UsernameXRef_UserStatus] CHECK ([UserStatus] = 'DNE' OR [UserStatus] = 'Closed' OR [UserStatus] = 'Open')
	,CONSTRAINT [UC_UsernameXRef_UsernameSource] UNIQUE NONCLUSTERED ([Username] ASC, [Source] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IDX_UsernameXRef_SourceDownload] ON [dbo].[UsernameXRef]([Source] ASC, [DownloadFlag] ASC)
