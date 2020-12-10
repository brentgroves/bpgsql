/*
Avilla has no common_v_location location and group called Tool Boss.
Albion has a group called Tool Boss and a location called Tool Boss Plant 6
Ask about group name use Tool Boss?


*/
/*
create table #StateMap
(
  Abbreviation varchar(2),
  FullName varchar(50)
)
insert into #StateMap (Abbreviation,FullName)
values
('IN','Indiana'),
('IL','Illinois'),
('TX','Texas')
*/
create table #ItemSupplierPrice
(
  item_key int,
  item_no varchar (50),
  supplier_no int,
  supplier_code varchar (25),

  Address	varchar (200),  -- A supplier can be linked to many supplier_address records.
  City	varchar (60),
  County	varchar (50),  -- NO COUNTY IN COMMON_V_SUPPLIER SO THIS MUST BE LINKED TO COMMON SUPPLIER_ADDRESS
  State	varchar (50),
  -- select * from common_v_state where state like '%Ind%'
  Country	varchar (20),
  Zip	varchar (10),


  supplier_part_no varchar (50),  -- Supplier_Item_No
  supplier_std_purch_qty decimal(19,2),  -- Purchase_Quantity
  currency char (3),
  supplier_std_unit_price decimal (19,6),
  supplier_purchase_unit varchar (20),
  Supplier_Unit_Conversion decimal (18,6),
  Supplier_Lead_Time decimal (9,2)
)

insert into #ItemSupplierPrice(item_key,item_no,supplier_no,supplier_code,
Address,City,County,State,Country,Zip,  -- added these fields 12/08
supplier_part_no,supplier_std_purch_qty,currency,supplier_std_unit_price,supplier_purchase_unit,Supplier_Unit_Conversion,Supplier_Lead_Time)
(
  select 
  sp.item_key,
  i.item_no,
  sp.supplier_no,
  s.supplier_code,
  
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
      sp.price_key  -- There could be multiple price records for this vendor for different unit_keys.
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

left outer join -- There may not be a main supplier address for this supplier but there could be alternate
(
  select 
  case 
    when ms.supplier_no is null then alt.supplier_no
    else ms.supplier_no
  end supplier_no,
  case
    when ms.supplier_address_key is null then alt.supplier_address_key
    else ms.supplier_address_key 
  end supplier_address_key
  from
  (
      select supplier_no,max(Supplier_Address_Key) supplier_address_key 
      from 
      (
        select sa.supplier_no, sa.supplier_address_key, sat.supplier_address_type_code 
        from Common_v_Supplier_address sa
        inner join Common_v_Supplier_Address_Type sat 
        on sa.supplier_address_type_key = sat.supplier_address_type_key -- 1 to 1
        -- some don't have any Main address so just pick the latest address added
      ) sa
      group by supplier_no
  )alt
  left outer join
  (
      select supplier_no,max(Supplier_Address_Key) supplier_address_key 
      from 
      (
        select sa.supplier_no, sa.supplier_address_key, sat.supplier_address_type_code 
        from Common_v_Supplier_address sa
        inner join Common_v_Supplier_Address_Type sat 
        on sa.supplier_address_type_key = sat.supplier_address_type_key -- 1 to 1
        where supplier_address_type_code = 'Main'  -- some are inactive and some don't have any Main address
      ) sa
      group by supplier_no
  )ms
  on alt.supplier_no=ms.supplier_no
)ms -- supplier address chosen
on s5.supplier_no=ms.supplier_no -- 1 to 1
inner join Common_v_Supplier_address sa -- Inner join OK. We know the supplier_address_key exists.
on ms.supplier_address_key=sa.supplier_address_key -- 1 to 1
inner join common_v_country c 
on sa.country_key=c.country_key -- 1 to 1
inner join common_v_state st
on sa.country_key=st.country_key
and sa.state=st.state
  left outer join common_v_unit cu
  on sp.unit_key=cu.unit_key  --1 to 1
  left outer join common_v_currency cc
  on sp.currency_key=cc.currency_key --1 to 1
  where 
  -- i.active = 1  --16995  -- EVEN IF THE ITEM IS INACTIVE STILL PULL IT'S INFO
  i.item_no not like '%[-" ]%'  -- we don't want any records with item_no containing a dash, double-quote, or space.
  and brief_description <> ''  -- These might be in Edon already but they are not in our list to make inactive because
  -- our comparision check is for stipped leading zeros and for the brief_description to match.
  -- select count(*) from purchasing_v_item where brief_description = ''  -- 7  These 7 items will not get uploaded
  -- select count(*) from purchasing_v_item where item_no like '%[-" ]%'  --49
--  and i.item_no not like 'BE%'
--  and i.item_no not like '%R'  
)

/*
            select 
            sp.supplier_no,  -- 663575  -- 663575
            sp.item_key,
            sp.unit_price  -- pick the lowest price
            from purchasing_v_item i 
            left outer join purchasing_v_Item_Supplier_Price sp
            on i.item_key=sp.item_key
            where item_no = '0000079'
*/
-- select * from #ItemSupplierPrice where item_no = '0000079'
-- select * from #ItemSupplierPrice where supplier_code ='Carboloy'
-- select * from #ItemSupplierPrice where supplier_code = 'MSC Industrial Supply'

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
  when 'Tool Boss' = t.storage_location then 'Tool Boss Plant 6'
  else t.storage_location
  end Location,
  'OK' Inventory_Status,
  '' Grade,
  case 
    when isp.supplier_std_unit_price  is not null then isp.supplier_std_unit_price
    else pi.Average_Cost
  end Value_Per_Tool,
  -- 0.00 Value_Per_Tool,
  --select top 100 value_per_tool,* from part_v_tool_inventory where value_per_tool <> 0 -- No record in Alabamba has this
  '' Note,
  case
    when isp.supplier_code is null then ''
    else isp.supplier_code 
  end Supplier,
  t.Supplier_No,
  case 
    when isp.address is null then ''
    else isp.address
  end Address,
  case 
    when isp.city is null then ''
    else isp.city
  end City,
  case 
    when isp.County is null then ''
    else isp.County
  end County,
  case 
    when isp.State is null then ''
    else isp.State
  end State,
  case 
    when isp.Country is null then ''
    else isp.Country
  end Country,
  case 
    when isp.Zip is null then ''
    else isp.Zip
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
  from part_v_tool t -- 357
  
  /*
  left outer join -- NO COUNTY IN COMMON_V_SUPPLIER SO THIS MUST BE LINKED TO COMMON SUPPLIER_ADDRESS
  (
    select m.supplier_no,s.supplier_code,sa.address,sa.city,sa.county,sa.state,c.country,sa.zip
    from
    (
      select supplier_no,max(Supplier_Address_Key) supplier_address_key 
      from 
      (
        select sa.supplier_no, sa.supplier_address_key, sat.supplier_address_type_code 
        from Common_v_Supplier_address sa
        inner join Common_v_Supplier_Address_Type sat 
        on sa.supplier_address_type_key = sat.supplier_address_type_key -- 1 to 1
        where supplier_address_type_code = 'Main'  -- some are inactive
      ) sa
      group by supplier_no
      -- select distinct county from common_v_supplier_address
      -- select distinct state from common_v_supplier_address
      -- select distinct supplier_address_type_code from common_v_supplier_address_type -- Choose Main
    ) m 
    inner join common_v_supplier_address sa 
    on m.supplier_address_key=sa.supplier_address_key
    inner join common_v_supplier s 
    on m.supplier_no=s.supplier_no
    inner join common_v_country c 
    on sa.country_key=c.country_key
    
  )sa
  on t.supplier_no=sa.supplier_no
  left outer join common_v_supplier s 
  on t.supplier_no=s.supplier_no
  */
  
  left outer join #ItemSupplierPrice isp
  on t.tool_no=isp.item_no
  and t.supplier_no=isp.supplier_no  -- 1 to 1 I hope
--  and s.supplier_no=i.supplier_no  -- put this info in the #ItemSupplierPrice table
  left outer join purchasing_v_item pi
  on t.tool_no=pi.item_no
  where t.Add_By = 	11728751  -- 286 -- Brent
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
where Row_No > 350

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