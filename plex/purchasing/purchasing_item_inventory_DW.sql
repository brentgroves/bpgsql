-- https://www.youtube.com/watch?v=iiNDq2VrZPY
-- https://www.mssqltips.com/sqlservertip/4518/dynamically-build-a-multi-or-with-like-query-for-sql-server/

-- select 'Plant ?' area,l.location,'"' + i.item_no + '"' item_no,cast(il.quantity as int) quantity 
select 
row_number() over(order by l.plexus_customer_no,l.location) id,
l.plexus_customer_no pcn, i.item_key,item_no,l.location,cast(il.quantity as int) quantity 
--select count(*) cnt  -- 6039
from common_v_location_e l
left outer join purchasing_v_item_location_e il
on l.plexus_customer_no = il.plexus_customer_no
and l.location = il.location
left outer join purchasing_v_item_e i 
on il.plexus_customer_no = i.plexus_customer_no
and il.item_key= i.item_key
where 
l.plexus_customer_no = @PCN
and i.item_key is not null
and i.active = 1
and l.location != '01-002A01'
and i.item_no not like 'BE%'

/*
create table Plex.purchasing_item_inventory
(
  id int,
  item_key int,
  item_no varchar(50),
  location varchar(50),
  quantity int
)
*/
/*
Add 3 sets to DW
1. purchaseing_item_summary_DW
2. purchasing_item_usage_DW
3. purchasing_item_inventory_DW
*/