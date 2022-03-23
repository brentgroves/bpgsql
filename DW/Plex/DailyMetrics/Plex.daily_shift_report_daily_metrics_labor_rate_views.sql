/*
 * Do we have a workcenter_key for every daily shift report record so that we locate the workcenter labor cost per hour? yes
 */
select workcenter_key,part_key,operation_no  
--select count(*)
from Plex.daily_shift_report_daily_metrics_filter_view  -- 14,038
order by workcenter_key desc
where workcenter_key is null  -- 0 

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
-- select count(*)
from Plex.labor_cost_diff_view
where percent_diff_direct_labor_cost > .1 -- 1,214

-- drop view Plex.daily_shift_report_daily_metrics_labor_rate_view 
create view Plex.daily_shift_report_daily_metrics_labor_rate_view 
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
	end min_zero,
	count(distinct nl.workcenter_key) no_labor_rate_workcenter_count -- counts non null values
	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	left outer join Plex.daily_metrics_workcenter_no_labor_rate nl -- We only use the preferred workcenter in the calculation.
	on d.pcn=nl.pcn 
	and d.workcenter_key = nl.workcenter_key 

	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) > 0.009
),
--select count(*) from diff_direct_labor_cost -- 1,434
--where no_labor_rate_workcenter_count > 0  -- 5
no_diff_direct_labor_cost 
as 
(
	select d.pcn,d.report_date,d.part_key,
	max(w.Workcenter_Key) preferred_workcenter_key, -- pick a workcenter to get the direct_labor_cost.
	min(w.Direct_Labor_Cost) min_direct_labor_cost,max(w.Direct_Labor_Cost) max_direct_labor_cost,
	max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) diff_direct_labor_cost,
	count(distinct nl.workcenter_key) no_labor_rate_workcenter_count -- counts non null values

	--count(distinct w.Direct_Labor_Cost) count_diff_direct_labor_cost
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d -- 14,038
	join Plex.workcenter_view w 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key -- 14,038
	left outer join Plex.daily_metrics_workcenter_no_labor_rate nl -- We only use the preferred workcenter in the calculation.
	on d.pcn=nl.pcn 
	and d.workcenter_key = nl.workcenter_key 
	group by d.pcn,d.report_date,d.part_key 
	having max(w.Direct_Labor_Cost) - min(w.Direct_Labor_Cost) < 0.01
),
--select count(*) from no_diff_direct_labor_cost -- 5,167
--where no_labor_rate_workcenter_count > 0  -- 0
/*
 * If there are differnt part labor cost for a day we must
 * do a weighted average to compute the direct labor cost
 */
weighted_average_sums 
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
	end zero_rate,
	case 
	when max(f.no_labor_rate_workcenter_count) > 0 then 50 
	else 0 
	end valid
	
	--select count(*)
	from Plex.daily_shift_report_daily_metrics_filter_view d 
	join diff_direct_labor_cost f -- filter only workceter with different labor cost per hour
	on d.pcn=f.pcn
	and d.report_date=f.report_date
	and d.part_key=f.part_key 
	join Plex.workcenter_view w 
	--d.pcn,d.report_date,d.part_key, 
	on d.pcn = w.PCN 
	and d.workcenter_key = w.Workcenter_Key 
	group by d.pcn,d.report_date,d.part_key 
	
),
--select count(*) from weighted_average_sums -- 1,434
percent_diff_direct_labor_cost
as 
(	
	select pcn,report_date,part_key,51 valid 
	from Plex.labor_cost_diff_view
	where percent_diff_direct_labor_cost > .1 -- 1,214
),
--select count(*) from percent_diff_direct_labor_cost --1,214
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
	end labor_rate,
	case 
	when s.valid > 0 then s.valid 
	when pd.valid > 0 then pd.valid 
	else 0
	end valid 
	--select count(*)
	from weighted_average_sums s
	left outer join percent_diff_direct_labor_cost pd 
	on s.pcn=pd.pcn 
	and s.report_date = pd.report_date 
	and s.part_key = pd.part_key 

),
--select count(*) from labor_rate_weighted_average -- 1,434
--where valid = 51 -- 1,209
--where valid = 50 -- 5
/*
 * If there are not any part labor cost differences for a day 
 * we can use the preferred workcenter to identify the labor rate.
 */
labor_rate_preferred_workcenter 
as 
(
	select 
	d.pcn,
	d.report_date,
	d.part_key,
	w.Direct_Labor_Cost labor_rate,
	case 
	when d.no_labor_rate_workcenter_count > 0 then 50 
	else 0 
	end valid
	--select count(*)
	from no_diff_direct_labor_cost d
	join Plex.workcenter_view w 
	--d.pcn,d.report_date,d.part_key, 
	on d.pcn = w.PCN 
	and d.preferred_workcenter_key = w.Workcenter_Key 
)
--select count(*) from labor_rate_preferred_workcenter -- 5,167
--where valid = 50 --0
select * from labor_rate_preferred_workcenter
union 
select * from labor_rate_weighted_average 

select labor_rate 
--select count(*)
from Plex.daily_shift_report_daily_metrics_labor_rate_view  -- 5,167+1,434=6,601
--where valid = 51  -- 1,209
where valid = 50  -- 5
