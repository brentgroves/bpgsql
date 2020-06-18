-- Reports: SalesReleaseVolumeRevenue
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

--select @start_of_week_for_start_date 
--select @end_of_week_for_end_date

--select @start_year,@start_week,@start_of_week_for_start_date
--select @end_year,@end_week,@end_of_week_for_end_date



/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int  --part_key
)


insert into #primary_key(primary_key)
(
  select 
  --top 10
  part_key as primary_key
  from 
  (
    select
    pl.part_key
    from sales_v_release sr
    left outer join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    left outer join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    where ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
  )s1 
  group by part_key
)  

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
create table #set2group
(
  primary_key int,
  quantity decimal (18,3),  
  price decimal (18,6)
)

insert into #set2group (primary_key,quantity,price)
(
  select
  pl.part_key as primary_key,
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
  where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
  and ss.shipper_status='Shipped' 

)

--select count(*) #set2groupC from #set2groupC  --324
--select top(100) * from #set2groupC
create table #volume_revenue
(
  primary_key int,
  volume  decimal (18,3),   
  revenue decimal (18,6),
  volume_revenue_rank int
  
)



insert into #volume_revenue (primary_key,volume,revenue,volume_revenue_rank)
(

  select 
  --sc.*
  vr.primary_key,
  vr.volume,
  vr.revenue,
  vr.volume_revenue_rank
  from
  (
    select 
    gr.primary_key,
    sum(gr.quantity) volume,
    sum(gr.price*gr.quantity) revenue,
    ROW_NUMBER() OVER (
        ORDER BY sum(gr.price*gr.quantity) desc
    ) volume_revenue_rank
    from #set2group gr
    group by gr.primary_key
  )vr
  where vr.volume_revenue_rank < 6

)

--select count(*) #volume_revenue from #volume_revenue  --83
--select top(100) * from #volume_revenue




/*
Final set: Join of all intermediate sets.
*/

create table #sales_release_weekly_volume_revenue_rank
(
  primary_key int,
  part_no varchar (113),
  volume  decimal,   
  revenue decimal (18,2),
  volume_revenue_rank int
)


insert into #sales_release_weekly_volume_revenue_rank (primary_key,part_no,volume,revenue, volume_revenue_rank)
(
  select
  primary_key,
  part_no,
  volume,
  revenue,
  volume_revenue_rank
  from
  (
    select 
    vr.primary_key,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no,  --The report says 10025543 RevD I can't find the Rev word
    volume,  -- NOT VALIDATED
    revenue,
    volume_revenue_rank
    from #volume_revenue vr
    inner join part_v_part p -- 1 to 1
    on vr.primary_key=p.part_key 
  )s1
  
)
select * from #sales_release_weekly_volume_revenue_rank

--select count(*) #sales_release_weekly from #sales_release_weekly
--select top(100) * from #sales_release_weekly 
--where qty_loaded > 0

--select * from  #volume_revenue_info

--order by primary_key


--insert into #sales_release_weekly (primary_key,customer_code,part_no,year_week,year_week_fmt,start_week,end_week,rel_qty,shipped,short)
--exec sproc300758_11728751_1681704 @Start_Date,@End_Date
--sales_release_diff_v2