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
select * from AlbSPS.ItemSummary

/*
 * Import all Busche Managed item numbers with unit cost 
 */
select * 
from AlbSPS.ItemSummary
where SUPPLIERNUMBER = 'BUSCHE'

/*
 * Can't find 8035 CPMT 21.52 MQ AP25N
 */

