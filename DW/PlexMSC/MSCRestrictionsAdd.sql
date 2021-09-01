select 'TOOL SETTER' group_id,'TOOL SETTER' group_description,b.part_operation_key job_number,b.name + '-' + b.part_no as job_description ,
CAST(CAST(b.tool_no AS INT) AS VARCHAR(50)) item_number
--,b.tool_no,b.part_no,b.operation_no,b.operation_code,b.assembly_no,b.assy_descr,b.tool_no,b.tool_type_code, b.tool_descr,b.storage_location 
from Plex.part_tool_BOM b
where b.part_no = '10216019-JT'
and b.tool_no not like '%[A-Z-]%'  --17558
--and b.storage_location like '%Tool%'
and b.storage_location = 'Tool Boss'
--'SOT' user_group_id,'SOT CERTIFIED' group_description,
union 
select 'SOT' user_group_id,'SOT CERTIFIED' group_description,b.part_operation_key job_number,b.name + '-' + b.part_no as job_description ,
CAST(CAST(b.tool_no AS INT) AS VARCHAR(50)) item_number, storage_location 
--,b.tool_no,b.part_no,b.operation_no,b.operation_code,b.assembly_no,b.assy_descr,b.tool_no,b.tool_type_code, b.tool_descr,b.storage_location 
from Plex.part_tool_BOM b
where b.part_no = '10216019-JT'
and b.tool_no not like '%[A-Z-]%'  --17558
--and b.storage_location like '%Tool%'
and b.storage_location = 'Tool Boss'
-- select count(*) from Plex.part_tool_BOM b  -- 1548

select top 10 * from Plex.part_tool_BOM b