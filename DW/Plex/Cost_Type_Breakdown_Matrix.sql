-- DROP TABLE Plex.Cost_Type_Breakdown_Matrix;
-- TRUNCATE TABLE mgdw.Plex.Cost_Type_Breakdown_Matrix;
CREATE TABLE mgdw.Cost_Type_Breakdown_Matrix(
	cost decimal(18,6) null,
)
select * from Plex.Cost_Type_Breakdown_Matrix;
