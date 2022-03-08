-- daily_metrics_validation

Use an ETL script to transfer the data from daily_shift_report_get Plex web service to the mgdw.Plex.daily_shift_report_get table in the DW. 

Run DailyShiftReportDownload ETL script to import the daily shift report csv file that 
can be generated from Plex report download button. Import this data set into the mgdw.Plex.daily_shift_report_download
DW table to validate the Plex daily_shift_report_get web service.


Does the web service get the same number of records as the Plex report download? 300758,2022_02_20,passed
select count(*) from Plex.daily_shift_report_download  -- 86
where report_date = '2022-02-21'  -- 86
--where report_date = '2022-02-20'  -- 32-
--where report_date = '2022-02-19'  -- 67
--where report_date = '2022-02-18'  -- 88
--where report_date = '2022-02-17'  -- 86
--where report_date = '2022-02-16'  -- 90
--where report_date = '2022-02-15'  -- 94
--where report_date = '2022-02-14'  -- 93
select count(*) from Plex.daily_shift_report  
where report_date = '2022-02-21'  -- 86
--where report_date = '2022-02-20'  -- 32-
--where report_date = '2022-02-19'  -- 67
--where report_date = '2022-02-18'  -- 88
--where report_date = '2022-02-17'  -- 86
--where report_date = '2022-02-16'  -- 90
--where report_date = '2022-02-15'  -- 94
--where report_date = '2022-02-14'  -- 93


--select *
--select distinct pcn,report_date 
--select count(*)
--from Plex.daily_shift_report_download_view sd 
from Plex.daily_shift_report_get_view  -- 32
where pcn=300758 and report_date = '2022-02-14'  -- 93/93
where pcn=300758 and report_date = '2022-02-20'  -- 32
order by pcn,report_date 

select count(*)
from Plex.daily_shift_report_get_view s 
--where s.pcn=300758 and s.report_date = '2022-02-20'  -- 32
left outer join Plex.daily_shift_report_download_view sd 
--left outer join Plex.daily_shift_report_download_view sd 
on s.pcn = sd.pcn 
and s.report_date = sd.report_date 
and s.workcenter_key = sd.workcenter_key 
and s.part_key = sd.part_key 
--and s.part_no = sd.part_no 
--and s.revision = sd.revision 
and s.operation_no = sd.operation_no 
--where s.pcn=300758 and s.report_date = '2022-02-14'  -- 93
--where s.pcn=300758 and s.report_date = '2022-02-15'  -- 94
--where s.pcn=300758 and s.report_date = '2022-02-16'  -- 90
where s.pcn=300758 and s.report_date = '2022-02-17'  -- 82
--where s.pcn=300758 and s.report_date = '2022-02-20'  -- 32
and sd.pcn is null -- 0
order by pcn,report_date 

-- Can we map the columns we need in the Daily Metrics? Yes
-- What is it's primary key? pcn,workcenter_key,part_key,operation_no


-- Do the columns we need in the Daily Metrics have equal values?
--Part_No,Part Name,Parts Produced,Parts Scrapped,Quantity Produced,Labor Hours Earned,Labor Hours Actual
--select *
select g.pcn,g.part_no,g.revision,g.operation_no,g.actual_hours,d.actual_labor_hours  
--select count(*) cnt
from Plex.daily_shift_report_get_view g
inner join Plex.daily_shift_report_download_view  d 
--pcn,workcenter_key,part_key,operation_no
on g.pcn=d.pcn
and g.report_date = d.report_date 
and g.workcenter_key = d.workcenter_key 
and g.part_key = d.part_key 
and g.operation_no = d.operation_no -- 86
--where g.pcn=300758 and g.report_date = '2022-02-14'  -- 200
--where g.pcn=300758 and g.report_date = '2022-02-20'  -- 32
--and  g.earned_hours = d.earned_labor_hours  -- 32 
--and g.actual_hours = d.actual_labor_hours  -- 30  
--and g.actual_hours != d.actual_labor_hours  -- 2  ETL script issues
--and g.quantity_produced = d.quantity_produced  -- 32  
--and g.parts_scrapped = d.parts_scrapped  -- 32  
--and g.part_name = d.part_name -- 32  
--and g.part_no=d.part_no -- 32



