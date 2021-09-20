/*
 * Valid DW schema as of 09/07/21
 */
create schema MSC;
-- DROP TABLE mgdw.MSC.Jobs;
/*
CREATE TABLE mgdw.MSC.Jobs (
	ID int not null,
	PCN int NOT NULL,
	VMID int NOT NULL,
	JOBENABLE int NOT NULL,
	JOBNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	DESCR nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);
select * from mgdw.MSC.Jobs 
--where pcn = 300758
--where pcn = 310507
where pcn = 306766
order by vmid
SELECT * from ssis.ScriptComplete sc 
*/
/*

-- DROP TABLE mgdw.MSC.TransactionLog;

CREATE TABLE mgdw.MSC.TransactionLog (
	PCN int NULL,
	tlid numeric(27,15) NULL,
	VMID int NULL,
	transtartdatetime datetime NULL,
	TRANENDDATETIMe datetime NULL,
	TRANSCODE nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	USERNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	USERGROUP01 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	JOBNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ITEMNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	UNITCOST numeric(12,4) NULL,
	qty int NULL,
	QTYNEW int NULL,
	QTYONORDER int NULL,
	ITEMGROUP nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ITEMALIASNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	SUPPLIERNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	SUPPLIERPARTNUMBER nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);
select *
--select count(*) cnt  -- 4606
from mgdw.MSC.TransactionLog
*/
/*

-- DROP TABLE mgdw.AlbSPS.Import;
-- truncate TABLE mgdw.AlbSPS.Import;
CREATE TABLE mgdw.AlbSPS.Import (
	ID int NOT NULL,
	Description varchar(100) NULL,
	LastSuccess datetime NULL,
	PRIMARY KEY (ID)
);

declare @start_date datetime
set @start_date = '2021-04-27 00:00:00'
insert into mgdw.AlbSPS.Import (ID,Description,LastSuccess)
values (1,'AlbMSCTransactions',@start_date)
select * from mgdw.AlbSPS.Import
*/

-- DROP TABLE mgdw.Plex.Customer_Release_Due_WIP_Ready_Loaded;

/*
 * create schema Plex
select * 
from Plex.Customer_Release_Due_WIP_Ready_Loaded  
-- where building_key = 5644
-- where building_key = 5641
where building_key = 5646

**/

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
select * from Plex.part_op_with_tool_list  

**/
/*
create table Plex.part_tool_assembly
(
id int,
pcn int,
part_key int,
Part_No	varchar (100), --Part_No,
Revision	varchar (8), --Part.Revision,
name varchar(100), -- part.name
part_status varchar(50), -- part.part_status
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
-- select distinct ta.pcn,ta.part_key,ta.part_operation_key from Plex.part_tool_assembly ta
select * from ssis.ScriptComplete sc 
