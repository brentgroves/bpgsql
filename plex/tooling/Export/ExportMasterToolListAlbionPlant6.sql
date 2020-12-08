/*
START: Work on Plant 6 first should be the easist since mostly knuckles.
1. Create set of all Albion ToolList items for plant 8. How to handle toolboss-plt11 containing diff case parts?  Ask for Customer/PartFamily/Operation or import from toolboss itself.
2. Create set of all Albion ToolBoss items for plant 8.
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
('0000010'),  
('0000042'),  
('0000056'),  
('0000057'),  
('0000079'),  
('0000081'),  
('0000103'),  
('0000162'),  
('0000227'),  
('0000252'),  
('0000267'),  
('0000343'),  
('0000344'),  
('0000349'),  
('0000355'),  
('0000359'),  
('0000369'),  
('0000370'),  
('0000414'),  
('0000417'),  
('0000426'),  
('0000429'),  
('0000430'),  
('0000431'),  
('0000444'),  
('0000466'),  
('0000490'),  
('0000500'),  
('0000553'),  
('0000557'),  
('0000574'),  
('0000575'),  
('0000598'),  
('0000601'),  
('0000611'),  
('0000622'),  
('0000623'),  
('0000634'),  
('0000636'),  
('0000637'),  
('0000644'),  
('0000646'),  
('0000653'),  
('0000655'),  
('0000667'),  
('0000678'),  
('0000680'),  
('0000692'),  
('0000708'),  
('0000718'),  
('0000720'),  
('0000723'),  
('0000730'),  
('0000733'),  
('0000741'),  
('0000754'),  
('0000755'),  
('0000766'),  
('0000768'),  
('0000778'),  
('0000781'),  
('0000783'),  
('0000783R'), 
('0000791'),  
('0000802'),  
('0000803'),  
('0000804'),  
('0000810'),  
('0000813R'), 
('0000813RR'),
('0000829R'), 
('0000855'),  
('0000863'),  
('0000864'),  
('0000890'),  
('0000922'),  
('0000923'),  
('0000924'),  
('0000926'),  
('0000951'),  
('0000954'),  
('0000959'),  
('0000988'),  
('0000994'),  
('0000999'),  
('0001154'),  
('0001160'),  
('0001162'),  
('0001447'),  
('0001459'),  
('0001505'),  
('0001580'),  
('0001602'),  
('0001632'),  
('0002005'),  
('0002006'),  
('0002008'),  
('0002009'),  
('0002010'),  
('0002020'),  
('0002021'),  
('0002022'),  
('0002048'),  
('0002082'),  
('0002124'),  
('0002143'),  
('0002144'),  
('0002145'),  
('0002192'),  
('0002219'),  
('0002269'),  
('0002285'),  
('0002326'),  
('0002336'),  
('0002357'),  
('0002375'),  
('0002378'),  
('0002397'),  
('0002402'),  
('0002440'),  
('0002443'),  
('0002592'),  
('0002605'),  
('0002661'),  
('0002664'),  
('0002726'),  
('0002727'),  
('0002729'),  
('0002732'),  
('0002760'),  
('0002770'),  
('0002785'),  
('0002806'),  
('0002810'),  
('0002827'),  
('0002856'),  
('0003003'),  
('0003024'),  
('0003054'),  
('0003084'),  
('0003086'),  
('0003087'),  
('0003091'),  
('0003093'),  
('0003104'),  
('0003105'),  
('0003107'),  
('0003108'),  
('0003110'),  
('0003112'),  
('0003113'),  
('0003114'),  
('0003115'),  
('0003118'),  
('0003126'),  
('0003144'),  
('0003145'),  
('0003146'),  
('0003151'),  
('0003155'),  
('0003177'),  
('0003178'),  
('0003179'),  
('0003180'),  
('0003184'),  
('0003189'),  
('0003191'),  
('0003198'),  
('0003199'),  
('0003224'),  
('0003241'),  
('0003246'),  
('0003250'),  
('0003262'),  
('0003268'),  
('0003296'),  
('0003356'),  
('0003396'),  
('0003411'),  
('0003417'),  
('0003466'),  
('0003480'),  
('0003490'),  
('0003491'),  
('0003495'),  
('0003594'),  
('0003597'),  
('0003598'),  
('0003603'),  
('0003625'),  
('0003626'),  
('0003662'),  
('0003677'),  
('0003679'),  
('0003680'),  
('0003694'),  
('0003696'),  
('0003700'),  
('0003704'),  
('0003730'),  
('0003738'),  
('0003740'),  
('0003747'),  
('0003752'),  
('0003822'),  
('0003829'),  
('0003837'),  
('0003838'),  
('0003839'),  
('0003840'),  
('0003841'),  
('0003842'),  
('0003844'),  
('0003845'),  
('0003846'),  
('0003847'),  
('0003848'),  
('0003849'),  
('0003850'),  
('0003851'),  
('0003852'),  
('0003853'),  
('0003854'),  
('0003855'),  
('0003856'),  
('0003857'),  
('0003858'),  
('0003859'),  
('0003864'),  
('0003866'),  
('0003872'),  
('0003881'),  
('0003882'),  
('0003883'),  
('0003887'),  
('0003904'),  
('0003930'),  
('0003934'),  
('0003935'),  
('0003962'),  
('0003964'),  
('0004002'),  
('0004011'),  
('0004017'),  
('0004021'),  
('0004022'),  
('0004025'),  
('0004032'),  
('0004033'),  
('0004041'),  
('0004050'),  
('0004088'),  
('0004093'),  
('0004137'),  
('0004184'),  
('0004195'),  
('0004225'),  
('0004235'),  
('0004241'),  
('0004245'),  
('0004246'),  
('0004258'),  
('0004260'),  
('0004270'),  
('0004273'),  
('0004290'),  
('0004293'),  
('0004313'),  
('0004360'),  
('0004405'),  
('0004439'),  
('0004509'),  
('0004556'),  
('0004582'),  
('0004596'),  
('0004597'),  
('0004598'),  
('0004599'),  
('0004600'),  
('0004601'),  
('0004602'),  
('0004615'),  
('0004654'),  
('0004677'),  
('0004704'),  
('0004757'),  
('0004761'),  
('0004769'),  
('0004777'),  
('0004779'),  
('0004860'),  
('0004985'),  
('0005013'),  
('0005016'),  
('0005028'),  
('0005038'),  
('0005143'),  
('0005147'),  
('0005187'),  
('0005188'),  
('0005203'),  
('0005206'),  
('0005305'),  
('0005324'),  
('0005331'),  
('0005411'),  
('0005492'),  
('0005526'),  
('005715'),   
('005756'),   
('006145'),   
('006227'),   
('006262'),   
('006283'),   
('006296'),   
('006328'),   
('006348'),   
('006392'),   
('006494'),   
('006511'),   
('006609'),   
('006627'),   
('006628'),   
('006648'),   
('006691'),   
('006693'),   
('006694'),   
('006695'),   
('006696'),   
('006697'),   
('006698'),   
('006699'),   
('006700'),   
('006701'),   
('006712'),   
('006713'),   
('006714'),   
('006715'),   
('006716'),   
('006763'),   
('006766'),   
('006767'),   
('006770'),   
('006773'),   
('006777'),   
('006779'),   
('006781'),   
('006801'),   
('006808'),   
('006813'),   
('006845'),   
('006846'),   
('006847'),   
('006848'),   
('006849'),   
('006856'),   
('006891'),   
('006906'),   
('006946'),   
('006948'),   
('006949'),   
('006951'),   
('006952'),   
('006981'),   
('006995'),   
('006996'),   
('006999'),   
('007000'),   
('007010'),   
('007015'),   
('007021'),   
('007039'),   
('007098'),   
('007107'),   
('007108'),   
('007111'),   
('007112'),   
('007134'),   
('007135'),   
('007136'),   
('007157'),   
('007186'),   
('007225'),   
('007226'),   
('007237'),   
('007248'),   
('007250'),   
('007255'),   
('007297'),   
('007351'),   
('007353'),   
('007359'),   
('007360'),   
('007374'),   
('007381'),   
('007391'),   
('007447'),   
('007499'),   
('007665'),   
('007706'),
('007752'), 
('007785'), 
('007809'), 
('007811'), 
('007821'), 
('007846'), 
('007859'), 
('007864'), 
('007893'), 
('007894'), 
('007902'), 
('007979'), 
('007987'), 
('007988'), 
('008035'), 
('008048'), 
('008118'), 
('008128'), 
('008154'), 
('008207'), 
('008215'), 
('008223'), 
('008251'), 
('008318'), 
('008326'), 
('008337'), 
('008358'), 
('008360'), 
('008361'), 
('008366'), 
('008375'), 
('008383'), 
('008389'), 
('008391'), 
('008397'), 
('008403'), 
('008406'), 
('008407'), 
('008409'), 
('008410'), 
('008411'), 
('008412'), 
('008413'), 
('008414'), 
('008416'), 
('008418'), 
('008419'), 
('008420'), 
('008421'), 
('008422'), 
('008423'), 
('008424'), 
('008425'), 
('008426'), 
('008429'), 
('008433'), 
('008434'), 
('008435'), 
('008472'), 
('008473'), 
('008474'), 
('008475'), 
('008476'), 
('008477'), 
('008479'), 
('008480'), 
('008484'), 
('008485'), 
('008486'), 
('008488'), 
('008492'), 
('008493'), 
('008496'), 
('008497'), 
('008500'), 
('008504'), 
('008505'), 
('008506'), 
('008507'), 
('008508'), 
('008509'), 
('008512'), 
('008513'), 
('008514'), 
('008521'), 
('008535'), 
('008539'), 
('008540'), 
('008541'), 
('008566'), 
('008570'), 
('008571'), 
('008572'), 
('008573'), 
('008574'), 
('008575'), 
('008576'), 
('008577'), 
('008578'), 
('008579'), 
('008580'), 
('008581'), 
('008582'), 
('008583'), 
('008584'), 
('008586'), 
('008587'), 
('008588'), 
('008589'), 
('008594'), 
('008596'), 
('008597'), 
('008598'), 
('008599'), 
('008600'), 
('008601'), 
('008602'), 
('008604'), 
('008605'), 
('008609'), 
('008664'), 
('008677'), 
('008678'), 
('008679'), 
('008680'), 
('008683'), 
('008685'), 
('008687'), 
('008688'), 
('008944'), 
('008987'), 
('009131'), 
('009155'), 
('009156'), 
('009157'), 
('009196'), 
('009197'), 
('009197R'),
('009198'), 
('009231'), 
('009233'), 
('009235'), 
('009238'), 
('009239'), 
('009240'), 
('009242'), 
('009243'), 
('009246'), 
('009256'), 
('009257'), 
('009258'), 
('009259'), 
('009261'), 
('009266'), 
('009267'), 
('009268'), 
('009289'), 
('009292'), 
('009312'), 
('009328'), 
('009356'), 
('009366'), 
('009402'), 
('009403'), 
('009406'), 
('009412'), 
('009416'), 
('009456'), 
('009459'), 
('009460'), 
('009462'), 
('009475'), 
('009478'), 
('009487'), 
('009496'), 
('009500'), 
('009508'), 
('009528'), 
('009728'), 
('009729'), 
('009791'), 
('009792'), 
('009802'), 
('009806'), 
('009831'), 
('009832'), 
('009834'), 
('009838'), 
('009863'), 
('009865'), 
('009868'), 
('009871'), 
('009872'), 
('009884'), 
('009891'), 
('009929'), 
('009976'), 
('009984'), 
('009992'), 
('010002'), 
('010067'), 
('010077'), 
('010110'), 
('010123'), 
('010137'), 
('010172'), 
('010192'), 
('010193'), 
('010208'), 
('010299'), 
('010302'), 
('010306'), 
('010338'), 
('010346'), 
('010546'), 
('010547'), 
('010559'), 
('010576'), 
('010584'), 
('010631'), 
('010808'), 
('010826'), 
('010834'), 
('010950'), 
('011075'), 
('12102'),  
('12129'),  
('12159'),  
('12214'),  
('12231'),  
('12740'),  
('12741'),  
('12818'),  
('12819'),  
('12821'),  
('12822'),  
('12875'),  
('12991'),  
('13017'),  
('13018'),  
('13223'),  
('13509'),  
('13510'),  
('13753'),  
('13754'),  
('13755'),  
('13756'),  
('13821'),  
('13931'),  
('13934'),  
('14006'),  
('14159'),  
('14163'),  
('14164'),  
('14205'),  
('14234'),  
('14321'),  
('14367'),  
('14394'),  
('14395'),  
('14658'),  
('14683'),  
('14687'),  
('14709'),  
('14710'),  
('14711'),  
('14712'),  
('14773'),  
('14855'),  
('14901'),  
('14902'),  
('14994'),  
('14995'),  
('14999'),  
('15091'),  
('15147'),  
('15234'),  
('15314'),  
('15367'),  
('15513'),  
('15520'),  
('15522'),  
('15684'),  
('15718'),  
('15721'),  
('15736'),  
('15834'),  
('15843'),  
('15865'),  
('15979'),  
('15980'),  
('15981'),  
('15982'),  
('16107'),  
('16169'),  
('16170'),  
('16172'),  
('16173'),  
('16174'),  
('16179'),  
('16180'),  
('16195'),  
('16197'),  
('16211'),  
('16217'),  
('16458'),  
('16492'),  
('16547'),  
('16637'),  
('16641'),  
('16671'),  
('16743'),  
('16953'),  
('17001'),  
('17002'),  
('17007'),  
('17022'),  
('17023'),  
('17024'),  
('17086'),  
('17100')  
-- select * from #btToolListItemsInPlant6

-- 721 Plant #6 Tool List Items

create table #btToolBossItemsInPlant6 
(
  Tool_No	varchar (50)
)

insert into #btToolBossItemsInPlant6 (Tool_No)
values 
('0000010'),
('0000042'),
('0000056'),
('0000057'),
('0000079'),
('0000081'),
('0000103'),
('0000162'),
('0000227'),
('0000252'),
('0000267'),
('0000343'),
('0000344'),
('0000349'),
('0000355'),
('0000359'),
('0000369'),
('0000370'),
('0000414'),
('0000417'),
('0000426'),
('0000429'),
('0000430'),
('0000431'),
('0000444'),
('0000466'),
('0000490'),
('0000500'),
('0000553'),
('0000557'),
('0000574'),
('0000575'),
('0000653'),
('0000863'),
('0000864'),
('0000926'),
('0000951'),
('0000954'),
('0000959'),
('0000988'),
('0000999'),
('0001154'),
('0001160'),
('0001162'),
('0001505'),
('0001580'),
('0001602'),
('0002005'),
('0002006'),
('0002008'),
('0002009'),
('0002010'),
('0002020'),
('0002021'),
('0002022'),
('0002048'),
('0002082'),
('0002124'),
('0002143'),
('0002144'),
('0002145'),
('0002219'),
('0002269'),
('0002326'),
('0002336'),
('0002375'),
('0002378'),
('0002397'),
('0002592'),
('0002732'),
('0002760'),
('0002770'),
('0003003'),
('0003024'),
('0003084'),
('0003086'),
('0003087'),
('0003144'),
('0003145'),
('0003146'),
('0003178'),
('0003179'),
('0003180'),
('0003224'),
('0003262'),
('0003268'),
('0003396'),
('0003417'),
('0003480'),
('0003490'),
('0003491'),
('0003594'),
('0003597'),
('0003603'),
('0003625'),
('0003677'),
('0003696'),
('0003700'),
('0003704'),
('0003730'),
('0003752'),
('0003837'),
('0003838'),
('0003842'),
('0003844'),
('0003846'),
('0003847'),
('0003854'),
('0003855'),
('0003864'),
('0003866'),
('0003881'),
('0003882'),
('0003883'),
('0003887'),
('0003930'),
('0003934'),
('0003935'),
('0003962'),
('0003964'),
('0004025'),
('0004184'),
('0004405'),
('0004556'),
('0004582'),
('0004600'),
('0004601'),
('0004677'),
('0004704'),
('0004985'),
('0005016'),
('0005028'),
('0005038'),
('0005143'),
('0005147'),
('0005187'),
('0005188'),
('0005203'),
('0005206'),
('0005305'),
('0005324'),
('0005331'),
('006227'), 
('006296'), 
('006328'), 
('006348'), 
('006627'), 
('006628'), 
('006694'), 
('006695'), 
('006713'), 
('006714'), 
('006715'), 
('006763'), 
('006767'), 
('006770'), 
('006773'), 
('006777'), 
('006779'), 
('006781'), 
('006808'), 
('006846'), 
('006847'), 
('006848'), 
('006952'), 
('006995'), 
('006996'), 
('006999'), 
('007000'), 
('007010'), 
('007021'), 
('007039'), 
('007107'), 
('007108'), 
('007157'), 
('007186'), 
('007250'), 
('007255'), 
('007351'), 
('007353'), 
('007391'), 
('007499'), 
('007706'), 
('007752'), 
('007785'), 
('007809'), 
('007811'), 
('007821'), 
('007846'), 
('007859'), 
('007864'), 
('007893'), 
('007894'), 
('007902'), 
('007979'), 
('007988'), 
('008035'), 
('008118'), 
('008128'), 
('008154'), 
('008207'), 
('008215'), 
('008223'), 
('008251'), 
('008318'), 
('008326'), 
('008337'), 
('008358'), 
('008366'), 
('008383'), 
('008389'), 
('008409'), 
('008410'), 
('008411'), 
('008412'), 
('008413'), 
('008414'), 
('008422'), 
('008434'), 
('008435'), 
('008472'), 
('008475'), 
('008476'), 
('008477'), 
('008484'), 
('008485'), 
('008488'), 
('008492'), 
('008497'), 
('008500'), 
('008505'), 
('008508'), 
('008509'), 
('008514'), 
('008535'), 
('008540'), 
('008541'), 
('008566'), 
('008571'), 
('008572'), 
('008573'), 
('008574'), 
('008575'), 
('008576'), 
('008578'), 
('008581'), 
('008582'), 
('008584'), 
('008586'), 
('008588'), 
('008589'), 
('008596'), 
('008601'), 
('008602'), 
('008604'), 
('008664'), 
('008688'), 
('008944'), 
('009155'), 
('009157'), 
('009196'), 
('009198'), 
('009235'), 
('009240'), 
('009242'), 
('009256'), 
('009259'), 
('009261'), 
('009289'), 
('009312'), 
('009328'), 
('009356'), 
('009366'), 
('009402'), 
('009403'), 
('009412'), 
('009456'), 
('009460'), 
('009478'), 
('009487'), 
('009496'), 
('009728'), 
('009729'), 
('009802'), 
('009865'), 
('009871'), 
('009992'), 
('010002'), 
('010110'), 
('010137'), 
('010193'), 
('010338'), 
('010546'), 
('010547'), 
('010559'), 
('010808'), 
('011075'), 
('12129'),  
('12740'),  
('12741'),  
('12819'),  
('12822'),  
('13223'),  
('13753'),  
('13755'),  
('13931'),  
('14159'),  
('14394'),  
('14710'),  
('14855'),  
('14901'),  
('14902'),  
('14999'),  
('15091'),  
('15147'),  
('15314'),  
('15513'),  
('15522'),  
('15721'),  
('15736'),  
('15843'),  
('15865'),  
('15979'),  
('15980'),  
('15982'),  
('16169'),  
('16170'),  
('16197'),  
('16217'),  
('16458'),  
('16547'),  
('16637'),  
('16641'),  
('16671'),  
('16953'),  
('17001'),  
('17007'),  
('17022'),  
('17086'),  
('17100')  
-- select * from #btToolBossItemsInPlant6
-- 1326 - 986 = 340 
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
select r.Tool_No,Tool_type,r.Description,Price,Extra_Description,storage_location,supplier_code
from #result r
left join purchasing_v_item i 
on r.tool_no=i.item_no
where len(i.description)>50  -- only 1 record.
*/

select r.Tool_No,Tool_type,Description,Price,Extra_Description,storage_location,supplier_code
from #result r
left outer join #btToolBossItemsInPlant6 p6
on r.tool_no=p6.tool_no
-- where p6.tool_no is null  -- 381
where p6.tool_no is not null  -- 340
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