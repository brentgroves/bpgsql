-- DROP TABLE mgdw.Plex.daily_shift_report_download;
-- TRUNCATE TABLE mgdw.Plex.daily_shift_report_download;
-- drop table Plex.daily_shift_report_download
CREATE TABLE mgdw.Plex.daily_shift_report_download (
	pcn int null,
	report_date datetime NULL,
	department varchar(60) NULL,
	workcenter varchar(60) NULL,
	part_name varchar(100) null,
	operation varchar(30) null,
	operators varchar(1020) null,
	note varchar(1020) null,
	planned_production_hours decimal(18,6) null,  
	parts_produced int null,
	parts_scrapped int null,
	scrap_rate decimal(18,6) null,
	earned_machine_hours decimal(18,6) null,
	actual_machine_hours decimal(18,6) null,
	efficiency decimal(18,6) null,
	utilization decimal(18,6) null,
	oee decimal(18,6) null,
	earned_labor_hours decimal(18,6) null,
	actual_labor_hours decimal(18,6) null,
	labor_efficiency decimal(18,6) null,
	downtime_hours decimal(18,6) null,
	workcenter_rate decimal(18,6) null,
	labor_rate decimal(18,6) null,
	child_part_count int null,
	accounting_job varchar(1020) null,
	department_no int NULL,
	manager_first_name varchar(50) null,
	manager_middle_name varchar(50) null,
	manager_last_name varchar(50) null,
	workcenter_key int null,
	part_key int null,
	part_no varchar(100) null,
	part_revision varchar(8) null,
	operation_no int null,
	part_operation_key int null,
	quantity_produced int null,
	crew_size decimal(18,6) null,
	department_unassigned_hours varchar(1020) null,
);

select count(*) from Plex.daily_shift_report_download  -- 86
where report_date = '2022-02-21'  -- 86
--where report_date = '2022-02-20'  -- 32-
--where report_date = '2022-02-19'  -- 67
--where report_date = '2022-02-18'  -- 88
--where report_date = '2022-02-17'  -- 86
--where report_date = '2022-02-16'  -- 90
--where report_date = '2022-02-15'  -- 94
--where report_date = '2022-02-14'  -- 93

select count(*)
from Plex.daily_shift_report_get_view s 
--where pcn = 300758 and  report_date = '2022-02-14'  -- 93
--where pcn = 300758 and  report_date = '2022-02-15'  -- 94
--where pcn = 300758 and  report_date = '2022-02-16'  -- 90
where pcn = 300758 and  report_date = '2022-02-18'  -- 88

--where pcn = 300758 and  report_date = '2022-02-17'  -- 82

where pcn = 300758 and report_date = '2022-02-21'  -- 86
where pcn = 300758 and  report_date = '2022-02-20'  -- 32-
where pcn = 300758 and  report_date = '2022-02-19'  -- 67

select DISTINCT pcn,report_date from Plex.daily_shift_report_download  -- 300758,02-20,32
--delete from Plex.daily_shift_report_download  

-- drop view Plex.daily_shift_report_download_view
create view Plex.daily_shift_report_download_view
as 
select 
	pcn,
	report_date,
	department,
	workcenter,
	part_name,
	operation,
	operators,
	note,
	planned_production_hours,  
	parts_produced,
	parts_scrapped,
	scrap_rate,
	earned_machine_hours,
	actual_machine_hours,
	efficiency,
	utilization,
	oee,
	earned_labor_hours,
	actual_labor_hours,
	labor_efficiency,
	downtime_hours,
	workcenter_rate,
	labor_rate,
	child_part_count,
	accounting_job,
	department_no,
	manager_first_name,
	manager_middle_name,
	manager_last_name,
	workcenter_key,
	part_key,
	part_no,
	part_revision revision,
	operation_no,
	part_operation_key,
	quantity_produced,
	crew_size,
	department_unassigned_hours
	FROM Plex.daily_shift_report_download
	
	
