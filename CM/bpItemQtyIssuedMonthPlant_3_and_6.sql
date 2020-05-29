CREATE TABLE m2mdata01.dbo.ToolingTransLog (
	JobNumber nvarchar(32),
	PartNumber nvarchar(25),
	Rev nvarchar(3),
	ItemNumber nvarchar(32),
	Qty int,
	UNITCOST money,
	TranStartDateTime smalldatetime NOT NULL,
	UserNumber nvarchar(32),
	UserName nvarchar(50),
	Plant nvarchar(3)
) GO


--///////////////////////////////////////////////////////////////////////////////////
-- Determines item quantities issued within the last month in Plant 3 and 6
-- I DID NOT ADD THIS SPROC YET
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpItemQtyIssuedMonthPlant_3_and_6] 
AS
BEGIN
	SET NOCOUNT ON
	Declare @startDateParam DATETIME
	Declare @endDateParam DATETIME
	set @startDateParam = DATEADD (month ,-1, GETDATE())
	set @endDateParam = GETDATE()
	
	
	IF Object_ID('tempdb..#primary_key') is not null
	DROP TABLE #primary_key

	/*
	primary_key: Determine primary key of result set.
	*/
	create table #primary_key
	(
	  	primary_key int identity(1,1),
	--  	plant nvarchar(3),
		ItemNumber nvarchar(32)
	)

	insert into #primary_key (ItemNumber)
	(
		select 
		DISTINCT itemNumber 
		from toolingtranslog
		where transtartdatetime >= @startDateParam
		and transtartdatetime <= @endDateParam
		and plant in ('6','3')
		--and itemNumber not like '%R'
		and itemNumber <> ''
	)

	--select count(*) #primary_key from #primary_key  --367
	IF Object_ID('tempdb..#set2group3') is not null
	drop table #set2group3 
	
	create table #set2group3
	(
		ItemNumber nvarchar(32),
		Qty int,
		UnitCost decimal(18,2),
		TotalCost decimal(18,2),
		Plant nvarchar(3)
	)
	
	insert into #set2group3 (ItemNumber,Qty,UnitCost,TotalCost,Plant)
	(
		select 
		ItemNumber,
		Qty,
		UnitCost,
		Cast(Qty*UnitCost as decimal(18,2)) as TotalCost,
		plant 
		from toolingtranslog
		where transtartdatetime >= @startDateParam
		and transtartdatetime <= @endDateParam
		and itemNumber <> ''
		and plant in ('3')
	)
	
	--select count(*) #set2group3 from #set2group3  --2312
	--select top(50) *  from #set2group3
	
	IF Object_ID('tempdb..#set2group6') is not null
	drop table #set2group6 
	
	create table #set2group6
	(
		ItemNumber nvarchar(32),
		Qty int,
		UnitCost decimal(18,2),
		TotalCost decimal(18,2),
		Plant nvarchar(3)
	)
	
	insert into #set2group6 (ItemNumber,Qty,UnitCost,TotalCost,Plant)
	(
		select 
		ItemNumber,
		Qty,
		UnitCost,
		Cast(Qty*UnitCost as decimal(18,2)) as TotalCost,
		plant 
		from toolingtranslog
		where transtartdatetime >= @startDateParam
		and transtartdatetime <= @endDateParam
		and itemNumber <> ''
		and plant in ('6')
	)
	
	
	--select count(*) #set2group6 from #set2group6  --1452
	--select top(50) * from #set2group6  --1452
	IF Object_ID('tempdb..#ItemQtyIssuedLastMonthPlant_3_and_6') is not null
	drop table #ItemQtyIssuedLastMonthPlant_3_and_6 
	
	create table #ItemQtyIssuedLastMonthPlant_3_and_6
	(
		ItemNumber nvarchar(32),
		Plt3_Qty int,
		Plt3_TotalCost decimal(18,2),
		Plt6_Qty int,
		Plt6_TotalCost decimal(18,2),
		TotalQty int,
		TotalCost decimal(18,2)
	)
	
	insert into #ItemQtyIssuedLastMonthPlant_3_and_6 (ItemNumber,Plt3_Qty,Plt3_TotalCost,Plt6_Qty,Plt6_TotalCost,TotalQty,TotalCost)
	(
		select 
		pk.ItemNumber, 
		case 
		when s3.qty is null then 0 
		else s3.qty 
		end Plt3_Qty,
		case 
		when s3.TotalCost is null then 0.00 
		else s3.TotalCost 
		end Plt3_TotalCost,
		case 
		when s6.qty is null then 0 
		else s6.qty 
		end Plt6_Qty,
		case 
		when s6.TotalCost is null then 0.00 
		else s6.TotalCost 
		end Plt6_TotalCost,
		case 
		when s3.qty is null and s6.qty is null then 0.00 --00
		when s3.qty is null and s6.qty is not null then s6.qty --01
		when s3.qty is not null and s6.qty is null then s3.qty --10
		when s3.qty is not null and s6.qty is not null then s3.qty + s6.qty --11
		end TotalQty,
		case 
		when s3.TotalCost is null and s6.TotalCost is null then 0.00 --00
		when s3.TotalCost is null and s6.TotalCost is not null then s6.TotalCost --01
		when s3.TotalCost is not null and s6.TotalCost is null then s3.TotalCost --10
		when s3.TotalCost is not null and s6.TotalCost is not null then s3.TotalCost + s6.TotalCost --11
		end TotalCost
		
		from #primary_key pk 
		left outer join 
		(
			select 
			s3.ItemNumber,
			sum(s3.Qty) Qty,
			sum(s3.TotalCost) TotalCost
			from #set2group3 s3
			group by s3.itemNumber 
		) s3
		on pk.ItemNumber=s3.ItemNumber
		left outer join 
		(
			select 
			s6.ItemNumber,
			sum(s6.Qty) Qty,
			sum(s6.TotalCost) TotalCost
			from #set2group6 s6
			group by s6.itemNumber 
		)s6
		on pk.ItemNumber=s6.ItemNumber
	)
	
	select 
	*
--	count(*) 
	from #ItemQtyIssuedLastMonthPlant_3_and_6 
	order by TotalCost desc
	
--	where Plt3_Qty = 0  --100
--	where Plt3_Qty != 0  --267
--	where Plt6_Qty = 0  --248
	where Plt6_Qty != 0  --119
--	where Plt3_Qty != 0 and Plt6_Qty != 0  --19

	
end;





Declare @startDateParam DATETIME
Declare @endDateParam DATETIME
set @startDateParam = DATEADD (month ,-1, GETDATE())
set @endDateParam = GETDATE()
select itemNumber,qty from toolingtranslog
where transtartdatetime >= @startDateParam
and transtartdatetime <= @endDateParam
and itemNumber not like '%R'
and itemNumber <> ''


--///////////////////////////////////////////////////////////////////////////////////
-- Total Item quantities that have been issued from the Cribs and ToolBosses
--///////////////////////////////////////////////////////////////////////////////////
create function [dbo].[bfItemQtyIssued]
( 
	@startDateParam DATETIME,
	@endDateParam DATETIME 
)
returns table
AS
return
	select itemNumber,lQtyIssued,rQtyIssued,
	lQtyIssued+rQtyIssued qtyIssued
	from 
	(
		select tll.itemNumber,tll.lQtyIssued,
		case
			when tlr.rQtyIssued is null then 0
			else tlr.rQtyIssued
		end rQtyIssued
		from 
		(
			select itemNumber,sum(qty) lQtyIssued 
			from 
			(
				select itemNumber,qty from toolingtranslog
				where transtartdatetime >= @startDateParam
				and transtartdatetime <= @endDateParam
				and itemNumber not like '%R'
				and itemNumber <> ''
			)tl1
			group by itemNumber
			--20 secs
			--1197
		)tll
		left outer join
		(
			select substring(itemNumber,0,len(itemNumber)) rItemNumber,sum(qty) rQtyIssued 
			from 
			(
				select itemNumber,qty from toolingtranslog
				where transtartdatetime >= @startDateParam
				and transtartdatetime <= @endDateParam
				and itemNumber like '%R'
				and itemNumber <> ''
			)tl1
			group by itemNumber
			--68
		)tlr
		on tll.itemNumber = ritemNumber
	)tlog;
