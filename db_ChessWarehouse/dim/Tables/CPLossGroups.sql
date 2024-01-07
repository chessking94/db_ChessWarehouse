CREATE TABLE [dim].[CPLossGroups] (
    [CPLossGroupID] TINYINT        IDENTITY (1, 1) NOT NULL,
    [LBound]        DECIMAL (5, 2) NOT NULL,
    [UBound]        DECIMAL (5, 2) NOT NULL,
    [CPLoss_Range]  VARCHAR (11)   NULL,
    CONSTRAINT [PK_CPLossGroups] PRIMARY KEY CLUSTERED ([CPLossGroupID] ASC)
);

