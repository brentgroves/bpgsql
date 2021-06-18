

select tl.*
from AlbSPS.TransactionLog tl  

select tc.pcn,tc.JOBNUMBER,j.DESCR,tc.totalcost 
from
(
	select tl.pcn,tl.JOBNUMBER, sum(totalcost) totalcost
	from
	(
		select tl.pcn,tl.JOBNUMBER,tl.UNITCOST,tl.qty,(tl.UNITCOST*tl.qty) totalcost 
		from AlbSPS.TransactionLog tl  
		inner join AlbSPS.Jobs j 
		on tl.PCN = j.PCN 
		and tl.JOBNUMBER = j.JOBNUMBER 
	)tl 
	group by tl.pcn,tl.JOBNUMBER -- 28
) tc
inner join AlbSPS.Jobs j 
on tc.pcn=j.PCN 
and tc.jobnumber=j.JOBNUMBER 
order by tc.totalcost desc



select * from albsps.import
/*
update albsps.import
set LastSuccess='2021-04-27 00:00:00'
where id=1
 */
select *
--select count(*) cnt  -- 1389
from myDW.AlbSPS.TransactionLog
/*
-- myDW.AlbSPS.TransactionLog definition

-- Drop table

-- myDW.AlbSPS.TransactionLog definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.TransactionLog;

CREATE TABLE myDW.AlbSPS.TransactionLog (
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
*/