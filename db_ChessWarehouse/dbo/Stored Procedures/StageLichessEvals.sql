﻿CREATE PROCEDURE [dbo].[StageLichessEvals] (@fileid int = NULL)

AS

TRUNCATE TABLE stage.LichessEvaluations

INSERT INTO stage.LichessEvaluations (
	FEN,
	ToMove,
	KNodes,
	Depth,
	Evaluation,
	Mate,
	Line,
	FileID
)

SELECT
FEN,
ToMove,
KNodes,
Depth,
Evaluation,
Mate,
Line,
@fileid AS FileID

FROM stage.BulkInsertLichessEvaluations