CREATE TABLE [dim].[Scores] (
    [ScoreID]     TINYINT       IDENTITY (1, 1) NOT NULL,
    [ScoreName]   VARCHAR (25)  NOT NULL,
    [ScoreDesc]   VARCHAR (150) NOT NULL,
    [ScoreActive] BIT           CONSTRAINT [DF_Scores_ScoreActive] DEFAULT ((0)) NOT NULL,
    [ScoreProc]   AS            ('UpdateMoveScores_ScoreID_'+CONVERT([nvarchar](30),[ScoreID])) PERSISTED,
    CONSTRAINT [PK_Scores] PRIMARY KEY CLUSTERED ([ScoreID] ASC),
    CONSTRAINT [UC_Scores_ScoreName] UNIQUE NONCLUSTERED ([ScoreName] ASC)
);


GO
CREATE TRIGGER [dim].trg_Scores ON dim.Scores

AFTER INSERT, DELETE

AS

BEGIN

	EXEC dbo.CreateScoreViews

END