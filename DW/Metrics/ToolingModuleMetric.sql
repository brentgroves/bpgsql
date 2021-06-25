/*
 * Create new Plex.ToolingModuleMetric after every script run
 * Automate this
 */
-- Step 1: get rid of jobnumbers with alpha characters this can't be done from a subquery
-- Make this into a script
-- drop table AlbSPS.JobsWithNumbersOnly
/* 
select *
 into AlbSPS.JobsWithNumbersOnly
 from AlbSPS.Jobs 
 where JOBNUMBER not like '%[A-Z]%'
*/ 
select j.DESCR msc_descr,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
/*
select j.DESCR msc_descr,m.original_process_id,m.process_id,tl.part_operation_key,tl.part_key,tl.operation_key,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
*/
case 
when ta.pcn is null then 'no'
else 'yes'
end in_plex,
case 
when j.DESCR is null then 'no'
else 'yes'
end in_MSC_VM
-- drop table Plex.ToolingModuleMetric0624A
-- select * from Plex.ToolingModuleMetric0624A
--into Plex.ToolingModuleMetric0624A
-- select count(*)
from Plex.Customer_Release_Due_WIP_Ready_Loaded cr  -- 12
inner join Plex.part_op_with_tool_list tl
on cr.pcn = tl.pcn 
and cr.part_key = tl.part_key -- 22
left outer join 
(
	select distinct ta.pcn,ta.part_key,ta.part_operation_key 
	from Plex.part_tool_assembly ta  -- 9
-- #distinct_part_ops_with_tool_assemblies ta 
)ta
on tl.pcn=ta.pcn
and tl.part_operation_key = ta.part_operation_key  --
inner join Maps.Tool_Part_Op m 
on tl.pcn = m.pcn
and tl.part_operation_key = m.part_operation_key
left outer join AlbSPS.JobsWithNumbersOnly j 
on m.pcn=j.PCN 
and m.original_process_id = j.JOBNUMBER