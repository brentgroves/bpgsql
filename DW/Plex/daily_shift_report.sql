-- DROP TABLE mgdw.Plex.daily_shift_report;
-- TRUNCATE TABLE mgdw.Plex.daily_shift_report;
-- drop table Plex.daily_shift_report
CREATE TABLE mgdw.Plex.daily_shift_report (
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

select count(*) from Plex.daily_shift_report  -- 78
select max(len(workcenter_code)) from Plex.daily_shift_report  -- 44

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
--select *
--into Archive.daily_shift_report_01_28_2022  -- 74
-- delete from Plex.daily_shift_report
from Plex.daily_shift_report  -- 78
--where workcenter_code like '%CD 4 Control Arm LH CNC 450 455%'
--where part_name like '%CD4.2 LH%'
--where part_no = '%H2GC%'
where part_no = 'H2GC 5K651 AB'
and workcenter_code = 'CD 4 Control Arm RH CNC 295 449'
and part_name = 'CD4.2 RH'
