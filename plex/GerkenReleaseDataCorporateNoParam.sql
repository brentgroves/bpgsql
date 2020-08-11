-- Declare @Start_Date datetime 
-- Declare @Work_Days datetime
-- set @Work_Days = 10
-- 1. Place the following SPROC in your folder in any query.
-- 2. Copy the following to the SDE parameters tab:
--    @Start_Date datetime = '20200801',@Work_Days int = 20
-- 3. Save SPROC and select the 'Access in Intelliplex' option.
-- 4. Create Intelliplex report and use SPROC as datasource.
-- @Start_Date datetime = '20200801'
-- @Work_Days int = 20

Declare @Start_Date datetime 

-- set @Start_Date = '20200801'
set @Start_Date = GETDATE()

Declare @Work_Days datetime
set @Work_Days = 20

Declare @End_Date datetime

Declare @PCN int
--set @PCN = 	295933  -- Franklin
set @PCN = 	295932  -- Fruitport


Declare @start_of_week_for_start_date datetime
Declare @start_year char(4)
Declare @start_week int

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)

if DATEPART(WEEK,@Start_Date) = 1
set @start_of_week_for_start_date = datefromparts(DATEPART(YEAR,@Start_Date), 1, 1)
else
set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 7)  --start of week

set @Start_Date = @start_of_week_for_start_date

-- Make sure time starts at 12am.
set @Start_Date = datefromparts(DATEPART(YEAR,@Start_Date),DATEPART(MONTH,@Start_Date), DATEPART(DAY,@Start_Date));



with cte_business_days(date,workDays) as
(
  select 
  @Start_Date date,
  CASE
    WHEN ((DATENAME(WEEKDAY, @Start_Date) = 'Sunday') or (DATENAME(WEEKDAY, @Start_Date) = 'Saturday'))
    THEN 0
    ELSE 1
  END as workDays
  union all
  select dateadd(day, 1, date),
  CASE
    WHEN ((DATENAME(WEEKDAY, dateadd(day, 1, date)) != 'Sunday') and (DATENAME(WEEKDAY, dateadd(day, 1, date)) != 'Saturday'))
    THEN workDays+1
    ELSE workDays
  END  
  -- weekday+1
  from cte_business_days
  where workDays < @Work_Days
)

select @End_Date = max(date) 
from cte_business_days
option (maxrecursion 100);


set @End_Date = DATEADD(second,-1,DATEADD(day,1,@End_Date))



--/* testing 0
-- select @Start_Date, @End_Date
--*/ end testing 0 

/*
primary_key: Determine primary key of result set.
*/

create table #primary_key
(
  primary_key int,
  PCN int,
  part_key int,
  part_no varchar(100),
  name varchar(100)
)
insert into #primary_key(primary_key,PCN,part_key,part_no,name)
(
  select 
  ROW_NUMBER() OVER (
    ORDER BY part_no
  ) primary_key,
  s1.PCN,
  s1.part_key,
  s1.part_no,
  s1.name
  from
  (

  select 
  distinct p.plexus_customer_no PCN,p.part_key,p.part_no,p.name

-- COUNTS ARE FOR FRUITPORT ON 08/05
  from part_v_part_e as p  -- 735

  inner join part_v_part_operation_e o  -- 4335
  on p.part_key=o.part_key  -- 1 to many

  inner join part_v_container_e as c  -- 2,597,167
  on o.part_operation_key=c.part_operation_key -- 1 to many; only operation_key is necessary  
  
  inner join part_v_container_status_e as cs  -- 2,597,167
  on c.container_status = cs.container_status  -- 1 to 1

  where 
  c.active = 1  -- 2335  -- FRUITPORT
  and (p.part_source_key = 373  or p.part_source_key = 788 ) -- 2000 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 2000 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 1964 
  and cs.allow_ship = 1  -- 1932 -- PPAP or quality
  and o.shippable=1  --627 Joining to the part_operation table adds more time to query and does not filter any additional records --4411,releases
  )s1
)



-- select* from #primary_key
-- Release total quantities


create table #set2groupB
(
  part_key int,
  part_no varchar(100),
  quantity decimal
  
)

insert into #set2groupB(part_key,part_no,quantity)
(

  select 
  p.part_key,
  p.part_no,
  sr.quantity
  -- COUNTS ARE FOR FRUITPORT ON 08/05
  from sales_v_release_e sr -- 36,712
  inner join sales_v_release_status_e rs  -- 36,712
  on sr.release_status_key = rs.release_status_key -- 1 to 1  
  inner join sales_v_po_line_e as pl  -- 36,712
  on sr.po_line_key = pl.po_line_key  -- 1 to 1
  inner join sales_v_po_e as po  -- 36,712
  on pl.po_key = po.po_key  -- 1 to 1
  inner join sales_v_po_status_e as ps  -- 36,712
  on po.po_status_key = ps.po_status_key  -- 1 to 1
  inner join part_v_part_e as p  -- 36,712
  on pl.part_key = p.part_key  -- 1 to 1 
  where 
  (rs.release_status ='Open' or rs.release_status = 'Scheduled')  -- 1,289
  and sr.ship_date between @Start_Date and @End_Date  -- 287
  and sr.quantity > 0  -- 285
)  
-- select count(*) cnt from #set2groupB
-- select top 100 * from #set2groupB

-- Inventory totals
create table #set2groupA
(
  part_key int,
  quantity decimal (19,5)
)


insert into #set2groupA(part_key,quantity)
(
  select 
  p.part_key,
  c.quantity
  
-- COUNTS ARE FOR FRUITPORT ON 08/05
  from part_v_part_e as p  -- 735

  inner join part_v_part_operation_e o  -- 4335
  on p.part_key=o.part_key  -- 1 to many

  inner join part_v_container_e as c  -- 2,597,167
  on o.part_operation_key=c.part_operation_key -- 1 to many; only operation_key is necessary  
  
  inner join ( 
    select container_status,max(allow_ship) allow_ship 
    from
    (
      select distinct container_status,allow_ship from part_v_container_status_e as cs --order by container_status -- 2,597,167
    )s
    group by container_status
  -- select container_status,allow_ship from part_v_container_status_e as cs order by container_status  -- 2,597,167
  )cs
  on c.container_status = cs.container_status  -- 1 to 1

  where 
  c.active = 1  -- 2335  -- FRUITPORT
  and (p.part_source_key = 373  or p.part_source_key = 788 )  -- 2000 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 2000 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 1964 
  and cs.allow_ship = 1  -- 1932 -- PPAP or quality
  and o.shippable=1  --627 Joining to the part_operation table adds more time to query and does not filter any additional records 
)

-- select count(*) #set2groupA from #set2groupA  --627
/*
select top 10 * 
from #set2groupA a
where a.part_key = 2800320
inner join part_v_part p
on a.part_key=p.part_key
where p.part_no = '001-0408-04'
*/
create table #price
(
  part_key int,
  price decimal (18,6)
  
)

insert into #price(part_key,price)
(
  select
  s4.part_key,
  -- pr.effective_date,
  pr.price
  from
  (
    select
    s2.part_key,
    s2.effective_date,
    max(s3.price_key) price_key  -- there can be multiple price_keys with the same effective_date so pick the last added
    from
    (
      select
      s1.part_key,
      max(effective_date) effective_date 
      from
      (
        select
        pl.part_key,
        pr.Effective_Date
        -- pr.price_key,
        -- pr.price
        from sales_v_price_e pr
        inner join sales_v_po_line_e pl
        on pr.po_line_key=pl.po_line_key -- many to 1
        where 
        -- part_key = 2488053
        -- pl.part_key in (2488053,2488530)
        --order by pl.part_key,pr.effective_date desc
        pr.active=1
        and 
        (
          (@Start_Date between pr.effective_date and pr.expiration_date) or
          (pr.expiration_date is null)
        )
      )s1
      group by s1.part_key
    )s2
    inner join 
    (
      select
      s1b.part_key,
      s1b.price_key,
      s1b.effective_date 
      from
      (
        select
        pl.part_key,
        pr.Effective_Date,
        pr.price_key
        -- pr.price
        from sales_v_price_e pr
        inner join sales_v_po_line_e pl
        on pr.po_line_key=pl.po_line_key
        where 
        -- part_key = 2488053
        -- pl.part_key in (2488053,2488530)
        --order by pl.part_key,pr.effective_date desc
        pr.active=1
        and 
        (
          (@Start_Date between pr.effective_date and pr.expiration_date) or
          (pr.expiration_date is null)
        )
        -- same as the set s2 except with no grouping; multiple records per part
      )s1b
  
    )s3
    on s2.part_key=s3.part_key
    and s2.effective_date=s3.effective_date  -- 1 to many
    group by s2.part_key,s2.effective_date

  )s4
  inner join sales_v_price_e pr
  on s4.price_key=pr.price_key
)  


-- select count(*) #price from #price
-- select * from #price


create table #result
(
  primary_key int,
  PCN int,
  part_key int,
  part_no varchar(100),
  name varchar(100),
  unit_price decimal (18,6),
  total_quantity decimal (19,5),
  total_price decimal (18,6),
  release_quantity int
)

insert into #result (primary_key,PCN,part_key,part_no,name,unit_price,total_quantity,total_price,release_quantity)
(
  select 
  s2.primary_key,
  s2.PCN,
  s2.part_key,
  s2.part_no,
  s2.name,

  case
    when s2.unit_price is null then 0.00
    else s2.unit_price
  end unit_price,

  case
    when s2.total_quantity is null then 0.00
    else s2.total_quantity
  end total_quantity,
  case
    when s2.total_price is null then 0.00
    else s2.total_price
  end total_price,
  case
    when s2.release_quantity is null then 0.00
    else s2.release_quantity
  end release_quantity
  from
  (
    select 
    pk.primary_key,
    pk.PCN,
    pk.part_key,
    pk.part_no,
    pk.name,
    s1.quantity total_quantity,
    pr.price unit_price,
    s1.quantity * pr.price total_price,
    s0.release_quantity
    from #primary_key pk
    left outer join
    (
      select
      sg.part_key,
      sum(sg.quantity) quantity
      from #set2groupA sg -- 729
      group by sg.part_key
    )s1
    on pk.part_key=s1.part_key
    left outer join
    (
      select
      sb.part_key,
      sum(sb.quantity) release_quantity
      from #set2groupB sb
      group by sb.part_key
    )s0
    on pk.part_key=s0.part_key
    left outer join #price pr 
    on pk.part_key = pr.part_key 
  )s2
)

-- select count(*) cnt from #result
select
PCN,
part_no,
part_key,
name,
unit_price,
total_quantity,
total_price,
release_quantity
from #result

/*
  select
  pk.part_no,
  sg.quantity
  from #set2groupA sg -- 729
  inner join #primary_key pk
  on sg.part_key=pk.part_key
  where 
  pk.part_no = '4030'
*/
/*
  select 
  p.part_key,
  o.operation_no,
  c.serial_no,
  o.shippable,
  c.quantity
  from part_v_part as p  -- 4988
  inner join part_v_part_operation o
  on p.part_key=o.part_key
  inner join part_v_container as c  -- 97,391,628
  on o.part_operation_key=c.part_operation_key
  inner join part_v_container_status as cs  -- 97,391,628
  on c.container_status = cs.container_status  -- 1 to 1
  where c.active = 1  -- 86,513
  and (p.part_source_key = 373  or p.part_source_key = 788 )  -- 844 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 844 None in this set so I don't know if this line is necessary
  and cs.allow_ship = 1  -- 844 Same as container_status in ('OK','Loaded','Staged')
  and o.shippable=1  --844 Joining to the part_operation table adds more time to query and does not filter any additional records     

and p.part_no = '4031'
-- and c.serial_no = 'FC413047'
order by o.operation_no 
*/
/*
select o.operation_no 
  from part_v_part as p  -- 4988
  inner join part_v_part_operation o
  on p.part_key=o.part_key
  inner join part_v_container as c  -- 97,391,628
  on o.part_operation_key=c.part_operation_key
where c.serial_no = 'FC413047'
*/