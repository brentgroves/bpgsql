-- Reports: SalesReleaseDiff
-- release_status: Any 
-- release_type: Any. 
-- Quantity shipped: from sales_release.quantity_shipped field.
-- Revenue and Volume: shipper_status='Shipped'
-- Primary Key: year_week,year_week_fmt,start_week,end_week,customer_no,part_key 
-- Order: customer_code,part_no,year_week
/*
UPDATE FOR CHARLES 
short column, for color styling in intelliplex
add dash to separate year/week
*/
--//////////////////////////////////////////////////////////
--Check Parameters
--/////////////////////////////////////////////////////////
--SELECT DATEADD(YEAR,-2,GETDATE()) 
IF @Start_Date < DATEADD(YEAR,-5,GETDATE())
BEGIN
  --PRINT 'ERROR'
  RETURN
END


IF @End_Date > DATEADD(YEAR,5,GETDATE())
BEGIN
  --PRINT 'ERROR'
  RETURN
END


IF DATEDIFF(year, @End_Date,@Start_Date) > 1 
BEGIN
  --PRINT 'ERROR'
  RETURN
END



Declare @start_year char(4)
Declare @start_week int
Declare @end_year char(4)
Declare @end_week int
Declare @start_of_week_for_start_date datetime
Declare @end_of_week_for_end_date datetime

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)
set @end_year = DATEPART(YEAR,@End_Date)
set @end_week = DATEPART(WEEK,@End_Date)


set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
set @end_of_week_for_end_date = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week

--BUG FIX ADDED 23 HOURS AND 59 MINS TO END DATE
set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

--/* testing 0
--select @start_of_week_for_start_date, @end_of_week_for_end_date
--*/ end testing 0 


--@Start_Date must be less at least 2 weeks for comparison to make sense
IF @start_of_week_for_start_date > @end_of_week_for_end_date
BEGIN
  RETURN
END

create table #sales_release_weekly_volume_revenue
(
  primary_key int,
  part_key int,
--  revenue_rank int,  Plex does not allow dynamic queries.
  year_week int,
  year_week_fmt varchar(10),
  start_week datetime,
  end_week datetime,
  part_no varchar (113),
  volume decimal,
  revenue decimal
)

insert into #sales_release_weekly_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1681826 @start_of_week_for_start_date, @end_of_week_for_end_date
--select * from  #sales_release_weekly_volume_revenue  
insert into #sales_release_weekly_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1686509 @start_of_week_for_start_date, @end_of_week_for_end_date

--select * from  #sales_release_weekly_volume_revenue

create table #primary_key
(
  primary_key int,
  year_week_fmt varchar(10),
)

insert into #primary_key (primary_key,year_week_fmt)
select 
ROW_NUMBER() OVER (ORDER BY year_week_fmt),
year_week_fmt 
from #sales_release_weekly_volume_revenue 
group by year_week_fmt

--select * from #primary_key
create table #sales_release_weekly_volume_revenue_pivot 
(
  year_week_fmt varchar(10),
  [H2GC 5K652 AB] decimal (18,2),
  [H2GC 5K651 AB] decimal (18,2),
  [10103355_Rev_A] decimal (18,2),
  [10103353_Rev_A] decimal (18,2),
  [AA96128_Rev_B] decimal (18,2),
  [Other] decimal (18,2)
)

insert into #sales_release_weekly_volume_revenue_pivot  (year_week_fmt,[H2GC 5K652 AB],p.[H2GC 5K651 AB],p.[10103355_Rev_A],[10103353_Rev_A],[AA96128_Rev_B],[Other])
SELECT year_week_fmt,p.[H2GC 5K652 AB],p.[H2GC 5K651 AB],p.[10103355_Rev_A],[10103353_Rev_A],[AA96128_Rev_B],[Other]
FROM
(
  select * from  #sales_release_weekly_volume_revenue 
) AS j
PIVOT
(
  SUM(Revenue) FOR part_no IN ([H2GC 5K652 AB],[H2GC 5K651 AB],[10103355_Rev_A],[10103353_Rev_A],[AA96128_Rev_B],[Other])
) AS p;

--select * from #sales_release_weekly_volume_revenue_pivot 

create table #sales_release_week_revenue_chart
(
  year_week_fmt varchar(10),
  [H2GC 5K652 AB] decimal (18,2),
  [H2GC 5K651 AB] decimal (18,2),
  [10103355_Rev_A] decimal (18,2),
  [10103353_Rev_A] decimal (18,2),
  [AA96128_Rev_B] decimal (18,2),
  [Other] decimal (18,2)
)

insert into #sales_release_week_revenue_chart (year_week_fmt,[H2GC 5K652 AB],[H2GC 5K651 AB],[10103355_Rev_A],[10103353_Rev_A],[AA96128_Rev_B],[Other])
select pk.year_week_fmt,
(
select [H2GC 5K652 AB] 
from #sales_release_weekly_volume_revenue_pivot vr
where [H2GC 5K652 AB] is not null
and vr.year_week_fmt= pk.year_week_fmt
) [H2GC 5K652 AB],
(
select [H2GC 5K651 AB] 
from #sales_release_weekly_volume_revenue_pivot vr
where [H2GC 5K651 AB] is not null
and vr.year_week_fmt= pk.year_week_fmt
) [H2GC 5K651 AB], 
(
select [10103355_Rev_A] 
from #sales_release_weekly_volume_revenue_pivot vr
where [10103355_Rev_A] is not null
and vr.year_week_fmt= pk.year_week_fmt
) [10103355_Rev_A], 
(
select [10103353_Rev_A] 
from #sales_release_weekly_volume_revenue_pivot vr
where [10103353_Rev_A] is not null
and vr.year_week_fmt= pk.year_week_fmt
) [10103353_Rev_A], 
(
select [AA96128_Rev_B] 
from #sales_release_weekly_volume_revenue_pivot vr
where [AA96128_Rev_B] is not null
and vr.year_week_fmt= pk.year_week_fmt
) [AA96128_Rev_B],
(
select [Other] 
from #sales_release_weekly_volume_revenue_pivot vr
where [Other] is not null
and vr.year_week_fmt= pk.year_week_fmt
) [Other]    
from #primary_key pk

select * from  #sales_release_week_revenue_chart





/*
(
select year_week_fmt,[H2GC 5K651 AB]
from #volume_revenue_info
where [H2GC 5K651 AB] is not null
)s1
*/


/*
create table #volume_revenue_info
(
  week varchar(20),
  [H2GC 5K652 AB] decimal (18,2),
  [H2GC 5K651 AB] decimal (18,2),
  [10103355_Rev_A] decimal (18,2),
  [10103353_Rev_A] decimal (18,2),
  [AA96128_Rev_B] decimal (18,2),
  [Other] decimal (18,2)
)

insert into #volume_revenue_info (week,[H2GC 5K652 AB],[H2GC 5K651 AB],[10103355_Rev_A],[10103353_Rev_A],[AA96128_Rev_B],[Other])
select 'Week 1',214929.64,214904.14,118754.88,118754.88,53227.20,300000.30
union
select 'Week 2',214929.64,214904.14,118754.88,118754.88,53227.20,300000.30
union
select 'Week 3',214929.64,214904.14,118754.88,118754.88,53227.20,300000.30

select * from #volume_revenue_info
*/
/*
SELECT p.[foo], p.[bar], p.[kin]
FROM
(
  SELECT p.Name, o.Quantity
   FROM dbo.Products AS p
   INNER JOIN dbo.OrderDetails AS o
   ON p.ProductID = o.ProductID
) AS j
PIVOT
(
  SUM(Quantity) FOR Name IN ([foo],[bar],[kin])
) AS p;

*/
/*
create table #volume_revenue_info
(
  primary_key int,
  part_no varchar (113),
  volume  decimal,   
  revenue decimal (18,2),
  volume_revenue_rank int
)
*/


/*

insert into #volume_revenue_info (primary_key,part_no,volume,revenue, volume_revenue_rank)
exec sproc300758_11728751_1684867 @start_of_week_for_start_date, @end_of_week_for_end_date

select 
--group_key,
max(p1) p1,
max(v1) v1,
max(p2) p2,
max(v2) v2,
max(p3) p3,
max(v3) v3,
max(p4) p4,
max(v4) v4,
max(p5) p5,
max(v5) v5

from
(
  select 
  '1' group_key,
  (
    select part_no 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 1
  ) p1,
  (
    select revenue 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 1
  ) v1,
  (
    select part_no 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 2
  ) p2,
  (
    select revenue 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 2
  ) v2,
  (
    select part_no 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 3
  ) p3,
  (
    select revenue 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 3
  ) v3,
  (
    select part_no 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 4
  ) p4,
  (
    select revenue 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 4
  ) v4,
  (
    select part_no 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 5
  ) p5,
  (
    select revenue 
    from #volume_revenue_info vr 
    where vr.volume_revenue_rank = 5
  ) v5
  from #volume_revenue_info vr
)s1
group by group_key

*/