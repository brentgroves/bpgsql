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

/*
CREATE TABLE myDW.SSIS.ScriptComplete (
	ID int NOT NULL,
	Description varchar(100) NOT NULL,
	Done bit NOT NULL,
	PRIMARY KEY (ID)
);
INSERT into ssis.ScriptComplete (ID,Description,Done)
values
(1,'Albion MSC Jobs Import',0),
(2,'Albion MSC TransactionLog Import',0),
(3,'Customer Release Due WIP Ready Loaded',0)
*/
select * from ssis.ScriptComplete
/*
CREATE TABLE myDW.AlbSPS.DWInfo (
	ID int NOT NULL,
	LastImportSPSAlb datetime NULL,
	PRIMARY KEY (ID)
);
INSERT into myDW.AlbSPS.DWInfo (ID,LastImportSPSAlb)
values (1,'2021-04-27 00:00:00')
UPDATE myDW.AlbSPS.DWInfo 
set LastImportSPSAlb = '2021-04-27 00:00:00'
where id = 1;
DELETE from myDW.AlbSPS.DWInfo 
where LastImportSPSAlb = '2021-04-27 00:00:00'
*/
select LastImportAlbion from myDW.MSC.Import where id = 1
-- create SCHEMA Plex
select * from myDW.AlbSPS.TransactionLog tl 

-- myDW.MSC.Job definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.Jobs;  -- 37
/*
CREATE TABLE myDW.AlbSPS.Jobs (
	PCN int NOT NULL,
	JOBNUMBER nvarchar(32) NOT NULL,
	DESCR nvarchar(50) NOT NULL
);

CREATE TABLE Plex.Test (
    Name varchar(100)
)
select * from Plex.test2

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
