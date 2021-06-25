/*
START: Work on Plant 6 first should be the easist since mostly knuckles.
*/
/*
Working Set
Set of valid item_supplier and item_supplier_price records
*/
  select s.pcn,s.item_key,s.supplier_no,s.sort_order,s.resource_id,p.price_key,p.unit_price 
  into #isp
  from purchasing_v_Item_Supplier_e s
  inner join purchasing_v_Item_Supplier_Price_e p -- 1 to many
  on s.pcn=p.pcn
  and s.item_key=p.item_key
  and s.supplier_no=p.supplier_no
  inner join purchasing_v_item_e i
  on s.pcn=i.plexus_customer_no
  and s.item_key=i.item_key
  where p.pcn = @PCN
  and p.unit_price != 0
  and i.active = 1
  and i.item_no not like '%[A-Z-]%'  
  -- and s.item_key=1011208  --item no 14457


  -- Find min sort_order that for records that have a unit_price
  select s.pcn,s.item_key,min(s.sort_order) sort_order
  --count(*) 
  into #sort_order
  from #isp s 
  group by s.pcn,s.item_key
  
  -- Filter set to include supplier with the lowest sort_order
  select s.pcn,s.item_key,s.supplier_no,s.sort_order,s.resource_id,s.price_key,s.unit_price 
  into #isp_sort_order
  from #isp s
  inner join #sort_order o
  on s.pcn=o.pcn
  and s.item_key=o.item_key
  and s.sort_order=o.sort_order

  -- set of lowest sort_order and max resource_id (newest)
  select s.pcn,s.item_key,max(s.resource_id) resource_id
  into #isp_so_min_id_max
  from #isp_sort_order s
  group by s.pcn,s.item_key

  -- Pick a price_key from min sort_order and max resource_id set; price_key is an identity key so this should be the most recent record
  select s.pcn,s.item_key,s.resource_id,max(s.price_key) price_key 
  into #supplier_price_record 
  from #isp_so_min_id_max m
  inner join #isp s
  on m.pcn = s.pcn
  and m.item_key=s.item_key
  and m.resource_id=s.resource_id
  group by s.pcn,s.item_key,s.resource_id

  -- Item supplier price records with the resource_id we want
  select s.pcn,s.item_key,s.supplier_no,s.sort_order,s.resource_id,s.price_key,s.unit_price 
  into #supplier_price
  from #supplier_price_record p
  inner join #isp s
  on p.pcn = s.pcn
  and p.item_key=s.item_key
  and p.resource_id=s.resource_id 
  and p.price_key = s.price_key


/*
Do we have at most 1 record for each pcn,item_key
*/

select count(*) cnt
from #supplier_price p

select count(*) cnt
from
(
  select distinct p.pcn,p.item_key
  from #supplier_price p
)s

