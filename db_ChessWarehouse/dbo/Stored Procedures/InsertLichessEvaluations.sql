CREATE PROCEDURE [dbo].[InsertLichessEvaluations]

AS

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

SELECT
FEN,
ToMove AS ColorID,
KNodes,
Depth,
Evaluation,
Mate,
Line,
FileID

FROM stage.LichessEvaluations
