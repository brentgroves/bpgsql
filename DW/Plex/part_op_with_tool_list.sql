-- drop table Plex.part_op_with_tool_list;
/*
 --truncate table Plex.part_op_with_tool_list 
create table Plex.part_op_with_tool_list 
(
	ID int not null,
	pcn int not null,
	part_key int not null,
	part_no varchar(100) not null,
	name varchar(100) not null,
	part_type varchar(50) not null,
	part_source_key int not null,
	part_source varchar(50) not null,
	part_operation_key int not null,
	operation_no int not null,
	operation_key int not null,
	operation_code varchar(30) not null,
	po_description varchar(1500) not null,
	part_op_type_key int not null,
	ot_description varchar(50) not null,
	customer_part_list varchar(max) not null
);
*/

select * from Plex.part_op_with_tool_list 
select count(*) cnt from Plex.part_op_with_tool_list -- 300
select distinct pcn,part_operation_key from Plex.part_op_with_tool_list -- 300

