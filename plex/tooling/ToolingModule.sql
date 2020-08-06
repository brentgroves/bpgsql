Declare @PCN int
	set @PCN = 300757  -- Alabama
--	set @PCN = 300758  -- Albion
-- select top 100 tool_no,min_quantity,extra_description,note,* from part_v_tool_e where Plexus_Customer_No = @PCN

-- select top 100 tool_no,min_quantity,description,extra_description,note,* from part_v_tool_e where Plexus_Customer_No = @PCN -- supply list item
-- select distinct part_key, operation_key from part_v_tool_assembly  --null
-- select distinct part_key, operation_key from part_v_tool_assembly_part  --null
-- select * part_v_Tool_BOM_e b  

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

select top 100
p.part_no,p.revision,p.name,p.part_type,
o.operation_no,
a.assembly_no,a.description,
t.tool_no,t.min_quantity,tt.tool_type_code,t.Storage_Location,i.quantity,i.Tool_Serial_No,t.Serialize_Individuals,t.description,t.extra_description
from 
part_v_part p
inner join part_v_part_operation o  -- 2
on p.part_key=o.part_key  --1 to many
inner join part_v_tool_assembly_part_e ap  -- 12
on p.part_key=ap.part_key --1 to many
and o.operation_key=ap.operation_key
-- select * from part_v_tool_assembly_part_e where part_key = 2585595  --12
inner join part_v_tool_assembly_e a  -- 12
on ap.assembly_key=a.assembly_key
inner join 
(
select distinct Plexus_Customer_No,assembly_key,tool_key from part_v_Tool_BOM_e b 
) b  --87
on a.assembly_key=b.assembly_key -- 1 to many
inner join part_v_tool_e t  -- 87
on b.tool_key=t.tool_key -- 1 to 1
inner join part_v_tool_type_e tt
on t.tool_type_key=tt.tool_type_key  --1 to 1
inner join part_v_Tool_Inventory_e i
on t.tool_key=i.tool_key
where 
p.Plexus_Customer_No = @PCN
and o.Plexus_Customer_No = @PCN  
and ap.PCN = @PCN 
and a.Plexus_Customer_No = @PCN
and b.Plexus_Customer_No = @PCN
and t.Plexus_Customer_No = @PCN
and tt.Plexus_Customer_No = @PCN
and i.Plexus_Customer_No = @PCN
and p.part_key = 2585595  --2
order by a.assembly_no,t.tool_no

/*

select top 100
p.part_key,p.part_no,p.revision,p.name,p.part_type,
o.operation_no,
--ap.part_key,ap.operation_key,
a.assembly_no,a.description,a.update_date,
-- ap.part_key,ap.operation_key,
b.tool_key,b.assembly_key,
t.tool_no,t.min_quantity,t.description,t.extra_description
from 
part_v_part p
inner join part_v_part_operation o  -- 2
on p.part_key=o.part_key  --1 to many
inner join part_v_tool_assembly_part_e ap  -- 12
on p.part_key=ap.part_key --1 to many
and o.operation_key=ap.operation_key
-- select * from part_v_tool_assembly_part_e where part_key = 2585595  --12
inner join part_v_tool_assembly_e a  -- 12
on ap.assembly_key=a.assembly_key
inner join 
(
select distinct Plexus_Customer_No,assembly_key,tool_key from part_v_Tool_BOM_e b 
) b  --87
on a.assembly_key=b.assembly_key -- 1 to many
inner join part_v_tool_e t  -- 87
on b.tool_key=t.tool_key -- 1 to 1
where 
p.Plexus_Customer_No = @PCN
and o.Plexus_Customer_No = @PCN  
and ap.PCN = @PCN 
and a.Plexus_Customer_No = @PCN
and b.Plexus_Customer_No = @PCN
and t.Plexus_Customer_No = @PCN
and p.part_key = 2585595  --2
order by a.assembly_no,t.tool_no


--select top 100 * from part_v_part p where part_key= 2585595
select top 100 a.assembly_key, a.assembly_no,a.description,a.update_date 
from part_v_tool_assembly a 
where a.Plexus_Customer_No = @PCN
order by a.update_by desc


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