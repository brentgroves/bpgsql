/*
@PCN int = 306766,
@Building_Key int = 5609,
@Part_No varchar(100) = '10216019-JT',
@Operation_No int = 120,
@CNC_Type varchar(20) = '' 
BUSCHE_ENTERPRISES_EDON_OH	REAR	4	9066440	JT/JL Front SORB STD M210 - 10216019-JT	10216019-JT
 */
select 
'BUSCHE_ENTERPRISES_EDON_OH' msc_database,
'FRONT' vending_machine,
'3' vmid,
tl.part_operation_key job_number,
tl.name + tl.part_no as job_description, 
tl.part_no Alias
from Plex.part_op_with_tool_list tl 
