I
-- DROP TABLE Plex.cost_type_breakdown_matrix_download;
-- TRUNCATE TABLE mgdw.Plex.cost_type_breakdown_matrix_download;
CREATE TABLE Plex.cost_type_breakdown_matrix_download(
	pcn int null,
	part_description varchar(100) null,
	revision varchar(8) null,
	line_type varchar(50) null,
	material decimal(18,6) null,
	labor decimal(18,6) null,
	overhead decimal(18,6) null,
	subcontract decimal(18,6) null,
	total decimal(18,6) null
)
select * from Plex.cost_type_breakdown_matrix_download;

select * 
from Plex.cost_type_breakdown_matrix_download
where line_type != 'Part'