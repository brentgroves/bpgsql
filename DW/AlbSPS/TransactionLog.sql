

select tl.*
from AlbSPS.TransactionLog tl  

select * from albsps.import
/*
update albsps.import
set LastSuccess='2021-04-27 00:00:00'
where id=1
 */
select *
select count(*) cnt  -- 1389
from myDW.AlbSPS.TransactionLog
/*
-- myDW.AlbSPS.TransactionLog definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.TransactionLog;
-- truncate table AlbSPS.TransactionLog   

CREATE TABLE myDW.AlbSPS.TransactionLog (
	PCN int NOT NULL,
	TLID decimal(27,15) NOT NULL,
	VMID int NULL,
	TRANSTARTDATETIME datetime NULL,
	TRANENDDATETIME datetime NULL,
	TRANSCODE nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ITEMNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ITEMGROUP nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ITEMALIASNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	UNITCOST decimal(12,4) NULL,
	QTY int NULL,
	QTYNEW int NULL,
	QTYONORDER int NULL,
	SUPPLIERNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	SUPPLIERPARTNUMBER nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	USERGROUP01 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	USERNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	JOBNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_TRANSACTIONLOG PRIMARY KEY (TLID)
);
*/