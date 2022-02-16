-- select * from Plex.daily_shift_report_get_aggregate_pcn_view
-- drop view Plex.daily_shift_report_get_aggregate_pcn_view
create view Plex.daily_shift_report_get_aggregate_pcn_view
as 
select pcn,report_date,
5 id, sum(produced_plus_scrapped) total  -- Gross Volumen
-- The Fruitport standard says you can use the parts_produced column of the daily_shift_report_get web service
-- but in the Albion PCN parts_produced equals the quantity_produced so this total must be calculated
-- as sum(quantity_produced) + sum(parts_scrapped). 
--select count(*) 
from Plex.daily_shift_report_get_daily_metrics_pcn_view  -- 86
group by pcn,report_date 
union 
select pcn,report_date,
10 id, sum(parts_scrapped) total 
--select count(*) 
from Plex.daily_shift_report_get_daily_metrics_pcn_view  -- 86
group by pcn,report_date 
union 
select pcn,report_date,
15 id, sum(quantity_produced) total 
--select count(*) 
from Plex.daily_shift_report_get_daily_metrics_pcn_view  
group by pcn,report_date 
union 
select pcn,report_date,
40 id, sum(earned_hours) total 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,report_date 
union 
select pcn,report_date,
45 id, sum(actual_hours) total 
--select count(*) 
from Plex.daily_shift_report_get_view  -- 86
group by pcn,report_date 

select * 
from Plex.daily_shift_report_get
where parts_produced != quantity_produced 
select * 
from Plex.daily_shift_report_get_view
where parts_produced != quantity_produced 
--where operation_no is null -- 0
select *
--select count(*)
--select distinct part_no, part_revision 
from Plex.daily_shift_report_get  -- 86
where part_no ='10103353'
where part_no = 'H2GC 5K652 AB'
