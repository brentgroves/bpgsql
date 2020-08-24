-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location

Declare @PCN int
	set @PCN = 300757  -- Alabama
--	set @PCN = 300758  -- Albion
-- select top 100 tool_no,min_quantity,extra_description,note,* from part_v_tool_e where Plexus_Customer_No = @PCN
-- select * from part_v_tool_status
-- select top 100 tool_no,min_quantity,description,extra_description,note,* from part_v_tool_e where Plexus_Customer_No = @PCN -- supply list item
-- select distinct part_key, operation_key from part_v_tool_assembly  --null
-- select distinct part_key, operation_key from part_v_tool_assembly_part  --null
-- select * part_v_Tool_BOM_e b  
-- select * from part_v_tool_life
-- uncheck serialize
 -- NO WORKCENTER
-- btl.tool_no=plx.assembly_no
-- btl.opdescription=plx.assembly_description,
-- btl.tlm.operationNumber=plx.part_operation.operation_no
-- btl.itemNumber=plex.tool_no
-- plx.min_quantity=1
-- btl.tooltype=plx.tool_type_code
-- btl.customer_partFamily_operation,=plx.storage_location
-- plx.serial_individuals doesn't make us track each tool; each tool does not create serial_no
-- plx.description = plx.purchasing_v_item.manufacturer_no 
-- btl.tooltype = plx.extra_description.
-- select count(*) cnt from part_v_part_operation  -- 436
-- select distinct part_operation_key from part_v_part_operation  -- 436
-- select count(*) from part_v_tool where part_key is null  -- 1171
-- select top 10 drawing_no,revision,* from part_v_tool where revision <> '' 

/*
-- non Enterprise query
-- ENTERPRISE QUERY WONT WORK IF THE TOOL_TYPE TABLE IS REQUIRED BECAUSE TOOL_TYPE_KEY/TOOL_TYPE_CODE IS NOT UNIQUE BETWEEN PCN
-- -- select * from part_v_tool_type_e order by tool_type_key  not distinct over PCN

Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
create table
(
Assembly_No	varchar (50), --Assembly No,
Tool_Assembly_Type	varchar (50), --Tool Assembly Type,
Description	varchar (100), --Description,
Part_No	varchar (100), --Part No,
Revision	varchar (8), --Part Revision,
Operation_Code	varchar (30), --Operation,
Tool_Assembly_Status	varchar (50),  --Tool Assembly Status
Include_In_Analysis smallint,  --Include in Analysis
Analysis_Note	varchar (500), --Analysis Note,
Note	varchar (500), -- Note,
Location varchar (5) --	I don't know what this is 
)

Assembly No=T02
substring(assembly_no,1,2)
21,
25,
OP,
T[0-6],
TF,
TM

Tool_Assembly_Type= Machining --({12,Maching}= 395,{13,Other}= 2  
Description = 4" Face Mill  -- select top 100 description from part_v_tool_assembly
Tool Assembly Status = Active
*/

-- select tool_type_code,storage_location
-- from
-- (
    select 
    --top 100
    a.assembly_no,
    -- select distinct substring(assembly_no,1,2) from part_v_tool_assembly
    at.Tool_Assembly_Type,
    a.description Description,
    p.Part_No,
    p.Revision,
    o.Operation_Code Operation,
    s.Tool_Assembly_Status,
    a.Include_In_Analysis,  -- Always = 1
    a.Analysis_Note,  -- Always blank
    '' Location, -- Don't know
    -- END OF TOOL_ASSEMBLY FIELDS
    -- select top 100 description from part_v_tool_assembly
    a.update_date
    -- at.Tool_Assembly_Type_Code,
    -- select analysis_note from part_v_tool_assembly  where analysis_note <> ''  -- 0 records
    -- select include_in_analysis from part_v_tool_assembly  where include_in_analysis <> 1  -- 0 records
    --select * from part_v_tool_assembly_type  -- 12-Machining, 13-Other
    --select count(*) from  part_v_tool_assembly where tool_assembly_type_key =  12 -- 395  
    --select count(*) from  part_v_tool_assembly where tool_assembly_type_key =  13 -- 2  


    -- select count(*) cnt from part_v_tool where drawing_no <> ''  -- all are 0
    -- select * from part_v_tool_attribute_value  -- 0 records
    -- select * from part_v_tool_attributes  -- 0 records
    -- select count(*) cnt from part_v_tool where Tool_Dimensions <> ''
    -- select count(*) cnt from part_v_tool where Storage_Section <> ''  -- all are blank
    -- select count(*) cnt from part_v_tool where Storage_Row <> ''  -- all are blank
    -- select count(*) cnt from part_v_tool where Storage_Rack_Side <> ''  -- all are blank
    -- select count(*) cnt from part_v_tool where Storage_Position <> ''  -- all are blank
    -- select count(*) cnt from part_v_tool where Auto_Pick <> 0  -- all are 0
    -- select count(*) cnt from part_v_tool where Max_Recuts <> 0  -- all are 0
    -- select count(*) cnt from part_v_tool where Customer_No is null  -- all are null
    -- select count(*) cnt from part_v_tool where Accounting_Job_Key is null  -- all but 1 is null
    -- select * from part_v_tool where supplier_no is not null  only 43
    -- select count(*) from part_v_tool  -- 1171
    -- select distinct Purchase_Description from part_v_tool
    -- select * from part_v_tool_life
    -- select distinct grade from part_v_tool
    -- select * from part_v_tool_status
    -- select distinct tool_group_code from part_v_tool_group
    -- select distinct item_category from purchasing_v_item_category i 
    --select tg.tool_group_code,ic.item_category from part_v_tool_group tg left outer join purchasing_v_item_category ic on trim(tg.tool_group_code)=trim(ic.item_category)
    --select count(*) cnt  
    -- CURRENT COUNTS ARE FOR ALABAMA  on 08/24
    --select distinct tool_group_code  -- Body,Heads,Mach,Mill
    --select count(*) cnt
    --select ap.part_key,ap.operation_key
    from part_v_tool_assembly a  -- 397
    inner join part_v_tool_assembly_type at --397
    on a.tool_assembly_type_key=at.tool_assembly_type_key  -- 1 to 1
    inner join part_v_tool_assembly_part ap  -- 833
    on ap.assembly_key=a.assembly_key  -- 1 to many
    inner join part_v_part p  -- 833
    on ap.part_key=p.part_key -- 1 to 1
    inner join part_v_operation o  -- 833
    on o.operation_key=ap.operation_key  -- 1 to 1
    inner join part_v_tool_assembly_status s -- 833
    on a.tool_assembly_status_key=s.tool_assembly_status_key  -- 1 to 1
    -- inner join part_v_tool_inventory i 
     
    --where p.part_key = 2585595  --87
    order by a.assembly_no
-- )s1
-- order by Tool_type_code,storage_location



/*
-- Enterprise query
-- ENTERPRISE QUERY WONT WORK IF THE TOOL_TYPE TABLE IS REQUIRED BECAUSE TOOL_TYPE_KEY/TOOL_TYPE_CODE IS NOT UNIQUE BETWEEN PCN
-- -- select * from part_v_tool_type_e order by tool_type_key  not distinct over PCN
-- C05013-T20P EDP 00059

DEBURR STONE    
ADJ. SCREW      
ANVIL           
ANVIL SCREW     
BURNISHER ROLLS 
CENTER DRILL    
CHAMFER TOOL    
CHIP BREAKER    
CLAMP           
CLAMP ASSEMBLY  
CLAMP SCREW     
DRILL           
DRILL TIP       
END MILL        
EZ BURR ARM     
EZ BURR INSERT  
HONING STONE    
INSERT          
INSERT SCREW    
LEVER           
LOCK PIN        
LOCK SCREW      
MINIMASTER TIPS 
MOUNTING SCREW  
PORT TOOL       
REAMER          
SCREW           
SHIM            
SHIM SCREW      
SPOT DRILL      
TAP             
WASHER          
WEDGE           
WEDGE SCREW     
CLAMP STUD      
DEBURR BLADES   
HYD. COUPLER    
SPOTFACE TOOL   
ENGRAVING       

*/
/*
select top 100
p.part_key,p.part_no,p.revision,p.name,p.part_type,
o.operation_no,
--ap.part_key,ap.operation_key,
a.assembly_no,a.description,a.update_date,
-- ap.part_key,ap.operation_key,
b.tool_key,b.assembly_key,
t.tool_no,t.min_quantity,t.description,t.extra_description
-- select count(*) cnt
from part_v_part_e p  -- 3379
inner join part_v_part_operation_e o  -- 9644
on p.part_key=o.part_key  --1 to many
inner join part_v_tool_assembly_part_e ap  -- 861
on p.part_key=ap.part_key 
and o.operation_key=ap.operation_key --1 to many
-- select * from part_v_tool_assembly_part_e where part_key = 2585595  --12
inner join part_v_tool_assembly_e a  -- 861
on ap.assembly_key=a.assembly_key  -- 1 TO 1
inner join part_v_Tool_BOM_e b  -- 3587
on a.assembly_key=b.assembly_key -- 1 to many
inner join part_v_tool_e t  -- 3587
on b.tool_key=t.tool_key -- 1 to 1
inner join 
(
-- won't work because there are several tool_type_key with many tool_type_codes.
select distinct tool_type_key,tool_type_code from part_v_tool_type_e tt -- order by tool_type_key  -- 187
) tt
on t.tool_type_key=tt.tool_type_key  -- 1 to 1
where 
--p.Plexus_Customer_No = @PCN
p.part_key = 2585595  --87
order by a.assembly_no,t.tool_no
*/





/*
-- ENTERPRISE QUERY WONT WORK BECAUSE THE TOOL_TYPE_KEY IS NOT UNIQUE BETWEEN PCN

select top 100
p.part_no,p.revision,p.name,p.part_type,
o.operation_no,
a.assembly_no,a.description,
t.tool_no,t.min_quantity,tt.tool_type_code,t.Storage_Location,i.quantity,i.Tool_Serial_No,t.Serialize_Individuals,t.description,t.extra_description
select 
count(*) cnt
from 
part_v_part_e p
inner join part_v_part_operation_e o  -- 9644
on p.part_key=o.part_key  --1 to many
inner join part_v_tool_assembly_part_e ap  -- 861
on p.part_key=ap.part_key -- 
and o.operation_key=ap.operation_key  -- 1 to many; but only Alabama has implemented the tooling module
-- select * from part_v_tool_assembly_part_e where part_key = 2585595  --12
inner join part_v_tool_assembly_e a  -- 861
on ap.assembly_key=a.assembly_key  -- 1 to 1
inner join 
(
 select distinct Plexus_Customer_No,assembly_key,tool_key from part_v_Tool_BOM_e b -- 2010
-- select Plexus_Customer_No,workcenter_key,assembly_key,tool_key from part_v_Tool_BOM_e b where workcenter_key is not null-- 0  -- workcenter_key is always null
) b  --3587
on a.assembly_key=b.assembly_key -- 1 to many
inner join part_v_tool_e t  -- 3587
on b.tool_key=t.tool_key -- 1 to 1
inner join part_v_tool_type_e tt
on t.tool_type_key=tt.tool_type_key  --1 to 1
-- select * from part_v_tool_type_e order by tool_type_key  not distinct over PCN
inner join 
(
  select distinct tt.tool_type_key,tt.tool_type_code from part_v_tool_type_e tt
 select distinct Plexus_Customer_No,assembly_key,tool_key from part_v_Tool_BOM_e b -- 2010
-- select Plexus_Customer_No,workcenter_key,assembly_key,tool_key from part_v_Tool_BOM_e b where workcenter_key is not null-- 0  -- workcenter_key is always null
) b  --3587

inner join part_v_Tool_Inventory_e i
on t.tool_key=i.tool_key
where 
p.Plexus_Customer_No = @PCN
and p.part_key = 2585595  --2
order by a.assembly_no,t.tool_no
*/

/*




select top 100 ap.*,a.assembly_no,a.description,a.update_date 
from part_v_tool_assembly a
inner join part_v_tool_assembly_part ap
on a.assembly_key= ap.assembly_key
where Plexus_Customer_No = @PCN
--and ap.part_key = 2561342
and a.assembly_key = 156644

*/


--select top 100 a.assembly_key,a.assembly_no,a.description,a.update_date from part_v_tool_assembly_e a where Plexus_Customer_No = @PCN  -- Face Mill, Drill, Fixture and part_key is not null 0 records

-- select top 100 ap.assembly_key,ap.part_key,ap.operation_key,* from part_v_tool_assembly_part_e ap where PCN = @PCN 

-- select top 100 b.tool_key,b.assembly_key,b.workcenter_key,* from part_v_Tool_BOM_e b where b.Plexus_Customer_No = @PCN

--select top 100 tool_no,min_quantity,extra_description,note,* from part_v_tool_e where Plexus_Customer_No = @PCN -- supply list item

-- select top 1000 * from part_v_tool_sub  -- No records