CREATE PROCEDURE [dbo].[InsertLichessEvaluations]

AS

WHILE EXISTS (SELECT FEN FROM stage.LichessEvaluations)
BEGIN
    INSERT INTO lake.LichessEvaluations (
	    FEN, 
        ColorID,
        KNodes, 
        Depth, 
        Evaluation, 
        Mate, 
        Line,
        FileID
    )

    SELECT TOP(1000000)
    FEN,
    ToMove AS ColorID,
    KNodes,
    Depth,
    Evaluation,
    Mate,
    Line,
    FileID

    FROM stage.LichessEvaluations

    ORDER BY ID

    DELETE TOP(1000000)
    FROM stage.LichessEvaluations
    WHERE ID IN (SELECT TOP(1000000) ID FROM stage.LichessEvaluations ORDER BY ID)
END
