
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
  s2.supplier_no,
  s3.supplier_item_no,
  s4.Supplier_Std_Purch_Qty,
  s4.Supplier_Std_Unit_Price
  from
  (
      --select count(*) from (
      select 
      item_key,
      max(si.supplier_no) supplier_no 
      from purchasing_v_item_supplier si
      inner join common_v_supplier s
      on si.supplier_no=s.supplier_no  --1 to 1
      group by item_key
      --)s1  --27670
  )s2
  inner join purchasing_v_item_supplier s3
  on s2.supplier_no=s3.supplier_no  -- many to 1
  and s2.item_key=s3.item_key  --1 to many
  inner join 
  (
    select 
    s31.item_key,
    s31.supplier_no,
    sp.Purchase_Quantity Supplier_Std_Purch_Qty,
    sp.unit_price Supplier_Std_Unit_Price
    from
    (
    --select count(*) from purchasing_v_Item_Supplier_Price sp  --28853
    --select count(*) from (  
      select 
      sp.item_key,sp.supplier_no,
      max(price_key) price_key
      from purchasing_v_Item_Supplier_Price sp
      group by sp.item_key,supplier_no
    )s31
    inner join purchasing_v_Item_Supplier_Price sp
    on s31.item_key=sp.item_key
    and s31.supplier_no=sp.supplier_no
    and s31.price_key=sp.price_key
  )s4  --28851
  on s2.supplier_no=s4.supplier_no
  and s2.item_key=s4.item_key
)
-- select top 100 * from purchasing_v_Item_Supplier_Price Unit_Price  where purchase_quantity <> 0
-- 	1003298	0002475	2
--select top 10 * from purchasing_v_item_supplier
--select count(*) from (
--  select item_key from #maxSupplierNo group by item_key --27670
--)s1  --27670

--select count(*) #maxSupplierNo from #maxSupplierNo  --27670
-- select top 100 * from #maxSupplierNo mx
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
select 
count(*)
from purchasing_v_item_supplier  --28851


select 
count(*)  --27670
from
(

select 
max(supplier_no) supplier_no 
from purchasing_v_item_supplier
group by item_key
)s1