/*
START: Work on Plant 6 first should be the easist since mostly knuckles.
*/
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
      sp.price_key    -- There could be multiple price records for this vendor for different unit_keys.
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
            group by sp.item_key -- pick only 1 supplier_price for each item
          )s1
          inner join purchasing_v_Item_Supplier_Price sp
          on s1.item_key=sp.item_key  
          and s1.unit_price=sp.unit_price -- 1 to many.  There could be many suppliers with the same price for that item
        )s2
        group by s2.item_key,s2.unit_price  -- pick only 1 min unit_price supplier
      )s3
      inner join purchasing_v_Item_Supplier_Price sp
      on s3.item_key=sp.item_key
      and s3.supplier_no=sp.supplier_no
      and s3.unit_price=sp.unit_price -- 1 to many. There could be many item-supplier_price records with the same supplier_no and unit price.  
      -- Maybe those having different unit keys; so we will just pick one at random.  There is only 1 like this.
    )s4
    group by s4.item_key,s4.supplier_no,s4.unit_price
    -- now we have an item_key,supplier_no, and unit_price we can get pick one unit_price_key to use.
  )s5
  inner join purchasing_v_Item_Supplier_Price sp  -- primary_key is item_key,supplier_no, price_key combo
  on s5.item_key=sp.item_key
  and s5.supplier_no=sp.supplier_no
  and s5.price_key=sp.price_key -- 1 to 1.
  inner join purchasing_v_item i
  on s5.item_key=i.item_key  --1 to 1  
  inner join purchasing_v_item_supplier si  -- primary_key is item_key,supplier_no
  on s5.item_key=si.item_key
  and s5.supplier_no=si.supplier_no  -- 1 to 1
  inner join common_v_supplier s  -- primary_key is supplier_no
  on s5.supplier_no=s.supplier_no  --1 to 1
  left outer join common_v_unit cu
  on sp.unit_key=cu.unit_key  --1 to 1
  left outer join common_v_currency cc
  on sp.currency_key=cc.currency_key --1 to 1
  where 
  -- i.active = 1 -- Do we care if the item is active or not? 
  i.item_no not like '%[-" ]%'  -- we don't want any records with item_no containing a dash, double-quote, or space.
  and brief_description <> ''  -- These might be in Edon already but they are not in our list to make inactive because
  -- our comparision check is for stipped leading zeros and for the brief_description to match.
  -- select count(*) from purchasing_v_item where brief_description = ''  -- 7  These 7 items will not get uploaded
  -- select count(*) from purchasing_v_item where item_no like '%[-" ]%'  --49
--  and i.item_no not like 'BE%'
--  and i.item_no not like '%R'  
)

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
 
--select distinct tool_group_code  -- Body,Heads,Mach,Mill

-- select distinct tool_group_code from part_v_tool_group

-- select distinct item_category from purchasing_v_item_category i 
-- select tg.tool_group_code,ic.item_category from part_v_tool_group tg left outer join purchasing_v_item_category ic on trim(tg.tool_group_code)=trim(ic.item_category)
-- select count(*) cnt from part_v_tool  -- 71
*/

-- Not using this set because many fields should be .  Keeping it around because it has all the datatypes listed.
create table #result
(
  Row_No int,
  Part_No	varchar (100),
  Tool_No	varchar (50),
  Drawing_No	varchar (50),
  Revision	varchar (50),
  Description	varchar (50),
  Extra_Description	varchar (200),
  Tool_Type	varchar (20), -- Tool_Type_Code in plex
  Tool_Group	varchar (5), -- Tool_Group_Code in plex
  Tool_Status	varchar (50), -- Description in plex
  Grade	varchar (40),
  Storage_Location	varchar (50),
  Min_Qty	varchar(20),  -- In plex as Min_Quantity

--  Min_Qty	int,  -- In plex as Min_Quantity
  Tool_Life	varchar(20),
--  Tool_Life	int,
  
  Reworked_Tool_Life	varchar(20),
--  Reworked_Tool_Life	int,
  Std_Reworks varchar (5), -- Maybe this is true or false for a reworked no,
  Action varchar(5), -- Not using
  Serialize varchar(20), -- 0 or 1, Only 0 for us
--  Serialize int, -- 0 or 1, Only 0 for us
  
  Purchasing_Description varchar(5), -- Always blank in Alabama
  Tool_Product_Line	varchar (10), --Tool_Product_Line_Code in Plex
  Source	varchar (50), --Tool_Source in Plex
  Replenish_Qty	varchar(50),  -- In plex as Replenish_Quantity
--  Replenish_Qty	int,  -- In plex as Replenish_Quantity
  Supplier_Code	varchar (25), -- The items that I uploaded included supply codes but the ones that others uploaded did not.
  Price	varchar(20),
--  Price	decimal (18,4),
  Accounting_Job_No	varchar (25),
  Customer_Code	varchar (35),
  Max_Recuts	varchar(20),
--  Max_Recuts	int,
  Recut_Length	varchar(20),
--  Recut_Length	decimal (9,3),
  Recut_Unit	varchar (20),
  
  Auto_Pick	smallint,
  
  Storage_Section	varchar (50),
  Storage_Row	varchar (50),
  Storage_Rack	varchar (50),
  Storage_Rack_Side	varchar (50),
  Storage_Position	varchar (50),
  Tool_Dimensions	varchar (30), -- part_v_tool_attributes
  Tool_Weight	int, -- part_v_tool_attributes
  Output_Per_Cycle	int,  -- part_v_tool_attributes
  Design_Cycle_Time	int,  -- part_v_tool_attributes
  Press_Size	varchar (25),	-- part_v_tool_attributes
  Data_Date	datetime 
)

create table #btToolListItemsInPlant6 
(
  Tool_No	varchar (50)
)
/* Add the the tool list items FROM \\buschesql\toollist\bvToolListItemsInPlant6 there is a limit of 1000 rows per insert statement */

insert into #btToolListItemsInPlant6 (Tool_No)
values 
('16547'),  
('007821'),  
('00008035'),  -- obsolete
('008128'),  
('008488'),  
('008541')  
-- 974 - 253 = 721
-- select count(*) from #btToolListItemsInPlant6

-- 721 Plant #6 Tool List Items
/*
-- use bpgsql\toollist\bvToolBossItemsInPlant6.sql this is not a view but just a sql statement.
-- 340
--
*/
create table #btToolBossItemsInPlant6 
(
  Tool_No	varchar (50)
)

insert into #btToolBossItemsInPlant6 (Tool_No)
values 
('16547'),  
('007821'),  
('00008035'),  -- obsolete
('008128'),  
('008488'),  
('008541')  
-- select count(*) from #btToolBossItemsInPlant6
-- 1330 - 990 = 340 
/*
select
s1.tool_type,
tt.tool_type_code
from
(
select 
distinct tool_type
from 
(

select
count(*) cnt
from 
(
*/

insert into #result (Row_No,Part_No,Tool_No,Drawing_No,Revision,Description,Extra_Description,Tool_Type,Tool_Group,Tool_Status,Grade,Storage_Location,Min_Qty,Tool_Life,
Reworked_Tool_Life,Std_Reworks,Action,Serialize,Purchasing_Description,Tool_Product_Line,Source,Replenish_Qty,Supplier_Code,Price,Accounting_Job_No,Customer_Code,Max_Recuts,
Recut_Length,Recut_Unit,Auto_Pick,Storage_Section,Storage_Row,Storage_Rack,Storage_Rack_Side,Storage_Position,Tool_Dimensions,Tool_Weight,
Output_Per_Cycle,Design_Cycle_Time,Press_Size,Data_Date)

--(
select
	row_number() OVER(ORDER BY Tool_No ASC) AS Row_No,
Part_No
,Tool_No
,Drawing_No
,Revision
-- ,Description OldDescription
/*
If item.description <= 50 characters then use it.
If item.description > 50 the stop at the last complete word in the 50 char substring by reversing the string and searching for the first space.
*/
,case
  when LEN(Description) <= 50 then Description
  when LEN(Description) > 50  then 
    rtrim(substring(rtrim(substring(Description,1,50)),1,LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))))
end Description
/*
If item.description was <= 50 then use extra_description
if item.description was > 50 then use the last full word that is within the 50 character substring of description to its end
*/
,case
  when LEN(Description) <= 50 then Extra_Description  -- no need to do any parsing
  -- if last character is a space then no truncation occurs -- i have only seen this case with maintenance items
  when len(Description) > 50 AND substring(Description,50,1) = ' ' and len(Description) - 50 < = 195 then substring(Description,51,len(description)) + ' ' + Extra_Description
  when len(Description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) <= 195 -- substring is inclusive with respect to indexes
  -- last character in last full word
  -- select (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' '))  -- 2 the index of the space
  -- select substring('12345678 9ABCDEF',10 - (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' ')-2),len('12345678 9ABCDEF')) -- 9ABCDEF -- substring is inclusive with respect to indexes
  -- select len('12345678 9ABCDEF') -- 16
  -- select len(substring('12345678 9ABCDEF',10,16)) -- 7
  -- select len(substring('12345678 9ABCDEF',10 - (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' ')-2),16)) -- substring is inclusive with respect to indexes
  -- select len(substring('12345678 9ABCDEF',10 - (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' ')-2),len('12345678 9ABCDEF'))) -- 7 -- substring is inclusive with respect to indexes
  /* Starting from the last word within the first 50 characters up to the length of item.description is <= 195 characters. */
  -- trim_end_whitespace_from_substring_of_first_50_characters = LEN(rtrim(substring(Description,1,50))) 
  -- LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))
  -- LEN(right(first_50_characters_remove_end_whitespace,find_start_of_last_word_of_the_reverse_of_the_first_50_characters_trim_end_whitespace_add_1_space_to_end-1))
  -- Use the start of the first full word that is not fully with the 50 character boundary of item.description to item.descriptions end and add extra_description to 
  -- the end.
  then substring(Description,
  --LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))+1,  -- rtrim not needed because of 2nd case above
  50 - LEN(right(substring(Description,1,50),charindex(' ',reverse(substring(Description,1,50))+' ')-1)),
  len(Description)) + ' ' + Extra_Description
  when (len(Description) > 50 AND substring(Description,50,1) = ' ' and len(Description) - 50 > 195) then substring(Description,51,200) -- case 4
  when (len(Description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) > 195 ) then -- case 5
  substring(Description,50 - LEN(right(substring(Description,1,50),charindex(' ',reverse(substring(Description,1,50))+' ')-1)),200)
end Extra_Description 
-- i.brief_description is varchar(50) and Extra_Description is varchar(200)
--,Description  -- This field is a 	varchar (800) but in part_v_tool it is a 	varchar (50)
,Tool_Type
,Tool_Group
,Tool_Status
,Grade
,Storage_Location
,Min_Qty
,Tool_Life
,Reworked_Tool_Life
,Std_Reworks
,Action
,Serialize
,Purchasing_Description
,Tool_Product_Line
,Source
,Replenish_Qty
,Supplier_Code
,Price
,Accounting_Job_No
,Customer_Code
,Max_Recuts
,Recut_Length
,Recut_Unit
,Auto_Pick
,Storage_Section
,Storage_Row
,Storage_Rack
,Storage_Rack_Side
,Storage_Position
,Tool_Dimensions
,Tool_Weight
,Output_Per_Cycle
,Design_Cycle_Time
,Press_Size
,Data_Date

from
(
  select 
	'' Part_No,  -- This will be blank, since we assign part numbers to assemblies and not supply list items. 
  i.item_no Tool_No,
  '' Drawing_No, -- We don't assign a drawing to a supply list item
  '' Revision,  -- We don't have supply list item revisions 
-- Since we are importing this set using a CSV replace problem characters with a space IF UPLOADING TO PLEX else replace with code that can be decoded on server.
  REPLACE(REPLACE(REPLACE(REPLACE(rtrim(i.description), ',', ' '), '"', ' '),CHAR(10),' '),CHAR(13),' ') Description,
--  REPLACE(REPLACE(REPLACE(REPLACE(rtrim(i.description), ',', '###'), '"', '##@'),CHAR(10),'#@#'),CHAR(13),'#@@') Description,
-- Since we are importing this set using a CSV replace problem characters with a space.
  REPLACE(REPLACE(REPLACE(REPLACE(rtrim(i.brief_description), ',', ' '), '"', ' '),CHAR(10),' '),CHAR(13),' ') Extra_Description,
  -- i.brief_description is varchar(50) and Extra_Description is varchar(200)
  ic.item_category Tool_Type,
  -- select distinct item_category from purchasing_v_item i inner join purchasing_v_item_category ic on i.item_category_key=ic.item_category_key
  'Mill' Tool_Group,-- Alabama uses (Body,Heads,Mach,Mill) but most of them are Mill
  -- select * from part_v_tool_status
  'Current Production' Tool_Status,
  '' Grade,
  case
    when tb.Tool_No is null then il.location 
    else 'Tool Boss'
  end Storage_Location, 
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
  sp.Supplier_Code, -- The items that I uploaded included supply codes but the ones that others uploaded did not.
  sp.supplier_std_unit_price Price,
  '' Accounting_Job_No,
  '' Customer_Code,
  '' Max_Recuts,  -- This is always 0 in Alabama which is the fields default value.
  '' Recut_Length,
  '' Recut_Unit,
   0 Auto_Pick, -- (0 or 1)  All are 0 in Alabama
   '' Storage_Section,
   '' Storage_Row,
   '' Storage_Rack,
   '' Storage_Rack_Side,
   '' Storage_Position,
   '' Tool_Dimensions,
   '' Tool_Weight,
   '' Output_Per_Cycle,
   '' Design_Cycle_Time,
   '' Press_Size,
   '' Data_Date  -- select * from part_v_tool_attributes -- there are no tool attributes

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
 -- left outer join #ItemSupplierPrice sp
--  on i.item_key=sp.item_key
  left outer join purchasing_v_commodity c  -- no supply item has a commodity_code_key. and the key does not exactly match
  on i.commodity_code_key=c.commodity_key
  left outer join common_v_unit u
  on i.cube_unit_key=u.unit_key  
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
      max(s2.item_location_key) item_location_key  -- picked 1 location to use out of the many that could have a max quantity.
      from
      (
        -- Which location has the most items?
        -- pick 1 item only
        select item_key, max(quantity) quantity 
        from
        (
          select item_key,quantity from purchasing_v_item_location il where substring(il.location,1,2) = '01'
        )sa group by item_key
      ) s1 
      inner join 
      (
        select item_location_key,item_key,quantity 
        from purchasing_v_item_location il 
      ) s2   
      on s1.item_key = s2.item_key  -- in s1 we have selected 1 item_location record for each item_key.
      and s1.quantity = s2.quantity  -- 1 to many, Many locations may have an equal number of items. 
      group by s1.item_key,s1.quantity  -- out of all the locations with a max quantity pick one.
    ) s3 
    inner join purchasing_v_item_location il 
    on s3.item_location_key=il.item_location_key
  ) il -- one Location_key with a max quantity
  on i.item_key=il.item_key
  left outer join #ItemSupplierPrice sp
  on i.item_key=sp.item_key
  -- FILTER BY PLANT 6 TOOL LIST ITEMS
  inner join #btToolListItemsInPlant6 p6 
  on i.item_no=p6.tool_no
  left outer join #btToolBossItemsInPlant6 tb -- This will help us determine which items have a toolboss location.
  on i.item_no=tb.Tool_No
  -- TESTING ONLY
--  where len(i.description) <= 50  -- CASE 1  -- OK  -- 720 records
--  where len(i.description) > 50 AND substring(i.Description,50,1) = ' ' and len(i.description) - 50 < = 195 -- case 2 -- 0 records
--where len(i.description) > 50 AND substring(i.Description,50,1) <> ' ' and len(substring(i.Description, 50 - (charindex(' ',reverse(substring(i.Description,1,50))+' ')-2),len(i.Description))) <= 195 -- case 3 -- 1 record
-- where (len(i.description) > 50 AND substring(i.Description,50,1) = ' ' and len(i.description) - 50 > 195) -- case 4  -- 0 records
-- where (len(i.description) > 50 AND substring(i.Description,50,1) <> ' ' and len(substring(i.Description, 50 - (charindex(' ',reverse(substring(i.Description,1,50))+' ')-2),len(i.Description))) > 195 ) -- case 5  -- 0 records

--  where substring(il.location,1,2) = '12'  
)s1
select 
-- CHAR(39) + Tool_No + CHAR(39) Tool_No 
Tool_No,
CAST(CAST(tool_no AS INT) AS VARCHAR(10)) trim,
Revision,Description,Tool_Type,Storage_Location,r.price
from #result r  --721

/*
http://www.flukenetworks.com/support/manuals/50015/IntelliTone%25E2%2584%25A2%2BPro%2B200%2BLAN%2BToner%2Band%2BProbe
select * from #result
where tool_no = '0003241'
-- where Tool_No = '008431'
*/
-- Tests
--  where len(i.description) <= 50  -- CASE 1  -- OK  -- 720 records
--  where len(i.description) > 50 AND substring(i.Description,50,1) = ' ' and len(i.description) - 50 < = 195 -- case 2 -- 0 records
--where len(i.description) > 50 AND substring(i.Description,50,1) <> ' ' and len(substring(i.Description, 50 - (charindex(' ',reverse(substring(i.Description,1,50))+' ')-2),len(i.Description))) <= 195 -- case 3 -- 1 record
-- where (len(i.description) > 50 AND substring(i.Description,50,1) = ' ' and len(i.description) - 50 > 195) -- case 4  -- 0 records
-- where (len(i.description) > 50 AND substring(i.Description,50,1) <> ' ' and len(substring(i.Description, 50 - (charindex(' ',reverse(substring(i.Description,1,50))+' ')-2),len(i.Description))) > 195 ) -- case 5  -- 0 records
/*
select
 r.Tool_No,Tool_type,r.Description,Price,Extra_Description,storage_location,supplier_code
from #result r
left join purchasing_v_item i 
on r.tool_no=i.item_no
where len(i.description)>50  -- only 1 record.
*/
/*
-- for the tool item upload
select 
Part_No,Tool_No,Drawing_No,Revision,Description,Extra_Description,Tool_Type,Tool_Group,Tool_Status,Grade,Storage_Location,Min_Qty,Tool_Life,
Reworked_Tool_Life,Std_Reworks,Action,Serialize,Purchasing_Description,Tool_Product_Line,Source,Replenish_Qty,Supplier_Code,Price,Accounting_Job_No,Customer_Code,Max_Recuts,
Recut_Length,Recut_Unit,Auto_Pick,Storage_Section,Storage_Row,Storage_Rack,Storage_Rack_Side,Storage_Position,Tool_Dimensions,Tool_Weight,
Output_Per_Cycle,Design_Cycle_Time,Press_Size
,'' Data_Date
-- ,Data_Date  -- This is for Tool_attributes and it displays 1/1/1900 12:00:00 AM here so i'm just going to make it '' and have the plex upload to choose a date or ignore it.
--r.Tool_No,Tool_type,Description,Price,Extra_Description,storage_location,supplier_code
-- select count(*)
from #result r  --721
-- where r.Row_No between 1 and 250
-- where r.Row_No between 251 and 500
where r.Row_No between 501 and 800
-- where r.storage_location <> 'Tool Boss'  -- 375
-- where r.storage_location is null  -- 340  -- 6  -- 381
-- where r.storage_location = 'Tool Boss'  -- 340  -- 721
-- 715
*/
/*
2 ITEMS WERE ALREADY IN THE DATABASE AND WERE ADDED BY 2462729	THE GUI SAYS THIS WAS KARA BUT HER USER NUMBER IS 11730877 BUT HER PLEX USER NUMBER WAS ADDED BY 2462729
I THINK THIS IS SOME ADMIN ACCOUNT THAT DOES NOT SHOW UP IN Plexus_Control_v_Plexus_User
0006891
left outer join #btToolBossItemsInPlant6 p6
on r.tool_no=p6.tool_no
where p6.tool_no is null  -- 381
-- and r.storage_location = 'Tool Boss'
-- where p6.tool_no is not null  -- 340
*/
/*
select * from #result
where Tool_No 
in 
(
'17022',  
'17086',  
'17100'  
)
*/