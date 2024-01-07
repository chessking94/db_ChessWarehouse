CREATE TABLE [dim].[Measurements] (
    [MeasurementID]     TINYINT      IDENTITY (1, 1) NOT NULL,
    [MeasurementName]   VARCHAR (25) NOT NULL,
    [ZScore_Multiplier] SMALLINT     NULL,
    CONSTRAINT [PK_Measurements] PRIMARY KEY CLUSTERED ([MeasurementID] ASC)
);

