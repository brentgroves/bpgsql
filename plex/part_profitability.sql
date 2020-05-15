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

/*
    case                                                        
    when DATEPART(WEEK,sh.ship_date) > 51 and  (DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 5))=1)  then DATEADD(second,-1,DATEADD(day, 1,datefromparts(DATEPART(YEAR,sh.ship_date), 12, 31)))
    else DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 5)))
    end end_week,
*/

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

/* 
This call is flakey so I put it at the beginning of the SPROC.
If it does not work here then just copy the code from the SPROC and remove the call
*/
create table #sales_release_week_volume_revenue_rank
(
  primary_key int,
  part_key int,
  part_no varchar (113),
  volume  decimal,   
  revenue decimal (18,2),
  volume_revenue_rank int
)


insert into #sales_release_week_volume_revenue_rank (primary_key,part_key,part_no,volume,revenue, volume_revenue_rank)
exec sproc300758_11728751_1684867 @Start_Date, @End_Date

-- DETERMINE THE REVENUE RANKING  
/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int,
  part_key int,
  part_no varchar (113)  
)

--The primary_key should contain all parts with sales release items even if they don't have any quantity shipped.
--If quantity shipped is 0 for a part it still should be included in the report.
insert into #primary_key(primary_key,part_key,part_no)
(
  select 
  --top 10
  part_key as primary_key,
  part_key,
  part_no
  from 
  (
    select
    p.part_key,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no  
    from sales_v_release sr
    inner join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    inner join part_v_part p -- 1 to 1  
    on pl.part_key=p.part_key 
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
  group by part_key,part_no  -- sales release to shipper_line is a 1 to many relationship so make sure these records are distinct

  --BUG: The primary key was based upon the sr.ship_date and the set to group was based on the sh.ship_date 
  --so some records could be dropped. Changed the primary key and set to group both to be based upon sh.ship_date
)

-- select * from #primary_key  


--select count(*) #primary_key from #primary_key  --154


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

-- select count(*) #volume_revenue from #volume_revenue  --154
--select top(100) * from #volume_revenue


/*
Final set: Join of all intermediate sets.
*/

create table #part_profitability
(
  primary_key int,
  part_key int,
  volume_revenue_rank int,  
  part_no varchar (113),
  volume decimal,
  revenue decimal(18,2)
)


insert into #part_profitability (primary_key,part_key,volume_revenue_rank,part_no,volume,revenue)
(
  select
  primary_key,
  part_key,
  volume_revenue_rank,
  part_no,
  volume,
  revenue
  from
  (
    select 
    pk.primary_key,
    pk.part_key,
    vrr.volume_revenue_rank,
    pk.part_no,  
    case
      when vr.volume is null then 0
      else vr.volume
    end volume,  
    case
      when vr.revenue is null then 0
      else vr.revenue
    end revenue
    from #primary_key pk
    inner join #volume_revenue vr
    on pk.primary_key=vr.primary_key
    inner join #sales_release_week_volume_revenue_rank vrr
    on pk.part_key = vrr.part_key
    
  )s1
  
)


--select count(*) #part_profitability from #part_profitabilitye
--select top(100) * from #part_profitability


select * 
from #part_profitability
order by volume_revenue_rank
--154



/*
select 
vr.part_no,
'USD' as Currency,
vr.year_week as Period,
vr.volume as [Actual Volume],
vr.revenue as [Actual Revenue (Local)],
vr.revenue as [Actual Revenue (USD)]
from #sales_release_week_volume_revenue vr
order by vr.revenue desc
*/
--inner join #sales_release_week_volume_revenue_rank rk
--on vr.part_key=rk.part_key
--order by rk.volume_revenue_rank, year_week