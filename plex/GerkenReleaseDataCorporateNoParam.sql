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

--set @Start_Date = '20200801'
set @Start_Date = GETDATE()

Declare @Work_Days datetime
set @Work_Days = 20

Declare @End_Date datetime



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
  part_key int,
  part_no varchar(100),
  name varchar(100)
)
insert into #primary_key(primary_key,part_key,part_no,name)
(
  select 
  ROW_NUMBER() OVER (
    ORDER BY part_no
  ) primary_key,
  s1.part_key,
  s1.part_no,
  s1.name
  from
  (
  
  select 
  -- count(*) cnt
  -- sr.release_key,
  -- sr.release_no,
  distinct p.part_key,part_no,name
  -- c.quantity
  
  from sales_v_release sr
  inner join sales_v_release_status rs  -- 4988
  on sr.release_status_key = rs.release_status_key -- 1 to 1  
  inner join sales_v_po_line as pl  -- 4988
  on sr.po_line_key = pl.po_line_key  -- 1 to 1
  inner join sales_v_po as po  -- 4988
  on pl.po_key = po.po_key  -- 1 to 1
  inner join sales_v_po_status as ps  -- 4988
  on po.po_status_key = ps.po_status_key  -- 1 to 1
  inner join part_v_part as p  -- 4988
  on pl.part_key = p.part_key  -- 1 to 1 
  inner join part_v_part_operation o
  on p.part_key=o.part_key
  inner join part_v_container as c  -- 97,391,628
  on pl.part_key = c.part_key  -- 1 to many
  and o.part_operation_key=c.part_operation_key
  inner join part_v_container_status as cs  -- 97,391,628
  on c.container_status = cs.container_status  -- 1 to 1
  where c.active = 1  -- 86,513
  and (rs.release_status ='Open' or rs.release_status = 'Scheduled')  -- 4910
  and sr.ship_date between @Start_Date and @End_Date  -- 883
  and sr.quantity > 0  -- 844
  and pl.active = 1  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  and ps.active = 1  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  -- 2 records do not have an EDI line and Release no.  What does that mean?
  and p.part_source_key = 373  -- 844 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 844 None in this set so I don't know if this line is necessary
--  and c.container_status in ('OK','Loaded','Safe Launch','Quality PPAP') -- 794 I don't think 'Safe Launch' and 'Quality PPAP' is a container status. 
  and cs.allow_ship = 1  -- 844 Same as container_status in ('OK','Loaded','Staged')
  and o.shippable=1  --844 Joining to the part_operation table adds more time to query and does not filter any additional records   
  
  )s1
)

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
  from sales_v_release sr
  inner join sales_v_release_status rs  -- 4988
  on sr.release_status_key = rs.release_status_key -- 1 to 1  
  inner join sales_v_po_line as pl  -- 4988
  on sr.po_line_key = pl.po_line_key  -- 1 to 1
  inner join sales_v_po as po  -- 4988
  on pl.po_key = po.po_key  -- 1 to 1
  inner join sales_v_po_status as ps  -- 4988
  on po.po_status_key = ps.po_status_key  -- 1 to 1
  inner join part_v_part as p  -- 4988
  on pl.part_key = p.part_key  -- 1 to 1 
--  inner join part_v_part_operation o
--  on p.part_key=o.part_key
--  inner join part_v_container as c  -- 97,391,628
--  on pl.part_key = c.part_key  -- 1 to many
--  and o.part_operation_key=c.part_operation_key
--  inner join part_v_container_status as cs  -- 97,391,628
--  on c.container_status = cs.container_status  -- 1 to 1
  where 
  (rs.release_status ='Open' or rs.release_status = 'Scheduled')  -- 4910
  and sr.ship_date between @Start_Date and @End_Date  -- 883
  and sr.quantity > 0  -- 844
  and pl.active = 1  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  and ps.active = 1  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  -- 2 records do not have an EDI line and Release no.  What does that mean?
  and p.part_source_key = 373  -- 844 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 844 None in this set so I don't know if this line is necessary
  
)  
--  and c.container_status in ('OK','Loaded','Safe Launch','Quality PPAP') -- 794 I don't think 'Safe Launch' and 'Quality PPAP' is a container status. 

--  and cs.allow_ship = 1  -- 844 Same as container_status in ('OK','Loaded','Staged')
--  and o.shippable=1  --844 Joining to the part_operation table adds more time to query and does not filter any additional records  

-- select count(*) cnt from #set2groupB
-- select top 100 * from #set2groupB


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
  from part_v_part as p  -- 4988
  inner join part_v_part_operation o
  on p.part_key=o.part_key
  inner join part_v_container as c  -- 97,391,628
  on o.part_operation_key=c.part_operation_key
  inner join part_v_container_status as cs  -- 97,391,628
  on c.container_status = cs.container_status  -- 1 to 1
  where c.active = 1  -- 86,513
  and p.part_source_key = 373  -- 844 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 844 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 844 None in this set so I don't know if this line is necessary
  and cs.allow_ship = 1  -- 844 Same as container_status in ('OK','Loaded','Staged')
  and o.shippable=1  --844 Joining to the part_operation table adds more time to query and does not filter any additional records 
)

-- select count(*) #set2groupA from #set2groupA  --844

-- select top 10 * from #set2groupA
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
        top 100
        pl.part_key,
        pr.Effective_Date
        -- pr.price_key,
        -- pr.price
        from sales_v_price pr
        inner join sales_v_po_line pl
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
        top 100
        pl.part_key,
        pr.Effective_Date,
        pr.price_key
        -- pr.price
        from sales_v_price pr
        inner join sales_v_po_line pl
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
  inner join sales_v_price pr
  on s4.price_key=pr.price_key
)  


-- select count(*) #price from #price
-- select * from #price

create table #result
(
  primary_key int,
  part_key int,
  part_no varchar(100),
  name varchar(100),
  unit_price decimal (18,6),
  total_quantity decimal (19,5),
  total_price decimal (18,6),
  release_quantity int
)

insert into #result (primary_key,part_key,part_no,name,unit_price,total_quantity,total_price,release_quantity)
(
  select 
  pk.primary_key,
  pk.part_key,
  pk.part_no,
  pk.name,
  s2.unit_price,
  s2.total_quantity,
  s2.total_price,
  s2.release_quantity
  from
  (
    select 
    s1.part_key,
    s1.quantity total_quantity,
    pr.price unit_price,
    s1.quantity * pr.price total_price,
    s0.release_quantity
    from 
    (
      select
      sg.part_key,
      sum(sg.quantity) quantity
      from #set2groupA sg -- 729
      group by sg.part_key
    )s1
    inner join
    (
      select
      sb.part_key,
      sum(sb.quantity) release_quantity
      from #set2groupB sb
      group by sb.part_key
    )s0
    on s1.part_key=s0.part_key
    inner join #price pr 
    on s1.part_key = pr.part_key 
  )s2
  inner join #primary_key pk
  on s2.part_key=pk.part_key
)

-- select count(*) cnt from #result
select 
part_no,
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
  and p.part_source_key = 373  -- 844 All of the records for this set have this source_key; so I don't know if this line is necessary
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