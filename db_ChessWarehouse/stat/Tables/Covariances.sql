CREATE TABLE [stat].[Covariances] (
    [SourceID]          TINYINT          NOT NULL,
    [AggregationID]     TINYINT          NOT NULL,
    [RatingID]          SMALLINT         NOT NULL,
    [TimeControlID]     TINYINT          NOT NULL,
    [ColorID]           TINYINT          NOT NULL,
    [EvaluationGroupID] TINYINT          NOT NULL,
    [MeasurementID1]    TINYINT          NOT NULL,
    [MeasurementID2]    TINYINT          NOT NULL,
    [Covariance]        DECIMAL (18, 10) NULL,
    CONSTRAINT [PK_Covariances] PRIMARY KEY CLUSTERED ([SourceID] ASC, [AggregationID] ASC, [RatingID] ASC, [TimeControlID] ASC, [ColorID] ASC, [EvaluationGroupID] ASC, [MeasurementID1] ASC, [MeasurementID2] ASC),
    CONSTRAINT [FK_Covariances_AggregationID] FOREIGN KEY ([AggregationID]) REFERENCES [dim].[Aggregations] ([AggregationID]),
    CONSTRAINT [FK_Covariances_ColorID] FOREIGN KEY ([ColorID]) REFERENCES [dim].[Colors] ([ColorID]),
    CONSTRAINT [FK_Covariances_EvaluationGroupID] FOREIGN KEY ([EvaluationGroupID]) REFERENCES [dim].[EvaluationGroups] ([EvaluationGroupID]),
    CONSTRAINT [FK_Covariances_MeasurementID1] FOREIGN KEY ([MeasurementID1]) REFERENCES [dim].[Measurements] ([MeasurementID]),
    CONSTRAINT [FK_Covariances_MeasurementID2] FOREIGN KEY ([MeasurementID2]) REFERENCES [dim].[Measurements] ([MeasurementID]),
    CONSTRAINT [FK_Covariances_RatingID] FOREIGN KEY ([RatingID]) REFERENCES [dim].[Ratings] ([RatingID]),
    CONSTRAINT [FK_Covariances_SourceID] FOREIGN KEY ([SourceID]) REFERENCES [dim].[Sources] ([SourceID]),
    CONSTRAINT [FK_Covariances_TimeControlID] FOREIGN KEY ([TimeControlID]) REFERENCES [dim].[TimeControls] ([TimeControlID])
);

