CREATE TABLE [dim].[Colors] (
    [ColorID] TINYINT     NOT NULL,
    [Color]   VARCHAR (5) NOT NULL,
    CONSTRAINT [PK_Color] PRIMARY KEY CLUSTERED ([ColorID] ASC),
    CONSTRAINT [UC_Colors_Color] UNIQUE NONCLUSTERED ([Color] ASC)
);

