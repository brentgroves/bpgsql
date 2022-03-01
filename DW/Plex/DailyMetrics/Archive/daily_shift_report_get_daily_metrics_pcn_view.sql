select * from Plex.daily_shift_report_get_daily_metrics_view

select * from Plex.daily_shift_report_get_daily_metrics_pcn_view
--drop view Plex.daily_shift_report_get_daily_metrics_pcn_view
create view Plex.daily_shift_report_get_daily_metrics_pcn_view
as 
WITH max_operation_no
as 
(
	select pcn,report_date,part_no,
	revision,
	max(operation_no) max_operation_no
	from Plex.daily_shift_report_view g 
	group by g.pcn,g.report_date,g.part_no,g.revision  --182
	--having part_no = 'H2GC 5K652 AB'
	
),
part_workcenter
as
(
	select m.max_operation_no,g.* 
	from max_operation_no m 
	join Plex.daily_shift_report_view g -- add all workcenters for that operation
	on m.pcn = g.pcn
	and m.report_date = g.report_date 
	and m.part_no = g.part_no 
	and m.revision = g.revision 
	and m.max_operation_no = g.operation_no 
),
--select count(*) from part_workcenter  -- 214
--select pcn,report_date,part_no,revision,operation_no,count(*) from part_workcenter group by pcn,report_date,part_no,revision,operation_no -- 182
part_last_operation
as 
( 	-- this will be the primary key for the result set 
	select pcn,report_date,part_no,revision, max_operation_no operation_no 
	from part_workcenter  
	group by pcn,report_date,part_no,revision,max_operation_no  
	-- needed because there are multiple workcenters per part operation_no 
),
--select * from part_last_operation  -- 182
-- this matches with the max_operation_no view above which is grouped by pcn,part_no, and part_revision.
--Are these all the parts? yes.
last_op_quantity_produced 
as
(
	select o.pcn,o.report_date,g.part_name,
	o.part_no,o.revision,o.operation_no,sum(g.quantity_produced) quantity_produced 
	from part_last_operation o -- primary key for result set 
	join Plex.daily_shift_report_view g -- add all the workcenters 
	on o.pcn = g.pcn
	and o.report_date = g.report_date 
	and o.part_no = g.part_no 
	and o.revision = g.revision 
	and o.operation_no = g.operation_no 
	group by o.pcn,o.report_date,g.part_name,o.part_no,o.revision,o.operation_no  
),
--select * from last_op_parts_produced -- 182 
part_revision_sums 
as 
(  -- these sums are for all operations not just the final one.
	select pcn,report_date,part_no,
	revision,
	sum(parts_scrapped) parts_scrapped,
	sum(earned_hours) earned_hours,
	sum(actual_hours) actual_hours
	from Plex.daily_shift_report_view g 
	group by g.pcn,g.report_date,g.part_no,g.revision  
	--having part_no = 'H2GC 5K652 AB'
),
--select * from part_revision_sums -- 182
produced_plus_scrapped 
as 
(
	-- calcs involving last op sums 
	select pp.pcn,pp.report_date,pp.part_no,pp.revision, 
	pp.quantity_produced + ps.parts_scrapped produced_plus_scrapped 
	from last_op_quantity_produced pp 
	join part_revision_sums ps 
	on pp.pcn=ps.pcn 
	and pp.report_date = ps.report_date 
	and pp.part_no = ps.part_no 
	and pp.revision = ps.revision
),
--select * from produced_minus_scrapped  -- 182
daily_shift_report_get_daily_metrics
as 
( 
	select pp.*,ps.parts_scrapped,ms.produced_plus_scrapped,ps.earned_hours,ps.actual_hours  
	from last_op_quantity_produced pp 
	join part_revision_sums ps 
	on pp.pcn=ps.pcn
	and pp.report_date = ps.report_date 
	and pp.part_no = ps.part_no 
	and pp.revision = ps.revision
	join produced_plus_scrapped ms 
	on pp.pcn=ms.pcn 
	and pp.report_date = ms.report_date 
	and pp.part_no = ms.part_no 
	and pp.revision = ms.revision
) 
select * from daily_shift_report_get_daily_metrics  -- 182
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
