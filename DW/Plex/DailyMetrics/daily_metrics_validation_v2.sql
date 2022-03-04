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
Mobex Global Aluminum Fruitport, MI	5246 -- everything equals zero.	
Mobex Global Albion	501-0994-05	8 -- downtime_hours, planned_production_hours both = 3.16667
Mobex Global Albion	51215T6N A000	00- --5 records everything equals zero,  I think this is inactive.  Revision 01 01 has 4 entries with values for the same operation.
Mobex Global Albion	51210T6N A000	00- -- 1 out of 5 records have all values.  I think this is inactive. Revision 01 01 has 2 entries and 1 has values.
 */
select * from Plex.Part_Operation po 
where po.Part_No in ('5246','501-0994-05','51215T6N A000','51210T6N')

/*
 * What kind of activity is showing up on the daily shift report for these parts?
 */
select *
from Plex.daily_shift_report_view 
--where part_no = '5246'  -- everything equals zero.
--where part_no = '501-0994-05 Rev 8'  -- downtime_hours, planned_production_hours both = 3.16667
--where part_no = '51215T6N A000'  '00-' --5 records everything equals zero,  I think this is inactive.  Revision 01 01 has 4 entries with values for the same operation.
where part_no = '51210T6N A000'  -- 1 out of 5 records have all values.  I think this is inactive. Revision 01 01 has 2 entries and 1 has values.
and report_date = '2022-02-14 00:00:00.000'
/* 
 * What daily shift report part number are we missing from daily_shift_report_get_daily_metrics_view?  None
 */

select * 
select count(*)
from 
(
	select pcn,report_date,part_key,part_no,revision from Plex.daily_shift_report_view ds 
) ds
left outer join Plex.daily_shift_report_get_daily_metrics_view dm   -- 3,383
on ds.pcn = dm.pcn 
and ds.report_date = dm.report_date 
and ds.part_key = dm.part_key 
where dm.pcn is not null --7,369
--where dm.pcn is null -- 0

/*
 * Are the parts with the missing shippable part operation data on the report? Yes
 * Do they have the same data as the daily shift report?  No. but we added a valid column 
 * to identify parts that we do not know the shippable operation for.
 */
select * 
from Plex.daily_shift_report_get_daily_metrics_view dm 
where part_no = '51210T6N A000'  -- 1 out of 5 records have all values.  I think this is inactive. Revision 01 01 has 2 entries and 1 has values.
and report_date = '2022-02-14 00:00:00.000'

--where dm.Part_No in ('5246','501-0994-05','51215T6N A000','51210T6N A000')
--and dm.revision != '01 01'
order by part_no 

/*
 * Does Plex.daily_shift_report_get_daily_metrics_view have the same number of parts as the
 * daily shfit report?
 */
select count(*)
from 
(
	select distinct pcn,report_date, part_key from Plex.daily_shift_report_view 
)s --3,575
select count(*)
from 
(
	select distinct pcn,report_date,part_key  from Plex.daily_shift_report_get_daily_metrics_view 
)s -- 3,575


/*
 * Is there a Plex.cost_sub_type_breakdown_matrix material cost record for each part number in the daily shift report? 
 */
select distinct ep.Plexus_Customer_Code,dm.part_no,dm.revision  
--ct.material,dm.* 
-- select *
from Plex.daily_shift_report_get_daily_metrics_view dm
left outer join 
(
	select pcn,part_key,material  from Plex.cost_sub_type_breakdown_matrix_pivot_view 
)ct 
on dm.pcn = ct.pcn 
and dm.part_key = ct.part_key 
inner join  Plex.Enterprise_PCNs_Get ep
on dm.pcn = ep.PCN 
where ct.pcn is null -- 24
order by dm.pcn,dm.part_no  

/*
 * What is the primary_key?
 * Or what is on the information line of the gross margin report to the left of the cost and quantity data. 
 * 
 * 
 */
	
-- Customer	Salesperson	Order No	Cust PO	Invoice No	Part No	Customer Part No	Description
select * 
select Plexus_Customer_Code,report_date,Part_No,Customer_Part_No,Sales_Qty,Unit_Price,gm.PO_No
--,gm.Order_No
from Plex.Cost_Gross_Margin_Daily_View gm
order by gm.pcn,gm.report_date, Part_No 

/*
 * Is it possible to join sales_qty and price to the parts in the daily shift report?
 * Randy K.: It is a promising idea to relate sale price to the quantity produced in 
 * a monthly summary report. For a daily report though it is not necessary.    
 * 
 */

/*
 * 
 */

/*
 * Can we detect parts sold with different prices?
 */
select * 
from Plex.Cost_Gross_Margin_Daily_View gm
where gm.report_date ='2022-02-24 00:00:00.000'	
and Part_No = '50610TZ5 A012M1'	12-M1-
select * from Plex.price_list
drop view Plex.price_list_2 
create view Plex.price_list_2 
as 
with all_po
as 
(
	select pcn,Plexus_Customer_Code,report_date,Part_No,revision, Customer_Part_No,Sales_Qty,Unit_Price,gm.PO_No
	from Plex.Cost_Gross_Margin_Daily_View gm
)
select * from all_po 
--where Sales_Qty is null-- 0
where Sales_Qty < 0-- 0
part_aggregate  
as 
( 
	select ap.pcn,ap.Plexus_Customer_Code,ap.report_date,ap.Part_No,ap.revision,
	count(distinct Unit_Price) price_count,
	count(*) po_count,
	min(Unit_Price) min_price,
	max(Unit_Price) max_price
	from all_po ap 
	group by ap.pcn,ap.Plexus_Customer_Code,ap.report_date,ap.Part_No,ap.revision

),
price_diff 
as 
( 
	select *
	--select count(*) 
	from part_aggregate  
	where max_price - min_price > .01
),
--select *
--select count(*) 
--from price_diff 
po_price_diff 
as 
(
	select ap.* 
	from all_po ap 
	inner join price_diff pd
	on ap.pcn = pd.pcn 
	and ap.report_date = pd.report_date 
	and ap.part_no = pd.part_no 
	and ap.revision = pd.revision 
	
),
/*
			select 
			case 
			when pd1.po_no = '' and pd1.unit_price is null then 'no-po/no-price;'
			when pd1.po_no = '' and pd1.unit_price is not null then 'no-po/' + cast(pd1.unit_price as varchar) + ';'
			when pd1.po_no != '' and pd1.unit_price is null then pd1.po_no + '/no-price;'
			else pd1.po_no + '/' + cast(pd1.unit_price as varchar) + ';'
			end as [text()]
			from po_price_diff pd1 
*/		
/*
	select distinct pd2.pcn,pd2.report_date,pd2.part_no,pd2.revision 
	from po_price_diff pd2 	
*/
/*
	select 
		(
			select 
			case 
			when pd1.po_no = '' then 'no-po,'
			else pd1.po_no + ',' 
			end as [text()]
			from po_price_diff pd1 
			order by pd1.pcn,pd1.report_date,pd1.part_no,pd1.revision 
			for xml path (''), type 
		).value('text()[1]','varchar(max)') [prices]
*/
price_list
as 
(
	select main.Plexus_Customer_Code,main.report_date,main.part_no,main.revision,
	left(main.prices,len(main.prices)-1) as prices 
	from 
	(
	
		select distinct pd2.pcn,pd2.Plexus_Customer_Code,pd2.report_date,pd2.part_no,pd2.revision, 
			(
				select 
				case 
				when pd1.po_no = '' and pd1.unit_price is null then 'no-po/no-price;'
				when pd1.po_no = '' and pd1.unit_price is not null then 'no-po/' + cast(pd1.unit_price as varchar) + ';'
				when pd1.po_no != '' and pd1.unit_price is null then pd1.po_no + '/no-price;'
				else pd1.po_no + '/' + cast(pd1.unit_price as varchar) + ';'
				end as [text()]
				from po_price_diff pd1 
				where pd1.pcn = pd2.pcn 
				and pd1.report_date = pd2.report_date 
				and pd1.part_no = pd2.part_no 
				and pd1.revision = pd2.revision 
				order by pd1.pcn,pd1.report_date,pd1.part_no,pd1.revision 
				for xml path (''), type 
			).value('text()[1]','varchar(max)') [prices]
		from po_price_diff pd2 
	) [main]	
)
select * from price_list 
--order by pcn,report_date,part_no,revision
multiple_price_count
as 
(
	select pcn,Plexus_Customer_Code,report_date,Part_No,revision,price_count 
	from part_aggregate 
	where price_count > 1
--where Part_No like '%100998%'
--	where po_count =2 -- 259
--	where po_count =3 -- 39
)
select ap.plexus_customer_code,ap.report_date,ap.part_no,ap.revision,ap.sales_qty,ap.unit_price   
from all_po ap 
inner join multiple_price_count mp 
on ap.pcn = mp.pcn 
and ap.report_date = mp.report_date 
and ap.part_no = mp.part_no 
and ap.revision = mp.revision 
order by mp.pcn,mp.report_date,mp.part_no,mp.revision 

select 

select *
--select count(*) 
from multiple_price_count  
--where price_count >1  -- 110
--where price_count =2 -- 99
--where price_count =3 -- 10
--where price_count = 4 -- 1


labor rate = parts per hour 

Mobex Global Albion	2022-02-15 00:00:00.000	10115487	H	108.00000	190.8148100
Mobex Global Albion	2022-02-15 00:00:00.000	10115487	H	36.00000	190.8147200
Mobex Global Albion	2022-02-21 00:00:00.000	H2GC 5K652 AB		936.00000	62.5413000
Mobex Global Albion	2022-02-21 00:00:00.000	H2GC 5K652 AB		66.00000	62.5413600

-- truncate table Plex.gross_margin_report gmr 
select * 
--select * from Archive.gross_margin_report 
--into Archive.gross_margin_report 
from Plex.gross_margin_report gmr 
where part_no =e 'H2GC 5K652 AB'
SELECT * FROM Plex.Daily_Metrics_Report_View






