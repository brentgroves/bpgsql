/*
123681 Southfield
295932 FruitPort
300757 Alabama
300758 Albion
306766 Edon
310507 Avilla
	*/
select count(*) cnt 
from 
(
	select distinct part_key from Plex.Part_Operation po 
) c  -- 1,663 

select count(*) from part_v_part_e p
where part_status in ('Production')  -- 1169
--where part_status in ('Service')  -- 363

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
	
--drop view Plex.part_final_production_operation_view 
create view Plex.part_final_production_operation_view 
as 
with all_ops
as 
(
	select *
	--select count(*) 
	from Plex.Part_Operation po 
	--where po.PCN = 123681  -- 232 --Southfield
	where po.Part_Op_Type =  'Production'
), 
final_ops 
as 
( 
	select pcn,part_key,part_no,Revision,max(Operation_No) final_op 
	from all_ops 
	group by pcn,part_key,part_no,Revision  
)
select * from final_ops 
