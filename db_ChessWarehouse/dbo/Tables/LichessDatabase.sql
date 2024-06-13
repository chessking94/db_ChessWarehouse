CREATE TABLE [dbo].[LichessDatabase]
(
	[Filename] VARCHAR(50) NOT NULL, 
    [Decompression_Start] DATETIME NULL, 
    [Decompression_End] DATETIME NULL, 
    [ErrorLog_Start] DATETIME NULL, 
    [ErrorLog_End] DATETIME NULL, 
    [2200_Start] DATETIME NULL, 
    [2200_End] DATETIME NULL, 
    [Corr_Start] DATETIME NULL, 
    [Corr_End] DATETIME NULL, 
    [Bullet_2200] INT NULL, 
    [Blitz_2200] INT NULL, 
    [Rapid_2200] INT NULL, 
    [Classical_2200] INT NULL, 
    [Corr_All] INT NULL, 
    [Corr_Additional] INT NULL,
    CONSTRAINT [PK_LichessDatabase] PRIMARY KEY CLUSTERED ([Filename] ASC)
)
