/*
 * Summary of Plex tooling module and MSC Vending machine for P558 6k LH Knuckles part number 10103355.
 */
/*
How many MSC tooling items are assigned to Horizontal Mill operation for part number '10103355'? 32
*/
select * from plex.ToolingModuleMetric0616B tmmb 
-- select count(*) cnt
select count(*) cnt
from 
(
	select distinct r.pcn,r.R_JOB,r.R_ITEM from AlbSPS.Restrictions2 r -- 32
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
	and r.R_ITEM not like '%[^0-9]%'
	and r.R_JOB = '54485'
	-- and r_item = '17100'  -- there are 2 entries for 17100
) as r
where r.R_JOB = '54485' -- 54485 Horizontal Mill

/*
 * How many MSC tooling items have a corresponding Plex tool number
 * If we strip the leading zeros  29 out of 32
 * I don't believe the tool list has includes the 3 global tooling items
 */

select 
-- count(*) cnt
r.pcn,r.R_JOB,r.R_ITEM, b.tool_no,b.tool_descr 
from 
(
-- select * from  AlbSPS.Restrictions2 where R_ITEM like '%CCC%'
-- SELECT * FROM Plex.part_tool_BOM ptb where tool_no like '%CCC%'
-- select * from  AlbSPS.Restrictions2 where R_job like '%CCC%'
	select distinct r.pcn,r.R_JOB,r.R_ITEM from AlbSPS.Restrictions2 r -- 32
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
	and r.R_ITEM not like '%[^0-9]%'
	and r.R_JOB = '54485'
	-- and r_item = '17100'  -- there are 2 entries for 17100

) as r
inner join 
[Map].Tool_Part_Op m 
on r.pcn=m.PCN 
and r.r_job = m.original_process_id -- 32
left outer join 
(
	select 
	distinct b.pcn,b.part_operation_key,b.tool_no,b.tool_descr --71, tool is on more than 1 assembly 
	from Plex.part_tool_BOM b 
	where tool_no not like '%[^0-9]%'
	and b.part_operation_key = 7874404
) b
on r.pcn= b.pcn 
and m.part_operation_key = b.part_operation_key
--and r.R_ITEM = b.tool_no 
and CAST(CAST(b.tool_no AS INT) AS VARCHAR(10)) = r.R_ITEM 

where r.R_JOB = '54485'
and b.tool_no is null

/*
 * How many Plex tooling items are assigned to the part number '10103355' OP 10/20 Horizontal Mill,Machine A - WIP operation? 100
 */

select count(*) cnt
from Plex.part_tool_BOM b 
where b.part_operation_key = 7874404  -- 76



/*
 * How many Plex tooling items have a corresponding entry in the MSC Vending Machine table. 29 out of 71
 */

select count(*) cnt
-- select distinct b.pcn,m.original_process_id,b.tool_no -- 42 is null
select b.pcn,m.original_process_id,
-- b.part_no,b.operation_no,b.assembly_no,b.assy_descr,
b.tool_descr,b.tool_no -- 42 is null
--into Plex.tmp_no_msc_entry
from 
(
	select 
	distinct b.pcn,b.part_operation_key,b.tool_no,b.tool_descr --71, tool is on more than 1 assembly 
	from Plex.part_tool_BOM b 
	where tool_no not like '%[^0-9]%'
	and b.part_operation_key = 7874404
) b  -- 71
inner join [Map].Tool_Part_Op m -- 71
on b.pcn=m.PCN 
and b.part_operation_key = m.part_operation_key 
left outer join
(
	select distinct r.pcn,r.R_JOB,r.R_ITEM from AlbSPS.Restrictions2 r -- 32
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
	and r.R_ITEM not like '%[^0-9]%'
	and r.R_JOB = '54485'
	-- and r_item = '17100'  -- there are 2 entries for 17100
) as r
on b.pcn=r.pcn 
and m.original_process_id = r.R_JOB 
-- and b.tool_no = r.R_ITEM 
and CAST(CAST(b.tool_no AS INT) AS VARCHAR(10)) = r.R_ITEM 


where b.part_operation_key = 7874404  -- 71
and r.R_ITEM is null  -- 42
-- and r.R_ITEM is not null  -- 29

select b.part_no,b.operation_code,b.assembly_no,b.assy_descr,b.tool_no,b.tool_descr from 
Plex.part_tool_BOM b 
where b.tool_no in 
(
select tool_no
from Plex.tmp_no_msc_entry
) 
and b.part_operation_key = 7874404  -- 71


/*
 * Of those 42 Plex tooling items that are not in the MSC vending machine is there any that should be in the Vending Machine?  
 * 
 */

select b.pcn,m.original_process_id,b.tool_no,b.tool_descr,r.R_ITEM, i.DESCR msc_descr 
from 
Plex.part_tool_BOM b 
inner join [Map].Tool_Part_Op m 
on b.pcn=m.PCN 
and b.part_operation_key = m.part_operation_key 
left outer join
(
	select distinct r.pcn,r.R_JOB,r.R_ITEM from AlbSPS.Restrictions2 r -- 34
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
	and r.R_JOB = '54485'
	-- and r_item = '17100'  -- there are 2 entries for 17100
) as r
on b.pcn=r.pcn 
and m.original_process_id = r.R_JOB 
and b.tool_no = r.R_ITEM 
left outer join AlbSPS.ItemSummary i 
on b.pcn = i.pcn 
and b.tool_no = i.ITEMNUMBER 
where b.part_operation_key = 7874404  -- 76
and r.R_ITEM is null

/*
 * Can we find these items in the SPS items table by looking at the description
 */
select i.*
from AlbSPS.ItemSummary i 
where i.DESCR like '%0905%'
-- CV50BSMC100400  -- not in there
-- ONMU 090520ANTN-M15 MK2050  -- yes 009196/9196

/*
 * Are these items in the SPS restrictions2 table under the wrong R_ITEM number?
 */
select r.*
from AlbSPS.Restrictions2 r 
where r.R_ITEM = '9196'  -- yes,

/*
 * Is 9196 also in Plex? No
 * 
*/

/*
 * If we strip off the Plex leading zeros in this query how many matches can we find? 31
 */
select b.pcn,m.original_process_id,b.tool_no,b.tool_descr,r.R_ITEM, i.DESCR msc_descr 
from 
Plex.part_tool_BOM b 
inner join [Map].Tool_Part_Op m 
on b.pcn=m.PCN 
and b.part_operation_key = m.part_operation_key 
left outer join
(
	select distinct r.pcn,r.R_JOB,r.R_ITEM from AlbSPS.Restrictions2 r -- 34
	where r.R_JOB  not LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
	and r.R_JOB = '54485'
	-- and r_item = '17100'  -- there are 2 entries for 17100
) as r
on b.pcn=r.pcn 
and m.original_process_id = r.R_JOB 
--and b.tool_no = r.R_ITEM 
and CAST(CAST(b.tool_no AS INT) AS VARCHAR(10)) = r.R_ITEM 
left outer join AlbSPS.ItemSummary i 
on b.pcn = i.pcn 
and CAST(CAST(b.tool_no AS INT) AS VARCHAR(10)) = i.ITEMNUMBER 
-- b.tool_no = i.ITEMNUMBER 
where b.part_operation_key = 7874404  -- 76
--and r.R_ITEM is null  -- 45
and r.R_ITEM is not null  -- 31


select b.tool_no,CAST(CAST(b.tool_no AS INT) AS VARCHAR(10)) trimmed from Plex.part_tool_BOM b
where b.tool_no not LIKE '%[^0-9]%'
-- CAST(CAST(@LeadingZeros AS INT) AS VARCHAR(10))
