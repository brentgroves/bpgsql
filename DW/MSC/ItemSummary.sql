-- create schema AlbSPS
-- myDW.AlbSPS.ItemSummary definition

-- Drop table

-- DROP TABLE mgdw.AlbSPS.ItemSummary;
-- TRUNCATE TABLE mgdw.AlbSPS.ItemSummary;
/*
CREATE TABLE mgdw.AlbSPS.ItemSummary (
	pcn int NULL,
	VMID int NULL,
	ITEMNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	DESCR nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ITEMALIASNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	SUPPLIERNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	SUPPLIERPARTNUMBER nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	MINQTY int NULL,
	MAXQTY int NULL,
	onhandqty int NULL,
	locationexist int NULL,
	UNITCOST numeric(12,4) NULL,
	datecreated datetime NULL,
	DATELASTMODIFIED datetime NULL
);

*/
--truncate table MSC.ItemSummary;
select * from MSC.ItemSummary
-- truncate table Kors.recipient
select * from Kors.recipient
select * from SSIS.ScriptComplete
-- truncate table mgdw.MSC.Jobs 
select * from mgdw.MSC.Jobs 

--update SSIS.ScriptComplete set Done = 0

/*
 * Import all Busche Managed item numbers with unit cost 
 */
select * 
from AlbSPS.ItemSummary
where SUPPLIERNUMBER = 'BUSCHE'

/*
 * Can't find 8035 CPMT 21.52 MQ AP25N
 */
-- drop table MSC.ItemSummary
--CREATE TABLE MSC.ItemSummary (pcn INT, VMID INT, ITEMNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, DESCR NVARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ITEMALIASNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, SUPPLIERNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, SUPPLIERPARTNUMBER NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS, MINQTY INT, MAXQTY INT, onhandqty INT, locationexist INT, UNITCOST NUMERIC(12,4), datecreated DATETIME, 
DATELASTMODIFIED DATETIME,
primary key(pcn,VMID,itemnumber));
