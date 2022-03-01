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
 * Do we know the shippable part operation for all needed parts?
Thank you guys for finding the shippable part operations for the Daily Metrics, column 15, Volume produced calc.
Out of all the daily shift report entries that have been transfered to the DW we are only missing 4.
/*
Mobex Global Aluminum Fruitport, MI 5246
Mobex Global Albion 501-0994-05 8
Mobex Global Albion 51215T6N A000 00-
Mobex Global Albion 51210T6N A000 00-
*/
4 that we don't know the shippable part operation for.
I will keep track of these and ask about them at our next meeting.

 */
select * 
--select count(*)
from Plex.part_operation_shippable_view

select distinct pcn from Plex.daily_shift_report_view  
select distinct pcn,report_date  from Plex.daily_shift_report_view  order by pcn,report_date 
select distinct pcn,report_date  from Plex.daily_shift_report  order by pcn,report_date 

select count(*)
from 
(
	select distinct pcn,part_no,revision from Plex.daily_shift_report_view  
	
)s -- 386

select * 
--select count(*)
from Plex.part_operation_shippable_view  -- 1,662

select count(*)
from 
(
	select distinct pcn,report_date,part_key,part_no,revision from Plex.daily_shift_report_view  
	
)s -- 3,383

/*
 * How many daily shift report records are there with a shippable operation?
 */
select count(*) 
from 
(
select ep.Plexus_Customer_Code,ds.part_no,ds.revision,sh.operation_no shippable_operation
-- select *
--select count(*) cnt 
from Plex.daily_shift_report_view ds --
left outer join Plex.part_operation_shippable_view sh 
on ds.pcn = sh.pcn 
and ds.part_key = sh.part_key 
and ds.operation_no = sh.operation_no 
inner join  Plex.Enterprise_PCNs_Get ep
on ds.pcn = ep.PCN 
where sh.pcn is not null 
and ds.report_date  between '2022-02-08' AND '2022-02-27' -- date range FOR TESTING ONLY
--where sh.pcn is null -- 30
)s -- 3017


with daily_shift_report_part_list 
as 
(
	select distinct pcn, part_key,part_no,revision from Plex.daily_shift_report_view g --
)
--select count(*) from daily_shift_report_part_list  -- 344 -- no multi-out parts.

select count(*) 
from 
(
select ep.Plexus_Customer_Code,ds.part_no,ds.revision,sh.operation_no shippable_operation
--select count(*) cnt 
from daily_shift_report_part_list ds 
left outer join Plex.part_operation_shippable_view sh 
on ds.pcn = sh.pcn 
and ds.part_key = sh.part_key 
inner join  Plex.Enterprise_PCNs_Get ep
on ds.pcn = ep.PCN 
where sh.pcn is not null 
--where sh.pcn is null -- 30
)s -- 340


/*
Mobex Global Aluminum Fruitport, MI	5246	
Mobex Global Albion	501-0994-05	8
Mobex Global Albion	51215T6N A000	00-
Mobex Global Albion	51210T6N A000	00-
 */
select * from Plex.Part_Operation po 
where po.Part_No in ('5246','501-0994-05','51215T6N A000','51210T6N')





