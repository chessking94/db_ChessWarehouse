CREATE TABLE [dim].[Aggregations] (
    [AggregationID]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [AggregationName] VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_Aggregations] PRIMARY KEY CLUSTERED ([AggregationID] ASC)
);

