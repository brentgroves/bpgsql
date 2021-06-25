-- select  from part_v_tool_e 
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
  where p.pcn = @PCN
  and p.unit_price != 0
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
  select s.pcn,s.item_key,s.resource_id,max(s.price_key) price_key -- (newest?)
  into #supplier_price_record 
  from #isp_so_min_id_max m
  inner join #isp s
  on m.pcn = s.pcn
  and m.item_key=s.item_key
  and m.resource_id=s.resource_id
  group by s.pcn,s.item_key,s.resource_id

  -- Item supplier price records with the resource_id we want
  -- add fields we want to see in DW
select r.pcn,r.item_key,
t.tool_key,
i.item_no tool_no,
CAST(CAST(i.item_no AS INT) AS VARCHAR(50)) trim,
--r.resource_id,r.price_key,
t.revision, s.unit_price,t.description,tt.tool_type_code,t.storage_location
--s.sort_order,s.resource_id,p.price_key,p.unit_price 
into #tool_summary
from #supplier_price_record r 
inner join #isp s
on r.pcn=s.pcn
and r.item_key=s.item_key
and r.resource_id=s.resource_id -- unique supplier identifier  
and r.price_key=s.price_key  -- identity column, unique item_supplier_price record
-- filter item_no with alpha characters
inner join 
(
  select i.plexus_customer_no pcn,i.item_key,i.item_no from purchasing_v_item_e i
  where i.plexus_customer_no = @PCN
  and i.item_no not like '%[A-Z-]%'  --17558
) i
on s.pcn=i.pcn
and s.item_key=i.item_key
inner join part_v_tool_e t
on i.pcn=t.plexus_customer_no 
and i.item_no=t.tool_no
inner join part_v_tool_type_e tt
on t.plexus_customer_no=tt.plexus_customer_no 
and t.tool_type_key=tt.tool_type_key

-- select count(*) from part_v_tool_e t where t.plexus_customer_no = 300758  -- 723
-- select * from part_v_tool_type
select 
t.pcn,
t.item_key,
t.tool_key,
t.tool_no,
t.trim,
t.revision,
t.tool_type_code,
t.description,
t.unit_price,
t.storage_location
--Revision,Description,Tool_Type,Storage_Location,r.price
from #tool_summary t


  

  

/*
Do we have at most 1 record for each pcn,item_key: YES, 21973/21941 with filter
*/
select count(*) cnt
from #tool_summary t

select count(*) cnt
from
(
  select distinct t.pcn,t.item_key
  from #tool_summary t
)s
  



