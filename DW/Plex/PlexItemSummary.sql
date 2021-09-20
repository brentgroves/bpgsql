/*
 * -- create schema AlbSPS
-- myDW.AlbSPS.ItemSummary definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.ItemSummary;
truncate table AlbSPS.ItemSummary

create schema AlbSPS
CREATE TABLE mgdw.MSC.ItemSummary (
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

CREATE TABLE mgdw.MSC.ItemSummaryBak (
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
select * from MSC.ItemSummaryBak
*/

-- mgdw.btl.btJobsIn9B definition

-- Drop table

-- DROP TABLE mgdw.btl.btJobsIn9B;
--TRUNCATE table btl.btJobsIn9BBak
--select * from btl.btJobsIn9BBak
-- select * from btl.btJobsIn9B
CREATE TABLE mgdw.btl.btJobsIn9BBak (
	JobNumber int NULL,
	Descr nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	alias nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Plant int NOT NULL,
	CreatedBy varchar(4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	DATECREATED varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	DATELASTMODIFIED varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	LASTMODIFIEDBY varchar(4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	JOBENABLE int NOT NULL,
	DATERANGEENABLE int NOT NULL
);
