/*
 * This is where the ETL scripts now copy the Plex daily_shift_report_get web service results.
 */
-- mgdw.Plex.Daily_Shift_Report definition

-- Drop table

-- DROP TABLE mgdw.Plex.Daily_Shift_Report;

CREATE TABLE mgdw.Plex.Daily_Shift_Report (
	PCN int NOT NULL,
	Plexus_Customer_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Report_Date datetime NULL,
	Department_No int NULL,
	Department_Code varchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Manager_First_Name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Manager_Middle_Name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Manager_Last_Name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Workcenter_Key int NULL,
	Workcenter_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Key int NULL,
	Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Revision varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Operation_No int NULL,
	Operation_Code varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Downtime_Hours decimal(19,5) NULL,
	Planned_Production_Hours decimal(19,5) NULL,
	Parts_Produced int NULL,
	Parts_Scrapped int NULL,
	Scrap_Rate decimal(19,5) NULL,
	Utilization decimal(19,5) NULL,
	Efficiency decimal(19,5) NULL,
	OEE decimal(18,6) NULL,
	Earned_Hours decimal(19,5) NULL,
	Actual_Hours decimal(19,5) NULL,
	Labor_Efficiency decimal(19,5) NULL,
	Earned_Machine_Hours decimal(19,5) NULL,
	Actual_Machine_Hours decimal(19,5) NULL,
	Part_Operation_Key int NULL,
	Quantity_Produced int NULL,
	Workcenter_Rate decimal(19,5) NULL,
	Labor_Rate decimal(19,5) NULL,
	Crew_Size decimal(19,5) NULL,
	Department_Unassigned_Hours varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Child_Part_Count int NULL,
	Operators varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Note varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Accounting_Job_Nos varchar(1020) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);
 CREATE CLUSTERED INDEX IX_plex_daily_shift_report ON Plex.Daily_Shift_Report (  PCN ASC  , Report_Date ASC  , Workcenter_Key ASC  , Part_Key ASC  , Part_Operation_Key ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

select * 
select count(*)
--select distinct pcn,Report_Date 
from Plex.Daily_Shift_Report dsr
from Plex.Part_Operation po 

order by pcn,Report_Date 
--where pcn=300758
--where Labor_Rate != 0  -- 6,266
where Labor_Rate = 0  -- 3,966

3,966 / 6,266
select * 
--select count(*)
from Plex.daily_shift_report_get_view ds
where part_no = 'H2GC 5K652 AB'
order by report_date desc 
and report_date = '2022-03-04'
inner join Plex.part_operation_shippable_view po 
on ds.pcn = po.PCN  
and ds.part_key = po.Part_key 
where Shippable = 1
and Labor_Rate != 0  -- 2,028
and Labor_Rate = 0  -- 1,273


select * from Plex.daily_shift_report_view dsrgv 


--drop view Plex.daily_shift_report_view
create view Plex.daily_shift_report_view
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
operation_no,operation_code,
downtime_hours,planned_production_hours,
parts_produced,
case 
when parts_scrapped is null then 0
else Parts_Scrapped
end parts_scrapped,
scrap_rate,utilization,efficiency,oee,
case 
when earned_hours is null then 0 
else earned_hours
end earned_hours,
case 
when actual_hours is null then 0 
else actual_hours 
end actual_hours,
labor_efficiency,
earned_machine_hours,actual_machine_hours,
part_operation_key,quantity_produced,workcenter_rate,labor_rate,crew_size,
department_unassigned_hours,child_part_count,operators,note,accounting_job_nos
--select count(*) 
from Plex.daily_shift_report


