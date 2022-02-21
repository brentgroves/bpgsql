
-- DROP TABLE Plex.cost_sub_type_breakdown_matrix_download;
-- TRUNCATE TABLE mgdw.Plex.cost_sub_type_breakdown_matrix_download;
CREATE TABLE Plex.cost_sub_type_breakdown_matrix_download(
	pcn int null,
	cost_model varchar(50) null,
--	part_key int null,
	sub_type varchar(50) null, 
	part_description varchar(100) null,
	revision varchar(8) null,
	material decimal(18,6) null,
	labor decimal(18,6) null,
	overhead decimal(18,6) null,
	subcontract decimal(18,6) null,
	total decimal(18,6) null,
	selling decimal(18,6) null,
	margin decimal(18,6) null
)
select * from Plex.cost_sub_type_breakdown_matrix_download;

-- drop view Plex.cost_sub_type_breakdown_matrix_download_view 
create view Plex.cost_sub_type_breakdown_matrix_download_view 
as 
select 
pcn,cost_model,sub_type,part_description,revision,
case 
when material is null then 0
else material
end material,
case 
when labor is null then 0
else labor
end labor,
case 
when overhead is null then 0
else overhead
end overhead,
case 
when subcontract is null then 0
else subcontract
end subcontract,
case 
when total is null then 0
else total
end total,
case 
when selling is null then 0
else selling
end selling,
case 
when margin is null then 0
else margin
end margin 
from Plex.cost_sub_type_breakdown_matrix_download;
