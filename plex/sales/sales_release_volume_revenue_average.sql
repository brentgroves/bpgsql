-- Next: Could add a @Parts_To_Display parameter and work it into the #filter
-- Reports: SalesReleaseVolumeRevenue
-- release_status: Any 
-- release_type: Any. 
-- Quantity shipped: from sales_release.quantity_shipped field.
-- Revenue and Volume: shipper_status='Shipped'
-- Primary Key: year_week,year_week_fmt,start_week,end_week,part_key 
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
Declare @number_of_weeks int

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)
set @end_year = DATEPART(YEAR,@End_Date)
set @end_week = DATEPART(WEEK,@End_Date)
--select  DATEADD(second,-1,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31)))
--select convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31)))
--set @end_of_week_for_end_date = DATEADD(second,-1,convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31))))  

if DATEPART(WEEK,@Start_Date) = 1
set @start_of_week_for_start_date = datefromparts(DATEPART(YEAR,@Start_Date), 1, 1)
else
set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
--select DATEPART(WEEK,@End_Date)
--select DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,@End_Date))) + (DATEPART(WEEK,@End_Date)-1), 5))
if DATEPART(WEEK,@End_Date) > 51 and  (  DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,@End_Date))) + (DATEPART(WEEK,@End_Date)-1), 5))   =1)
set @end_of_week_for_end_date = DATEADD(second,-1,convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31))))
else
set @end_of_week_for_end_date = DATEADD(second,-1,DATEADD(day,1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)))  --end of week

set @number_of_weeks = DATEPART(WEEK,@end_of_week_for_end_date) - DATEPART(WEEK,@start_of_week_for_start_date)
--select @number_of_weeks
--select convert(varchar,DATEPART(YEAR,@Start_Date) * 100) + '-0' + convert(varchar(2),DATEPART(WEEK,@Start_Date)) + ' (Shipped)'

--set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
--set @end_of_week_for_end_date = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week

--BUG FIX ADDED 23 HOURS AND 59 MINS TO END DATE
--set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

--/* testing 0
--select @start_of_week_for_start_date, @end_of_week_for_end_date
--*/ end testing 0 

--@Start_Date must be less at least 2 weeks for comparison to make sense
IF @start_of_week_for_start_date > @end_of_week_for_end_date
BEGIN
  RETURN
END

-- DETERMINE THE REVENUE RANKING  























/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int,  --part_key
)

insert into #primary_key(primary_key)
(
  select 
  --top 10
  s1.part_key primary_key
  from 
  (
    select
    pl.part_key 
    from sales_v_release sr
    left outer join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    left outer join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    inner join sales_v_shipper_line sl 
    on sr.release_key=sl.release_key --1 to many
    inner join sales_v_shipper sh 
    on sl.shipper_key=sh.shipper_key   --1 to 1
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    --BUG: THIS WAS SR.SHIP_DATE SHOULD BE SH.SHIP_DATE
    where sh.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.shipper_status='Shipped'
    --where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    --and pl.part_key not in (select * from #filter)
  )s1 
  group by part_key  
)

--select * from #primary_key


--select count(*) #primary_key from #primary_key  --169
--select top(1) * from #primary_key


--Use this set to calculate volume shipped and revenue.
--Although shipped is calculated from sales_release.quantity_shipped column
-- The revenue can only be calculated from the shipper_line since it has
-- the price that we charged customer.
-- select * from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??

--2684943,2684942,2794731,2794706,2793953,2807625,2794748,2794752
create table #set2group
(
  primary_key int,
  quantity decimal (18,3),  
  price decimal (18,6)
)

insert into #set2group (primary_key,quantity,price)
(
  select 
  pk.primary_key,
  sl.quantity,
  sl.price
  from
  (
    select
    pl.part_key,
    sl.quantity,
    sl.price
    from sales_v_release sr  
    inner join sales_v_po_line pl 
    on sr.po_line_key=pl.po_line_key --1 to 1
    inner join sales_v_po po  
    on pl.po_key = po.po_key  --1 to 1
    inner join sales_v_shipper_line sl 
    on sr.release_key=sl.release_key --1 to many
    inner join sales_v_shipper sh 
    on sl.shipper_key=sh.shipper_key   --1 to 1
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    --BUG: THIS WAS SR.SHIP_DATE SHOULD BE SH.SHIP_DATE
    where sh.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.shipper_status='Shipped' 
--    and ss.shipper_status='Shipped' and pl.part_key in (2684943,2684942,2794731,2794706,2793953,2807625,2794748,2794752)
  )sl
  inner join #primary_key pk
  on pk.primary_key=sl.part_key

)


create table #volume_revenue
(
  primary_key int,
  volume  decimal (18,3),   
  revenue decimal (18,6)
  
)



insert into #volume_revenue (primary_key,volume,revenue)
(

  select 
  --sc.*
  pk.primary_key,
  sum(gr.quantity) volume,
  sum(gr.price*gr.quantity) revenue
  from #primary_key pk  
  inner join #set2group gr
  on pk.primary_key=gr.primary_key
  group by pk.primary_key

)

--select count(*) #volume_revenue from #volume_revenue  --83
--select top(100) * from #volume_revenue


/*
Final set: Join of all intermediate sets.
*/

create table #sales_release_volume_revenue_average
(
  primary_key int,
  part_key int,
  part_no varchar (113),
  volume decimal,
  revenue decimal(18,2),
)


insert into #sales_release_volume_revenue_average (primary_key,part_key,part_no,volume,revenue)
(
  select
  primary_key,
  part_key,
  part_no,
  volume/@number_of_weeks as volume,
  revenue/@number_of_weeks as revenue
  from
  (
    select 
    pk.primary_key,
    pk.primary_key as part_key,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no,  
    case
      when vr.volume is null then 0
      else vr.volume
    end volume,  
    case
      when vr.revenue is null then 0
      else vr.revenue
    end revenue
    from #primary_key pk
    inner join part_v_part p -- 1 to 1  
    on pk.primary_key=p.part_key 
    inner join #volume_revenue vr
    on pk.primary_key=vr.primary_key
  )s1
  
)






--select count(*) #sales_release_week_high_volume_revenue from #sales_release_week_high_volume_revenue
--select top(100) * from #sales_release_weekly 
--where qty_loaded > 0




select vr.*
from #sales_release_volume_revenue_average vr


--inner join #sales_release_week_volume_revenue_rank rk
--on vr.part_key=rk.part_key
--order by rk.volume_revenue_rank, year_week