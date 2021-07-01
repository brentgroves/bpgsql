select * from ssis.ScriptComplete
-- update ssis.ScriptComplete set done = 0

select * from Plex.purchasing_item_inv_cube  -- 19

-- truncate table Plex.purchasing_item_inventory
select count(*) cnt from  Plex.purchasing_item_inventory  -- 6038
select * from  Plex.purchasing_item_inventory
-- truncate table Plex.purchasing_item_usage
select count(*) cnt from Plex.purchasing_item_usage  -- 883/878
select * from Plex.purchasing_item_usage
-- truncate table Plex.purchasing_item_summary
select count(*) from Plex.purchasing_item_summary  -- 500
select * from Plex.purchasing_item_summary

-- truncate table Plex.part_tool_BOM
select count(*) from Plex.part_tool_BOM -- 403
select count(*) from Plex.part_tool_BOM where part_no = '10103355'  -- 100 
select * from Plex.part_tool_BOM where part_no = '10103355'

-- truncate table AlbSPS.ItemSummary
select * from AlbSPS.ItemSummary  -- 158
-- truncate table AlbSPS.Jobs
select * from AlbSPS.Jobs j -- 40/37

-- truncate table AlbSPS.TransactionLog
select * from AlbSPS.TransactionLog tl -- 1617
select count(*) from AlbSPS.TransactionLog tl -- 2112,1900,1733,1623,
/*
 select *
 into AlbSPS.TransactionLogNO
 from AlbSPS.TransactionLog tl 
 where tl.JOBNUMBER not like '%[A-Z]%'
*/
select * from AlbSPS.Import i 
/*
update albsps.import
set LastSuccess='2021-04-27 00:00:00'
where id=1
 */

-- truncate table Plex.Customer_Release_Due_WIP_Ready_Loaded

-- truncate table Plex.part_op_with_tool_list
-- select count(*) from Plex.part_op_with_tool_list  -- 300
select * from Plex.part_op_with_tool_list

-- truncate table Plex.part_tool_assembly
-- select * from Plex.part_tool_assembly  -- 126
select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta  -- 11/9

select * from Plex.ToolingModuleMetric0616B tmm 


/*
 * Create new Plex.ToolingModuleMetric after every script run
 * Automate this
 */
-- Step 1: get rid of jobnumbers with alpha characters this can't be done from a subquery
-- Make this into a script
-- drop table AlbSPS.JobsNO
/*
 select *
 into AlbSPS.JobsNO
 from AlbSPS.Jobs 
 where JOBNUMBER not like '%[A-Z]%'
*/ 
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
--into Plex.ToolingModuleMetric0629
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