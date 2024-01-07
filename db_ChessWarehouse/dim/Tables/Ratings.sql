CREATE TABLE [dim].[Ratings] (
    [RatingID]         SMALLINT NOT NULL,
    [RatingUpperBound] SMALLINT NOT NULL,
    CONSTRAINT [PK_Rating] PRIMARY KEY CLUSTERED ([RatingID] ASC),
    CONSTRAINT [UC_Ratings_RatingUpperBound] UNIQUE NONCLUSTERED ([RatingUpperBound] ASC)
);

