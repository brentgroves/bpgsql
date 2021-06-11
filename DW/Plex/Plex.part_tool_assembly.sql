/*
create table Plex.part_tool_assembly
(
id int,
pcn int,
part_key int,
Part_No	varchar (100), --Part_No,
Revision	varchar (8), --Part.Revision,
name varchar(100), -- part.name
part_status varchar(50), part.part_status
part_operation_key int, 
operation_no int,
operation_key int,
operation_code varchar(30),
assembly_key int,
Assembly_No	varchar (50), --Assembly No,
-- Tool_Assembly_Type	varchar (50), --Tool Assembly Type,
description	varchar (100), --assembly.description,
)
*/
-- truncate table Plex.part_tool_assembly
-- select * from Plex.part_tool_assembly
select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta