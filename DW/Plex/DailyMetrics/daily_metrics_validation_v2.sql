-- daily_metrics_validation
-- SAM changed the table from Plex.daily_shift_report_get to just Plex.daily_shift_report
Use an ETL script to transfer the data from daily_shift_report_get Plex web service to the mgdw.Plex.daily_shift_report table in the DW. 

Run DailyShiftReportDownload ETL script to import the daily shift report csv file that 
can be generated from Plex report download button. Import this data set into the mgdw.Plex.daily_shift_report_download
DW table to validate the Plex daily_shift_report_get web service.

/*
 * Days to validate: 2022-02-15 to 2022-02-21
 */
select distinct pcn,Report_Date  from Plex.daily_shift_report_view 
where pcn = 300758
order by pcn, Report_Date -- 2022-02-08 to 2022-02-23

Does the web service get the same number of records as the Plex report download? Yes, 2022_02_22 14:52
select count(*) from Plex.daily_shift_report_download  -- 86
where report_date = '2022-02-21'  -- 86
--where report_date = '2022-02-20'  -- 32-
--where report_date = '2022-02-19'  -- 67
--where report_date = '2022-02-18'  -- 88
--where report_date = '2022-02-17'  -- 86
--where report_date = '2022-02-16'  -- 90
--where report_date = '2022-02-15'  -- 94
select count(*) from Plex.daily_shift_report_view  
--where pcn = 300758 and report_date = '2022-02-21'  -- 86
--where pcn = 300758 and  report_date = '2022-02-20'  -- 32-
--where pcn = 300758 and  report_date = '2022-02-19'  -- 67
--where pcn = 300758 and  report_date = '2022-02-18'  -- 88
--where pcn = 300758 and report_date = '2022-02-17'  -- 86
--where pcn = 300758 and  report_date = '2022-02-16'  -- 90
--where pcn = 300758 and  report_date = '2022-02-15'  -- 94

-- Do the columns we need in the Daily Metrics have the same values as in the daily shift report CSV download?
--select *
select g.pcn,g.part_no,g.revision,g.operation_no,
g.earned_hours,d.earned_labor_hours
--g.actual_hours,d.actual_labor_hours  
--select count(*) cnt
from Plex.daily_shift_report_view g
inner join Plex.daily_shift_report_download_view  d 
--pcn,workcenter_key,part_key,operation_no
on g.pcn=d.pcn
and g.report_date = d.report_date 
and g.workcenter_key = d.workcenter_key 
and g.part_key = d.part_key 
and g.operation_no = d.operation_no -- 
where g.pcn=300758 and g.report_date = '2022-02-15'  -- 94
--and g.part_name = d.part_name -- 94  
--and g.part_no=d.part_no -- 94
--and g.parts_produced = d.parts_produced  -- 94  
--and g.parts_scrapped = d.parts_scrapped  -- 94  
--and g.quantity_produced = d.quantity_produced  -- 94  
--and  g.earned_hours = d.earned_labor_hours  -- 58 
--and  g.earned_hours != d.earned_labor_hours  -- 36 
--and  (g.earned_hours - d.earned_labor_hours) < .01  -- 94 
--and g.actual_hours = d.actual_labor_hours  -- 88  
--and g.actual_hours != d.actual_labor_hours  -- 6  
--and  (g.actual_hours - d.actual_labor_hours) < .01  -- 94 

Part_No,
Part Name
Parts Produced / Fruitport standard is to map quantity_produced to parts_produced but we should still validate this field just in case 
Parts Scrapped
Quantity Produced
Labor Hours Earned
Labor Hours Actual

/*
 * Do we know the final production operation for all needed parts?
 */

select distinct pcn from Plex.daily_shift_report_view  
select distinct pcn,report_date  from Plex.daily_shift_report_view  order by pcn,report_date 
select distinct pcn,report_date  from Plex.daily_shift_report  order by pcn,report_date 

select count(*)
from 
(
	select distinct pcn,part_no,revision from Plex.daily_shift_report_view  
	
)s -- 380

select * 
--select count(*)
from Plex.part_final_production_operation_view f  -- 1,079

with daily_shift_report_part_list 
as 
(
	select distinct pcn, part_key,part_no,revision from Plex.daily_shift_report_view g 
)
select p.Plexus_Customer_Code,s.part_no,s.revision
--select count(*) cnt 
from daily_shift_report_part_list s 
left outer join Plex.part_final_production_operation_view f 
on s.pcn = f.pcn 
and s.part_key = f.part_key 
inner join  Plex.Enterprise_PCNs_Get p 
on s.pcn = p.PCN 
where f.pcn is null -- 51




