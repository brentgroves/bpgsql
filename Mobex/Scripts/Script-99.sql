create table Plex.value_added_report 
(
	part_key int null,
	part_no varchar(100) null,
	material_cost int null,
	outside_cost int null,
	inside_cost int null,
	bom_cost int null,
	unit_price int null,
	scrap_rate int null,
	quantity int null
)
/*
create table Plex.value_added_report 
(
	part_key int null,
	part_no varchar(100) null,
	material_cost numeric(18,5) null,
	outside_cost numeric(18,5) null,
	inside_cost numeric(18,5) null,
	bom_cost numeric(18,5) null,
	unit_price numeric(18,5) null,
	scrap_rate int null,
	quantity int null
)

truncate table Plex.value_added_report 
*/
select * 
--select count(*)
from Plex.value_added_report --100
where material_cost != 0 or bom_cost !=0