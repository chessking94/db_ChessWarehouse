CREATE PROCEDURE dbo.InsertNewTimeControls

AS

BEGIN
	--stage
	INSERT INTO stage.TimeControlDetail (TimeControlDetail)
	SELECT DISTINCT TimeControlDetail FROM stage.Games

	UPDATE stg
	SET stg.TimeControlDetailID = prod.TimeControlDetailID
	FROM stage.TimeControlDetail AS stg
	INNER JOIN dim.TimeControlDetail AS prod ON stg.TimeControlDetail = prod.TimeControlDetail


	--insert
	INSERT INTO dim.TimeControlDetail (TimeControlDetail, TimeControlID)
	SELECT TimeControlDetail, dbo.GetTimeControlID(TimeControlDetail) FROM stage.TimeControlDetail WHERE TimeControlDetailID IS NULL

	UPDATE stg
	SET stg.TimeControlDetailID = prod.TimeControlDetailID
	FROM stage.TimeControlDetail AS stg
	INNER JOIN dim.TimeControlDetail AS prod ON stg.TimeControlDetail = prod.TimeControlDetail
	WHERE stg.TimeControlDetailID IS NULL
END
