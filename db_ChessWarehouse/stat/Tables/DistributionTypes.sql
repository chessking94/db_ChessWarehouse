CREATE TABLE [stat].[DistributionTypes] (
    [DistributionID]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [DistributionType] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_DT_DistributionID] PRIMARY KEY CLUSTERED ([DistributionID] ASC),
    CONSTRAINT [UC_DistributionType] UNIQUE NONCLUSTERED ([DistributionType] ASC)
);

