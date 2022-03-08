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

select DISTINCT pcn,report_date from Plex.daily_shift_report_get  -- 86
where pcn = 300758
order by pcn,report_date 
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


select * 
--into Archive.daily_shift_report_Albion_2022_02_20 
select actual_hours,part_no,part_revision,* from Archive.daily_shift_report_Albion_2022_02_20 -- 32
where part_no in ('501-1234-02','001-0924-03')
and operation_no in (150,130)

from Plex.daily_shift_report_get r 
where r.pcn = 300758
and DATEADD(dd, 0, DATEDIFF(dd, 0, r.report_date))  = '2022-02-20' -- 32
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

select count(*) from Plex.daily_shift_report_get  -- 86
select * from Plex.daily_shift_report_get  -- 86

-- are there an equal number of records?
select count(*) from Plex.daily_shift_report_get g  -- 86
select count(*) from Plex.daily_shift_report_download  -- 86


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
