--drop table Plex.Customer_Release_Due_WIP_Ready_Loaded
/*
 * 
truncate table Plex.Customer_Release_Due_WIP_Ready_Loaded
create table Plex.Customer_Release_Due_WIP_Ready_Loaded
(
ID int,
pcn int,
building_key int,
building_code varchar(50),
part_key int,
part_no varchar(100),
name varchar(100),
qty_due int,
qty_shipped int,
qty_wip int,
qty_ready int,
qty_loaded int,
qty_ready_or_loaded int
)
*/

select * from Plex.Customer_Release_Due_WIP_Ready_Loaded cr
order by cr.qty_due - cr.qty_ready_or_loaded desc

select * from Plex.part_tool_assembly

/*  This query gives the same part operation result as 
the disinct pcn,part_operation_key clause

select distinct ta.pcn,ta.part_key,ta.part_operation_key 
--into #distinct_part_ops_with_tool_assemblies
from Plex.part_tool_assembly ta  -- 9
*/
select distinct ta.pcn,ta.part_operation_key 
into #distinct_part_ops_with_tool_assemblies
from Plex.part_tool_assembly ta  -- 9

select cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
case 
when ta.pcn is null then 'no'
else 'yes'
end in_plex
-- select count(*)
from Plex.Customer_Release_Due_WIP_Ready_Loaded cr  -- 12
inner join Plex.part_op_with_tool_list tl
on cr.pcn = tl.pcn 
and cr.part_key = tl.part_key -- 22
left outer join #distinct_part_ops_with_tool_assemblies ta 
on tl.pcn=ta.pcn
and tl.part_operation_key = ta.part_operation_key  -- 
-- where ta.pcn is null  -- 18
order by cr.qty_due - cr.qty_ready_or_loaded desc
-- 10103344,10103351,10103353,10103355,2007699
select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta


*/
