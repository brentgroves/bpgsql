-- Reports: SalesReleaseVolumeRevenue
-- release_status: Any 
-- release_type: Any. 
-- Quantity shipped: from sales_release.quantity_shipped field.
-- Revenue and Volume: shipper_status='Shipped'
-- Primary Key: year_week,year_week_fmt,start_week,end_week,customer_no,part_key 
-- Order: customer_code,part_no,year_week
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
create table #volume_revenue_info
(
  primary_key int,
  part_no varchar (113),
  volume  decimal,   
  revenue decimal (18,2),
  volume_revenue_rank int
)


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

