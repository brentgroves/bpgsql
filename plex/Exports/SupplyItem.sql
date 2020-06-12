
/*
 * plxSupplyItem 
 * SUPPLY ITEM UPLOAD
 * Ctrl-m supply list screen
 * 
 *  This set is used for the plex supply item upload.
 * Template: ~/src/sql/templates/supply_item_template.csv
 * 
 * Field List:
   1. Item_No (Required)
   2. Brief_Description
   3. Description
   4. Note
   5. Item_Type (Required, must already exist)
   6. Item_Group (Required, must already exist)
   7. Item_Category (Required, must already exist)
   8. Item_Priority  (Required, must already exist)
   9. Customer_Unit_Price (If specified,must be a number)
   10. Average_Cost (If specified,must be a number)
   11. Inventory_Unit  (If specified, it must exist)
   12. Min_Quantity (If specified, must be a number)
   13. Max_Quantity (If specified, must be a number)
   14. Tax_Code (If specified, it must exist)
   15. Account_No (If specified, it must exist)
   16. Manufacturer  -- THIS HAS TO EXIST IN THE COMMON_V_MANUFACTURER TABLE
   17. Manf_Item_No (50 character limit)
   18. Drawing_No
   19. Item_Quantity  (If specified, must be a number and have a location)
   20. Location (If specified, it must exist)
   21. Supplier_Code (If specified, it must exist. If it is not, Supplier data is ignored)
   22. Supplier_Part_No
   23. Supplier_Std_Purch_Qty (If specified, must be a number)
   24. Currency (Required, must be a valid currency code per the currency table)
   25. Supplier_Std_Unit_Price (If specified, must be a number)
   26. Supplier_Purchase_Unit (If specified, it must exist)
   27. Supplier_Unit_Conversion (If specified, it must be a number.  Recommended greater than 0 as this affects extended price values)
   28. Supplier_Lead_Time (If specified, it must be a number)
   29. Update_When_Received (must be either Y for yes, or N or no)
   30. Manufacturer_Item_Revision (max 8 characters)
   31. Country_Of_Origin (if specified must exist)
   32. Commodity_Code (if specified must exist)
   33. Harmonized_Tariff_Code (if specified must exist)
   34. Cube_Length (If specified, it must be a number)
   35. Cube_Width (If specified, it must be a number)
   36. Cube_Height (If specified, it must be a number)
   37. Cube_Unit (if specified must exist)
 --select manufacturer from purchasing_v_item where manufacturer is not null  --5
 --select * from common_v_manufacturer  --285
 -- select manf_item_no from purchasing_v_item where manf_item_no is not null
 -- select top 100 item_quantity from purchasing_v_item
select * from purchasing_v_manufacturer
WITH Results_CTE AS
(
SELECT item_no,manufacturer, 
ROW_NUMBER() OVER (ORDER BY item_no) AS RowNum
FROM purchasing_v_item 
--where manufacturer is not null and item_no like 'BE%'
where item_no like 'BE%'  and manufacturer is not null
)
SELECT *
FROM Results_CTE
WHERE RowNum >= 1
AND RowNum < 100

START HERE
   26. Supplier_Purchase_Unit (If specified, it must exist)
   27. Supplier_Unit_Conversion (If specified, it must be a number.  Recommended greater than 0 as this affects extended price values)
   28. Supplier_Lead_Time (If specified, it must be a number)
*/



--select count(*) from ( --16995
--select count(*) from ( --27673
 


create table #PrimaryKey
(
  item_key int,
  item_no varchar (50)
)

insert into #PrimaryKey (item_key,item_no)
(
  select 
  item_key,
  item_no 
  from purchasing_v_item i
  where i.active = 1
)

create table #ItemSupplierPriceKey
(
  item_key int,
  item_no varchar (50),
  supplier_no int,
  price_key int,
  Purchase_Quantity decimal (19,2),
  Unit_Price decimal (19,6),
  Lead_Time decimal (9,2),
  Unit_Key int
)

insert into #ItemSupplierPriceKey(item_key,item_no,supplier_no,price_key,purchase_quantity,unit_price,lead_time,unit_key)
(
  select 
  sp.item_key,i.item_no,sp.supplier_no,sp.price_key,sp.purchase_quantity,sp.unit_price,sp.lead_time,sp.unit_key
  from
  (
  
    select 
    s4.item_key,
    s4.supplier_no,
    s4.unit_price,
    max(s4.price_key) price_key -- pick at random, these probably have different unit_keys
    from
    (
    --select count(*) from (  --27674  
      select 
      s3.item_key,
      s3.supplier_no,
      s3.unit_price,
      sp.price_key
      from
      (
      --select count(*) from (  --27673  
        select
        s2.item_key,
        max(s2.supplier_no) supplier_no,  -- pick a supplier at random since they all have the same unit_price
        s2.unit_price
        from
        (
        --select count(*) from (  --28177
          select
          s1.item_key,
          sp.supplier_no,
          s1.unit_price
          from
          (
          --select count(*) from (  --27673
            select 
            sp.item_key,
            min(unit_price) unit_price  -- pick the lowest price
            from purchasing_v_Item_Supplier_Price sp
            group by sp.item_key 
          )s1
          inner join purchasing_v_Item_Supplier_Price sp
          on s1.item_key=sp.item_key  
          and s1.unit_price=sp.unit_price -- 1 to many  There could be many suppliers with the same price for that item
        )s2
        group by s2.item_key,s2.unit_price
      )s3
      inner join purchasing_v_Item_Supplier_Price sp
      on s3.item_key=sp.item_key
      and s3.supplier_no=sp.supplier_no
      and s3.unit_price=sp.unit_price -- 1 to many. There could be many item-supplier constants with the same unit price.  Maybe those having different unit keys; so we will just pick one at random.  There is only 1 like this.
    )s4
    group by s4.item_key,s4.supplier_no,s4.unit_price
  )s5
  inner join purchasing_v_Item_Supplier_Price sp
  on s5.item_key=sp.item_key
  and s5.supplier_no=sp.supplier_no
  and s5.price_key=sp.price_key -- 1 to 1.
  inner join purchasing_v_item i
  on s5.item_key=i.item_key  --1 to 1  --27673
  where i.active = 1  --16995
)

select count(*) #ItemSupplierPriceKey from #ItemSupplierPriceKey --16995
--select count(*) from purchasing_v_Item_Supplier_Price sp

--select count(*) #SecondaryKey from #SecondaryKey --16995
select 
s.supplier_code,
si.Supplier_Item_No,
cu.unit,
sk.* 
from #ItemSupplierPriceKey sk
inner join purchasing_v_item_supplier si
on sk.item_key=si.item_key
and sk.supplier_no=si.supplier_no  -- 1 to 1
inner join common_v_supplier s
on sk.supplier_no=s.supplier_no  --1 to 1
inner join common_v_unit cu
on sk.unit_key=cu.unit_key
where sk.item_no = '0003491'
/*
select 
s1.item_key,
i.item_no
from
(
      select si.item_key, count(*) cnt
      from purchasing_v_item_supplier si
      group by si.item_key,si.sort_order
)s1
inner join purchasing_v_item i
on s1.item_key=i.item_key
where s1.cnt > 1



*/


create table #maxSupplierNo
(
  item_key int,
  supplier_no int,
  supplier_item_no varchar (50),
  Supplier_Std_Purch_Qty decimal (19,2),
  Supplier_Std_Unit_Price decimal (19,6)
)
insert into #maxSupplierNo (item_key,supplier_no,supplier_item_no,Supplier_Std_Purch_Qty,Supplier_Std_Unit_Price)
(
  select
  s2.item_key,
  --s2.sort_order,
  s3.supplier_no,
  s3.supplier_item_no,
  s5.Supplier_Std_Purch_Qty,
  s5.Supplier_Std_Unit_Price
  from
  (
      --select count(*) from (
      select 
      item_key,
      min(si.sort_order) sort_order -- this supplier appears 1st on the supply list screen.  This is not the minimum price.
      from purchasing_v_item_supplier si
      group by item_key
      --)s1  --27673
  )s2
  inner join purchasing_v_item_supplier s3
  on s2.sort_order=s3.sort_order  
  and s2.item_key=s3.item_key --1 to 1
  inner join 
  (
    select 
    s4.item_key,
    s4.supplier_no,
    sp.Purchase_Quantity Supplier_Std_Purch_Qty,
    sp.unit_price Supplier_Std_Unit_Price
    from
    (
    --select count(*) from purchasing_v_Item_Supplier_Price sp  --28853
    --select count(*) from (  
      select 
      sp.item_key,sp.supplier_no,
      min(price_key) price_key  -- choose the minimum price key this is not the minimum price
      from purchasing_v_Item_Supplier_Price sp
      group by sp.item_key,supplier_no
    )s4
    inner join purchasing_v_Item_Supplier_Price sp
    on s4.item_key=sp.item_key
    and s4.supplier_no=sp.supplier_no
    and s4.price_key=sp.price_key  -- 1 to 1
  )s5  --28851
  on s3.supplier_no=s5.supplier_no
  and s3.item_key=s5.item_key
)
--select count(*) from #maxSupplierNo --27703
-- select top 100 * from purchasing_v_Item_Supplier_Price Unit_Price  where purchase_quantity <> 0
-- 	1003298	0002475	2
--select top 10 * from purchasing_v_item_supplier
select count(*) from (
select item_key from #maxSupplierNo group by item_key 
)s1  --27673

--select count(*) #maxSupplierNo from #maxSupplierNo  --27670
--select top 100 i.item_no from #maxSupplierNo mx
--inner join purchasing_v_item i
--on mx.item_key=i.item_key
--where i.item_no = '0002475'  
--where item_key = 1003298
--select supplier_code from common_v_supplier where supplier_no = 617316
   select 
   --top 100
   i.item_no,
   i.brief_description,
   i.description,
   i.note,
   it.item_type,
   ig.item_group,
   ic.item_category,
   ip.item_priority,
   i.Customer_Unit_Price,
   i.Average_Cost,
   i.Inventory_Unit,
   i.Min_Quantity,
   i.Max_Quantity,
   t.Tax_Code_no,
   i.Account_no,
   case
    when i.Manufacturer is null then ''
    else i.manufacturer  
   end Manufacturer,  
   i.Manf_Item_no,
   i.Drawing_no,
  '' as Item_Quantity,  -- don't load any item quantities 
  '' as Location,
  mx.supplier_code,
  mx.supplier_item_no,--Supplier_Part_No
  mx.Supplier_Std_Purch_Qty,  -- 
  'USD' as Currency,
  --av.Cost as Supplier_Std_Unit_Price,
   /*
      2. Brief_Description
     3. Description
     4. Note
     5. Item_Type (Required, must already exist)
     6. Item_Group (Required, must already exist)
     7. Item_Category (Required, must already exist)
     8. Item_Priority  (Required, must already exist)
     9. Customer_Unit_Price (If specified,must be a number)
     10. Average_Cost (If specified,must be a number)
     11. Inventory_Unit  (If specified, it must exist)
     12. Min_Quantity (If specified, must be a number)
     13. Max_Quantity (If specified, must be a number)
     14. Tax_Code (If specified, it must exist)
  */
 			'Ea' as Supplier_Purchase_Unit,
		1 as Supplier_Unit_Conversion,
		'' as Supplier_Lead_Time,
		'Y' as Update_When_Received,
		'' as Manufacturer_Item_Revision,
		'' as Country_Of_Origin,
		'' as Commodity_Code_Key,
		'' as Harmonized_Tariff_Code,
		'' as Cube_Length,
		'' as Cube_Width,
		'' as Cube_Height,
		'' as Cube_Unit

   from purchasing_v_item i
   inner join purchasing_v_item_type it
   on i.item_type_key=it.item_type_key  --1 to 1
   inner join purchasing_v_item_group ig
   on i.item_group_key=ig.item_group_key --1 to 1
   inner join purchasing_v_item_category ic
   on i.item_category_key=ic.item_category_key  --1 to 1
   inner join purchasing_v_item_priority ip
   on i.item_priority_key=ip.item_priority_key
   inner join purchasing_v_tax_code t
   on i.tax_code_no=t.tax_code_no
   inner join #maxSupplierNo mx
   on i.item_key=mx.item_key
   where i.active=1


-- select * from common_v_supplier

select i.item_no
from
(
  select 
  item_key,
  count(*) supplier_count
  from purchasing_v_item_supplier  --28851
  group by item_key
)s1
inner join purchasing_v_item i
on s1.item_key=i.item_key
where s1.supplier_count > 1

  select 
  count(*)
  from purchasing_v_item_supplier  --28851
  group by item_key


select 
count(*)  --27670
from
(

select 
max(supplier_no) supplier_no 
from purchasing_v_item_supplier
group by item_key
)s1