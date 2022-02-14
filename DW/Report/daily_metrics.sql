create schema Repor--t
--drop table Report.daily_metrics
create table Report.daily_metrics 
(
	pcn int null,
	part_name varchar(100) null,
	part_no varchar(100) null,
	revision varchar(8) null,
	parts_produced int null,
	parts_scrapped int null,
	produced_minus_scrapped int null,
	labor_hours_earned decimal(18,6) null,
	labor_hours_actual decimal(18,6) null, 
	material_standard  decimal(18,6) null,
	material decimal(18,6) null,
	
)

select * from Report.daily_metrics p


select count(*) from Plex.daily_shift_report_get_daily_metrics_view  --51

select *
from Plex.daily_shift_report_get_daily_metrics_view s 
left outer join Plex.cost_sub_type_breakdown_matrix_view c 
on c.pcn = s.pcn
and c.part_no = s.part_no  
and c.revision = s.revision 
where c.pcn is null 

-- select * from Report.daily_metrics 
-- truncate table Report.daily_metrics 
--insert into Report.daily_metrics 
select 
c.pcn,
s.part_name,
c.part_no,
c.revision,
s.parts_produced,
s.parts_scrapped,
s.produced_minus_scrapped quantity_produced,
s.earned_hours,
s.actual_hours,
c.material material_standard,
c.material*s.parts_produced material 

--select count(*)
from Plex.cost_sub_type_breakdown_matrix_view c -- 534
--select * from Plex.daily_shift_report_get_daily_metrics_view s 
inner join Plex.daily_shift_report_get_daily_metrics_view s 
on c.pcn = s.pcn
and c.part_no = s.part_no  
and c.revision = s.revision 
--select * from Plex.cost_sub_type_breakdown_matrix_view -- 534


