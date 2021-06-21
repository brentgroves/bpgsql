/*
-- drop table Plex.tool_BOM
create table Plex.part_tool_BOM (
  id int,
  pcn int,
  part_key int,
  part_no varchar(100),
  revision varchar(8),
  part_type varchar(50),
  name varchar(100),
  part_operation_key int,
  operation_no int,
  operation_key int,
  operation_code varchar(30),
  assembly_key int,
  assembly_no varchar(50),
  assy_descr varchar(100),
  tool_key int,
  tool_no varchar(50),
  tool_type_key int,
  tool_type_code varchar(20),
  tool_descr varchar(50),
  extra_description varchar(200),
  standard_tool_life int,
  rework_tool_life int,
  Quantity_Required int,
  primary key (id)
)
*/
--truncate table Plex.tool_BOM

select * from Plex.part_tool_BOM