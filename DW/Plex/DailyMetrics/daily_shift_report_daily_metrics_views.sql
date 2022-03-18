daily_shift_report_get_daily_metrics

select * from Plex.daily_shift_report_daily_metrics_filter_view
--drop view Plex.daily_shift_report_daily_metrics_filter_view
create view Plex.daily_shift_report_daily_metrics_filter_view
as 
select * 
from Plex.daily_shift_report_view ds 
-- See Part Filter tab of validation spreadsheet
where part_no not like 'MO%' -- no multi out parts
and operation_code not like '%Melt%' 
/*
 * Do we have a workcenter_key for every daily shift report record so that we locate the workcenter labor cost per hour? yes
 */
select workcenter_key,part_key,operation_no  
--select count(*)
from Plex.daily_shift_report_daily_metrics_filter_view  -- 14,038
order by workcenter_key desc
where workcenter_key is null  -- 0 

/*
 * How do we get the labor cost per hour from the dsr record?
 */
select w.Direct_Labor_Cost,w.valid,d.*
--select count(*)
from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
join Plex.workcenter_view w 
on d.pcn = w.PCN 
and d.workcenter_key = w.Workcenter_Key -- 14,038
where w.Direct_Labor_Cost =0 -- 5
where w.Direct_Labor_Cost is null -- 0
/*
 * How do compute the workcenter labor cost  
 */
workcenter_labor 
as 
(
	select 
	w.Direct_Labor_Cost,w.valid,
	w.Direct_Labor_Cost * d.actual_hours workcenter_labor, 
	d.*
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	--where w.Direct_Labor_Cost =0 -- 5
	--where w.Direct_Labor_Cost is null -- 0
),

/*
 * What is total daily direcect labor cost per part  
 */

with direct_labor 
as 
(
	select 
	d.pcn,d.report_date,d.part_key,
	sum(w.Direct_Labor_Cost * d.actual_hours) direct_labor -- Column id#80
	
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	--where w.Direct_Labor_Cost =0 -- 5
	--where w.Direct_Labor_Cost is null -- 0
)
select * from direct_labor 

/*
 * What is the weighted average of direct labor cost?  
 * This only needs to be calculated if there is a diff.
 */

with diff_direct_labor_cost 
as 
(
	select d.pcn,d.report_date,d.part_key, 
	min(w.Direct_Labor_Cost) min_direct_labor_cost,max(w.Direct_Labor_Cost) max_direct_labor_cost,
	max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) diff_direct_labor_cost,
	case 
	when min(w.Direct_Labor_Cost) = 0 then 1 
	else 0 
	end min_zero

	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) > 0.009
),
/*
 * How many workcenters for the same part and the same day have different labor cost per hour values?
 */
--drop view Plex.labor_cost_diff_vied
create view Plex.labor_cost_diff_view
as
with diff_direct_labor_cost 
as 
(
	select d.pcn,d.report_date,d.part_key, 
	min(w.Direct_Labor_Cost) min_direct_labor_cost,max(w.Direct_Labor_Cost) max_direct_labor_cost,
	max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) diff_direct_labor_cost,
	case 
	when min(w.Direct_Labor_Cost) = 0 then 1 
	else 0 
	end min_zero

	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) > 0.009
),
--select count(*) from diff_direct_labor_cost -- 1,399
no_diff_direct_labor_cost 
as 
(
	select d.pcn,d.report_date,d.part_key, 
	min(w.Direct_Labor_Cost) min_direct_labor_cost,max(w.Direct_Labor_Cost) max_direct_labor_cost,
	max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) diff_direct_labor_cost

	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) < 0.01
),
--select count(*) from no_diff_direct_labor_cost -- 5,033
percent_diff_direct_labor_cost
as 
(
	select d.pcn,d.report_date,d.part_key,
	min_direct_labor_cost,
	max_direct_labor_cost,
	case 
	when min_zero = 1 then 1 
	else (diff_direct_labor_cost/min_direct_labor_cost) 
	end percent_diff_direct_labor_cost 
	from diff_direct_labor_cost d
)
select *
--select count(*) 
from percent_diff_direct_labor_cost 

select *
from Plex.labor_cost_diff_view
where percent_diff_direct_labor_cost > .1 -- 1,183

select * from Plex.labor_cost_ten_percent_diff
select count(*) from no_diff_direct_labor_cost -- 5,033

select count(*)
from count_diff_direct_labor_cost -- 1,467
/*
 * How do we calculate the labor rate?
 * By taking a weighted average of labor cost per hour.
 * In this case the weights don't add to one
 * and the variable is labor cost per hour and its weight is labor hours.
 */
-- drop view view Plex.labor_rate_weighted_average 
create view Plex.labor_rate_weighted_average 
as 
/*
 * If there are differnt labor cost for a day we must
 * do a weighted average to compute the direct labor cost
 */
with diff_direct_labor_cost 
as 
(
	select d.pcn,d.report_date,d.part_key, 
	min(w.Direct_Labor_Cost) min_direct_labor_cost,max(w.Direct_Labor_Cost) max_direct_labor_cost,
	max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) diff_direct_labor_cost,
	case 
	when min(w.Direct_Labor_Cost) = 0 then 1 
	else 0 
	end min_zero

	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) > 0.009
),
--select count(*) from diff_direct_labor_cost -- 1,399

labor_sums 
as 
(

	-- sum (variable * weight) / sum(variable)
	select 
	d.pcn,d.report_date,d.part_key,
	sum(w.Direct_Labor_Cost*d.actual_hours) sum_rate_x_hours,
	sum(w.Direct_Labor_Cost) sum_rate,
	case 
	when sum(w.Direct_Labor_Cost) = 0 then 1
	else 0
	end zero_rate
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	
),
no_diff_direct_labor_cost 
as 
(
	select d.pcn,d.report_date,d.part_key, 
	min(w.Direct_Labor_Cost) min_direct_labor_cost,max(w.Direct_Labor_Cost) max_direct_labor_cost,
	max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) diff_direct_labor_cost

	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) < 0.01
),

labor_rate_weighted_average  
as 
(

	-- sum (variable * weight) / sum(variable)
	select 
	s.pcn,
	s.report_date,
	s.part_key,
	case 
	when s.zero_rate = 0 then 
	s.sum_rate_x_hours 
	/
	s.sum_rate 
	else 0
	end labor_rate_weighted_average 
	--select count(*)
	from labor_sums s
),
--select * from labor_rate_weighted_average 
labor_rate 
as 
(
	select 
	wa.pcn,
	wa.
	from labor_rate_weighted_average wa 
	left outer join diff_direct_labor_cost dl 
	on wa.pcn = dl.pcn 
	and wa.report_date = dl.report_date 
	and wa.part_key = dl.part_key 
	
)

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
--select * from Plex.daily_shift_report_daily_metrics_view
--drop view Plex.daily_shift_report_daily_metrics_view
create view Plex.daily_shift_report_daily_metrics_view
as 
with all_operation_sum 
as 
(  -- these sums are for all operations not just the final one.
	select pcn,report_date,part_key,part_no,
	revision,
	sum(parts_scrapped) parts_scrapped, -- Column ID: 10, view changes null to 0
	sum(earned_hours) earned_hours,-- view changes null to 0
	sum(actual_hours) actual_hours-- view changes null to 0
	from Plex.daily_shift_report_daily_metrics_filter_view ds 
	group by ds.pcn,ds.report_date,ds.part_key,ds.part_no,ds.revision 
	--having ds.report_date  between '2022-02-08' AND '2022-02-27' -- date range FOR TESTING ONLY
	--having part_no = 'H2GC 5K652 AB'
),
--select * 
--select count(*)
--from all_operation_sum -- 3,383
/*
 * What is total daily direcect labor cost per part  
 */
direct_labor 
as 
(
	select 
	d.pcn,d.report_date,d.part_key,
	sum(w.Direct_Labor_Cost * d.actual_hours) direct_labor -- Column id#80
	
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	group by d.pcn,d.report_date,d.part_key 
	--where w.Direct_Labor_Cost =0 -- 5
	--where w.Direct_Labor_Cost is null -- 0
),
--select * from direct_labor 
shippable_operation_only
as 
(
	select ds.*,so.operation_no shippable_operation 
	from Plex.daily_shift_report_daily_metrics_filter_view ds -- set of all shippable operation for daily shift report records,ie, workcenters with for that operation.
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
	so.part_key,so.part_no,so.revision,so.operation_no,
	sum(so.quantity_produced) quantity_produced -- Column Id: 5
	from shippable_operation_only so -- primary key for result set 
	group by so.pcn,so.report_date,so.part_name,so.part_key, so.part_no,so.revision,so.operation_no  
),
--select * 
--select count(*)
--from shippable_quantity_produced  -- 2,522
daily_shift_report_part_list 
as 
(
	select distinct pcn, part_key from Plex.daily_shift_report_daily_metrics_filter_view g --
),
-- For exception handling: issue number 41.
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
	else 41  -- Issue Key for this exception 
	end valid,
	case 
	when so.quantity_produced is null then 0 
	else so.quantity_produced  
	end volume_produced, -- COLUMN ID: 15
	ao.parts_scrapped, -- COLUMN ID: 10, view changes null to 0
	case 
	when so.quantity_produced is null then ao.parts_scrapped -- quantity_produced can be null but parts_scrapped can not 
	else so.quantity_produced + ao.parts_scrapped 
	end gross_volume_produced, -- COLUMN ID:_5
	ao.earned_hours,-- COLUMN ID: 40, view changes null to 0 --	Parts Produced (includes scrap unless setup otherwise) * (Crew Size / Selected Labor Rate)
	ao.actual_hours,-- COLUMN ID: 45, view changes null to 0
	wa.labor_rate_weighted_average labor_rate,-- Column id#75
	dl.direct_labor -- Column id#80
	from all_operation_sum ao  
	left outer join no_shippable_part_operation ns -- we do not have/know the shippable operation for some parts 
	on ao.pcn = ns.pcn 
	and ao.part_key = ns.part_key 
	left outer join shippable_quantity_produced so -- not all pcn,report_date,part_key combos have shippable parts.
	on ao.pcn=so.pcn 
	and ao.report_date = so.report_date 
	and ao.part_key = so.part_key 
	join Plex.labor_rate_weighted_average wa -- no filtering every key has a weighted average
	on ao.pcn=wa.pcn 
	and ao.report_date = wa.report_date 
	and ao.part_key = wa.part_key 
	join direct_labor dl -- no filtering every key has a direct_labor value 
	on ao.pcn=dl.pcn 
	and ao.report_date=dl.report_date 
	and ao.part_key = dl.part_key 
	
	--where so.pcn is null  -- 861
	--where so.pcn is not null  -- 2,522
	
)

select * 
--select count(*)
from daily_shift_report_sums  -- 6,432
--where valid =1


select * 
--select count(*)
from Plex.daily_shift_report_daily_metrics_view 
where pcn = 300757
where valid = 0  --4,745
where valid = 41  --12
where part_no = '51210T6N A000'  -- 1 out of 5 records have all values.  I think this is inactive. Revision 01 01 has 2 entries and 1 has values.
and report_date = '2022-02-14 00:00:00.000'
--where Part_No in ('5246','501-0994-05','51215T6N A000','51210T6N')
order by part_no 

/*
 * what is the criteria for daily shift report data to be on the 
 * daily metrics report
 */
-- drop view Plex.daily_shift_report_data_daily_metrics_criteria_view
create view Plex.daily_shift_report_data_daily_metrics_criteria_view
as 
select *
--select count(*)
from Plex.daily_shift_report_daily_metrics_view ds -- 4,757
where 
--(ds.actual_hours =0) and (ds.parts_scrapped = 0) and (ds.quantity_produced = 0)  -- 481
(ds.actual_hours !=0) -- 4,075
or (ds.parts_scrapped != 0) -- 1,654
or (ds.quantity_produced != 0)  -- 3,043

select * 
-- select count(*)
from Plex.daily_shift_report_data_daily_metrics_criteria_view -- 4,276
where valid != 0

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
