-- Declare @Start_Date datetime 
-- Declare @Work_Days datetime
-- set @Work_Days = 10
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
select @Start_Date, @End_Date
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
    distinct p.part_key,p.part_no,p.name
    from part_v_container c
    inner join part_v_part p 
    on c.part_key=p.part_key  -- 1 to 1
    where 
    c.quantity > 0
    and c.active = 1
    
  )s1
)

select * from #primary_key


create table #set2groupA
(
  release_key int,
  -- release_no varchar (50),
  part_key int,
  quantity decimal (19,5)
  
)

insert into #set2groupA(release_key,part_key,quantity)
(
  select 
  sr.release_key,
  -- sr.release_no,
  p.part_key,
  c.quantity
  
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
  inner join part_v_container as c  -- 97,341,456
  on pl.part_key = c.part_key  -- 1 to many
  inner join part_v_container_status as cs  -- 97,341,456
  on c.container_status = cs.container_status  -- 1 to 1
  
  where c.active = 1  -- 82,186


  and (rs.release_status ='Open' or rs.release_status = 'Scheduled')  -- 4995
  and sr.ship_date between @Start_Date and @End_Date  -- 833
  and sr.quantity > 0  -- 794
  and pl.active = 1  -- 794 All of the records for this set are active; so I don't know if this line is necessary
  and ps.active = 1  -- 794 All of the records for this set are active; so I don't know if this line is necessary
  
  -- 2 records do not have an EDI line and Release no.  What does that mean?
  and p.part_source_key = 373  -- 794 All of the records for this set have this source_key; so I don't know if this line is necessary
  and p.part_status not in ('Obsolete','Inactive')  -- 794 All of the records for this set are active; so I don't know if this line is necessary
  and p.part_no <> 'Melt'  -- 794 None in this set so I don't know if this line is necessary
  and c.active = 1  -- 794 Big drop; Maybe I should do this 1st. 
--  and c.container_status in ('OK','Loaded','Safe Launch','Quality PPAP') -- 794 I don't think 'Safe Launch' and 'Quality PPAP' is a container status. 
  and cs.allow_ship = 1  -- 794 Same as container_status in ('OK','Loaded','Staged')
  


)

select count(*) #set2groupA from #set2groupA

select top 10 * from #set2groupA