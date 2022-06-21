/*
123681 Southfield
295932 FruitPort
300757 Alabama
300758 Albion
306766 Edon
310507 Avilla
	*/

select distinct pcn from Plex.Part_Operation po 

select *
--select count(*) 
from Plex.Part_Operation po 
where po.PCN = 123681  -- 232 --Southfield
--where po.PCN = 295932 -- 1,828 -- FruitPort
--where po.PCN = 300757 -- 318 -- Alabama
--where po.PCN = 300758 -- 1,212 -- Albion
--where po.PCN = 306766 -- 453 -- Edon
where po.PCN = 310507 -- 105 -- Avilla

/*
What is the primary key? any of these 4 should be ok:
-- 	group by pcn,part_operation_key -- 4,148
--	group by pcn,part_key,operation_no -- 4,148
--	group by pcn,part_no_revision,operation_no  -- 4,148
--	group by pcn,part_no,revision,operation_no  -- 4,148

*/
select count(*)
from 
(
	select count(*) cnt 
	from Plex.Part_Operation po -- 4,148
--	group by pcn,part_operation_key -- 4,148
--	group by pcn,part_key,operation_no -- 4,148
--	group by pcn,part_no_revision,operation_no  -- 4,148
--	group by pcn,part_no,revision,operation_no  -- 4,148
) r 	
	
with all_ops
as 
(
	select *
	--select count(*) 
	from Plex.Part_Operation po 
	where po.PCN = 123681  -- 232 --Southfield
), 
final_ops 
( 
	select pnc,part_key,part_no,Revision,max Operation_No final_op 
	from all_ops 
	group by pcn,part_key,part_no,Revision  
)
