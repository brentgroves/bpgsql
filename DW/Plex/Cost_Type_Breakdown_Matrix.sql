-- DROP TABLE Plex.Cost_Type_Breakdown_Matrix;
-- TRUNCATE TABLE mgdw.Plex.Cost_Type_Breakdown_Matrix;
CREATE TABLE Plex.Cost_Type_Breakdown_Matrix(
	cost decimal(18,6) null,
	part_key int null,
	part_description varchar(100) null,  -- only a guess. map this to a plex column
	line_type varchar(100) null,-- only a guess. map this to a plex column
	cost_breakdown decimal(18,6) null,
	cost_type varchar(50) null,
	cost_model_key int null,
	cost_type_sort_order int null,
	revision varchar(8) null
	
)
select * from Plex.Cost_Type_Breakdown_Matrix;
