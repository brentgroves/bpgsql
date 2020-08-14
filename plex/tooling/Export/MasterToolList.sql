/*
 *  Master Tool List Plex upload
 *  Plex screen: Master Tool List 
 */
/*
1. Part No (Only used if customer setting Display Job No on Form is active)
2. Tool No*
3. Drawing No
4. Revision
5. Description
6. Extra Description
7. Tool Type*
8. Tool Group*
9. Tool Status*
10. Grade
11. Storage Location
12. Min Qty
13. Tool Life (Max of 99,999,999)
14. Reworked Tool Life
15. Std Reworks
16. Action
17. Serialize (0 or 1)*
18. Purchasing Description
19. Tool Product Line
20. Source
21. Replenish Qty
22. Supplier Code
23. Price
24. Accounting Job No
25. Customer Code
26. Max Recuts
27. Recut Length
28. Recut Unit
29. Auto Pick (0 or 1)
30. Storage Section
31. Storage Row
32. Storage Rack
33. Storage Rack Side
34. Storage Position
35. Tool Dimensions
36. Tool Weight
37. Ouput Per Cycle
38. Design Cycle Time
39. Press Size
40. Drawing/Data Date

* indicates required field.
 
 
Notes
What does the 0 and 1 represent for fields Serialize and Auto Pick? 
True = 1, False = 0    Auto Pick is part of a specific process designed for one customer and does not apply to most other customers.

What is Replenish Quantity? 
Used in TRP.
 
The Tool Type must be the description of the Tool Type
 


select brief_description, description from purchasing_v_item i
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key  --1 to 1
select * from purchasing_v_item_type in (17139)

--select distinct tool_group_code  -- Body,Heads,Mach,Mill

-- select distinct tool_group_code from part_v_tool_group

-- select distinct item_category from purchasing_v_item_category i 
select tg.tool_group_code,ic.item_category from part_v_tool_group tg left outer join purchasing_v_item_category ic on trim(tg.tool_group_code)=trim(ic.item_category)

*/

  select 
   --top 100
	row_number() OVER(ORDER BY i.item_no ASC) AS row_no,
	'' Part_No,  -- This will be blank, since we don't assign part numbers to assemblies and not supply list items. 
  i.item_no Tool_No,
  '' Drawing_No, -- We don't assign a drawing to a supply list item
  '' Revision,  -- We don't have supply list item revisions 
  i.brief_description Description,  -- This could change to the contents of i.description if desired look at the data and the plex screens.
  i.description Extra_Description,
  ic.item_category Tool_Type,
  -- select distinct item_category from purchasing_v_item i inner join purchasing_v_item_category ic on i.item_category_key=ic.item_category_key
  'Mill' Tool_Group,-- Alabama uses (Body,Heads,Mach,Mill) but most of them are Mill
  -- select * from part_v_tool_status
  'Current Production' Tool_Status,
  '' Grade,
  il.location Storage_Location,  -- NOT DONE if toolboss items then TBOSS-12-FRONT OR TBOSS-12-REAR  else CribLocation.
  1 Min_Qty,
  '' Tool_Life,  -- We don't use this.  I believe a tool_life record is created with this tool_key if this column contains a value.
  '' Reworked_Tool_Life,  -- This is a column in the the tool_life table.
  '' Std_Reworks, -- Maybe this is true or false for a reworked no,
  '' Action,
  0 Serialize,
  '' Purchasing_Description, -- Always blank in Alabama
  '' Tool_Product_Line, -- In common scale table
  '' Source,  -- No idea what this is
  '' Replenish_Qty,
  
  -- START HERE
  '' Supplier_Code, -- MANY ALABAMA TOOLING HAVE A SUPPLIER NO SO GET THIS
  
  
  -- END OF TOOLING TEMPLATE FIELDS
  i.note,
  it.item_type, -- nulls are NOT allowed
  -- select * from purchasing_v_item i where i.item_type_key is null --0 REC
  case
  when ig.item_group is null then null --null are allowed
  else ig.item_group
  end item_group,
  -- select * from purchasing_v_item i where i.item_group_key is null --0 REC
  ic.item_category, --nulls are NOT allowed
  -- select * from purchasing_v_item i where i.item_category_key is null --0 REC
  case
  when ip.item_priority is null then null --nulls are allowed
  else ip.item_priority
  end item_priority,
  -- select * from purchasing_v_item i where i.item_priority_key is null --0 REC   
  i.customer_unit_price,
  i.average_cost,
  i.inventory_unit,
  i.min_quantity,  
  i.max_quantity,
  case
  when t.tax_code_no is null then null -- nulls are allowed according to the supply item import template.
  else t.tax_code
  end tax_code,
  -- select * from purchasing_v_item i where i.tax_code_no is not null --0 REC   
  i.account_no,
  i.manufacturer,  
  -- select distinct manufacturer from purchasing_v_item
  -- select distinct manufacturer from purchasing_v_item  --662070
  -- select * from common_v_supplier s where s.supplier_no = 662070  M&M Machine Co.
  i.manf_Item_no,  -- I think we use this field for a manufacturer number even though the manufacture field contains a supplier_no and not a manufacturer
  i.drawing_no,
  null as item_quantity,  -- don't load any item quantities 
  '' as location,
	case 
	when i.update_when_received = 1 then 'Y'
	else 'N'
	end update_when_received,
	--select distinct update_when_received from purchasing_v_item  --0 or 1
	--select count(*) from purchasing_v_item where update_when_received = 0  --131 REC
	--select count(*) from purchasing_v_item where update_when_received = 1  --31278 REC
	i.manufacturer_item_revision,
	i.country_of_origin,
	c.commodity_code,
	tc.harmonized_tariff_code,  -- this can be null
	i.cube_length,
	i.cube_width,
	i.cube_height,
	u.unit cube_unit
	-- select count(*) cnt  
	-- COUNTS FROM EDON ON 08/14
  from purchasing_v_item i  -- 29849
  left outer join purchasing_v_item_type it --29,849
  on i.item_type_key=it.item_type_key  --1 to 1
  left outer join purchasing_v_item_group ig
  on i.item_group_key=ig.item_group_key --1 to 1
  left outer join purchasing_v_item_category ic
  on i.item_category_key=ic.item_category_key  --1 to 1
  left outer join purchasing_v_item_priority ip
  on i.item_priority_key=ip.item_priority_key  --1 to 1
  left outer join purchasing_v_tax_code t
  on i.tax_code_no=t.tax_code_no  -- 1 to 1
  left outer join sales_v_harmonized_tariff_code tc  -- 29,849
  on i.harmonized_tariff_code_key=tc.harmonized_tariff_code_key  -- 1 to 1
 -- left outer join #ItemSupplierPrice sp
--  on i.item_key=sp.item_key
  left outer join purchasing_v_commodity c  -- no supply item has a commodity_code_key. and the key does not exactly match
  on i.commodity_code_key=c.commodity_key
  left outer join common_v_unit u
  on i.cube_unit_key=u.unit_key  -- 29,849
  left outer join 
  (
    select
    il.item_key,
    il.location
    from 
    (
      select
      s1.item_key,
      s1.quantity,
      max(s2.item_location_key) item_location_key
      from
      (
        select item_key, max(quantity) quantity 
        from purchasing_v_item_location il group by item_key
      ) s1 
      inner join 
      (
        select item_location_key,item_key,quantity 
        from purchasing_v_item_location il 
      ) s2   
      on s1.item_key = s2.item_key  
      and s1.quantity = s2.quantity  -- 1 to many
      group by s1.item_key,s1.quantity
    ) s3 
    inner join purchasing_v_item_location il 
    on s3.item_location_key=il.item_location_key
  ) il 
  on i.item_key=il.item_key
  where 
-- item_no in ('16303')
 item_no = '16293'
 -- i.active=1
--  and i.item_no not like '%[-" ]%'  -- we don't want any records with item_no containing a dash, double-quote, or space.
--  and brief_description <> ''  -- These might be in Edon already but they are not in our list to make inactive because
  -- our comparision check is for stipped leading zeros and for the brief_description to match.

-- 2753842	LB5C-5K651-BF, Control Arm,
/*
select 
i.item_no
from
(
  select item_key, count(*) cnt
  from purchasing_v_item_location il 
  group by item_key
  having count(*) > 1 and max(quantity) > 0
) il 
inner join purchasing_v_item i 
on il.item_key=i.item_key
*/
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

--select count(*) #PrimaryKey from #PrimaryKey  --18645

create table #ItemSupplierPrice
(
  item_key int,
  item_no varchar (50),
  supplier_no int,
  supplier_code varchar (25),
  supplier_part_no varchar (50),  -- Supplier_Item_No
  supplier_std_purch_qty decimal(19,2),  -- Purchase_Quantity
  currency char (3),
  supplier_std_unit_price decimal (19,6),
  supplier_purchase_unit varchar (20),
  Supplier_Unit_Conversion decimal (18,6),
  Supplier_Lead_Time decimal (9,2)
)

insert into #ItemSupplierPrice(item_key,item_no,supplier_no,supplier_code,supplier_part_no,supplier_std_purch_qty,currency,supplier_std_unit_price,supplier_purchase_unit,Supplier_Unit_Conversion,Supplier_Lead_Time)
(
  select 
  sp.item_key,
  i.item_no,
  sp.supplier_no,
  s.supplier_code,
  si.Supplier_Item_No supplier_part_no,
  sp.purchase_quantity supplier_std_purch_qty,
  case
  when cc.currency_code is null then 'USD'
  else cc.currency_code
  end currency,
  sp.unit_price supplier_std_unit_price,
  case
  when cu.unit is null then 'EA' 
  else cu.unit
  end supplier_purchase_unit,
  sp.unit_conversion supplier_unit_conversion,
  sp.lead_time supplier_lead_time
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
      sp.price_key  -- now we have the full key of the record we want.
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
    -- now we have an item_key,supplier_no, and unit_price we can get pick one unit_price_key to use.
  )s5
  inner join purchasing_v_Item_Supplier_Price sp
  on s5.item_key=sp.item_key
  and s5.supplier_no=sp.supplier_no
  and s5.price_key=sp.price_key -- 1 to 1.
  inner join purchasing_v_item i
  on s5.item_key=i.item_key  --1 to 1  --27673
  inner join purchasing_v_item_supplier si
  on s5.item_key=si.item_key
  and s5.supplier_no=si.supplier_no  -- 1 to 1
  inner join common_v_supplier s
  on s5.supplier_no=s.supplier_no  --1 to 1
  left outer join common_v_unit cu
  on sp.unit_key=cu.unit_key  --1 to 1
  left outer join common_v_currency cc
  on sp.currency_key=cc.currency_key --1 to 1
  where i.active = 1  --16995
  and i.item_no not like '%[-" ]%'  -- we don't want any records with item_no containing a dash, double-quote, or space.
  and brief_description <> ''  -- These might be in Edon already but they are not in our list to make inactive because
  -- our comparision check is for stipped leading zeros and for the brief_description to match.
  -- select count(*) from purchasing_v_item where brief_description = ''  -- 7  These 7 items will not get uploaded
  -- select count(*) from purchasing_v_item where item_no like '%[-" ]%'  --49
--  and i.item_no not like 'BE%'
--  and i.item_no not like '%R'  
)

--select count(*) #ItemSupplierPrice from #ItemSupplierPrice --16995
--select top 100 * from #ItemSupplierPrice sp --16995
--where sp.item_no = '0002475' 
  /*
  If the PCN is configured to use Suppliers as Supply Item manufacturers, then this field contains the Supplier_No.
  If not configured to use Suppliers as Supply Item manufacturers, then this field contains the name of the Manufacturer.
  Manufacturer From Supplier List is checked in Albion and Edon.
  This field will contain a supplier_no in our case.
  */


create table #SupplyItem
(
  row_no int,
  item_no varchar (50),
  brief_description varchar (50),  
  description varchar (800),
  note varchar(200),
  item_type varchar(25),
  item_group varchar(50),
  item_category varchar (50),
  item_priority varchar (50),
  customer_unit_price decimal(19,4),
  average_cost decimal(23,9),
  inventory_unit varchar (20),
  min_quantity decimal(18,2),
  max_quantity decimal(18,2),
  tax_code varchar(100),
  account_no varchar(20),
  manufacturer int,
  manf_Item_no 	varchar(50),
  drawing_no varchar(50),
  item_quantity decimal(18,2), --we don't use this so want it to be null
  location varchar(50), -- from the item location table but we will not use it.
  supplier_code varchar (25),
  supplier_part_no varchar (50),  -- Supplier_Item_No
  supplier_std_purch_qty decimal(19,2),  -- Purchase_Quantity
  currency char(3),
  supplier_std_unit_price decimal(19,6),
  supplier_purchase_unit varchar(20),
  supplier_unit_conversion decimal(18,6),
  supplier_lead_time decimal(9,2),
  update_when_received char(1), --this is a smallint in plex, but needs to be 'Y' for the upload.
  manufacturer_item_revision varchar (8),
  country_of_origin int,
  commodity_code varchar(10),
  harmonized_tariff_code 	varchar(20),
  cube_length decimal(9,4),
  cube_width decimal(9,4),
  cube_height decimal(9,4),
  cube_unit varchar (20)

)

insert into #SupplyItem (
  row_no,
  item_no,
  brief_description,  
  description,
  note,
  item_type,
  item_group,
  item_category,
  item_priority,
  customer_unit_price,
  average_cost,
  inventory_unit,
  min_quantity, 
  max_quantity,
  tax_code,
  account_no,
  manufacturer,
  manf_Item_no,
  drawing_no,
  item_quantity,
  location,
  supplier_code,
  supplier_part_no,
  supplier_std_purch_qty,
  currency,
  supplier_std_unit_price,
  supplier_purchase_unit,
  supplier_unit_conversion,
  supplier_lead_time,
  update_when_received,
  manufacturer_item_revision,
  country_of_origin,
  commodity_code,
  harmonized_tariff_code,
  cube_length,
  cube_width,
  cube_height,
  cube_unit 
)
(
--where i.item_no = '0002475'  
--where item_key = 1003298
--select supplier_code from common_v_supplier where supplier_no = 617316
  select 
   --top 100
	row_number() OVER(ORDER BY i.item_no ASC) AS row_no,
  i.item_no,
  i.brief_description,
  i.description,
  i.note,
  it.item_type, -- nulls are NOT allowed
  -- select * from purchasing_v_item i where i.item_type_key is null --0 REC
  case
  when ig.item_group is null then null --null are allowed
  else ig.item_group
  end item_group,
  -- select * from purchasing_v_item i where i.item_group_key is null --0 REC
  ic.item_category, --nulls are NOT allowed
  -- select * from purchasing_v_item i where i.item_category_key is null --0 REC
  case
  when ip.item_priority is null then null --nulls are allowed
  else ip.item_priority
  end item_priority,
  -- select * from purchasing_v_item i where i.item_priority_key is null --0 REC   
  i.customer_unit_price,
  i.average_cost,
  i.inventory_unit,
  i.min_quantity,  
  i.max_quantity,
  case
  when t.tax_code_no is null then null -- nulls are allowed according to the supply item import template.
  else t.tax_code
  end tax_code,
  -- select * from purchasing_v_item i where i.tax_code_no is not null --0 REC   
  i.account_no,
  i.manufacturer,  
  -- select distinct manufacturer from purchasing_v_item
  -- select distinct manufacturer from purchasing_v_item  --662070
  -- select * from common_v_supplier s where s.supplier_no = 662070  M&M Machine Co.
  i.manf_Item_no,  -- I think we use this field for a manufacturer number even though the manufacture field contains a supplier_no and not a manufacturer
  i.drawing_no,
  null as item_quantity,  -- don't load any item quantities 
  '' as location,
  sp.supplier_code, -- this can be null
  sp.supplier_part_no, -- this can be null
  sp.supplier_std_purch_qty, -- this can be null   
  sp.currency, -- this can be null
  sp.supplier_std_unit_price, -- this can be null
 	sp.supplier_purchase_unit, -- this can be null
	sp.supplier_unit_conversion, -- this can be null
	sp.supplier_lead_time,
	case 
	when i.update_when_received = 1 then 'Y'
	else 'N'
	end update_when_received,
	--select distinct update_when_received from purchasing_v_item  --0 or 1
	--select count(*) from purchasing_v_item where update_when_received = 0  --131 REC
	--select count(*) from purchasing_v_item where update_when_received = 1  --31278 REC
	i.manufacturer_item_revision,
	i.country_of_origin,
	c.commodity_code,
	tc.harmonized_tariff_code,  -- this can be null
	i.cube_length,
	i.cube_width,
	i.cube_height,
	u.unit cube_unit
  from purchasing_v_item i
  left outer join purchasing_v_item_type it
  on i.item_type_key=it.item_type_key  --1 to 1
  left outer join purchasing_v_item_group ig
  on i.item_group_key=ig.item_group_key --1 to 1
  left outer join purchasing_v_item_category ic
  on i.item_category_key=ic.item_category_key  --1 to 1
  left outer join purchasing_v_item_priority ip
  on i.item_priority_key=ip.item_priority_key  --1 to 1
  left outer join purchasing_v_tax_code t
  on i.tax_code_no=t.tax_code_no  -- 1 to 1
  left outer join sales_v_harmonized_tariff_code tc
  on i.harmonized_tariff_code_key=tc.harmonized_tariff_code_key  -- 1 to 1
  left outer join #ItemSupplierPrice sp
  on i.item_key=sp.item_key
  left outer join purchasing_v_commodity c  -- no supply item has a commodity_code_key. and the key does not exactly match
  on i.commodity_code_key=c.commodity_key
  left outer join common_v_unit u
  on i.cube_unit_key=u.unit_key
  where 
 -- i.item_no = '16303'
  i.active=1
  and i.item_no not like '%[-" ]%'  -- we don't want any records with item_no containing a dash, double-quote, or space.
  and brief_description <> ''  -- These might be in Edon already but they are not in our list to make inactive because
  -- our comparision check is for stipped leading zeros and for the brief_description to match.

)

/*
select 
  -- top 1 
  row_no,
  item_no,
   -- Binary-like Key to replace characters which cause issues in CSV files: # = 0, @ = 1
  REPLACE(REPLACE(REPLACE(REPLACE(brief_description, ',', '###'), '"', '##@'),CHAR(10),'#@#'),CHAR(13),'#@@') brief_description,
--  brief_description,  
  REPLACE(REPLACE(REPLACE(REPLACE(description, ',', '###'), '"', '##@'),CHAR(10),'#@#'),CHAR(13),'#@@') description,
--  REPLACE(REPLACE(description, ',', '###'), '"', '##@') description,
--  description,
--  REPLACE(REPLACE(note, ',', '###'), '"', '##@') note,
  REPLACE(REPLACE(REPLACE(REPLACE(note, ',', '###'), '"', '##@'),CHAR(10),'#@#'),CHAR(13),'#@@') note,
--  note,
  item_type,
  item_group,
  item_category,
  item_priority,
  customer_unit_price,
  average_cost,
  inventory_unit,
  case 
  when item_no = '0003524' then min_quantity
  else null
  end min_quantity,
--  null as min_quantity, -- i.min_quantity,  CASEY SAID WE DON'T NEED THESE, 
  -- NOTE When the min and max quantity are not set the supplier information does not get imported.
  case 
  when item_no = '0003524' then max_quantity
  else null
  end max_quantity,
--  null as max_quantity, -- i.max_quantity
  tax_code,
  account_no,
  manufacturer,
  manf_Item_no,
  drawing_no,
  item_quantity,
  location,
  supplier_code,
  supplier_part_no,
  supplier_std_purch_qty,
  currency,
  supplier_std_unit_price,
  supplier_purchase_unit,
  supplier_unit_conversion,
  supplier_lead_time,
  update_when_received,
  manufacturer_item_revision,
  country_of_origin,
  commodity_code,
  harmonized_tariff_code,
  cube_length,
  cube_width,
  cube_height,
  cube_unit 
  
--select count(*)
from  #SupplyItem  --18643
WHERE item_no in ('16303')
*/
--('BE450713','BE705620','BE706816','BE850567','BE851453')
-- WHERE item_no >= 'BE851453' and item_no <= 'BE450589' order by item_no -- TRY BIG SET DOWNLOAD AND IMPORT INTO MYSQL with 1400 records. THIS WORKS
-- WHERE item_no >= 'BE207212' and item_no <= 'BE450589' order by item_no -- TRY BIG SET DOWNLOAD AND IMPORT INTO MYSQL with 1400 records. 
--WHERE item_no >= 'BE207212' and item_no <= 'BE450713' order by item_no -- TRY BIG SET DOWNLOAD AND IMPORT INTO MYSQL with 1515 records. HAD PROBLEMS WITH UPLOADED on 1409 .
-- WHERE item_no >= 'BE207212' and item_no <= 'BE851453' order by item_no -- TRY BIG SET DOWNLOAD AND IMPORT INTO MYSQL with 6031 records. HAD PROBLEMS WITH UPLOADED.

-- WHERE item_no > '008399'  and item_no <= '008713' order by item_no  
-- WHERE item_no > '008093'  and item_no <= '008399' order by item_no 
-- WHERE item_no > '007592' and item_no <= '008093' order by item_no 
-- WHERE item_no > '007085' and item_no <= '007592R' order by item_no 
-- WHERE item_no > '0004578' and item_no <= '0005239' order by item_no 
-- WHERE item_no > '0004057' and item_no <= '0004578'
-- '0003524'(7,13) - verify that if min_qty,max_qty are null supplier information is ignored on imports
-- WHERE item_no >= '0003524' and item_no <='0004057'
-- '0003524'(7,13) - verify that if min_qty,max_qty are null supplier information is ignored on imports
-- NotInEdon0620 range: {1=0003524, 200=0004066}, record count: 200
--WHERE item_no >= '0003040' and item_no <='0003523'
--and brief_description like '%"%' --0003194  -- " inserted but no supplier?
-- and description like '%' + CHAR(10) + '%'  -- 	0003394  after 25M
-- and description like '%' + CHAR(13) + '%'  -- 	0003394
-- and description not like '%' + CHAR(10) + '%'  -- 0
-- where description like '%' + CHAR(13) + '%'  -- 118
-- where description like '%' + CHAR(10) + '%'  -- 104
-- where description like '%' + CHAR(10) + CHAR(13) + '%'  -- 15
-- where description like '%' + CHAR(13) + CHAR(10) + '%'  -- 104
-- select * from parameters where name like '%'+char(13)+'%' or name like '%'+char(10)+'%'
/*
--where sp.item_no = '0003491'

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
select * from purchasing_v_item where item_no like 'BE701536'
select * 
from purchasing_v_item i
inner join purchasing_v_item_location il
on i.item_key=il.item_key
where il.location like '%A01A01%'
*/