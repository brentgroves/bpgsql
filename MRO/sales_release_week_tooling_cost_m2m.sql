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
) GO
*/
Declare @Start_Date datetime
Declare @End_Date datetime
Declare @start_year char(4)
Declare @start_week int
Declare @end_year char(4)
Declare @end_week int
Declare @start_of_week_for_start_date datetime
Declare @end_of_week_for_end_date datetime

set @Start_Date = '20200216'
set @End_Date = '20200314'
set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)
set @end_year = DATEPART(YEAR,@End_Date)
set @end_week = DATEPART(WEEK,@End_Date)
--select  DATEADD(second,-1,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31)))
--select convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31)))
--set @end_of_week_for_end_date = DATEADD(second,-1,convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31))))  
--select cast(DATEPART(YEAR,@Start_Date) as nvarchar)
--select cast(cast(DATEPART(YEAR,@Start_Date) as nvarchar)+'-01-01' as datetime)
--select convert(datetime, @dt, 101)
if DATEPART(WEEK,@Start_Date) = 1
set @start_of_week_for_start_date = cast(cast(DATEPART(YEAR,@Start_Date) as nvarchar)+'-01-01' as datetime)
else
set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
--select DATEPART(WEEK,@End_Date)
--select DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,@End_Date))) + (DATEPART(WEEK,@End_Date)-1), 5))
if DATEPART(WEEK,@End_Date) > 51 and  (  DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,@End_Date))) + (DATEPART(WEEK,@End_Date)-1), 5))   =1)
set @end_of_week_for_end_date = DATEADD(second,-1,convert(datetime,DATEADD(day, 1,cast(cast(DATEPART(YEAR,@Start_Date) as nvarchar)+'-12-31' as datetime))))
else
set @end_of_week_for_end_date = DATEADD(second,-1,DATEADD(day,1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)))  --end of week

--select @start_of_week_for_start_date,@end_of_week_for_end_date
/*
primary_key: Determine primary key of result set.
  ROW_NUMBER() OVER (
    ORDER BY year_week
  ) primary_key,

**/
	
IF Object_ID('tempdb..#primary_key') is not null
DROP TABLE #primary_key

create table #primary_key
(
  primary_key int,
  year_week int,
  year_week_fmt varchar(20),
  start_week datetime,
  end_week datetime,
  part_no nvarchar(25)
)

insert into #primary_key(primary_key,year_week,year_week_fmt,start_week,end_week,part_no)
(
   select 
  ROW_NUMBER() OVER (
    ORDER BY year_week,part_no
  ) primary_key,
  year_week, 
  year_week_fmt,
  start_week,
  end_week,
  part_no
  from 
  (
    select
    DATEPART(YEAR,tl.transtartdatetime) * 100 + DATEPART(WEEK,tl.transtartdatetime) year_week,
    case     
    when DATEPART(WEEK,tl.transtartdatetime) < 10 then convert(varchar,DATEPART(YEAR ,tl.transtartdatetime)) + '-0' + convert(varchar,DATEPART(WEEK,tl.transtartdatetime))
    else 
     convert(varchar,DATEPART(YEAR ,tl.transtartdatetime)) + '-' + convert(varchar,DATEPART(WEEK,tl.transtartdatetime))
    end year_week_fmt,
    case 
    when DATEPART(WEEK,tl.transtartdatetime) = 1 then cast(cast(DATEPART(YEAR,tl.transtartdatetime) as nvarchar)+'-01-01' as datetime)
    else DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,tl.transtartdatetime))) + (DATEPART(WEEK,tl.transtartdatetime)-1), 6) 
    end start_week, 
    case                                                        
    when DATEPART(WEEK,tl.transtartdatetime) > 51 and  (DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,tl.transtartdatetime))) + (DATEPART(WEEK,tl.transtartdatetime)-1), 5))=1)  then DATEADD(second,-1,convert(datetime,DATEADD(day, 1,cast(cast(DATEPART(YEAR,tl.transtartdatetime) as nvarchar)+'-12-31' as datetime))))
    else DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,tl.transtartdatetime))) + (DATEPART(WEEK,tl.transtartdatetime)-1), 5)))
    end end_week,
    tl.PartNumber part_no
	from toolingtranslog tl
	where tl.transtartdatetime between @start_of_week_for_start_date and @end_of_week_for_end_date
    and tl.PartNumber <> ''
    --where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    --and pl.part_key not in (select * from #filter)
  )s1 
  group by s1.year_week,s1.year_week_fmt,s1.start_week,s1.end_week,s1.part_no  -- sales release to shipper_line is a 1 to many relationship so make sure these records are distinct

)
--select * from #primary_key
/*
		select 
		TranStartDateTime,
		PartNumber,
		Qty,
		UnitCost,
		Cast(Qty*UnitCost as decimal(18,2)) as TotalCost
		from toolingtranslog
		where transtartdatetime >= @startDateParam
		and transtartdatetime <= @endDateParam
		and PartNumber <> ''
		order by transtartdatetime desc
*/
	
	
	--select count(*) #primary_key from #primary_key  --217

IF Object_ID('tempdb..#set2group') is not null
drop table #set2group 
	
create table #set2group
(
  	primary_key int,
	part_no nvarchar(25),
	total_cost decimal(18,2)
)

insert into #set2group (primary_key,part_no,total_cost)
(
	select 
	pk.primary_key,
	s1.part_no,
	s1.total_cost
	from 
	(
		select 
    	DATEPART(YEAR,tl.transtartdatetime) * 100 + DATEPART(WEEK,tl.transtartdatetime) year_week,
		PartNumber part_no,
		Cast(Qty*UnitCost as decimal(18,2)) as total_cost
		from toolingtranslog tl
		where tl.transtartdatetime between @start_of_week_for_start_date and @end_of_week_for_end_date
		and PartNumber <> ''
	)s1 
	inner join #primary_key pk 
	on s1.year_week=pk.year_week
	and s1.part_no=pk.part_no 
)
	
	
--select count(*) #set2group from #set2group  --7053
--select top(50) *  from #set2group 

IF Object_ID('tempdb..#sales_release_week_tooling_cost_m2m') is not null
drop table #sales_release_week_tooling_cost_m2m 

/*
Final set: Join of all intermediate sets.
*/

create table #sales_release_week_tooling_cost_m2m
(
  	primary_key int,
  	year_week int,
  	year_week_fmt varchar(20),
  	start_week datetime,
  	end_week datetime,
  	part_no varchar (25),
	total_cost decimal(18,2)
)


insert into #sales_release_week_tooling_cost_m2m (primary_key,year_week,year_week_fmt,start_week,end_week,part_no,total_cost)
(
  select
  primary_key,
  year_week,
  year_week_fmt,
  start_week,
  end_week,
  part_no,
  total_cost
  from
  (
    select 
    pk.primary_key,
    pk.year_week,
    pk.year_week_fmt,
    pk.start_week,
    pk.end_week,
    pk.part_no,
	case 
	when stg.total_cost is null then 0.00 
	else stg.total_cost 
	end total_cost
    from #primary_key pk
	inner join 
	(
		select
		stg.primary_key,
		sum(stg.total_cost) total_cost
		from #set2group stg
		group by stg.primary_key 
	) stg
	on pk.primary_key=stg.primary_key
  )s1
  
)

select * 
from #sales_release_week_tooling_cost_m2m
order by part_no desc

select top(100) * 
from dbo.ToolingTransLog tl 
order by TranStartDateTime desc 


