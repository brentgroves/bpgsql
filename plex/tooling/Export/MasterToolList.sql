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
  Min_Qty	int,  -- In plex as Min_Quantity
  Tool_Life	int,
  
  Reworked_Tool_Life	int,
  Std_Reworks varchar (5), -- Maybe this is true or false for a reworked no,
  Action varchar(5), -- Not using
  Serialize int, -- 0 or 1, Only 0 for us
  
  Purchasing_Description varchar(5), -- Always blank in Alabama
  Tool_Product_Line	varchar (10), --Tool_Product_Line_Code in Plex
  Source	varchar (50), --Tool_Source in Plex
  Replenish_Qty	int,  -- In plex as Replenish_Quantity
  Supplier_Code	varchar (25), -- The items that I uploaded included supply codes but the ones that others uploaded did not.
  Price	decimal (18,4),
  Accounting_Job_No	varchar (25),
  Customer_Code	varchar (35),
  Max_Recuts	int,
  Recut_Length	decimal (9,3),
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

/*
Declare @YourTable Table ([ID] varchar(50),[ProjectDescription] varchar(50))  Insert Into @YourTable Values 
 (1,'Some Project Item or Description') -- Multiword strubg
,(2,'OneWord    ')                      -- One word with trailing blanks
,(3,NULL)                               -- A NULL value
,(4,'')                                 -- An Empty String

Select * 
      ,LengthOfLastWord = LEN(right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1))
      ,StartOfLastWord = LEN(rtrim([ProjectDescription])) - LEN(right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1))
      ,UpToLastWord = rtrim(substring(rtrim([ProjectDescription]),1,LEN(rtrim([ProjectDescription])) - LEN(right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1))))
      ,LastWord = right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1)
      ,reverse(rtrim([ProjectDescription]))
 From  @YourTable 

*/

select 
distinct tool_type
from 
(

select
Part_No
,Tool_No
,Drawing_No
,Revision
-- ,Description OldDescription
,case
  when LEN(Description) <= 50 then Description
  when LEN(Description) > 50  then 
    rtrim(substring(rtrim(substring(Description,1,50)),1,LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))))
end Description
,case
  when LEN(Description) <= 50 then Extra_Description
  when (len(substring(Description,
  LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1)),
  len(Description))) <= 195) 
  
  then substring(Description,
  LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))+1,
  len(Description)) + ' ' + Extra_Description
  else 
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
	row_number() OVER(ORDER BY i.item_no ASC) AS Row_No,
	'' Part_No,  -- This will be blank, since we don't assign part numbers to assemblies and not supply list items. 
  i.item_no Tool_No,
  '' Drawing_No, -- We don't assign a drawing to a supply list item
  '' Revision,  -- We don't have supply list item revisions 

  REPLACE(REPLACE(REPLACE(REPLACE(rtrim(i.description), ',', '###'), '"', '##@'),CHAR(10),'#@#'),CHAR(13),'#@@') Description,
--,Description
  REPLACE(REPLACE(REPLACE(REPLACE(rtrim(i.brief_description), ',', '###'), '"', '##@'),CHAR(10),'#@#'),CHAR(13),'#@@') Extra_Description,
  -- i.brief_description is varchar(50) and Extra_Description is varchar(200)
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
   '' Data_Date
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
  
  left outer join #ItemSupplierPrice sp
  on i.item_key=sp.item_key
--  where substring(il.location,1,2) = '12'  
)s1
--where substring(Tool_No,1,2) <> 'BE'
  where Tool_No in 
  (
'0000433',
'0002010',
'0002305',
'0003883',
'0004160',
'0004161',
'0004162',
'0004622',
'0005187',
'0005188',
'007157', 
'008067', 
'008120', 
'008121', 
'008122', 
'008123', 
'008124', 
'008125', 
'008126', 
'009897', 
'009898', 
'0002305',
'0002445',
'0003730',
'0003881',
'0003882',
'0003883',
'0005187',
'0005188',
'007157', 
'008064', 
'008065', 
'008067', 
'008120', 
'008121', 
'008126', 
'0003216',
'0004356',
'0004766',
'0005187',
'0005188',
'0005457',
'0005556',
'007157', 
'007973', 
'008063', 
'008131', 
'0003696',
'0003698',
'0004185',
'0005187',
'0005188',
'0005242',
'0005244',
'007157', 
'16149',  
'16150',  
'16151',  
'16152',  
'16154',  
'16157',  
'16158',  
'16159',  
'16162',  
'16165',  
'16166',  
'16183',  
'16261',  
'16524',  
'16525',  
'16526',  
'16529',  
'16712',  
'16928',  
'0000138',
'0000816',
'0003144',
'0003189',
'0003224',
'0003262',
'0003589',
'0003600',
'0004235',
'0004250',
'0005187',
'0005188',
'0005203',
'007157', 
'007811', 
'008343', 
'008611', 
'010207', 
'010560', 
'010631', 
'12627',  
'14469',  
'15500',  
'16032',  
'16299',  
'16349',  
'16631',  
'16731',  
'0003224',
'0003613',
'0004779',
'0005187',
'0005188',
'007157', 
'007891', 
'009231', 
'16287',  
'16288',  
'17113',  
'0004659',
'0005187',
'0005188',
'007157', 
'16784',  
'16791',  
'16793',  
'0003696',
'0003697',
'0003698',
'0005187',
'0005188',
'007157', 
'010771', 
'16166',  
'16784',  
'16791',  
'16793',  
'16855',  
'0000138',
'0000816',
'0003144',
'0003224',
'0003262',
'0003600',
'0005187',
'0005188',
'0005203',
'007157', 
'007811', 
'010207', 
'010560', 
'010631', 
'12627',  
'14469',  
'16032',  
'16299',  
'16349',  
'16631',  
'0003696',
'0003698',
'0005187',
'0005188',
'0005242',
'007157', 
'16149',  
'16154',  
'16159',  
'16160',  
'16162',  
'16166',  
'16183',  
'0003696',
'0003698',
'0005187',
'0005188',
'0005242',
'007157', 
'16149',  
'16154',  
'16159',  
'16160',  
'16162',  
'16166',  
'16183',  
'0003696',
'0003698',
'0005187',
'0005188',
'0005242',
'0005244',
'007157', 
'16149',  
'16150',  
'16152',  
'16154',  
'16157',  
'16159',  
'16160',  
'16162',  
'16166',  
'16183',  
'0003087',
'0003904',
'0005187',
'0005188',
'007157', 
'14233',  
'0000816',
'0003224',
'0004265',
'0005187',
'0005188',
'007157', 
'010168', 
'010223', 
'13973',  
'14233',  
'14953',  
'16376',  
'16607',  
'16610',  
'16614',  
'16615',  
'16617',  
'16618',  
'16619',  
'16632',  
'0000138',
'0000816',
'0000959',
'0000963',
'0002021',
'0003144',
'0003224',
'0003262',
'0003589',
'0003600',
'0003625',
'0004039',
'0005187',
'0005188',
'0005203',
'007157', 
'007811', 
'008009', 
'008343', 
'010560', 
'15983',  
'16032',  
'16299',  
'16349',  
'16392',  
'16631',  
'0003224',
'0004779',
'0005187',
'0005188',
'007157', 
'007891', 
'009189', 
'009231', 
'009505', 
'010896', 
'0000138',
'0000816',
'0000963',
'0002021',
'0003144',
'0003224',
'0003262',
'0003600',
'0003625',
'0004039',
'0005187',
'0005188',
'0005203',
'007157', 
'007811', 
'008009', 
'010560', 
'16032',  
'16299',  
'16349',  
'16631',  
'0000138',
'0000480',
'0000816',
'0002021',
'0003144',
'0003224',
'0003262',
'0003600',
'0005187',
'0005188',
'0005203',
'007157', 
'007396', 
'007811', 
'007894', 
'008343', 
'010560', 
'16032',  
'16349',  
'16392',  
'16631',  
'16776',  
'0000138',
'0000480',
'0000816',
'0000959',
'0002008',
'0002021',
'0003144',
'0003224',
'0003262',
'0003589',
'0003600',
'0005187',
'0005188',
'0005203',
'007157', 
'007396', 
'007811', 
'007894', 
'008009', 
'008343', 
'010560', 
'12627',  
'16032',  
'16349',  
'16392',  
'16631',  
'16776',  
'0004030',
'0005187',
'0005188',
'007157', 
'15165',  
'16697',  
'16699',  
'0004030',
'0005187',
'0005188',
'007157', 
'15165',  
'16697',  
'16699',  
'0000816',
'0003224',
'0004265',
'0005187',
'0005188',
'007157', 
'010168', 
'010223', 
'13973',  
'14233',  
'14953',  
'16376',  
'16607',  
'16610',  
'16614',  
'16615',  
'16617',  
'16618',  
'16619',  
'16632',  
'0004659',
'0005187',
'0005188',
'007157', 
'010771', 
'14870',  
'16784',  
'16790',  
'16791',  
'0003696',
'0003697',
'0003698',
'0005187',
'0005188',
'007157', 
'010771', 
'16166',  
'16784',  
'16790',  
'16791',  
'16855',  
'0003244',
'0003491',
'0003662',
'0004292',
'0005187',
'0005188',
'007157', 
'008472', 
'010208', 
'010213', 
'010564', 
'16543',  
'16601',  
'16603',  
'16633',  
'0003189',
'0003246',
'0003999',
'0004202',
'0005187',
'0005188',
'0005288',
'006609', 
'007157', 
'12130',  
'15950',  
'16898',  
'16899',  
'0003189',
'0003246',
'0003999',
'0004202',
'0005187',
'0005188',
'0005288',
'006609', 
'007157', 
'12130',  
'15950',  
'16898',  
'16899',  
'0005187',
'0005188',
'0005398',
'007157', 
'14217',  
'16690',  
'16824',  
'16825',  
'16826',  
'16827',  
'16828',  
'16829',  
'16832',  
'16833',  
'16834',  
'16835',  
'16836',  
'16837',  
'16838',  
'16839',  
'16840',  
'16841',  
'16842',  
'16843',  
'16844',  
'0003696',
'0003698',
'0004185',
'0005187',
'0005188',
'0005242',
'0005244',
'007157', 
'16149',  
'16150',  
'16151',  
'16152',  
'16154',  
'16157',  
'16158',  
'16159',  
'16162',  
'16165',  
'16166',  
'16183',  
'16524',  
'16525',  
'16526',  
'16529',  
'16712',  
'16928',  
'0003244',
'0003491',
'0003662',
'0004292',
'0005187',
'0005188',
'007157', 
'008472', 
'010208', 
'010213', 
'010564', 
'16543',  
'16601',  
'16603',  
'16633'   
)
)s
/*

select * from part_v_tool_type
select 
-- count(*) cnt
distinct s1.item_type
from 
(
  select 
  top 100 
  i.item_no,
  it.item_type, -- nulls are NOT allowed
  ig.item_group,
  ic.item_category --nulls are NOT allowed
  from purchasing_v_item i
  left outer join purchasing_v_item_type it
  on i.item_type_key=it.item_type_key  --1 to 1
  left outer join purchasing_v_item_group ig
  on i.item_group_key=ig.item_group_key --1 to 1
  left outer join purchasing_v_item_category ic
  on i.item_category_key=ic.item_category_key  --1 to 1
--  where it.item_type not in ('Maintenance',	'Customer Packaging','Obsolete')	-- 19,010
)s1  

where substring(i.item_no,1,2) <> 'BE'
*/
-- where LEN(rtrim(s1.description)) > 50
--where row_no <= 200
--where row_no > 200

--  where 
-- item_no in ('16303')
--i.item_no = '16293'
 -- i.active=1
--  and i.item_no not like '%[-" ]%'  -- we don't want any records with item_no containing a dash, double-quote, or space.
--  and brief_description <> ''  -- These might be in Edon already but they are not in our list to make inactive because
  -- our comparision check is for stipped leading zeros and for the brief_description to match.

-- 2753842	LB5C-5K651-BF, Control Arm,
/*
select i.item_no,s.supplier_no,s.supplier_item_no 
from purchasing_v_item_supplier s
inner join purchasing_v_item i
on s.item_key=i.item_key
where i.item_no = '16293'
*/
--16293