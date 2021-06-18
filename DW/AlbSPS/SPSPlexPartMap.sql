select tc.pcn,tc.JOBNUMBER,j.DESCR,tc.totalcost 
from
(
	select tl.pcn,tl.JOBNUMBER, sum(totalcost) totalcost
	from
	(
		select tl.pcn,tl.JOBNUMBER,tl.UNITCOST,tl.qty,(tl.UNITCOST*tl.qty) totalcost 
		from AlbSPS.TransactionLog tl  
		inner join AlbSPS.Jobs j 
		on tl.PCN = j.PCN 
		and tl.JOBNUMBER = j.JOBNUMBER 
	)tl 
	group by tl.pcn,tl.JOBNUMBER -- 28
) tc
inner join AlbSPS.Jobs j 
on tc.pcn=j.PCN 
and tc.jobnumber=j.JOBNUMBER 
order by tc.totalcost desc
/*
select distinct ta.pcn,ta.part_key,ta.part_operation_key 
into #distinct_part_ops_with_tool_assemblies
from Plex.part_tool_assembly ta  -- 9
*/
-- select cr.part_no,cr.name,cr.qty_due,
-- tl.operation_no,tl.operation_code,tl.customer_part_list,
select j.DESCR msc_descr,m.original_process_id,m.process_id,tl.part_operation_key,tl.part_key,tl.operation_key,cr.part_no,cr.name,cr.qty_due,
tl.operation_no,tl.operation_code,tl.customer_part_list,
case 
when ta.pcn is null then 'no'
else 'yes'
end in_plex,
case 
when j.DESCR is null then 'no'
else 'yes'
end in_MSC_VM
-- select count(*)
-- into Plex.ToolingModuleMetric
from Plex.Customer_Release_Due_WIP_Ready_Loaded cr  -- 12
inner join Plex.part_op_with_tool_list tl
on cr.pcn = tl.pcn 
and cr.part_key = tl.part_key -- 22
left outer join #distinct_part_ops_with_tool_assemblies ta 
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
