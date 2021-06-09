-- DROP TABLE myDW.MSC.TransactionLog;
-- TRUNCATE table myDW.MSC.TransactionLog
select j.jobnumber,j.DESCR,tl.itemgroup,tl.ITEMNUMBER,count(*) withdrawals from MSC.TransactionLog tl
inner join MSC.Job j 
on tl.jobnumber=j.JOBNUMBER 
where j.jobnumber ='54484'
group by j.JOBNUMBER,j.DESCR,tl.itemgroup,tl.ITEMNUMBER 
order by count(*) desc

select distinct j.JOBNUMBER, j.DESCR
-- select j.JOBNUMBER,tl.USERGROUP01,tl.usernumber,j.DESCR,tl.TRANSTARTDATETIME,tl.TRANSCODE,tl.ITEMNUMBER,tl.ITEMGROUP,tl.unitcost,tl.QTY,tl.QTYNEW,tl.QTYONORDER,tl.SUPPLIERNUMBER 
from MSC.TransactionLog tl 
inner join MSC.Job j 
on tl.jobnumber=j.JOBNUMBER 
--where transtartdatetime > '2021-05-06 00:00:00'
order by j.jobnumber

select tl.jobnumber,j.DESCR,count(*) cnt
from MSC.TransactionLog tl
inner join MSC.Job j 
on tl.jobnumber=j.JOBNUMBER 
group by tl.jobnumber,j.DESCR 
order by count(*) DESC 

select j.*
from MSC.Job j 
where j.descr like '%2009828%'

SELECT * from AlbSPS.TransactionLog tl 
select DISTINCT  j.JOBNUMBER, j.DESCR
from AlbSPS.TransactionLog tl 
/*
CREATE TABLE myDW.MSC.TransactionLog (
	PCN int NOT NULL,
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
	CONSTRAINT PK_TRANSACTIONLOG PRIMARY KEY (PCN,TLID)
);
*/