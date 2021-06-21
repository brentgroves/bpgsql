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
/*
select * from Plex.Customer_Release_Due_WIP_Ready_Loaded cr
order by cr.qty_due - cr.qty_ready_or_loaded desc

select * from Plex.part_tool_assembly
*/
/*  This query gives the same part operation result as 
the disinct pcn,part_operation_key clause

select distinct ta.pcn,ta.part_key,ta.part_operation_key 
--into #distinct_part_ops_with_tool_assemblies
from Plex.part_tool_assembly ta  -- 9
*/
/*
select distinct ta.pcn,ta.part_key,ta.part_operation_key 
into #distinct_part_ops_with_tool_assemblies
from Plex.part_tool_assembly ta  -- 9
*/

SELECT msc_descr, part_no, name, qty_due, operation_no, operation_code, customer_part_list, in_plex, in_MSC_VM
FROM myDW.Plex.ToolingModuleMetric0616B;
select * from Plex.Customer_Release_Due_WIP_Ready_Loaded cr

select j.DESCR msc_descr,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
/*
select j.DESCR msc_descr,m.original_process_id,m.process_id,tl.part_operation_key,tl.part_key,tl.operation_key,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
*/
case 
when ta.pcn is null then 'no'
else 'yes'
end in_tooling_module,
case 
when j.DESCR is null then 'no'
else 'yes'
end in_MSC_VM
-- select count(*)
-- SELECT m.original_process_id
-- into Plex.ToolingModuleMetric
from Plex.Customer_Release_Due_WIP_Ready_Loaded cr  -- 12
-- select * from Plex.part_op_with_tool_list tl
-- THESE PART OPS SHOULD HAVE TOOL LISTS
inner join Plex.part_op_with_tool_list tl
on cr.pcn = tl.pcn 
and cr.part_key = tl.part_key -- 22
left outer join 
(
-- THIS SHOWS THE TOOL ASSEMBLIES IN THE TOOL MODULE.
-- SINCE THERE IS NO ACTUAL RECORD FOR SPECIFIC TOOL LISTS WE MUST
-- USE THIS TABLE TO VERIFY WE HAVE AT LEAST SOME TOOL ASSEMBLIES
-- IN THE TOOLING MODULE FOR EVERY PRODUCTION PART_OPERATION THAT WE
-- HAVE CUSTOMER RELEASES FOR.  THIS DOES NOT MEAN THAT WE HAVE 
-- ALL OF THE ASSEMBLIES THAT WE SHOULD HAVE.
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
 select j.PCN,
 -- don't know why we can't just use the where filter.
 -- but if we do we get a conversion error 
 case 
 when j.JOBNUMBER not LIKE '%[^0-9]%' then j.JOBNUMBER 
 else 99999
 end jobnumber,
 j.DESCR 
 from AlbSPS.Jobs j 
	where j.JOBNUMBER  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
) j
on m.pcn=j.PCN 
and m.original_process_id = j.JOBNUMBER 

--

--where ta.pcn is null  -- 18
-- where cr.part_no = '10103353' and operation_code = 'Machine A - WIP' 
order by cr.qty_due - cr.qty_ready_or_loaded desc
-- 10103344,10103351,10103353,10103355,2007699
-- select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta