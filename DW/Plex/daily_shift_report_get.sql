-- DROP TABLE mgdw.Plex.daily_shift_report_get;
-- TRUNCATE TABLE mgdw.Plex.daily_shift_report_get;
-- drop table Plex.daily_shift_report_get
CREATE TABLE mgdw.Plex.daily_shift_report_get (
	pcn int null,
	department_no int NULL,
	department_code varchar(60) NULL,
	manager_first_name varchar(50) null,
	manager_middle_name varchar(50) null,
	manager_last_name varchar(50) null,
	workcenter_key int null,
	workcenter_code varchar(50) NULL,  -- Plex schema says the part_v_workcenter_code is only 50 characters
--	workcenter_code varchar(200) NULL,  -- According to ZappySys the Workcenter code has > 150 characters. I don't think ZappySys is correct.
	part_key int null,
	part_no varchar(100) null,
	part_revision varchar(8) null,
	part_name varchar(100) null,
	operation_no int null,
	operation_code varchar(30) null,
	downtime_hours decimal(18,6) null,
	planned_production_hours decimal(18,6) null,  -- DT-R8 , double precision float changed to DT_DECIMAL in ZappySys
	parts_produced int null,
	parts_scrapped int null,
	scrap_rate decimal(18,6) null,
	utilization decimal(18,6) null,
	efficiency decimal(18,6) null,
	oee decimal(18,6) null,
	earned_hours decimal(18,6) null,
	actual_hours decimal(18,6) null,
	labor_efficiency decimal(18,6) null,
	earned_machine_hours decimal(18,6) null,
	actual_machine_hours decimal(18,6) null,
	part_operation_key int null,
	quantity_produced int null,
	workcenter_rate decimal(18,6) null,
	labor_rate decimal(18,6) null,
	crew_size decimal(18,6) null,
	department_unassigned_hours varchar(1020) null,
	child_part_count int null,
	operators varchar(1020) null,
	note varchar(1020) null,
	accounting_job_nos varchar(1020) null
);
select * from Plex.daily_shift_report_get  -- 86
where actual_hours is null
-- drop view Plex.daily_shift_report_get_view
create view Plex.daily_shift_report_get_view
as 

select pcn,department_no,department_code,manager_first_name,manager_middle_name,manager_last_name,
workcenter_key,workcenter_code,part_key,part_no,part_name,
case 
when part_revision is null then ''
else part_revision 
end revision,
operation_no,operation_code,downtime_hours,planned_production_hours,
parts_produced,parts_scrapped,scrap_rate,utilization,efficiency,oee,
earned_hours,actual_hours,labor_efficiency,
earned_machine_hours,actual_machine_hours,
part_operation_key,quantity_produced,workcenter_rate,labor_rate,crew_size,
department_unassigned_hours,child_part_count,operators,note,accounting_job_nos
--select count(*) 
from Plex.daily_shift_report_get  -- 86

select * from Plex.daily_shift_report_get_view

--where operation_no is null -- 0
select *
--select count(*)
--select distinct part_no, part_revision 
from Plex.daily_shift_report_get  -- 86
where part_no ='10103353'
where part_no = 'H2GC 5K652 AB'

select * from Plex.daily_shift_report_get_daily_metrics_view
--drop view Plex.daily_shift_report_get_daily_metrics_view
create view Plex.daily_shift_report_get_daily_metrics_view
as 
WITH max_operation_no
as 
(
	select pcn,part_no,
	revision,
	max(operation_no) max_operation_no
	from Plex.daily_shift_report_get_view g 
	group by g.pcn,g.part_no,g.revision  --51
	--having part_no = 'H2GC 5K652 AB'
	
),
part_workcenter
as
(
	select m.max_operation_no,g.* 
	from max_operation_no m 
	join Plex.daily_shift_report_get_view g 
	on m.pcn = g.pcn
	and m.part_no = g.part_no 
	and m.revision = g.revision 
	and m.max_operation_no = g.operation_no 
),
--select pcn,part_no,part_revision,operation_no,count(*) from part_workcenter group by pcn,part_no,part_revision,operation_no 
--select * from part_workcenter -- 54
part_last_operation
as 
( 
	select pcn,part_no,revision, max_operation_no operation_no 
	from part_workcenter  
	group by pcn,part_no,revision,max_operation_no  
	-- needed because there are multiple workcenters per part operation_no 
),
--select * from part_last_operation  -- 51
-- this matches with the max_operation_no view above which is grouped by pcn,part_no, and part_revision.
--Are these all the parts? yes.
last_op_parts_produced 
as
(
	select o.pcn,g.part_name,
	o.part_no,o.revision,o.operation_no,sum(g.parts_produced) parts_produced 
	from part_last_operation o 
	join Plex.daily_shift_report_get_view g 
	on o.pcn = g.pcn
	and o.part_no = g.part_no 
	and o.revision = g.revision 
	and o.operation_no = g.operation_no 
	group by o.pcn,g.part_name,o.part_no,o.revision,o.operation_no  
)
select * from last_op_parts_produced  
select count(*) from last_op_parts_produced  -- 51
select count(*) from Plex.daily_shift_report_get  -- 86

select * from last_op_parts_produced  
where part_no in ('10103353','10103355')
--order by part_no,part_revision,operation_no  

Part Name
Parts Produced
Parts Scrapped
Quantity Produced
Labor Hours Earned
Labor Hours Actual

select count(*) from Plex.daily_shift_report_get  -- 86
select * from Plex.daily_shift_report_get  -- 86

-- are there an equal number of records?
select count(*) from Plex.daily_shift_report_get g  -- 86
select count(*) from Plex.daily_shift_report_download  -- 86

-- Can we map the columns we need in the Daily Metrics?
-- What is it's primary key? pcn,workcenter_key,part_key,operation_no
select count(*) cnt
from Plex.daily_shift_report_get g
inner join Plex.daily_shift_report_download d 
--pcn,workcenter_key,part_key,operation_no
on g.pcn=d.pcn
and g.workcenter_key = d.workcenter_key 
and g.part_key = d.part_key 
and g.operation_no = d.operation_no -- 86

-- Do the columns we need in the Daily Metrics have equal values?
--Part_No,Part Name,Parts Produced,Parts Scrapped,Quantity Produced,Labor Hours Earned,Labor Hours Actual
--select *
select g.pcn,g.part_no,g.part_revision,g.operation_no,g.actual_hours,d.actual_labor_hours  
--select count(*) cnt
from Plex.daily_shift_report_get_view g
inner join Plex.daily_shift_report_download d 
--pcn,workcenter_key,part_key,operation_no
on g.pcn=d.pcn
and g.workcenter_key = d.workcenter_key 
and g.part_key = d.part_key 
and g.operation_no = d.operation_no -- 86
--where g.earned_hours = d.earned_labor_hours  -- 86  
--where g.actual_hours = d.actual_labor_hours  -- 85  
--where g.actual_hours != d.actual_labor_hours  -- 1 small rounding error on the 6th decimal position 

--where g.quantity_produced = d.quantity_produced  -- 86  
--where g.quantity_produced = d.quantity_produced  -- 86  
--where g.parts_scrapped = d.parts_scrapped  -- 86  
--where g.parts_produced  = d.parts_produced -- 86  
--where g.part_name = d.part_name -- 86  
--where g.part_no=d.part_no -- 86

select department_no,department_code,manager_first_name,manager_middle_name,manager_last_name,
workcenter_key,workcenter_code,part_key,
part_no,part_name,operation_no,operation_code,
downtime_hours,
planned_production_hours,
parts_produced,parts_scrapped,
scrap_rate,
utilization,efficiency,oee,
earned_hours,actual_hours,labor_efficiency,
earned_machine_hours,actual_machine_hours,
part_operation_key,quantity_produced,workcenter_rate,labor_rate,crew_size,
department_unassigned_hours,child_part_count,operators,note,accounting_job_nos
from Plex.daily_shift_report_get  -- 78
--where workcenter_code like '%CD 4 Control Arm LH CNC 450 455%'
--where part_name like '%CD4.2 LH%'
--where part_no = '%H2GC%'
where part_no = 'H2GC 5K651 AB'
and workcenter_code = 'CD 4 Control Arm RH CNC 295 449'
and part_name = 'CD4.2 RH'
