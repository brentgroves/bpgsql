-- delete from AlbSPS.Jobs where DESCR like 'DANA%'
select * from AlbSPS.Jobs j 
-- drop table Plex.part_op_with_tool_list;
create table Plex.part_op_with_tool_list 
(
	ID int not null,
	pcn int not null,
	part_key int not null,
	part_no varchar(100) not null,
	part_type varchar(50) not null,
	part_source_key int not null,
	part_source varchar(50) not null,
	part_operation_key int not null,
	operation_code varchar(30) not null,
	po_description varchar(1500) not null,
	part_op_type_key int not null,
	ot_description varchar(50) not null,
	customer_part_list varchar(max) not null,
);



truncate table Plex.Customer_Release_Due_WIP_Ready_Loaded
select * from Plex.Customer_Release_Due_WIP_Ready_Loaded

--drop table Plex.Customer_Release_Due_WIP_Ready_Loaded
create table Plex.Customer_Release_Due_WIP_Ready_Loaded
(
pcn int,
building_key int,
part_key int,
qty_due int,
qty_shipped int,
qty_wip int,
qty_ready int,
qty_loaded int,
qty_ready_or_loaded int
)
-- qty_ready_or_loaded int

select * from Plex.Customer_Release_Due_WIP_Ready_Loaded


*/
select * from myDW.AlbSPS.Jobs
select getdate()
SELECT DATEADD(day, 31, GETDATE())
select DATEADD(dd, DATEDIFF(dd, 0, DATEADD(day, 31, GETDATE())), 0)
select DATEADD("dd", DATEDIFF("dd", 0, DATEADD("day", 31, GETDATE())), 0)
select DATEDIFF(dd, 0, DATEADD(day, 31, GETDATE()))

DATEADD("day", 31, GETDATE())
select DATEDIFF(dd, 0, DATEADD(day, 31, GETDATE()))
