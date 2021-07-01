-- create schema Cubes
/*
 * Plex.ToolingCube
 */
create table tooling_cube
(
	id int AUTO_INCREMENT,
	rundate datetime,
)

-- select @LastImportTransactionLog = LastSuccess from myDW.AlbSPS.Import where id = 1
select 
DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0) run_date,
convert(varchar,getdate(),1) str_run_date,
j.DESCR msc_descr,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
/*
select j.DESCR msc_descr,m.original_process_id,m.process_id,tl.part_operation_key,tl.part_key,tl.operation_key,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
*/
case 
when ta.pcn is null then 0
else ta.tool_assembly_cnt
end tool_assembly_cnt,
case 
when tb.pcn is null then 0
else tb.tooling_item_cnt
end tooling_item_cnt,
case 
when j.DESCR is null then 'no'
else 'yes'
end in_MSC_VM
-- drop table Plex.ToolingModuleMetric0624A
-- select * from Plex.ToolingModuleMetric0629
--into Cubes.tooling_cube
-- select count(*)
--select * from Plex.Customer_Release_Due_WIP_Ready_Loaded cr  -- 12
from Plex.Customer_Release_Due_WIP_Ready_Loaded cr  -- 12
inner join Plex.part_op_with_tool_list tl
on cr.pcn = tl.pcn 
and cr.part_key = tl.part_key -- 21
-- select * from Plex.part_tool_BOM ptb 
-- select distinct b.pcn,b.part_key,b.part_operation_key from Plex.part_tool_BOM b -- 10
-- select b.pcn,b.part_key,b.part_operation_key, count(*) tooling_item_cnt from Plex.part_tool_BOM b group by b.pcn,b.part_key,b.part_operation_key  -- 10
left outer join 
(
	select ta.pcn,ta.part_key,ta.part_operation_key,count(*) tool_assembly_cnt from Plex.part_tool_assembly ta group by ta.pcn,ta.part_key,ta.part_operation_key  -- 11
	-- select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta  -- 11
)ta
on tl.pcn=ta.pcn
and tl.part_operation_key = ta.part_operation_key  --
left outer join 
(
	select b.pcn,b.part_key,b.part_operation_key, count(*) tooling_item_cnt from Plex.part_tool_BOM b group by b.pcn,b.part_key,b.part_operation_key  -- 10
)tb
on ta.pcn=tb.pcn
and ta.part_operation_key = tb.part_operation_key  --
inner join Maps.Tool_Part_Op m 
on tl.pcn = m.pcn
and tl.part_operation_key = m.part_operation_key
left outer join AlbSPS.JobsNO j 
on m.pcn=j.PCN 
and m.original_process_id = j.JOBNUMBER  -- 21