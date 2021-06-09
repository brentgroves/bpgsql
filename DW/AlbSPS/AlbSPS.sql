-- CREATE SCHEMA AlbSPS;
CREATE SCHEMA Mapping
-- myDW.dbo.AlbSPSJobs definition

-- Drop table

-- DROP TABLE myDW.MSC.Jobs;

CREATE TABLE myDW.MSC.Jobs (
	PCN int NOT NULL,
	JOBNUMBER nvarchar(32) NOT NULL,
	DESCR nvarchar(50) NOT NULL
);
-- TRUNCATE table  myDW.MSC.Jobs
select * from MSC.Jobs

-- DROP TABLE myDW.AlbSPS.Jobs;

CREATE TABLE myDW.dbo.Jobs (
	JOBNUMBER nvarchar(32) NULL,
	DESCR nvarchar(50) NULL
);
-- TRUNCATE table  myDW.AlbSPS.Jobs

-- DROP TABLE myDW.AlbSPS.TransactionLog;
-- TRUNCATE table myDW.AlbSPS.TransactionLog
select * from AlbSPS.TransactionLog
select j.DESCR,tl.*
select tl.USERGROUP01,tl.usernumber,j.DESCR,tl.TRANSTARTDATETIME,tl.TRANSCODE,tl.ITEMNUMBER,tl.ITEMGROUP,tl.unitcost,tl.QTY,tl.QTYNEW,tl.QTYONORDER,tl.SUPPLIERNUMBER 
from AlbSPS.TransactionLog tl 
inner join AlbSPS.Jobs j 
on tl.jobnumber=j.JOBNUMBER 
where transtartdatetime > '2021-05-06 00:00:00'

select * from myDW.AlbSPS.DWInfo  where id = 1
-- tlg account + msc
-- drop table myDW.AlbSPS.TransactionLog;
--truncate table myDW.AlbSPS.DWInfo
--INSERT into myDW.AlbSPS.DWInfo
-- values (1,'2021-05-15 00:00:00') -- Data Plant 6 tool boss came online
 values (1,'2021-04-27 00:00:00') -- Data Plant 6 tool boss came online
 --2021-05-17 19:51:52 -04:00

update myDW.AlbSPS.DWInfo
set LastImportSPSAlb = '2021-04-27 00:00:00'
-- set LastImportSPSAlb = GETDATE() 
-- set LastImportSPSAlb = CONVERT(DATETIME,GETDATE() AT TIME ZONE 
-- (SELECT CURRENT_TIMEZONE_ID()) AT TIME ZONE 'US Eastern Standard Time')
 where ID = 1
 select * from myDW.AlbSPS.DWInfo  where id = 1
/*
 SELECT 
tlid,
VMID,
transtartdatetime,
TRANENDDATETIMe,
TRANSCODE,
USERNUMBER,
USERGROUP01, 
JOBNUMBER, 
ITEMNUMBER,
UNITCOST,
qty,
QTYNEW,
QTYONORDER,
ITEMGROUP, 
ITEMALIASNUMBER, 
SUPPLIERNUMBER,
SUPPLIERPARTNUMBER
FROM sps.dbo.TransactionLog
where transtartdatetime BETWEEN '2021-05-13 00:00:00' AND '2021-05-14 00:00:00'
and ITEMGROUP = 'INSERTS'

 */
/*
 * drop table myDW.AlbSPS.DWInfo
 */
/*
CREATE TABLE myDW.AlbSPS.DWInfo (
	ID int NOT NULL,
	LastImportSPSAlb datetime
);
*/
/*
-- myDW.AlbSPS.TransactionLog definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.TransactionLog;

CREATE TABLE myDW.AlbSPS.TransactionLog (
	TLID decimal(27,15) NOT NULL,
	VMID int NULL,
	TRANSTARTDATETIME datetime NULL,
	TRANENDDATETIME datetime NULL,
	TRANSCODE nvarchar(3) NULL,
	ITEMNUMBER nvarchar(32) NULL,
	ITEMGROUP nvarchar(32) NULL,
	ITEMALIASNUMBER nvarchar(32) NULL,
	UNITCOST decimal(12,4) NULL,
	QTY int NULL,
	QTYNEW int NULL,
	QTYONORDER int NULL,
	SUPPLIERNUMBER nvarchar(32) NULL,
	SUPPLIERPARTNUMBER nvarchar(50) NULL,
	USERGROUP01 nvarchar(50) NULL,
	USERNUMBER nvarchar(32) NULL,
	JOBNUMBER nvarchar(32) NULL,
	CONSTRAINT PK_TRANSACTIONLOG PRIMARY KEY (TLID)
);
*/