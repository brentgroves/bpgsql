/*
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
)
*/
--select count(*) from dbo.ToolingTransLog --404541
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
		PartNumber nvarchar(25),
	)

	insert into #primary_key (PartNumber)
	(
		select 
		DISTINCT PartNumber 
		from toolingtranslog
		where transtartdatetime >= @startDateParam
		and transtartdatetime <= @endDateParam
		and PartNumber <> ''
	)

	--select count(*) #primary_key from #primary_key  --217

	IF Object_ID('tempdb..#set2group') is not null
	drop table #set2group 
	
	create table #set2group
	(
		PartNumber nvarchar(25),
		Qty int,
		UnitCost decimal(18,2),
		TotalCost decimal(18,2)
	)

	insert into #set2group (PartNumber,Qty,UnitCost,TotalCost)
	(
		select 
		PartNumber,
		Qty,
		UnitCost,
		Cast(Qty*UnitCost as decimal(18,2)) as TotalCost
		from toolingtranslog
		where transtartdatetime >= @startDateParam
		and transtartdatetime <= @endDateParam
		and PartNumber <> ''
	)
	
	--select count(*) #set2group from #set2group  --7053
	--select top(50) *  from #set2group

	IF Object_ID('tempdb..#sales_release_week_tooling_cost_m2m') is not null
	drop table #sales_release_week_tooling_cost_m2m 
	
	create table #sales_release_week_tooling_cost_m2m
	(
		PartNumber nvarchar(25),
		TotalQty int,
		TotalCost decimal(18,2)
	)
	
	insert into #sales_release_week_tooling_cost_m2m (PartNumber,TotalQty,TotalCost)
	(
		select 
		pk.PartNumber, 
		case 
		when stg.qty is null then 0 
		else stg.qty 
		end TotalQty,
		case 
		when stg.TotalCost is null then 0.00 
		else stg.TotalCost 
		end TotalCost
		from #primary_key pk 
		inner join 
		(
			select 
			stg.PartNumber,
			sum(stg.Qty) Qty,
			sum(stg.TotalCost) TotalCost
			from #set2group stg
			group by stg.PartNumber 
		) stg
		on pk.PartNumber=stg.PartNumber
	)
select * 
from #sales_release_week_tooling_cost_m2m
order by TotalCost desc


