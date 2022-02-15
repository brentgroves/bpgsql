-- DROP TABLE mgdw.Plex.daily_shift_report_get;
-- TRUNCATE TABLE mgdw.Plex.daily_shift_report_get;
-- drop table Plex.daily_shift_report_get
--select * from Plex.daily_shift_report_get
-- mgdw.Plex.daily_shift_report_get definition
-- mgdw.Plex.daily_shift_report_get definition

-- Drop table

-- DROP TABLE mgdw.Plex.daily_shift_report_get;

CREATE TABLE mgdw.Plex.daily_shift_report_get (
	pcn int NOT NULL,
	plexus_customer_code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	report_date datetime NULL,
	department_no int NULL,
	department_code varchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	manager_first_name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	manager_middle_name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	manager_last_name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	workcenter_key int NULL,
	workcenter_code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_key int NULL,
	part_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_revision varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	operation_no int NULL,
	operation_code varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	downtime_hours decimal(18,6) NULL,
	planned_production_hours decimal(18,6) NULL,
	parts_produced int NULL,
	parts_scrapped int NULL,
	scrap_rate decimal(18,6) NULL,
	utilization decimal(18,6) NULL,
	efficiency decimal(18,6) NULL,
	oee decimal(18,6) NULL,
	earned_hours decimal(18,6) NULL,
	actual_hours decimal(18,6) NULL,
	labor_efficiency decimal(18,6) NULL,
	earned_machine_hours decimal(18,6) NULL,
	actual_machine_hours decimal(18,6) NULL,
	part_operation_key int NULL,
	quantity_produced int NULL,
	workcenter_rate decimal(18,6) NULL,
	labor_rate decimal(18,6) NULL,
	crew_size decimal(18,6) NULL,
	department_unassigned_hours varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	child_part_count int NULL,
	operators varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	note varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	accounting_job_nos varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);
 CREATE CLUSTERED INDEX IX_plex_daily_shift_report_get ON Plex.daily_shift_report_get (  pcn ASC  , report_date ASC  , workcenter_key ASC  , part_key ASC  , part_operation_key ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
	
select * from Plex.daily_shift_report_get  -- 86
where actual_hours is null

SELECT count (column_name) as Number FROM information_schema.columns WHERE table_name='daily_shift_report_get'  -- 39
select * from Plex.daily_shift_report_get_view
-- select * from Plex.daily_shift_report_get_view
-- drop view Plex.daily_shift_report_get_view
create view Plex.daily_shift_report_get_view
as 
select 
pcn,
plexus_customer_code,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
department_no,department_code,manager_first_name,manager_middle_name,manager_last_name,
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
from Plex.daily_shift_report_get  -- 86;


declare @report_date datetime 
set @report_date = '2022-02-14 13:07:27.053'

SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, @report_date))

/*
 * WRONG HAS MULTIPLE OPERATION
 * quantity_produced should be for final operation only.
 */
-- select * from Plex.daily_shift_report_get_aggregate_view
-- drop view Plex.daily_shift_report_get_aggregate_view
create view Plex.daily_shift_report_get_aggregate_view
as 
select pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
5 id, sum(quantity_produced) + sum(parts_scrapped) total  
-- The Fruitport standard says you can use the parts_produced column of the daily_shift_report_get web service
-- but in the Albion PCN parts_produced equals the quantity_produced so this total must be calculated
-- as sum(quantity_produced) + sum(parts_scrapped). 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) 
union 
select pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
10 id, sum(parts_scrapped) total 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) 
union 
select pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
15 id, sum(quantity_produced) total 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) 
union 
select pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
40 id, sum(earned_hours) total 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) 
union 
select pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
45 id, sum(actual_hours) total 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) 

select * 
from Plex.daily_shift_report_get
where parts_produced != quantity_produced 
select * 
from Plex.daily_shift_report_get_view
where parts_produced != quantity_produced 
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
),
-- select count(*) from last_op_parts_produced -- 51 
-- select * from last_op_parts_produced  
part_revision_sums 
as 
(  
	select pcn,part_no,
	revision,
	sum(parts_scrapped) parts_scrapped,
	sum(earned_hours) earned_hours,
	sum(actual_hours) actual_hours
	from Plex.daily_shift_report_get_view g 
	group by g.pcn,g.part_no,g.revision  --51
	--having part_no = 'H2GC 5K652 AB'
),
produced_minus_scrapped 
as 
(
	
	select pp.pcn,pp.part_no,pp.revision, 
	case 
	when ps.parts_scrapped is null then pp.parts_produced  
	else pp.parts_produced - ps.parts_scrapped 
	end produced_minus_scrapped 
	from last_op_parts_produced pp 
	left outer join part_revision_sums ps 
	on pp.pcn=ps.pcn 
	and pp.part_no = ps.part_no 
	and pp.revision = ps.revision
),
--select count(*) from parts_scrapped -- 51
-- select * from parts_scrapped 
daily_shift_report_get_daily_metrics
as 
( 
	select pp.*,ps.parts_scrapped,ms.produced_minus_scrapped,ps.earned_hours,ps.actual_hours  
	from last_op_parts_produced pp 
	left outer join part_revision_sums ps 
	on pp.pcn=ps.pcn 
	and pp.part_no = ps.part_no 
	and pp.revision = ps.revision
	left outer join produced_minus_scrapped ms 
	on pp.pcn=ms.pcn 
	and pp.part_no = ms.part_no 
	and pp.revision = ms.revision
) 
--select count(*) from daily_shift_report_get_daily_metrics  -- 2601
select * from daily_shift_report_get_daily_metrics
--select * from Plex.daily_shift_report_get_daily_metrics_view
where part_no = '10103355'
-- parts_produced = 524+289 = 813
select * from Plex.daily_shift_report_get_daily_metrics_view dsrgdmv 	
	
)
select * from last_op_parts_produced  
select count(*) from last_op_parts_produced  -- 51
select parts_produced,parts_scrapped,quantity_produced,  * from Plex.daily_shift_report_get  -- 86
where pcn = 30078
parts_scrapped > 0
where part_no = '10103353'

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
