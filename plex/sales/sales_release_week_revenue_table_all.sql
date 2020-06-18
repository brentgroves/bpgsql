-- Reports: SalesReleaseDiff
-- release_status: Any 
-- release_type: Any. 
-- Quantity shipped: from sales_release.quantity_shipped field.
-- Revenue and Volume: shipper_status='Shipped'
-- Primary Key: year_week,year_week_fmt,start_week,end_week,customer_no,part_key 
-- Order: customer_code,part_no,year_week
Declare @Start_Date datetime
Declare @start_year char(4)
Declare @start_week int
Declare @end_year char(4)
Declare @end_week int
Declare @start_of_week_for_start_date datetime
Declare @end_of_week_for_end_date datetime
Declare @start_of_current_week datetime
Declare @end_of_previous_week datetime
Declare @current_year char(4)
Declare @current_week int
Declare @previous_quarter_start_date datetime
Declare @previous_quarter_end_date datetime


--set @end_year = DATEPART(YEAR,@End_Date)
--set @end_week = DATEPART(WEEK,@End_Date)
set @current_year = DATEPART(YEAR,getdate())
set @current_week = DATEPART(WEEK,getdate())

set @Start_Date = '1/1/' + @current_year

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)

if DATEPART(WEEK,getdate()) = 1
set @start_of_current_week = datefromparts(DATEPART(YEAR,getdate()), 1, 1)
else
set @start_of_current_week = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @current_year) + (@current_week-1), 6)  --start of current week

set @end_of_previous_week = DATEADD(second,-1,@start_of_current_week)

--select @start_of_current_week,@end_of_previous_week


if DATEPART(WEEK,@Start_Date) = 1
set @start_of_week_for_start_date = datefromparts(DATEPART(YEAR,@Start_Date), 1, 1)
else
set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week

set @previous_quarter_start_date =  DATEADD(wk, -13,@start_of_week_for_start_date)
set @previous_quarter_end_date =  DATEADD(wk, 13,@previous_quarter_start_date)

--select @previous_quarter_start_date,@previous_quarter_end_date

--ADJUST END DATE FOR 4TH QUARTER BASED UPON THE NUMBER OF WEEKS IN THE YEAR
set @end_of_week_for_end_date =  DATEADD(wk, 12,@start_of_week_for_start_date)
set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week

--BUG FIX ADDED 23 HOURS AND 59 MINS TO END DATE
--set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

--/* testing 0
--select @start_of_week_for_start_date,  @end_of_previous_week, @start_of_current_week,@end_of_week_for_end_date
--*/ end testing 0 



--select DATEPART(wk,@start_of_current_week),DATEPART(wk,@end_of_week_for_end_date);

--MUST BE CHANGED FOR WW1
create table #sales_release_week_volume_revenue_rank
(
  primary_key int,
  part_key int,
  part_no varchar (113),
  volume  decimal,   
  revenue decimal (18,2),
  volume_revenue_rank int
)

if @current_week = 1 
begin
insert into #sales_release_week_volume_revenue_rank (primary_key,part_key,part_no,volume,revenue, volume_revenue_rank)
exec sproc300758_11728751_1684867 @previous_quarter_start_date, @previous_quarter_end_date
end
else
begin
insert into #sales_release_week_volume_revenue_rank (primary_key,part_key,part_no,volume,revenue, volume_revenue_rank)
exec sproc300758_11728751_1684867 @start_of_week_for_start_date, @end_of_previous_week
end
--select * from #sales_release_week_volume_revenue_rank

/*
PREPARE TO CREATE AVERAGE SET
*/


create table #week_start_end
(
  week int,
  start_week datetime,
  end_week datetime
);


with cte_days_of_year(day_of_year) as
(
  select datefromparts(@start_year, 1, 1) day_of_year --1/1/2020 12:00:00 AM
  union all
  select dateadd(day, 1, day_of_year)
  from cte_days_of_year
  where day_of_year < datefromparts(@start_year, 12, 31)
)

insert into #week_start_end
select 
datepart(week,day_of_year) week,
min(day_of_year) start_week,
max(day_of_year) end_week
from cte_days_of_year
group by datepart(week,day_of_year)
option (maxrecursion 400);

--select * from #week_start_end


create table #primary_key_average
(
  primary_key int IDENTITY(1,1) PRIMARY KEY,
  year_week int,
  year_week_fmt varchar(20),
  start_week datetime,
  end_week datetime,
);


with cte_weeks(year_week,week) as
(
  select @start_year*100 + DATEPART(wk,@start_of_current_week) year_week, 
  DATEPART(wk,@start_of_current_week) week
  union all
  select year_week +1,week + 1
  from cte_weeks
  where week < DATEPART(wk,@end_of_week_for_end_date)
)
insert into #primary_key_average(year_week,year_week_fmt,start_week,end_week)
select 
w.year_week,
w.year_week_fmt,
se.start_week,
se.end_week
from
(
  select 
  year_week,
  week,
      case     
  --    when DATEPART(WEEK,sh.ship_date) < 10 then convert(varchar,DATEPART(YEAR,sh.ship_date)) +'-0' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + ' (Shipped)'
      when week < 10 then 'W0' + convert(varchar,week) + '-Avg'
      else 
       'W' + convert(varchar,week) + '-Avg'
  --    convert(varchar,DATEPART(YEAR,sh.ship_date)) +'-' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + ' (Shipped)'
      end year_week_fmt
  
  from cte_weeks 
)w
inner join #week_start_end se
on w.week=se.week

--@Start_Date must be less at least 2 weeks for comparison to make sense
create table #sales_release_volume_revenue_average
(
  primary_key int,
  part_key int,
  part_no varchar (113),
  volume decimal,
  revenue decimal(18,2),
)


insert into #sales_release_volume_revenue_average (primary_key,part_key,part_no,volume,revenue)
exec sproc300758_11728751_1691271 @start_of_week_for_start_date, @end_of_previous_week  --sales_release_week_volume_revenue_shipped_all


create table #sales_release_week_volume_revenue
(
  primary_key int,
  part_key int,
--  revenue_rank int,  Plex does not allow dynamic queries.
  year_week int,
  year_week_fmt varchar(20),
  start_week datetime,
  end_week datetime,
  part_no varchar (113),
  volume decimal,
  revenue decimal (18,2)
)



if @current_week != 1
begin
insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1691892 @start_of_week_for_start_date, @end_of_previous_week  --sales_release_week_volume_revenue_shipped_all
end

insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1691965 @start_of_current_week,@end_of_week_for_end_date  --sales_release_week_volume_revenue_releases_all

insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
select 
av.primary_key,
av.part_key,
pk.year_week,
pk.year_week_fmt,
pk.start_week,
pk.end_week,
av.part_no,
av.volume,
av.revenue
from #sales_release_volume_revenue_average av
cross apply #primary_key_average pk
--select * from  #sales_release_week_volume_revenue



/*
THANK YOU GOD 
CREATE A SET OF ALL PART_KEYS AND PART NUMBERS
FROM #sales_release_week_volume_revenue
WITH AN AUTO IDENTITY COLUMN

*/





--select @current_week
if @current_week = 11 
begin
  select vr.*
  from
  (
    select part_no,[W01-Shipped],[W02-Shipped],[W03-Shipped],[W04-Shipped],[W05-Shipped],[W06-Shipped],[W07-Shipped],[W08-Shipped],[W09-Shipped],[W10-Shipped],[W11-Avg],[W11-Forecast],[W12-Avg],[W12-Forecast],[W13-Avg],[W13-Forecast]
    from
    (
      select part_no,year_week_fmt,revenue  
      from 
      #sales_release_week_volume_revenue 
    ) vr
    pivot
    (
      sum(revenue) for year_week_fmt in ([W01-Shipped],[W02-Shipped],[W03-Shipped],[W04-Shipped],[W05-Shipped],[W06-Shipped],[W07-Shipped],[W08-Shipped],[W09-Shipped],[W10-Shipped],[W11-Avg],[W11-Forecast],[W12-Avg],[W12-Forecast],[W13-Avg],[W13-Forecast]) 
    ) ct
  )vr
  inner join #sales_release_week_volume_revenue_rank rk
  on vr.part_no=rk.part_no
  order by rk.volume_revenue_rank
  
  --order by part_no
  
--inner join #sales_release_week_volume_revenue_rank rk
--on 
--order by part_no
end


--select top(1) year_week,year_week_fmt
--from #sales_release_week_volume_revenue 
--where year_week_fmt like '%Ship%'
