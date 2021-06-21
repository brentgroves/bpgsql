select * from ssis.ScriptComplete
-- update ssis.ScriptComplete set done = 0

-- truncate table Plex.part_tool_BOM
select * from Plex.part_tool_BOM where part_no = '10103355'

-- truncate table AlbSPS.ItemSummary
select * from AlbSPS.ItemSummary  -- 158
-- truncate table AlbSPS.Jobs
select * from AlbSPS.Jobs j -- 37

-- truncate table AlbSPS.TransactionLog
select * from AlbSPS.TransactionLog tl -- 1617
select count(*) from AlbSPS.TransactionLog tl -- 1733,1623,

select * from AlbSPS.Import i 
/*
update albsps.import
set LastSuccess='2021-04-27 00:00:00'
where id=1
 */

-- truncate table Plex.Customer_Release_Due_WIP_Ready_Loaded
select * from Plex.Customer_Release_Due_WIP_Ready_Loaded  -- 12

-- truncate table Plex.part_op_with_tool_list
-- select count(*) from Plex.part_op_with_tool_list  -- 300
select * from Plex.part_op_with_tool_list

-- truncate table Plex.part_tool_assembly
-- select * from Plex.part_tool_assembly  -- 100
select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta  -- 9

select * from Plex.ToolingModuleMetric0616B tmm 


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
into Plex.ToolingModuleMetric0616B
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
inner join Map.Tool_Part_Op m 
on tl.pcn = m.pcn
and tl.part_operation_key = m.part_operation_key
left outer join
(
 select j.PCN,j.JOBNUMBER,j.DESCR from AlbSPS.Jobs j 
 where left(j.JOBNUMBER,1) like '[0-9]'
) j
on m.pcn=j.PCN 
and m.original_process_id = j.JOBNUMBER