CREATE TABLE [dbo].[OngoingLichessCorr] (
    [GameID]         VARCHAR (20) NOT NULL,
    [Filename]       VARCHAR (50) NULL,
    [LastReviewed]   DATETIME     NULL,
    [LastMoveAtUnix] BIGINT       NULL,
    [Download]       BIT          NULL,
    [Inactive]       BIT          NULL,
    CONSTRAINT [PK_OngoingLichessCorr] PRIMARY KEY CLUSTERED ([GameID] ASC)
);

