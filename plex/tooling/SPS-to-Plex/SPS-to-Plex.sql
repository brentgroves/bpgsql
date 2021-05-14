select top 100 
*, 
i.item_no,
ic.item_category
from purchasing_v_item i 
inner join purchasing_v_item_category ic 
on i.item_category_key=ic.item_category_key
where i.item_no like '%13753'
--45206471
/*
select top 100 * from purchasing_v_item
where item_no like '%8223'

select top 100 * from purchasing_v_item_category

select top 100 * from part_v_part where part_key = 36207330
*/
