-- ToDo: Add Revenue 
-- Reports: WeeklyVolumeTrend
-- Primary Key: Work Week, Part, 
-- Columns: work week, part, quantity shipped.
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

--select count(*) #primary_key from #primary_key  --169
--select top(1) * from #primary_key


/*
Find PO Status totals: Canceled,Open,Hold,etc.
*/

create table #set2group
(
  primary_key int,
  release_no varchar (50),
  release_status varchar (50),
  release_type varchar (50),
  quantity decimal,
  shipped decimal    
)

insert into #set2group (primary_key,release_no,release_status,release_type,quantity,shipped)
(
select
pk.primary_key,
sr.release_no,
sr.release_status,
sr.release_type,
sr.quantity,
sr.shipped
from #primary_key pk
inner join
(
  select
  DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
  po.customer_no,
  pl.part_key,
  sr.release_no,
  rs.release_status,
  rt.release_type,
  sr.quantity,
  sr.quantity_shipped shipped
  from sales_v_release sr
  left outer join sales_v_release_status rs  --1 to 1
  on sr.release_status_key=rs.release_status_key  
  left outer join sales_v_release_type rt --1 to 1
  on sr.release_type_key=rt.release_type_key 
  inner join sales_v_po_line pl --1 to 1
  on sr.po_line_key=pl.po_line_key 
  inner join sales_v_po po  -- 1 to 1
  on pl.po_key = po.po_key  
  where ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
)sr
on pk.year_week=sr.year_week
and pk.customer_no=sr.customer_no
and pk.part_key=sr.part_key
)

--select count(*) #set2group from #set2group  --2298

create table #release_info
(
  primary_key int,
  s_canceled int,
  s_closed int,
  s_hold int,
  s_open int,
  s_open_scheduled int,
  s_staged int,
  t_forecast int,
  t_pull_signal int,
  t_ship_schedule int,
  t_planned int,
  t_spot_buy int,
  rel_qty decimal,
  release_items int,
  shipped 	decimal,
  short int

)
--  sr.quantity_shipped shipped,  -- this is contained right in the sales_release record


insert into #release_info (primary_key,s_canceled,s_closed,s_hold,s_open,s_open_scheduled,s_staged,t_forecast,t_pull_signal,t_ship_schedule,t_planned,t_spot_buy,rel_qty,release_items,shipped,short)
(
    select
    primary_key,
    sum(s_canceled) s_canceled,
    sum(s_closed) s_closed,
    sum(s_hold) s_hold,
    sum(s_open) s_open,
    sum(s_open_scheduled) s_open_scheduled,
    sum(s_staged) s_staged,
    sum(t_forecast) t_forecast,
    sum(t_pull_signal) t_pull_signal,
    sum(t_ship_schedule) t_ship_schedule,
    sum(t_planned) t_planned,
    sum(t_spot_buy) t_spot_buy,
    sum(quantity) rel_qty,
    (
      select count(*) 
      from #set2group s2g2 
      where s2g2.primary_key=s2g.primary_key
    ) release_items,
--    (  DON'T THINK I NEED THIS INFO
--      select count(*) from
--      (
--        select distinct release_no 
--        from #set2group s2g2
--        where s2g2.primary_key=s2g.primary_key
--      )ss
--    ) release_numbers 
    sum(shipped) shipped,
    case 
    when sum(quantity) > sum(shipped) then 1
    else 0
    end short
    from 
    (
      select 
    --  top(1)
      primary_key,
      release_status,
      case 
        when release_status = 'Canceled' then 1
        else 0
      end s_canceled,
      case 
        when release_status = 'Closed' then 1
        else 0
      end s_closed,
      case 
        when release_status = 'Hold' then 1
        else 0
      end s_hold,
      case 
        when release_status = 'Open' then 1
        else 0
      end s_open,
      case 
        when release_status = 'Open - Scheduled' then 1
        else 0
      end s_open_scheduled,
      case 
        when release_status = 'Staged' then 1
        else 0
      end s_staged,
      release_type,
      case 
        when release_type = 'Forecast' then 1
        else 0
      end t_forecast,
      case 
        when release_type = 'Pull Signal' then 1
        else 0
      end t_pull_signal,
      case 
        when release_type = 'Ship Schedule' then 1
        else 0
      end t_ship_schedule,
      case 
        when release_type = 'Planned' then 1
        else 0
      end t_planned,
      case 
        when release_type = 'Spot Buy' then 1
        else 0
      end t_spot_buy,
      quantity,
      release_no,
      shipped
      from #set2group
    )s2g
    group by primary_key
  --where t_spot_buy != 0
)
--select count(*) #release_info from #release_info
--select * from #release_info
/*
--select release_type from sales_v_release_type
 	release_type
1	Forecast
2	Pull Signal
3	Ship Schedule
4	Planned
5	Spot Buy
*/
/*
--select release_status from sales_v_release_status
 	release_status
1	Canceled
2	Closed
3	Hold
4	Open
5	Open - Scheduled
6	Scheduled
7	Staged
*/
--select * from sales_v_release_type


-- A 2nd set to group is needed for info regarding shipping containers such as revenue.
-- There is a 1 to many relation between release items and shipper_container records.

create table #set2groupB
(
  primary_key int
)

insert into #set2groupB (primary_key)
(
  select 
  pk.primary_key
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

-- //////////////////////////////////////////////////////////////
-- active_containers: Count of all Containers with ‘Open’ or ‘Pending’ shippers. 
-- and sum of container quantitites. ie Loaded
-- This loaded quantity can be distributed amongst unshipped sales release items.
-- See sales_release sproc for the details
--///////////////////////////////////////////////////////////////
-- A shipper container gets created when a part container is
-- scanned into the load container to shipper screen.
-- Used to caculate the sum of loaded containers for a part.
-- This sum can also be calculated by the part_v_container.container_status = 'Loaded'
-- This sum can also be derived by summing the shipper_lines
-- See part_v_wip_ready_loaded sproc.
--////////////////////////////////////////////////////////////////////////////
-- select shipper_status_key,shipper_status,active from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??

-- //////////////////////////////////////////////////////////////

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
  s2.active_containers,
  s2.qty_loaded
  --ss.active
  from #primary_key pk  
  inner join
  (
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
      where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
      and ss.active=1
    )s1
    group by customer_no,part_key
  )s2
  on pk.customer_no=s2.customer_no
  and pk.part_key=s2.part_key
)

--select count(*) #active_containers from #active_containers
--select * from #active_containers





/*
Final set: Join of all intermediate sets.
*/

create table #sales_release_weekly
(
  primary_key int,
  year_week int,
  year_week_fmt varchar(10),
  start_week datetime,
  end_week datetime,
  customer_code varchar (35),
  part_no varchar (113),
  name varchar(100),
  active_containers int,
  qty_loaded decimal (18,3),
  s_canceled int,
  s_closed int,
  s_hold int,
  s_open int,
  s_open_scheduled int,
  t_forecast int,
  t_pull_signal int,
  t_ship_schedule int,
  t_planned int,
  t_spot_buy int,
  rel_qty decimal,
  release_items int,
  shipped decimal,
  short int,
  rel_bal decimal
-- release_numbers, doesn't make sense to get this becase a release can be for multiple part numbers?
-- number of po.  doesn't make sense because a po can be for multiple part numbers
-- shippers.  does not make sense to get this because a shipper can be for multiple part numbers.
)


insert into #sales_release_weekly (primary_key,year_week,year_week_fmt,start_week,end_week,customer_code,part_no,name,active_containers,qty_loaded,
s_canceled,s_closed,s_hold,s_open,s_open_scheduled,t_forecast,t_pull_signal,t_ship_schedule,t_planned,t_spot_buy,
rel_qty,release_items,shipped,short, rel_bal)
(
  select
  primary_key,
  year_week,
  year_week_fmt,
  start_week,
  end_week,
  customer_code,
  part_no,
  name,
  active_containers,  --NOT VALIDATED
  qty_loaded,  -- NOT VALIDATED
  s_canceled,
  s_closed,
  s_hold,
  s_open,
  s_open_scheduled,
  t_forecast,
  t_pull_signal,
  t_ship_schedule,
  t_planned,
  t_spot_buy,
  rel_qty,
  release_items,
  shipped,
  short,
  rel_qty - shipped - qty_loaded as rel_bal
  from
  (
    select 
    pk.primary_key,
    pk.year_week,
    pk.year_week_fmt,
    pk.start_week,
    pk.end_week,
    --gr.customer_no,
    c.customer_code,
    --gr.part_key,
    --p.part_no,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no,  --The report says 10025543 RevD I can't find the Rev word
    p.name,
    case
      when ac.active_containers is null then 0
      else ac.active_containers
    end active_containers,  --NOT VALIDATED
    case
      when ac.qty_loaded is null then 0
      else ac.qty_loaded
    end qty_loaded,  -- NOT VALIDATED
    ri.s_canceled,
    ri.s_closed,
    ri.s_hold,
    ri.s_open,
    ri.s_open_scheduled,
    ri.t_forecast,
    ri.t_pull_signal,
    ri.t_ship_schedule,
    ri.t_planned,
    ri.t_spot_buy,
    ri.rel_qty,
    ri.release_items,
    ri.shipped,
    ri.short
    from #primary_key pk
    left outer join #active_containers ac
    on pk.primary_key=ac.primary_key
    left outer join part_v_part p -- 1 to 1
    on pk.part_key=p.part_key 
    left outer join common_v_customer c  --1 to 1
    on pk.customer_no=c.customer_no 
    left outer join #release_info ri
    on pk.primary_key=ri.primary_key
  )s1
  
)

--select count(*) #sales_release_weekly from #sales_release_weekly
--select top(100) * from #sales_release_weekly 
--where qty_loaded > 0
select *
from #sales_release_weekly
where rel_qty > 0
order by customer_code,part_no,year_week
--order by primary_key


--insert into #sales_release_weekly (primary_key,customer_code,part_no,year_week,year_week_fmt,start_week,end_week,rel_qty,shipped,short)
--exec sproc300758_11728751_1681704 @Start_Date,@End_Date
--sales_release_diff_v2