/*
START: 
1. Create set of all Albion ToolList items.
2. Create set of all Albion ToolBoss items.
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
  i.active = 1 -- Do we care if the item is active or not? 
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

create table #btToolListItemsInPlant2Through9 
(
  Tool_No	varchar (50)
)

-- insert into #btToolBossItemsInPlant2Through9 (Tool_No)
-- values ('0000030'),


create table #btToolBossItemsInPlant2Through9 
(
  Tool_No	varchar (50)
)

insert into #btToolBossItemsInPlant2Through9 (Tool_No)
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
-- select * from #btToolBossItemsInPlant2Through9

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
  left outer join #ItemSupplierPrice sp
  on i.item_key=sp.item_key
  left outer join #btToolBossItemsInPlant2Through9 tb -- This will help us determine which items have a toolboss location.
  on i.item_no=tb.Tool_No
--  where substring(il.location,1,2) = '12'  
)s1
/*
-- Filter only a subset of Albion ToolList Items.
  where Tool_No in 
  (
'009196', 
'17100',  
'009240', 
'15721',  
'008318', 
'008485' 
,'007864' 
,'010338' 
,'008410' 
,'0003396'
,'008435' 
,'009155' 
,'13753'  
,'17022'  
,'14710'  
,'0000951'
,'16547'  
,'010559' 
,'15843'  

)
*/
-- )

select * from #result
where Tool_No = '008431'
/*
select Tool_No,Tool_type,Description,Price from #result
where Tool_No 
in 
(
'009196', 
'17100',  
'009240', 
'15721',  
'008318', 
'008485' 
,'007864' 
,'010338' 
,'008410' 
,'0003396'
,'008435' 
,'009155' 
,'13753'  
,'17022'  
,'14710'  
,'0000951'
,'16547'  
,'010559' 
,'15843'  
-- select Tool_type_key,tool_type_code from part_v_tool_type order by tool_type_code
)
*/

