-- 
create PROCEDURE AlbSPS.GetTransactions  
@PCN int = 300758,
@StartDate datetime = '20210426',
@EndDate datetime = '20210527'
AS
BEGIN
	SET NOCOUNT ON
		select tl.pcn,tl.JOBNUMBER,tl.UNITCOST,tl.qty,(tl.UNITCOST*tl.qty) totalcost, tl.transtartdatetime startdate, tl.TRANENDDATETIMe enddate
		from AlbSPS.TransactionLog tl  
		inner join AlbSPS.Jobs j 
		on tl.PCN = j.PCN 
		and tl.JOBNUMBER = j.JOBNUMBER 
		--where tl.transtartdatetime between @StartDate and @EndDate;
END

declare @StartDate datetime
declare @EndDate datetime
set @StartDate = '20210426'
set @EndDate = '20210527'
select @StartDate,@EndDate
EXEC AlbSPS.GetTransactions 300758,@StartDate, @EndDate
		
select i.location, '"' + i.item_no + '"' item_no, quantity 
	from  Plex.purchasing_item_inventory i 
	where 
	i.pcn = @PCN
	and (i.location like @RowFilter)  
	order by location 

end;

--CREATE TABLE MSC.TransactionLog (PCN INT, tlid NUMERIC(27,15), VMID INT, transtartdatetime DATETIME, TRANENDDATETIMe DATETIME, TRANSCODE NVARCHAR(3) COLLATE SQL_Latin1_General_CP1_CI_AS, USERNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, USERGROUP01 NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS, JOBNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, ITEMNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, UNITCOST NUMERIC(12,4), qty INT, QTYNEW INT, QTYONORDER INT, ITEMGROUP NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, ITEMALIASNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, SUPPLIERNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS, SUPPLIERPARTNUMBER NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS);
-- truncate table MSC.TransactionLog
select tl.*
from MSC.TransactionLog tl  
/*
 select *
 into AlbSPS.TransactionLogNO
 from AlbSPS.TransactionLog tl 
 where tl.JOBNUMBER not like '%[A-Z]%'
*/
 

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

-- DROP TABLE mgdw.AlbSPS.TransactionLog;

CREATE TABLE mgdw.AlbSPS.TransactionLog (
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