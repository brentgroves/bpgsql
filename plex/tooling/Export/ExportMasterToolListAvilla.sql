--select count(*) from ( --16995
--select count(*) from ( --27673
-- Item locations are not in Avilla PCN so run ExportMasterToolListAvilla from Albion PCN. 

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

select * from part_v_tool_type  -- 11

*/
create table #btToolBossItemsInPlant11
(
  Tool_No	varchar (50)
)

insert into #btToolBossItemsInPlant11 (Tool_No)
values ('0000030'),
('0000220'),
('0000430'),
('0000433'),
('0000466'),
('0000551'),
('0000553'),
('0000562'),
('0000575'),
('0000586'),
('0000734'),
('0000864'),
('0000952'),
('0000966'),
('0000979'),
('0000984'),
('0000985'),
('0002005'),
('0002008'),
('0002009'),
('0002010'),
('0002021'),
('0002022'),
('0002252'),
('0002349'),
('0003050'),
('0003087'),
('0003144'),
('0003180'),
('0003224'),
('0003244'),
('0003262'),
('0003270'),
('0003271'),
('0003422'),
('0003458'),
('0003491'),
('0003625'),
('0003682'),
('0003696'),
('0003730'),
('0003881'),
('0003882'),
('0003883'),
('0003934'),
('0003966'),
('0003995'),
('0004030'),
('0004161'),
('0004162'),
('0004216'),
('0004218'),
('0004405'),
('0004811'),
('0005010'),
('0005021'),
('0005028'),
('0005031'),
('0005114'),
('0005137'),
('0005181'),
('0005187'),
('0005188'),
('0005193'),
('0005203'),
('0005207'),
('0005288'),
('0005305'),
('005920'), 
('006218'), 
('006754'), 
('006825'), 
('006832'), 
('006833'), 
('006836'), 
('006838'), 
('006839'), 
('006876'), 
('006877'), 
('006878'), 
('006898'), 
('006900'), 
('006944'), 
('007157'), 
('007221'), 
('007319'), 
('007320'), 
('007398'), 
('007681'), 
('007802'), 
('007806'), 
('007808'), 
('007809'), 
('007811'), 
('007854'), 
('007947'), 
('007979'), 
('008009'), 
('008051'), 
('008206'), 
('008321'), 
('008343'), 
('008366'), 
('008431'), 
('008456'), 
('008472'), 
('008517'), 
('008528'), 
('008560'), 
('008562'), 
('008604'), 
('009152'), 
('009192'), 
('009193'), 
('009194'), 
('009329'), 
('009684'), 
('009768'), 
('009992'), 
('010050'), 
('010128'), 
('010168'), 
('010449'), 
('010559'), 
('010560'), 
('010578'), 
('010614'), 
('010721'), 
('010728'), 
('010734'), 
('010912'), 
('011003'), 
('011756'), 
('011812'), 
('12114'),  
('12212'),  
('12622'),  
('12623'),  
('12796'),  
('12986'),  
('13108'),  
('13110'),  
('13115'),  
('13295'),  
('13778'),  
('13915'),  
('13916'),  
('13917'),  
('13918'),  
('13919'),  
('13922'),  
('13925'),  
('13926'),  
('13927'),  
('13973'),  
('13987'),  
('13989'),  
('13990'),  
('13991'),  
('13992'),  
('13994'),  
('13996'),  
('14025'),  
('14027'),  
('14028'),  
('14030'),  
('14031'),  
('14032'),  
('14034'),  
('14035'),  
('14038'),  
('14039'),  
('14044'),  
('14051'),  
('14052'),  
('14053'),  
('14057'),  
('14058'),  
('14059'),  
('14060'),  
('14062'),  
('14063'),  
('14064'),  
('14065'),  
('14066'),  
('14067'),  
('14069'),  
('14070'),  
('14071'),  
('14072'),  
('14073'),  
('14074'),  
('14079'),  
('14080'),  
('14081'),  
('14083'),  
('14085'),  
('14086'),  
('14120'),  
('14192'),  
('14194'),  
('14195'),  
('14199'),  
('14207'),  
('14209'),  
('14211'),  
('14212'),  
('14215'),  
('14217'),  
('14218'),  
('14219'),  
('14228'),  
('14231'),  
('14235'),  
('14242'),  
('14244'),  
('14245'),  
('14262'),  
('14263'),  
('14264'),  
('14303'),  
('14306'),  
('14308'),  
('14319'),  
('14332'),  
('14334'),  
('14336'),  
('14341'),  
('14343'),  
('14344'),  
('14357'),  
('14358'),  
('14361'),  
('14362'),  
('14365'),  
('14453'),  
('14454'),  
('14455'),  
('14457'),  
('14506'),  
('14628'),  
('14635'),  
('14693'),  
('14716'),  
('14718'),  
('14723'),  
('14724'),  
('14742'),  
('14747'),  
('14748'),  
('14757'),  
('14760'),  
('14789'),  
('14799'),  
('14800'),  
('14857'),  
('14858'),  
('14859'),  
('14860'),  
('14861'),  
('14864'),  
('14879'),  
('14883'),  
('14953'),  
('14965'),  
('14973'),  
('15033'),  
('15041'),  
('15051'),  
('15066'),  
('15097'),  
('15123'),  
('15147'),  
('15165'),  
('15171'),  
('15286'),  
('15299'),  
('15374'),  
('15506'),  
('15610'),  
('15611'),  
('15613'),  
('15620'),  
('15626'),  
('15838'),  
('15839'),  
('15856'),  
('15875'),  
('15876'),  
('15877'),  
('15878'),  
('15890'),  
('15892'),  
('15894'),  
('15908'),  
('15977'),  
('16038'),  
('16110'),  
('16111'),  
('16130'),  
('16219'),  
('16376'),  
('16383'),  
('16405'),  
('16406'),  
('16461'),  
('16514'),  
('16520'),  
('16544'),  
('16545'),  
('16602'),  
('16605'),  
('16609'),  
('16612'),  
('16613'),  
('16616'),  
('16632'),  
('16633'),  
('16636'),  
('16690'),  
('16708'),  
('16713'),  
('16728'),  
('16733'),  
('16734'),  
('16741'),  
('16758'),  
('16826'),  
('16829'),  
('16833'),  
('16834'),  
('16837'),  
('16838'),  
('16840'),  
('16841'),  
('16843'),  
('16844'),  
('16853'),  
('16854'),  
('16856'),  
('16857'),  
('16858'),  
('16859'),  
('16860'),  
('16906'),  
('16907'),  
('16910'),  
('16911'),  
('16916'),  
('16922'),  
('16923'),  
('16940'),  
('16954'),  
('16983'),  
('17018'),  
('17028'),  
('17032'),  
('17034'),  
('17044'),  
('17045'),  
('17069'),  
('17070'),  
('17232')
-- select * from #btToolBossItemsInPlant11

create table #item_location_avilla
(
item_location_key int,
Item_Key	int,
Location	varchar (50),
Quantity	decimal (18,2)	
)
insert into #item_location_avilla(item_location_key,item_key,location,quantity)
select item_location_key,item_key,location,quantity
from purchasing_v_item_location il 
where substring(il.location,1,2) = '11'  -- 651


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
	'' Part_No,  -- This will be blank, since we assign part numbers to assemblies and not supply list items. 
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
  case
    when tb.Tool_No is null and ila.location is not null then ila.location  -- Avilla locations if possible
    when tb.Tool_No is null and ila.location is null then il.location -- Fall back to non-Avilla locations of null
    -- when tb.Tool_No is null then il.location
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
      max(s2.item_location_key) item_location_key  -- picked 1 location to use
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
  ) il -- Location_key with the greatest quantity
  on i.item_key=il.item_key
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
      max(s2.item_location_key) item_location_key  -- picked 1 location to use
      from
      (
        select item_key, max(quantity) quantity 
        from #item_location_avilla il group by item_key 
      ) s1 
      inner join 
      (
        select item_location_key,item_key,quantity 
        from #item_location_avilla il 
      ) s2   
      on s1.item_key = s2.item_key  
      and s1.quantity = s2.quantity  -- 1 to many
      group by s1.item_key,s1.quantity
    ) s3 
    inner join #item_location_avilla il
    on s3.item_location_key=il.item_location_key
  ) ila -- Location_key with the greatest quantity in Avilla
  on i.item_key=ila.item_key
  left outer join #ItemSupplierPrice sp
  on i.item_key=sp.item_key
  left outer join #btToolBossItemsInPlant11 tb
  on i.item_no=tb.Tool_No
--  where substring(il.location,1,2) = '12'  
)s1
--where substring(Tool_No,1,2) <> 'BE'
  where Tool_No in 
  (
'007052', 
'0004201',
'007681', 
'14334',  
'0004437',
'14069',  
'14243',  
'13108',  
'15650',  
'008456', 
'16632',  
'0003589',
'14691',  
'14742',  
'14864',  
'16545',  
'16110',  
'15774',  
'009152', 
'14058',  
'14308',  
'0003271',
'006873', 
'14402',  
'16805',  
'14245',  
'13926',  
'12622',  
'12796',  
'13778',  
'006872', 
'14025',  
'14192',  
'14965',  
'16542',  
'14052',  
'010053', 
'14438',  
'0004265',
'13919',  
'16407',  
'0003155',
'14035',  
'14876',  
'15200',  
'009996', 
'0003245',
'15874',  
'010050', 
'14053',  
'0003995',
'13076',  
'14879',  
'0003577',
'007320', 
'0003085',
'0000826',
'14842',  
'14074',  
'14089',  
'0005181',
'007802', 
'14120',  
'0003257',
'12212',  
'0004264',
'15675',  
'16826',  
'006832', 
'14066',  
'0004811',
'14748',  
'15049',  
'15890',  
'16861',  
'007106', 
'14322',  
'16513',  
'16520',  
'010346', 
'14347',  
'16609',  
'15839',  
'006875', 
'13990',  
'14033',  
'14070',  
'0000923',
'15609',  
'16111',  
'16909',  
'16829',  
'006754', 
'006831', 
'007811', 
'14344',  
'15620',  
'0005137',
'14953',  
'16815',  
'009890', 
'006923', 
'15947',  
'009861', 
'0004041',
'0004256',
'0004137',
'15201',  
'010945', 
'15674',  
'13728',  
'13996',  
'14443',  
'16943',  
'15623',  
'0004302',
'14037',  
'010564', 
'12103',  
'010728', 
'009703', 
'16624',  
'006251', 
'011811', 
'16052',  
'0004238',
'010912', 
'0005187',
'13918',  
'0003144',
'13110',  
'16620',  
'010634', 
'14455',  
'14448',  
'16851',  
'009388', 
'14445',  
'14244',  
'0000816',
'0003512',
'16923',  
'008266', 
'16220',  
'15897',  
'0004760',
'011812', 
'0003224',
'009992', 
'011050', 
'13973',  
'14228',  
'0003883',
'007852', 
'14024',  
'15977',  
'010721', 
'12073',  
'006825', 
'009386', 
'0004162',
'14236',  
'15892',  
'0005398',
'14403',  
'16835',  
'16376',  
'16619',  
'16409',  
'0005031',
'14348',  
'15853',  
'14718',  
'14442',  
'16472',  
'13115',  
'17034',  
'15123',  
'15832',  
'14764',  
'15506',  
'0003934',
'007260', 
'14049',  
'14031',  
'15906',  
'0000984',
'011205', 
'16053',  
'16406',  
'006878', 
'12976',  
'008230', 
'15838',  
'14188',  
'16461',  
'16911',  
'0000220',
'0000562',
'010865', 
'0003730',
'0003889',
'16907',  
'006648', 
'0004594',
'14060',  
'14973',  
'010734', 
'009768', 
'0002786',
'12623',  
'13987',  
'16838',  
'010128', 
'14071',  
'14194',  
'16617',  
'16939',  
'0004405',
'14044',  
'14039',  
'0002022',
'17026',  
'15613',  
'009292', 
'14693',  
'12246',  
'0003351',
'0000466',
'0003091',
'010213', 
'13992',  
'14064',  
'15910',  
'011756', 
'0004086',
'009364', 
'14264',  
'14027',  
'14082',  
'15374',  
'16470',  
'16841',  
'16813',  
'14792',  
'008563', 
'14883',  
'0003852',
'0003407',
'16471',  
'14305',  
'14759',  
'008472', 
'007947', 
'007806', 
'14729',  
'15912',  
'16544',  
'010589', 
'010168', 
'15909',  
'16130',  
'14454',  
'0002252',
'16837',  
'0003175',
'13976',  
'14357',  
'15895',  
'16797',  
'0003050',
'16038',  
'14572',  
'16618',  
'15857',  
'16807',  
'0000551',
'14717',  
'009675', 
'0003682',
'0003107',
'0004226',
'14198',  
'16832',  
'13920',  
'14635',  
'15517',  
'13829',  
'008528', 
'14506',  
'13116',  
'15852',  
'16602',  
'16802',  
'0003966',
'0003525',
'13922',  
'12970',  
'15610',  
'15908',  
'0004218',
'12231',  
'14453',  
'14491',  
'0004154',
'14652',  
'16733',  
'14358',  
'12986',  
'16912',  
'0004160',
'14204',  
'16801',  
'0003270',
'0004229',
'0004792',
'009997', 
'010576', 
'14073',  
'16627',  
'006876', 
'010631', 
'008517', 
'16467',  
'16680',  
'16983',  
'15147',  
'15875',  
'16404',  
'17044',  
'12298',  
'14028',  
'0004439',
'16842',  
'14195',  
'15001',  
'0004239',
'006944', 
'006900', 
'14747',  
'006880', 
'009469', 
'14038',  
'006801', 
'15380',  
'14242',  
'14365',  
'16418',  
'16823',  
'16854',  
'006837', 
'14051',  
'14215',  
'15206',  
'16824',  
'13752',  
'14032',  
'14263',  
'14757',  
'0004003',
'16728',  
'010633', 
'0003904',
'14083',  
'16636',  
'16908',  
'0005495',
'16799',  
'007808', 
'14363',  
'15891',  
'13991',  
'16628',  
'17033',  
'16853',  
'0005514',
'009684', 
'16860',  
'14057',  
'14861',  
'0005305',
'13295',  
'13921',  
'15894',  
'15907',  
'16825',  
'14726',  
'15856',  
'0003422',
'008453', 
'0003189',
'16839',  
'010614', 
'13989',  
'17041',  
'14072',  
'009411', 
'16856',  
'0004161',
'0003180',
'011003', 
'14045',  
'17070',  
'008366', 
'16809',  
'17232',  
'14050',  
'14345',  
'0000985',
'010189', 
'006218', 
'0002009',
'14340',  
'15611',  
'16954',  
'0003625',
'16800',  
'006838', 
'14193',  
'15505',  
'16830',  
'0003458',
'14335',  
'14790',  
'16614',  
'0004480',
'0004924',
'16916',  
'0000979',
'14336',  
'13997',  
'15893',  
'010223', 
'0002923',
'0000776',
'0004858',
'14043',  
'14343',  
'008672', 
'14078',  
'14859',  
'16412',  
'16836',  
'14200',  
'0005288',
'16610',  
'16413',  
'16105',  
'0003881',
'005840', 
'14332',  
'14054',  
'14233',  
'14211',  
'14450',  
'14860',  
'006836', 
'0004216',
'008051', 
'010560', 
'007398', 
'011329', 
'0000678R',
'16886',  
'16469',  
'006898', 
'15149',  
'15600',  
'009295', 
'14218',  
'010449', 
'0002010',
'14908',  
'17032',  
'0004656',
'16613',  
'16462',  
'0005595',
'14217',  
'14235',  
'14079',  
'14081',  
'14789',  
'16758',  
'0003087',
'14346',  
'14362',  
'0000030',
'008009', 
'010834', 
'0000430',
'0005188',
'0000966',
'15889',  
'006877', 
'15299',  
'15179',  
'006986', 
'16734',  
'16633',  
'008431', 
'006839', 
'14303',  
'0004270',
'0005531',
'010696', 
'15165',  
'0005028',
'16821',  
'15286',  
'0000864',
'0002349',
'14725',  
'008321', 
'0003954',
'13916',  
'14799',  
'16810',  
'16414',  
'16910',  
'16922',  
'010632', 
'14262',  
'0004030',
'16940',  
'14231',  
'005920', 
'17045',  
'14219',  
'009142', 
'14306',  
'0004039',
'16905',  
'0000636',
'14065',  
'010208', 
'17039',  
'0004566',
'0005193',
'14342',  
'14446',  
'007979', 
'010559', 
'14041',  
'15051',  
'14843',  
'15878',  
'0005114',
'010653', 
'15619',  
'16615',  
'009453', 
'007809', 
'14360',  
'15877',  
'16405',  
'14067',  
'14760',  
'008604', 
'14333',  
'14366',  
'16840',  
'16543',  
'14612',  
'16997',  
'0003882',
'007497', 
'16605',  
'16795',  
'007205', 
-- '14144',  
'14061',  
'0003397',
'15002',  
'009329', 
'17068',  
'14457',  
'16942',  
'14302',  
'14447',  
'16603',  
'16420',  
'16819',  
'14212',  
'12102',  
'16514',  
'14470',  
'0002008',
'14085',  
'16408',  
'16811',  
'010144', 
'0005010',
'009887', 
'14062',  
'007221', 
'14350',  
'14059',  
'16741',  
'15626',  
'16417',  
'16828',  
'006833', 
'0003994',
'007854', 
'009192', 
'16383',  
'0003156',
'14723',  
'007682', 
'008343', 
'14857',  
'008273', 
'009776', 
'16941',  
'0003505',
'0003612',
'0004274',
'0002357',
'009191', 
'16794',  
'0000952',
'007703', 
'14030',  
'15041',  
'16270',  
'16858',  
'14199',  
'14090',  
'0002005',
'0000575',
'13927',  
'13995',  
'14437',  
'16857',  
'008560', 
'14440',  
'16607',  
'15171',  
'008594', 
'0003262',
'0003696',
'15896',  
'16448',  
'0004262',
'010080', 
'14441',  
'14800',  
'15905',  
'16827',  
'007157', 
'0005207',
'15913',  
'0003241',
'007319', 
'0003856',
'007886', 
'010314', 
'008562', 
'14063',  
'0000734',
'14207',  
'15205',  
'009387', 
'14341',  
'14034',  
'14439',  
'16859',  
'0004057',
'14056',  
'14319',  
'12114',  
'16612',  
'16812',  
'009194', 
'13915',  
'13994',  
'16468',  
'010578', 
'16385',  
'16465',  
'0002021',
'0003491',
'14444',  
'16885',  
'17042',  
'16219',  
'006924', 
'010695', 
'0002445',
'14206',  
'16708',  
'13923',  
'14400',  
'0003244',
'16818',  
'17027',  
'16713',  
'17043',  
'14401',  
'0000586',
'14449',  
'16608',  
'15876',  
'006829', 
'13925',  
'14084',  
'16913',  
'16843',  
'16690',  
'008526', 
'0005203',
'0004692',
'16852',  
'010096', 
'0004982',
'008206', 
'14209',  
'14197',  
'009193', 
'14301',  
'0002849',
'14628',  
'14080',  
'15097',  
'14716',  
'17018',  
'0004752',
'16936',  
'16914',  
'13924',  
'14086',  
'14307',  
'009000', 
'16442',  
'0002827',
'009670', 
'16616',  
'12334',  
'15064',  
'010950', 
'16906',  
'14339',  
'14361',  
'15612',  
'12187',  
'17069',  
'16817',  
'14858',  
'0004909',
'15033',  
'13917',  
'14254',  
'0000433',
'16601',  
'14042',  
'16410',  
'16833',  
'16844',  
'0000553',
'0000678',
'0005021',
'16622',  
'15066',  
'16803',  
'14724',  
'15204',  
'17028',  
'0003088',
'010435', 
'16804',  
'006830', 
'010694', 
'14026',  
'16834'  
)
-- )

select * from #result
where Row_No < 500

/*
)s2
)s

)s1
left outer join part_v_tool_type tt  -- 11
on s1.tool_type=tt.tool_type_code
where tt.tool_type_code is null
*/
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