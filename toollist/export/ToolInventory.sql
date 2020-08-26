--"Tool No","Revision","Serial No","Quantity","Recut Level","Location","Inventory Status","Grade","Value Per Tool","Note","Supplier","Address","City","County","State","Country","Zip Code","Location Date","Location Verification Date","Service Date","Tool Builder","Origin Country","Customer Tool No","Old Tool No","Quoted Annual Capacity","Alternate Hours","Alternate Days"
create table #result
(
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
  Supplier_No	int,
  
  Address	varchar (200),  -- A supplier can be linked to many supplier_address records.
  City	varchar (60),
  County	varchar (50),  -- NO COUNTY IN COMMON_V_SUPPLIER SO THIS MUST BE LINKED TO COMMON SUPPLIER_ADDRESS
  State	varchar (50),
  Country	varchar (20),
  Zip	varchar (10),
  Location_Date	datetime,   --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Location_Verification_Date	datetime, --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Service_Date	datetime, 		--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon			
  Tool_Builder	varchar (50), --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Origin_Country_Key	int, --  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
  Customer_Tool_No	varchar (50),	--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon					
  Old_Tool_No	varchar (50),		--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon				
  Quoted_Annual_Capacity	int,	--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon					
  Alternate_Hours	int,--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon							
  Alternate_Days	int,	--  select * from part_v_Tool_Inventory_Attributes -- 0 in Alambama and Edon
 /*
 
 -- Both part_v_tool and part_v_tool_inventory have the same supplier number
   select t.tool_no,t.Supplier_No,sa.Supplier_Code,sa.address,sa.city,sa.county,sa.state,sa.country,sa.zip,ts.Supplier_Part_No,ts.price,
  ts.Add_By,ts.Add_Date
from part_v_tool t 
left outer join part_v_Tool_Supplier ts
on t.Supplier_No=ts.Supplier_No
and t.tool_key=ts.tool_key
left outer join -- NO COUNTY IN COMMON_V_SUPPLIER SO THIS MUST BE LINKED TO COMMON SUPPLIER_ADDRESS
(
  select m.supplier_no,s.supplier_code,sa.address,sa.city,sa.county,sa.state,c.country,sa.zip
  from
  (
    select supplier_no,max(Supplier_Address_Key) supplier_address_key 
    from Common_v_Supplier_address sa group by supplier_no
    -- select distinct county from common_v_supplier_address
  ) m 
  inner join common_v_supplier_address sa 
  on m.supplier_address_key=sa.supplier_address_key
  inner join common_v_supplier s 
  on m.supplier_no=s.supplier_no
  inner join common_v_country c 
  on sa.country_key=c.country_key
  
)sa
on sa.supplier_no=t.supplier_no  -- 357

-- left outer join common_v_country c 
--on s.Country_Key=c.Country_Key
where t.supplier_no is not null  -- 178
and sa.address <> ''  -- 154 
and sa.city <> ''  -- 154
and sa.county <> ''  -- all counties are blank
and sa.state <> ''
and sa.country <> ''  -- 177
and sa.zip <> ''  -- 174
-- and c.Country_Key is null
-- and s.address = ''  -- 1
-- where t.supplier_no is null -- 179
-- or ts.supplier_no is null -- 179
-- or s.supplier_no is null  -- 179

 */


)

--"Tool No","Revision","Serial No","Quantity","Recut Level","Location","Inventory Status","Grade","Value Per Tool","Note","Supplier","Address","City","County","State","Country","Zip Code","Location Date","Location Verification Date","Service Date","Tool Builder","Origin Country","Customer Tool No","Old Tool No","Quoted Annual Capacity","Alternate Hours","Alternate Days"
/*
select 
count(*) cnt 
from part_v_tool  -- 357
where Add_By = 	11728751  -- 286

  select t.tool_no,t.Supplier_No,s.Supplier_Code,ts.Supplier_Part_No,ts.price,
  ts.Add_By,ts.Add_Date
from part_v_tool t 
inner join part_v_Tool_Supplier ts
on t.Supplier_No=ts.Supplier_No
and t.tool_key=ts.tool_key
inner join Common_v_Supplier s 
on t.supplier_no=s.supplier_no
*/

--"Tool No","Revision","Serial No","Quantity","Recut Level","Location","Inventory Status","Grade","Value Per Tool","Note","Supplier","Address","City","County","State","Country","Zip Code","Location Date","Location Verification Date","Service Date","Tool Builder","Origin Country","Customer Tool No","Old Tool No","Quoted Annual Capacity","Alternate Hours","Alternate Days"

insert into #result (
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
Supplier_No,
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
Origin_Country_Key,
Customer_Tool_No,	
Old_Tool_No,		
Quoted_Annual_Capacity,	
Alternate_Hours,
Alternate_Days	
)
select 
t.Tool_No,
'' Revision,
'' Serial_No,
1 Quantity,
0 Recut_Level,
t.storage_location Location,
'OK' Inventory_Status,
'' Grade,
0.00 Value_Per_Tool,
'' Note,
t.Supplier_No,
sa.Address,
sa.City,
sa.County,
sa.State,
sa.Country,
sa.zip,
'' Location_Date,
'' Location_Verification_Date,
'' Service_Date,
'' Tool_Builder,
'' Origin_Country_Key,
'' Customer_Tool_No,	
'' Old_Tool_No,		
'' Quoted_Annual_Capacity,	
'' Alternate_Hours,
'' Alternate_Days	


from part_v_tool t -- 357
left outer join -- NO COUNTY IN COMMON_V_SUPPLIER SO THIS MUST BE LINKED TO COMMON SUPPLIER_ADDRESS
(
  select m.supplier_no,s.supplier_code,sa.address,sa.city,sa.county,sa.state,c.country,sa.zip
  from
  (
    select supplier_no,max(Supplier_Address_Key) supplier_address_key 
    from Common_v_Supplier_address sa group by supplier_no
    -- select distinct county from common_v_supplier_address
  ) m 
  inner join common_v_supplier_address sa 
  on m.supplier_address_key=sa.supplier_address_key
  inner join common_v_supplier s 
  on m.supplier_no=s.supplier_no
  inner join common_v_country c 
  on sa.country_key=c.country_key
  
)sa
on t.supplier_no=sa.supplier_no
where t.Add_By = 	11728751  -- 286

select * from #result
---select Tool_Serial_No,* from part_v_tool_inventory