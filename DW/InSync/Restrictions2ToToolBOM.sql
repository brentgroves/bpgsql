/*
Are all of the MSC tooling items in the Plex toolling module ?
 */


select 
b.pcn,r.R_JOB,b.part_no,b.operation_no,b.operation_code,b.assembly_no,b.tool_descr,b.tool_no,r.R_ITEM 
-- select count(*) cnt
from 
(
	select * from AlbSPS.Restrictions2 r 
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
) as r  
inner join 
[Map].Tool_Part_Op m 
on r.pcn=m.PCN 
and r.r_job = m.original_process_id -- 96
left outer join Plex.part_tool_BOM b 
on r.pcn= b.pcn 
and m.part_operation_key = b.part_operation_key
and r.R_ITEM = b.tool_no 
where b.part_no = '10103355'
and r.R_ITEM is not null

order by b.pcn,b.part_no,b.operation_no,b.assembly_no,b.tool_no 

/*
How many MSC tooling items are assigned to part number '10103355'? 35
*/

select count(*) cnt
from 
(
	select * from AlbSPS.Restrictions2 r 
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
) as r
where r.R_JOB = '54485'

select 
b.pcn,r.R_JOB,b.part_no,b.operation_no,b.operation_code,b.assembly_no,b.tool_descr,b.tool_no,r.R_ITEM 
-- select count(*) cnt
from 
(
	select * from AlbSPS.Restrictions2 r 
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
) as r
inner join 
[Map].Tool_Part_Op m 
on r.pcn=m.PCN 
and r.r_job = m.original_process_id -- 96
left outer join Plex.part_tool_BOM b 
on r.pcn= b.pcn 
and m.part_operation_key = b.part_operation_key
and r.R_ITEM = b.tool_no 
where r.R_JOB = '54485'
and b.tool_no is null

where b.part_no = '10103355'
and r.R_ITEM is not null

order by b.pcn,b.part_no,b.operation_no,b.assembly_no,b.tool_no 

/*
Are all of the Plex tool_BOM items in the MSC?
*/

/*
 * Are there any t01 tooling item not in the vm or with the wrong tool_no?
 */

select * from AlbSPS.restrictions2 r 
where 
r.R_JOB = '54485'
r.R_ITEM like '%3114%'
order by r.R_ITEM 

/* 
Item_no in MSC and Plex are not in sync
find out why
*/