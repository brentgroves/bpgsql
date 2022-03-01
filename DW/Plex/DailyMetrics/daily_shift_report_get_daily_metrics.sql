daily_shift_report_get_daily_metrics

select * from Plex.daily_shift_report_get_daily_metrics_view

select * from Plex.daily_shift_report_get_daily_metrics_pcn_view

/*
 * How many records should there be in Plex.daily_shift_report_get_daily_metrics_pcn_view? 3,218
 * How many records do we have for the test date range? 2,858
 * 1 for each pcn,report_date,part_no,revision record in the range of '2022-02-08' and '2022-02-25'
select count(*) 
from 
(
select distinct pcn,report_date,part_no,revision from  Plex.daily_shift_report_view where report_date  between '2022-02-08' and '2022-02-25'
 
)s  -- 3,218
 */
-- select * from Plex.daily_shift_report_get_daily_metrics_view
--drop view Plex.daily_shift_report_get_daily_metrics_view
create view Plex.daily_shift_report_get_daily_metrics_view
as 
with all_operation_sum 
as 
(  -- these sums are for all operations not just the final one.
	select pcn,report_date,part_key,part_no,
	revision,
	sum(parts_scrapped) parts_scrapped, -- view changes null to 0
	sum(earned_hours) earned_hours,-- view changes null to 0
	sum(actual_hours) actual_hours-- view changes null to 0
	from Plex.daily_shift_report_view ds 
	group by ds.pcn,ds.report_date,ds.part_key,ds.part_no,ds.revision 
	--having ds.report_date  between '2022-02-08' AND '2022-02-27' -- date range FOR TESTING ONLY

	--having part_no = 'H2GC 5K652 AB'
),
--select * 
--select count(*)
--from all_operation_sum -- 3,383

shippable_operation_only
as 
(
	select ds.*,so.operation_no shippable_operation 
	from Plex.daily_shift_report_view ds -- set of all shippable operation for daily shift report records,ie, workcenters with for that operation.
	left outer join Plex.part_operation_shippable_view so 
	on ds.pcn = so.pcn 
	and ds.part_key = so.part_key 
	and ds.operation_no = so.operation_no 
--	where so.pcn is null  -- 4,352
	where so.pcn is not null -- 3017
	--and ds.report_date  between '2022-02-08' AND '2022-02-27' -- date range FOR TESTING ONLY
),
--select count(*) 
--from shippable_operation_only so 
	-- Remember 4 parts are still missing a shippable operation
	/*
Mobex Global Aluminum Fruitport, MI	5246	
Mobex Global Albion	501-0994-05	8
Mobex Global Albion	51215T6N A000	00-
Mobex Global Albion	51210T6N A000	00-
 */
	
shippable_quantity_produced 
as
(
	select so.pcn,so.report_date,
	so.part_name,
	so.part_key,so.part_no,so.revision,so.operation_no,sum(so.quantity_produced) quantity_produced 
	from shippable_operation_only so -- primary key for result set 
	group by so.pcn,so.report_date,so.part_name,so.part_key, so.part_no,so.revision,so.operation_no  
),
--select * 
--select count(*)
--from shippable_quantity_produced  -- 2,522
daily_shift_report_part_list 
as 
(
	select distinct pcn, part_key from Plex.daily_shift_report_view g --
),
no_shippable_part_operation 
as 
( 
	select ds.pcn,ds.part_key
	--select count(*) cnt 
	from daily_shift_report_part_list ds 
	left outer join Plex.part_operation_shippable_view sh 
	on ds.pcn = sh.pcn 
	and ds.part_key = sh.part_key 
	--where sh.pcn is not null 
	where sh.pcn is null -- 30
),
--select * from no_shippable_part_operation 

daily_shift_report_sums 
as 
(
	
	select ao.pcn,ao.report_date,ao.part_key,ao.part_no,ao.revision,
	case 
	when ns.part_key is null then 0
	else 1
	end valid,
	case 
	when so.quantity_produced is null then 0 
	else so.quantity_produced  
	end quantity_produced,
	ao.parts_scrapped, -- view changes null to 0
	case 
	when so.quantity_produced is null then ao.parts_scrapped -- quantity_produced can be null but parts_scrapped can not 
	else so.quantity_produced + ao.parts_scrapped 
	end produced_plus_scrapped,
	ao.earned_hours,-- view changes null to 0
	ao.actual_hours-- view changes null to 0
	from all_operation_sum ao  
	left outer join no_shippable_part_operation ns -- we do not have/know the shippable operation for some parts 
	on ao.pcn = ns.pcn 
	and ao.part_key = ns.part_key 
	left outer join shippable_quantity_produced so -- not all pcn,report_date,part_key combos have shippable parts.
	on ao.pcn=so.pcn 
	and ao.report_date = so.report_date 
	and ao.part_key = so.part_key 
	
	--where so.pcn is null  -- 861
	--where so.pcn is not null  -- 2,522
	
)

select * 
--select count(*)
from daily_shift_report_sums  -- 3,383
--where valid =1

select * 
--select count(*)
from Plex.daily_shift_report_get_daily_metrics_view  -- 3,383
where valid = 1
where part_no = '51210T6N A000'  -- 1 out of 5 records have all values.  I think this is inactive. Revision 01 01 has 2 entries and 1 has values.
and report_date = '2022-02-14 00:00:00.000'
--where Part_No in ('5246','501-0994-05','51215T6N A000','51210T6N')
order by part_no 
/* 
 * What daily shift report part number are we missing from this view?  None
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
 * Are the parts with the missing shippable part operation data on the report
 */



--select * from Plex.daily_shift_report_get_daily_metrics_pcn_view
where part_no = '10103355'
-- parts_produced = 524+289 = 813
	
	
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
