-- mgdw.Plex.Customer_Release_Due_WIP_Ready_Loaded definition

-- Drop table

-- DROP TABLE mgdw.Plex.Customer_Release_Due_WIP_Ready_Loaded;

/*
-- create schema Plex
-- drop table Plex.PRP_Screen
create table Plex.PRP_Screen
(
ID int,
pcn int,
building_key int,
building_code varchar(50),
part_key int,
part_no varchar(100),
name varchar(100),
qty_rel int,
qty_shipped int,
qty_due int,
past_due int,
qty_wip int,
qty_ready int,
qty_loaded int,
qty_ready_or_loaded int,
primary key(ID,PCN,building_key)
)
CREATE TABLE PrpScreen (ID INT NOT NULL, pcn INT NOT NULL, building_key INT, building_code VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS, part_key INT, 
part_no VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS, name VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS, qty_rel INT, qty_shipped INT, qty_due INT, 
past_due INT, qty_wip INT, qty_ready INT, qty_loaded INT, qty_ready_or_loaded INT, PRIMARY KEY (ID, pcn));

*/
-- truncate table Plex.PRP_Screen
select count(*) from Plex.PRP_Screen -- 46
select * from Plex.PRP_Screen order by qty_rel desc

/* debug section
-- truncate table [Kors].[notification] 
select * from [Kors].[notification]
-- delete from [Kors].[notification] where notify_level = 5
select count(*) from [Kors].[notification]  -- 50

-- truncate table Kors.recipient
-- select count(*) from Kors.recipient  -- 36
select * from Kors.recipient
select * 
--into Kors.recipient0921
from Kors.recipient
--from Kors.recipient0921
-- truncate table Kors.recipient
select * from Kors.recipient --where pcn = 297638
-- delete from Kors.recipient where pcn = 297638
select * from SSIS.ScriptComplete
--update SSIS.ScriptComplete set Done = 0
*/