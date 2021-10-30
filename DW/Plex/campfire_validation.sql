select distinct period,pcn from Plex.campfire_extract
order by period,pcn
select c.pcn,c.period,c.part_number,a.part,c.actual_units,a.quantity 
from Plex.campfire_extract c
join Plex.revenue_analysis_by_part a 
on c.pcn=a.pcn
and c.part_number=a.part
and c.period=a.period
where 
pcn=123681
--and period=202101
--and period=202109
--and period=202110

select * from Plex.campfire_extract 
where 
pcn=300758
--and period=202101
--and period=202109
and period=202110

/*
create table Plex.campfire_validation
(
	pcn int not null,
	period int not null,
	part_key int not null,
	part_no varchar(50), 
	name varchar(100),
	quantity int,
	primary key (pcn,period,part_key)
)
*/
select 
v.pcn,
v.period,
v.part_key,
v.part_no,
v.name,
v.quantity
--select count(*)
from Plex.campfire_validation v  -- 211
where v.part_no = 'L1MW 4A028 GA'
