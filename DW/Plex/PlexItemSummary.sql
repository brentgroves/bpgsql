/*
 * -- create schema AlbSPS
-- myDW.AlbSPS.ItemSummary definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.ItemSummary;
truncate table AlbSPS.ItemSummary

create schema AlbSPS
CREATE TABLE mgdwdb.AlbSPS.ItemSummary (
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
select * from AlbSPS.ItemSummary
*/
