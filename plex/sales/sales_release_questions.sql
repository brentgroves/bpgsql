
-- Is sales_release.quantity = sales_release.order_quantity? NO, Order_quantity can be less than order_quantity.
select 
top (500)
release_no,
pl.part_key,
p.part_key,
p.part_no,
sr.quantity,
sr.order_quantity
from sales_v_release sr
left outer join sales_v_release_status rs  -- 1 to 1
on sr.release_status_key=rs.release_status_key  
left outer join sales_v_po_line pl --1 to 1
on sr.po_line_key=pl.po_line_key 
left outer join part_v_part p  --1 to 1
on pl.part_key=p.part_key
where rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
and sr.quantity<>sr.order_quantity
and pl.part_key is not null and p.part_key is null  --0
--where quantity<>order_quantity
--and sr.release_no = '857-1'
--and pl.part_key=2684942

select
--top(100) pl.part_key
count(*)
from sales_v_po_line pl
left outer join part_v_part p
on pl.part_key=p.part_key
where p.part_key is null  --0

-- Do all shipper_lines have a shipper_container? NO
select 
--top(5) *
count(*) cnt
from sales_v_shipper_line sl  --14613
left outer join sales_v_shipper_container sc
on sl.shipper_line_key=sc.shipper_line_key
where sc.shipper_line_key is null  --158

-- RELATION BETWEEN SHIPPER_LINE AND CONTAINER
--1 to many
select 
--top(5) *
count(*) cnt
from sales_v_shipper_line sl  --14613
left outer join sales_v_shipper_container sc
on sl.shipper_line_key=sc.shipper_line_key
where sc.shipper_line_key is not null  --71743

-- Do all shipper_containers have a shipper_line? YES
select 
--top(5) *
count(*) cnt
from sales_v_shipper_container sc
where sc.shipper_line_key is null  --0

-- Do all shipper_container have a loaded date? YES
select 
top(1000) loaded_date
--count(*) cnt
from sales_v_shipper_container sc
where sc.loaded_date is null  --0


--DOES SALES_V_PRICE = SHIPPER_LINE.PRICE? 
-- YES, BUT A FEW SHIPPER_LINE'S HAVE A PRICE BUT THE SALES_V_PRICE RECORDS HAS BEEN DELETED.
select 
top(10) part_key,quantity,sl.price,p.price,sl.shipment_price,p.shipment_price 
from sales_v_shipper_line sl
left outer join sales_v_price p
on sl.price_key=p.price_key
where p.price_key is null
--where sl.price<>p.price --0

--Does shipper_line.quanty = release.quantity? NO
--Thare are many shipper_line.quantity < release.quanttity
--1 release item to many shipper_line.
select 
top(10)
sl.quantity,sr.quantity
from sales_v_shipper_line sl
left outer join sales_v_release sr
on sl.release_key=sr.release_key
where sl.quantity != sr.quantity

--How to find the loaded quantity?
-- //////////////////////////////////////////////////////////////
-- Method 1: active_containers: Count of all shipper_containers with ‘Open’ or ‘Pending’ shippers. -- 0 'Pending" shippers.
-- and sum of container quantitites. ie Loaded
-- This loaded quantity can be distributed amongst unshipped sales release items.
-- See sales_release sproc for the details
--///////////////////////////////////////////////////////////////
-- A shipper container gets created when a part container is
-- scanned into the load container to shipper screen.
-- Used to caculate the sum of loaded containers for a part.
-- Method 2: This sum can also be calculated by the part_v_container.container_status = 'Loaded'
-- Method 3: This sum can also be derived by summing the shipper_lines.  
-- Method 3 has a problem. Some quantities shown in the shipper_lines can not be 
-- traced to a shipper_container or a part_v_container that has a container_status = 'Loaded'
-- of these shipper_lines I have checked none has an associated price and no revenue 
-- should be shown on a cost report for these lines.
-- See part_v_wip_ready_loaded sproc.
--////////////////////////////////////////////////////////////////////////////
-- select shipper_status_key,shipper_status,active from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??

-- //////////////////////////////////////////////////////////////

-- Which method best to calc Loaded quantity? Method 1 or 2 seems to produce the same results.

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
  primary_key int,
  year_week int,
  year_week_fmt varchar(10),
  start_week datetime,
  end_week datetime,
  customer_no int,
  part_key int
)


insert into #primary_key(primary_key,year_week,year_week_fmt,start_week,end_week,customer_no,part_key)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY year_week,customer_no,part_key
  ) primary_key,
  year_week,
  year_week_fmt,
  start_week,
  end_week,
  customer_no,
  part_key

    --FORMAT ( pk.start_week, 'd', 'en-US' ) start_week, 
		--FORMAT ( pk.end_week, 'd', 'en-US' ) end_week, 
--    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, year)) + (week-1), 6) start_week, 
--    DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, year)) + (week-1), 5) end_week, 

  from 
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    CONVERT(varchar(10),DATEPART(YEAR,sr.ship_date)) + '-' + CONVERT(varchar(10),DATEPART(WEEK,sr.ship_date)) year_week_fmt,
    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 6) start_week, 
    DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 5))) end_week, 
    
--set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);    
    --as Num2   DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    po.customer_no,
    pl.part_key
    from sales_v_release sr
    left outer join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    left outer join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    where ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
  )s1 
  group by year_week,year_week_fmt,start_week,end_week,customer_no,part_key

)  

create table #set2groupB
(
  primary_key int,
  quantity decimal (18,3)
)

insert into #set2groupB (primary_key,quantity)
(
  select 
  pk.primary_key,
  sc.quantity
  from
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    po.customer_no,
    pl.part_key,
    --Do not use this to calculate shipped quantity instead use sr.quantity_shipped
    --Although the shipper_container has a sales_release key and the sum of sc.quantity  
    -- should equal sr.quantity_shipped see wip_loaded sproc for more info.
    sc.quantity
    from sales_v_release sr  
    inner join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    inner join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    inner join sales_v_shipper_container sc --1 to many  
    on sr.release_key=sc.release_key  --Not all sales release items will have a shipper_container
    inner join sales_v_shipper_line sl 
    --Shipper_container primary key is shipper_line_key,serial_no,release_key combination
    --Be careful. Don't fully understand this key.
    on sc.shipper_line_key=sl.shipper_line_key  --many to 1 ; There can be many shipper_containers for a shipper_line
    inner join sales_v_shipper sh  --1 to 1
    on sl.shipper_key=sh.shipper_key  --
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.active=1
  )sc
  inner join #primary_key pk
  on pk.year_week=sc.year_week
  and pk.customer_no=sc.customer_no
  and pk.part_key=sc.part_key

)

select count(*) #set2groupB from #set2groupB



create table #active_containers
(
  primary_key int,
  active_containers int,
  qty_loaded decimal (18,3)
  
)



insert into #active_containers (primary_key,active_containers,qty_loaded)
(

  select 
  --sc.*
  pk.primary_key,
  count(*) active_containers,
  sum(gb.quantity) qty_loaded
  --ss.active
  from #primary_key pk  
  inner join #set2groupB gb
  on pk.primary_key=gb.primary_key
  group by pk.primary_key

)

select count(*) #active_containers from #active_containers
--select top(100) * from #active_containers


create table #set2groupC
(
  primary_key int,
  quantity decimal (18,3),  --Another way to calc Loaded via shipper_lines.
  price decimal (18,6)
)

insert into #set2groupC (primary_key,quantity,price)
(
  select 
  pk.primary_key,
  sl.quantity,
  sl.price
  from
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    po.customer_no,
    pl.part_key,
    --Do not use this to calculate shipped quantity instead use sr.quantity_shipped
    --Although the shipper_container has a sales_release key and the sum of sc.quantity  
    -- should equal sr.quantity_shipped see wip_loaded sproc for more info.
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
    and ss.active=1  --ie Open or Pending, not shipped or cancelled
  )sl
  inner join #primary_key pk
  on pk.year_week=sl.year_week
  and pk.customer_no=sl.customer_no
  and pk.part_key=sl.part_key

)

select count(*) #set2groupC from #set2groupC
create table #loaded_revenue
(
  primary_key int,
  qty_loaded decimal (18,3),
  revenue decimal (18,6)
  
)



insert into #loaded_revenue (primary_key,qty_loaded,revenue)
(

  select 
  --sc.*
  pk.primary_key,
  sum(gc.quantity) qty_loaded,
  sum(gc.price) revenue
  --ss.active
  from #primary_key pk  
  inner join #set2groupC gc
  on pk.primary_key=gc.primary_key
  group by pk.primary_key

)

select count(*) #loaded_revenue from #loaded_revenue
--select top(100) * from #loaded_revenue

-- Which method best to calc Loaded quantity?
select 
--top(100) * 
count (*) cnt  --0
from #active_containers ac
left outer join #loaded_revenue lr
on ac.primary_key=lr.primary_key
where lr.primary_key is null -- 0

select 
top(100) lr.* 
--count (*) cnt  --5
from #loaded_revenue lr
left outer join #active_containers ac
on lr.primary_key=ac.primary_key
--where ac.primary_key is not null -- Some price is 0?
where ac.primary_key is null -- 5  Why is there no price on these? Why are they not in the #active_container set?


  select 
  pk.primary_key,
  sl.quantity,
  sl.price,
  sl.price_key,
  sl.shipper_line_key,
  sl.shipper_line_note,
  sl.note,
  sl.part_key,
  sl.sl_part_key,
  sl.shipper_status,
  sl.shipped,
  sl.active  
  from
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    po.customer_no,
    pl.part_key,
    sl.part_key as sl_part_key,
    --Do not use this to calculate shipped quantity instead use sr.quantity_shipped
    --Although the shipper_container has a sales_release key and the sum of sc.quantity  
    -- should equal sr.quantity_shipped see wip_loaded sproc for more info.
    sl.quantity,
    sl.price,
    sl.price_key,
    sl.shipper_line_key,
    sl.shipper_line_note,
    sl.note,
    ss.shipper_status,
    ss.shipped,
    ss.active
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
    where sr.ship_date between @Start_Date and @End_Date
    and ss.active=1  --ie Open or Pending, not shipped or cancelled
  )sl
  inner join #primary_key pk
  on pk.year_week=sl.year_week
  and pk.customer_no=sl.customer_no
  and pk.part_key=sl.part_key
  where pk.primary_key in (52,74,125,128,129)


--What is the shipper_status of these items? Open
--Are there any shipper_containers associated with these shipper_lines? NO
--Are they linked to a part_container instead of a shipper_container?  No. None of the part_v_container had a container_status = 'Loaded'
select 
*
from
(
  select 
--  pk.primary_key,
  sl.quantity,
--  sl.price,
--  sl.shipper_line_key,
  sl.part_key
--  sl.sl_part_key
--  sl.shipper_status,
--  sl.shipped,
--  sl.active  
  from
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    po.customer_no,
    pl.part_key,
    sl.part_key as sl_part_key,
    --Do not use this to calculate shipped quantity instead use sr.quantity_shipped
    --Although the shipper_container has a sales_release key and the sum of sc.quantity  
    -- should equal sr.quantity_shipped see wip_loaded sproc for more info.
    sl.quantity,
    sl.price,
    sl.shipper_line_key,
    ss.shipper_status,
    ss.shipped,
    ss.active
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
    where sr.ship_date between @Start_Date and @End_Date
    and ss.active=1  --ie Open or Pending, not shipped or cancelled
  )sl
  inner join #primary_key pk
  on pk.year_week=sl.year_week
  and pk.customer_no=sl.customer_no
  and pk.part_key=sl.part_key
  where pk.primary_key in (52,74,125,128,129)
) s1
inner join part_v_container pc
on s1.part_key=pc.part_key 
and pc.container_status = 'Loaded'  --0
--and s1.quantity=pc.quantity
/*
    select
    customer_no,
    part_key,
    count(*) active_containers,
    sum(quantity) qty_loaded
    from
    (
      select
      po.customer_no,
      pl.part_key,
      sc.quantity
      from sales_v_release sr  
      inner join sales_v_po_line pl --1 to 1
      on sr.po_line_key=pl.po_line_key 
      inner join sales_v_po po  -- 1 to 1
      on pl.po_key = po.po_key  
      inner join sales_v_shipper_container sc --1 to many  
      on sr.release_key=sc.release_key  --
      inner join sales_v_shipper_line sl 
      --Shipper_container primary key is shipper_line_key,serial_no,release_key combination
      --Be careful. Don't fully understand this key.
      on sc.shipper_line_key=sl.shipper_line_key --many to 1 ; There can be many shipper_containers for a shipper_line
      inner join sales_v_shipper sh  --1 to 1
      on sl.shipper_key=sh.shipper_key  --
      inner join sales_v_shipper_status ss --1 to 1
      on sh.shipper_status_key=ss.shipper_status_key  --
      where sr.ship_date between @Start_Date and @End_Date
      and ss.active=1
    )s1
        group by customer_no,part_key
*/