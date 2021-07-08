/*
This is the best algorithm to determine the supplier price from plex
*/
/*
Working Set
Set of valid item_supplier and item_supplier_price records
*/
  select s.pcn,s.item_key,i.item_no,s.supplier_no,cs.supplier_code,s.sort_order,s.resource_id,p.price_key,p.unit_price,p.purchase_quantity,p.unit_key,p.currency_key,p.unit_conversion supplier_unit_conversion,
  p.lead_time supplier_lead_time

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
  select s.pcn,s.item_key,s.item_no,s.supplier_no,s.supplier_code,s.sort_order,s.resource_id,s.price_key,s.unit_price,s.purchase_quantity,s.unit_key,s.currency_key,s.supplier_unit_conversion,s.supplier_lead_time
  into #supplier_price
  from #supplier_price_record p
  inner join #isp s
  on p.pcn = s.pcn
  and p.item_key=s.item_key
  and p.resource_id=s.resource_id 
  and p.price_key = s.price_key

--  left outer join -- There may not be a main supplier address for this supplier but there could be alternate
--  (
  select  -- 2787
  alt.pcn,
  case 
    when ms.supplier_no is null then alt.supplier_no
    else ms.supplier_no
  end supplier_no,
  case
    when ms.supplier_address_key is null then alt.supplier_address_key
    else ms.supplier_address_key 
  end supplier_address_key
  into #supplier_address
  from
  (
      select sa.pcn,supplier_no,max(Supplier_Address_Key) supplier_address_key 
      from 
      (
        select sa.pcn,sa.supplier_no, sa.supplier_address_key, sat.supplier_address_type_code 
        from Common_v_Supplier_address_e sa
        inner join Common_v_Supplier_Address_Type_e sat 
        on sa.pcn=sat.pcn
        and sa.supplier_address_type_key = sat.supplier_address_type_key -- 1 to 1
        where sa.pcn = @PCN
        -- some don't have any Main address so just pick the latest address added
      ) sa
      group by sa.pcn,supplier_no
  )alt
  left outer join
  (
      select sa.pcn,supplier_no,max(Supplier_Address_Key) supplier_address_key 
      from 
      (
        select sa.pcn,sa.supplier_no, sa.supplier_address_key, sat.supplier_address_type_code 
        from Common_v_Supplier_address_e sa
        inner join Common_v_Supplier_Address_Type_e sat 
        on sa.pcn=sat.pcn
        and sa.supplier_address_type_key = sat.supplier_address_type_key -- 1 to 1
        where supplier_address_type_code = 'Main'  -- some are inactive and some don't have any Main address
        and sa.pcn = @PCN
      ) sa
      group by sa.pcn,supplier_no
  )ms
  on alt.pcn=ms.pcn
  and alt.supplier_no=ms.supplier_no
--  )ms -- supplier address chosen
--  on s.pcn = ms.pcn
--  and s.supplier_no=ms.supplier_no -- 1 to 1
--select count(*) from #supplier_price

select sp.*, sa.supplier_address_key
into #supplier_price_address
from #supplier_price sp 
left outer join #supplier_address sa 
on sp.pcn=sa.pcn
and sp.supplier_no=sa.supplier_no

--select count(*) from #supplier_price_address

select   
  spa.pcn,
  spa.item_key,
  spa.item_no,
  spa.supplier_no,
  spa.supplier_code,
  
  case 
    when sa.address is null then s.address
    else sa.address
  end Address,
  case 
    when sa.city is null then s.city
    else sa.city
  end City,
  case 
    when sa.County is null then ''
    else sa.County
  end County,
  case 
    when st.State is null then s.State
    else st.name
  end State,
  case 
    when c.Country is null then s.Country
    else c.Country
  end Country,
  case 
    when sa.Zip is null then s.Zip
    else sa.Zip
  end Zip,
  si.Supplier_Item_No supplier_part_no,
  spa.unit_price,
  spa.purchase_quantity supplier_std_purch_qty,
  case
  when cu.unit is null then 'EA' 
  else cu.unit
  end supplier_purchase_unit,
  spa.supplier_unit_conversion,
  spa.supplier_lead_time
into #inventory_info
from #supplier_price_address spa
inner join Common_v_Supplier_address_e sa -- Inner join OK. We know the supplier_address_key exists.
on spa.pcn=sa.pcn
and spa.supplier_address_key=sa.supplier_address_key -- 1 to 1
inner join common_v_country c -- no enterprise version one record does not have a country_key
--left outer join common_v_country c -- no enterprise version one record does not have a country_key
on sa.country_key=c.country_key -- 1 to 1
--where c.country_key is null
inner join common_v_state st  -- dropped 33 records
on sa.country_key=st.country_key
and sa.state=st.state
inner join common_v_supplier_e s
on spa.pcn = s.plexus_customer_no
and spa.supplier_no=s.supplier_no  --1 to 1
inner join purchasing_v_item_supplier_e si
on spa.pcn=si.pcn
and spa.item_key=si.item_key
and spa.supplier_no=si.supplier_no  -- 1 to 1
left outer join common_v_unit_e cu
on spa.pcn=cu.plexus_customer_no
and spa.unit_key=cu.unit_key  --1 to 1
left outer join common_v_currency cc
on spa.currency_key=cc.currency_key --1 to 1

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

create table #result
(
  Row_No int,
  Tool_No	varchar (50),
  Revision	varchar (15),  -- Not the same as part_v_tool.revision because of size difference
  -- Alabama
  -- select Revision from part_v_tool_inventory where Revision <> ''  -- 0
  Serial_No	varchar (50), -- Plex Tool_Serial_No
  -- Alabama
  -- select Tool_Serial_No from part_v_tool_inventory where Tool_Serial_No <> ''  -- 1
  -- select Tool_Serial_No from part_v_tool_inventory where Tool_Serial_No = ''  -- 1106
  Quantity	int,
    -- Alabama
  -- select quantity from part_v_tool_inventory where quantity <> 1  -- 0
  Recut_Level	int,
    -- Alabama
  -- select Recut_Level from part_v_tool_inventory where Recut_Level <> 0  -- 0
  Location	varchar (50),
/*
-- Alabama and Edon always equal
    select
    t.tool_no,
    t.storage_location,
    i.location 
    from part_v_tool_inventory i 
    left outer join part_v_tool t
    on i.tool_key=t.tool_key  
*/

  Inventory_Status	varchar (50),
  /*
      select     
    s.Tool_Inventory_Status_Key,
    s.description
    from part_v_tool_inventory i 
    inner join part_v_tool_inventory_status s 
    on i.Tool_Inventory_Status_Key= s.tool_inventory_status_key
    where s.description <> 'OK'  -- 0

  select * from part_v_tool_inventory_status
  */   
  
  Grade	varchar (40),
  -- Alabama
  --select grade    from part_v_tool_inventory i where grade <> ''  -- 0
  Value_Per_Tool	decimal (9,2),
  -- Alabama
  --select Value_Per_Tool from part_v_tool_inventory i  where Value_Per_Tool <> 0.00  -- 0
  Note	varchar (500),
  -- select Note from part_v_tool_inventory i  where Note <> ''  -- 0
  -- Supplier	int,
  Supplier	varchar (25),
  Supplier_No int, -- DEBUG ONLY
  Address	varchar (200),  -- A supplier can be linked to many supplier_address records.
  City	varchar (60),
  County	varchar (50),  -- NO COUNTY IN COMMON_V_SUPPLIER SO THIS MUST BE LINKED TO COMMON SUPPLIER_ADDRESS
  State	varchar (50),
  -- select * from common_v_state where state like '%Ind%'
  Country	varchar (20),
  Zip	varchar (10),
  Location_Date	datetime,   --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Location_Verification_Date	datetime, --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Service_Date	datetime, 		--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon			
  Tool_Builder	varchar (50), --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Origin_Country	VARCHAR(20),	
  Customer_Tool_No	varchar (50),	--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon					
  Old_Tool_No	varchar (50),		--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon				
  Quoted_Annual_Capacity	int,	--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon					
  Alternate_Hours	int,--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon							
  Alternate_Days	int,	--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon


)

--"Tool No","Revision","Serial No","Quantity","Recut Level","Location","Inventory Status","Grade","Value Per Tool","Note","Supplier","Address","City","County","State","Country","Zip Code","Location Date","Location Verification Date","Service Date","Tool Builder","Origin Country","Customer Tool No","Old Tool No","Quoted Annual Capacity","Alternate Hours","Alternate Days"

--"Tool No","Revision","Serial No","Quantity","Recut Level","Location","Inventory Status","Grade","Value Per Tool","Note","Supplier","Address","City","County","State","Country","Zip Code","Location Date","Location Verification Date","Service Date","Tool Builder","Origin Country","Customer Tool No","Old Tool No","Quoted Annual Capacity","Alternate Hours","Alternate Days"
-- Tool No,             Serial No,            Recut Level,I             nventory Status,           Value Per Tool,         Supplier,                                              Zip Code,  Location Date,  Location Verification Date,  Service Date,  Tool Builder,  Origin Country,  Customer Tool No,  Old Tool No,  Quoted Annual Capacity,  Alternate Hours,  Alternate Days
insert into #result (
Row_No,
Tool_No,
Revision,
Serial_No,
Quantity,
Recut_Level,
Location,
Inventory_Status,
Grade,
Value_Per_Tool,
Note,
Supplier,
Supplier_no, -- DEBUG ONLY
Address,
City,
County,
State,
Country,
zip,
Location_Date,
Location_Verification_Date,
Service_Date,
Tool_Builder,
Origin_Country,
Customer_Tool_No,	
Old_Tool_No,		
Quoted_Annual_Capacity,	
Alternate_Hours,
Alternate_Days	
)
select
row_number() OVER(ORDER BY Tool_No ASC) AS Row_No,
Tool_No,
Revision,
Serial_No,
Quantity,
Recut_Level,
Location,
Inventory_Status,
Grade,
Value_Per_Tool,
Note,
Supplier,
supplier_no,-- DEBUG ONLY
REPLACE(REPLACE(convert(varchar(max),Address), CHAR(13), ','), CHAR(10), ' ')  Address,
--REPLACE(convert(varchar(max),Address), CHAR(13), '')
-- Address,
City,
County,
-- select * from part_v_tool_inventory
-- '' State,  
 State,  -- CAN'T GET THIS TO WORK
Country,
zip,
Location_Date,
Location_Verification_Date,
Service_Date,
Tool_Builder,
Origin_Country,
Customer_Tool_No,	
Old_Tool_No,		
Quoted_Annual_Capacity,	
Alternate_Hours,
Alternate_Days
-- select count(*)
from 
(
  select 
  t.Tool_No,
  '' Revision,
  '' Serial_No,
  1 Quantity,
  0 Recut_Level,
  case 
  when 'Tool Boss' = t.storage_location then 'Tool Boss Plant 8'
  else t.storage_location
  end Location,
  'OK' Inventory_Status,
  '' Grade,
  case 
    when ii.unit_price  is not null then ii.unit_price
    else pi.Average_Cost
  end Value_Per_Tool,
  -- 0.00 Value_Per_Tool,
  --select top 100 value_per_tool,* from part_v_tool_inventory where value_per_tool <> 0 -- No record in Alabamba has this
  '' Note,
  case
    when ii.supplier_code is null then ''
    else ii.supplier_code 
  end Supplier,
  t.Supplier_No,
  case 
    when ii.address is null then ''
    else ii.address
  end Address,
  case 
    when ii.city is null then ''
    else ii.city
  end City,
  case 
    when ii.County is null then ''
    else ii.County
  end County,
  case 
    when ii.State is null then ''
    else ii.State
  end State,
  case 
    when ii.Country is null then ''
    else ii.Country
  end Country,
  case 
    when ii.Zip is null then ''
    else ii.Zip
  end Zip,
  '' Location_Date,
  '' Location_Verification_Date,
  '' Service_Date,
  '' Tool_Builder,
--  	pi.country_of_origin Origin_Country,  -- always null
--  i.'' Origin_Country_Key,
  '' Origin_Country,
  '' Customer_Tool_No,	
  '' Old_Tool_No,		
  '' Quoted_Annual_Capacity,	
  '' Alternate_Hours,
  '' Alternate_Days	
  
  -- select count(*)
  from part_v_tool_e t -- 357

  left outer join #inventory_info ii
  on  t.plexus_customer_no=ii.pcn
  and t.tool_no=ii.item_no
  and t.supplier_no=ii.supplier_no  -- 1 to 1 I hope
--  and s.supplier_no=i.supplier_no  -- put this info in the #ItemSupplierPrice table
  left outer join purchasing_v_item pi
  on t.tool_no=pi.item_no
--  where t.Add_By = 	11728751  -- 286 -- Brent
where t.plexus_customer_no = @PCN
and t.tool_no in ('0003144',
'0002008',
'0003262',
'16420',
'16468',
'16470',
'16471',
'0003241',
'0003512',
'16111',
'16130',
'16405',
'16406',
'16407',
'16409',
'16680',
'010449',
'007221',
'12623',
'16461',
'0002357',
'16417',
'15149',
'16465',
'16404',
'16408',
'16462',
'0002827',
'16469',
'16472',
'0003088',
'010053',
'0003397',
'010695',
'008431',
'16110',
'16412',
'16410',
'12622',
'16467' )
--and t.add_date > '07/06/21'
)s1
-- select distinct country_of_origin from purchasing_v_item
-- select count(*) from #result -- 721
select -- Row_No,
Tool_No,
Revision,
Serial_No,
Quantity,
Recut_Level,
Location,
Inventory_Status,
Grade,
Value_Per_Tool,
Note,
Supplier,
-- supplier_no, -- DEBUG ONLY
Address,
City,
County,
State,
Country,
zip,
'' Location_Date,  -- This gets added as 1/1/1900 12:00:00 if you don't do this
'' Location_Verification_Date, -- This gets added as 1/1/1900 12:00:00 if you don't do this
'' Service_Date, -- This gets added as 1/1/1900 12:00:00 if you don't do this
Tool_Builder,
Origin_Country,
Customer_Tool_No,	
Old_Tool_No,		
Quoted_Annual_Capacity,	
Alternate_Hours,
Alternate_Days	
from #result -- 721
-- where Row_No <= 350
--where Row_No > 350

/*
select * from common_v_location
where location like 'ToolBoss%'
select t.tool_no,i.Last_Action,i.* 
from part_v_tool_inventory i 
inner join part_v_tool t 
on i.tool_key= t.tool_key
where i.Add_By = 	11728751 
*/
--where i.Add_By <> 	11728751 

-- select * from part_v_tool_inventory i where Add_By <>	11728751 
-- where Address like '%' + CHAR(10) + '%'  -- 18
-- where Address like '%' + CHAR(13) + '%'  -- 18
-- where tool_no = '15500'
