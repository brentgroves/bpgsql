/*
 *  Master Tool List Plex upload
 *  Plex screen: Master Tool List 
 Rev has the newer way to determine the supplier price 07/07/21
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


/*
This is the best algorithm to determine the supplier price from plex
*/
/*
Working Set
Set of valid item_supplier and item_supplier_price records
*/
  select s.pcn,s.item_key,s.supplier_no,cs.supplier_code,s.sort_order,s.resource_id,p.price_key,p.unit_price 
  into #isp
  -- select count(*)  --  6379
  from purchasing_v_Item_Supplier_e s
  inner join purchasing_v_Item_Supplier_Price_e p -- 1 to many
  on s.pcn=p.pcn
  and s.item_key=p.item_key
  and s.supplier_no=p.supplier_no
  inner join common_v_supplier_e cs  -- primary_key is supplier_no
  on s.pcn=cs.plexus_customer_no
  and s.supplier_no=cs.supplier_no  --1 to 1

  
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
  select s.pcn,s.item_key,s.supplier_no,s.supplier_code,s.sort_order,s.resource_id,s.price_key,s.unit_price 
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
--select top 100 * from #supplier_price
/*
select count(*) cnt from #supplier_price p  -- 5033

select count(*) cnt  -- 5033
from
(
  select distinct p.pcn,p.item_key
  from #supplier_price p
)s

*/

-- Not using this set because many fields should be .  Keeping it around because it has all the datatypes listed.
create table #result
(
--  Row_No int,
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
-- truncate table #btToolListItemsInPlant8
create table #btToolListItemsInPlant8 
(
  Tool_No	varchar (50)
)
insert into #btToolListItemsInPlant8 (Tool_No)
values 
('0002008'),
('0002357'),
('0002827'),
('0003088'),
('0003144'),
('0003241'),
('0003262'),
('0003397'),
('0003512'),
('007221'), 
('008431'), 
('010053'), 
('010449'), 
('010695'), 
('12622'),  
('12623'),  
('15149'),  
('16110'),  
('16111'),  
('16130'),  
('16404'),  
('16405'),  
('16406'),  
('16407'),  
('16408'),  
('16409'),  
('16410'),  
('16412'),  
('16417'),  
('16420'),  
('16461'),  
('16462'),  
('16465'),  
('16467'),  
('16468'),  
('16469'),  
('16470'),  
('16471'),  
('16472'),  
('16680')  
/* Add the the tool list items FROM \\buschesql\toollist\bvToolListItemsInPlant8 there is a limit of 1000 rows per insert statement */

--select * from #btToolListItemsInPlant8

/*
-- use bpgsql\toollist\bvToolBossItemsInPlant6.sql this is not a view but just a sql statement.
-- 340
--
*/
create table #btToolBossItemsInPlant8 
(
  Tool_No	varchar (50)
)

insert into #btToolBossItemsInPlant8 (Tool_No)
values 
('0002008'),
('0003144'),
('0003262'),
('007221'), 
('008431'), 
('010449'), 
('12622'),  
('12623'),  
('16110'),  
('16111'),  
('16130'),  
('16405'),  
('16406'),  
('16461') 


insert into #result (Part_No,Tool_No,Drawing_No,Revision,Description,Extra_Description,Tool_Type,Tool_Group,Tool_Status,Grade,Storage_Location,Min_Qty,Tool_Life,
Reworked_Tool_Life,Std_Reworks,Action,Serialize,Purchasing_Description,Tool_Product_Line,Source,Replenish_Qty,Supplier_Code,Price,Accounting_Job_No,Customer_Code,Max_Recuts,
Recut_Length,Recut_Unit,Auto_Pick,Storage_Section,Storage_Row,Storage_Rack,Storage_Rack_Side,Storage_Position,Tool_Dimensions,Tool_Weight,
Output_Per_Cycle,Design_Cycle_Time,Press_Size,Data_Date)

--(
select
--	row_number() OVER(ORDER BY Tool_No ASC) AS Row_No,
Part_No
,Tool_No
,Drawing_No
,Revision
-- ,Description OldDescription
/*
If item.description <= 50 characters then use it.
If item.description > 50 the stop at the last complete word by reversing the string and searching for the first space.
*/
,case
  when LEN(Description) <= 50 then Description
  when LEN(Description) > 50  then 
    rtrim(substring(rtrim(substring(Description,1,50)),1,LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))))
end Description
/*
If item.description was <= 50 then use extra_description
if item.description was > 50 then use the last full word that is within the 50 character range onward to the end
*/
,case
  when LEN(Description) <= 50 then Extra_Description
  when (len(substring(Description,
  LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1)),
  -- start of last word in 50 character substring of item.description.
  len(Description))) <= 195) 
  /* Starting from the last word within the first 50 characters up to the length of item.description is <= 195 characters. */
  -- trim_end_whitespace_from_substring_of_first_50_characters = LEN(rtrim(substring(Description,1,50))) 
  -- LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))
  -- LEN(right(first_50_characters_remove_end_whitespace,find_start_of_last_word_of_the_reverse_of_the_first_50_characters_trim_end_whitespace_add_1_space_to_end-1))
  -- Use the start of the first full word that is not fully with the 50 character boundary of item.description to item.descriptions end and add extra_description to 
  -- the end.
  then substring(Description,
  LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))+1,
  len(Description)) + ' ' + Extra_Description
  else 
  -- item_description is too large to include any of Extra_Description.
substring(Description,
  LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1)),
  200)  
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
-- Since we are importing this set using a CSV replace problem characters with a space.
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
  end Storage_Location,  -- NOT DONE if toolboss items then tool boss  else CribLocation.
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
  sp.unit_price Price,
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
   '' Data_Date

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
        from purchasing_v_item_location il group by item_key
      ) s1 
      inner join 
      (
        select item_location_key,item_key,quantity 
        from purchasing_v_item_location il 
      ) s2   
      on s1.item_key = s2.item_key  
      and s1.quantity = s2.quantity  -- 1 to many, Many locations may have an equal number of items. 
      group by s1.item_key,s1.quantity  -- out of all the locations with a max quantity pick one.
    ) s3 
    inner join purchasing_v_item_location il 
    on s3.item_location_key=il.item_location_key
  ) il -- one Location_key with a max quantity
  on i.item_key=il.item_key
  left outer join #supplier_price sp --#ItemSupplierPrice sp
  on i.item_key=sp.item_key
  -- FILTER BY PLANT 6 TOOL LIST ITEMS
  inner join #btToolListItemsInPlant8 p6 
  on i.item_no=p6.tool_no
  left outer join #btToolBossItemsInPlant8 tb -- This will help us determine which items have a toolboss location.
  on i.item_no=tb.Tool_No
  
--  where substring(il.location,1,2) = '12'  
)s1
-- The next line is for the Plex master tool list screen
--  select * from #result
-- The next line is for adding MSC Job restriction 

--  select * from #result where storage_location = 'Tool Boss'
 
select '''' + tool_no + ''',' from #result