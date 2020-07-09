/*
Continue working on part_production_rate_method_1 SPROC by creating a set of finished containers with the date they became ready to ship. 
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

select @start_of_week_for_start_date, @end_of_week_for_end_date


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

SELECT
  CustomerID,
  TransactionDate,
  Price,
  SUM(Price) OVER (PARTITION BY CustomerID ORDER BY TransactionDate) AS RunningTotal
FROM
  dbo.Purchases

Set to group A
START HERE:
Accumulate the quantities shipped by date
Find the date range that we worked on the part for 500 hours by adding time records
*/
select
s1.part_key,
s1.part_no,
min(s1.change_date) first_moved,
s1.serial_no,
s1.quantity,
sum(s1.quantity) over (partition by s1.part_key order by min(s1.change_date)) RunningTotalQuantity,
count(*) cnt
from
(
  select
  --count(*)
  p.part_key,
  p.part_no,
  c.serial_no,
  c.quantity,
  cc.change_date
  from sales_v_shipper_container sc --85808
  inner join part_v_container c
  on sc.serial_no=c.serial_no  -- 1 to 1 ; There can be more than one shipper_container with the same serial_no but not more than 1 part_v_container.
  inner join part_v_part p
  on c.part_key=p.part_key -- 1 to 1
  inner join part_v_container_change2 cc
  on c.serial_no=cc.serial_no  --1 to many, 1,627,750
  inner join sales_v_shipper_line sl
  on sc.shipper_line_key=sl.shipper_line_key  -- 1 to 1 
  inner join sales_v_shipper sh
  on sl.shipper_key=sh.shipper_key  -- 1 to 1 
  inner join sales_v_shipper_status ss
  on sh.shipper_status_key=ss.shipper_status_key  -- 1 to 1, 1,627,750 
  where 
  ss.shipper_status = 'Shipped'  -- 1,626,271
  and c.container_status = 'Shipped'  -- 1,626,271
  and cc.location like 'Finished%'
  and cc.last_action = 'Container Move'  -- moved to Finished, 	81,400
) s1
group by s1.part_key,s1.part_no,s1.serial_no,s1.quantity
having min(s1.change_date) between @start_of_week_for_start_date and @end_of_week_for_end_date 

--cc.Change_Date between @start_of_week_for_start_date and @end_of_week_for_end_date  -- 168769
-- select distinct container_status from part_v_container_status

/*
select
top 10
c.serial_no,
max(cc.Change_Date) change_date,
from sales_v_shipper_container sc
inner join part_v_container c
on sc.serial_no=c.serial_no
inner join part_v_container_status cs
on c.container_status=cs.container_status --1 to 1
inner join sales_v_shipper_line 
inner join part_v_container_change2 cc 
on c.serial_no=cc.serial_no  --1 to many

where 
c.Change_Date between @start_of_week_for_start_date and @end_of_week_for_end_date
and c.location like 'Finished%'
and cs.defective = 0  
and cs.shipped = 'Shipped'
and cc.last_action = 'Container Move'
group by c.serial_no,cc.last_action
order by c.serial_no, cc.change_date  -- 77 
*/
/*
select
top 10
c.serial_no,
cc.Change_Date,
c.container_key,
c.Tracking_No,
c.location,
c.Last_Action cont_lst_action,
cc.last_action chg_lst_action,
c.Container_Status cont_status,
cc.Container_Status chg_status,
c.quantity
from part_v_container c
inner join part_v_container_status cs
on c.container_status=cs.container_status --1 to 1
inner join part_v_container_change2 cc 
on c.serial_no=cc.serial_no  --1 to many

where 
cc.Change_Date between @start_of_week_for_start_date and @end_of_week_for_end_date
-- and c.container_status='Shipped'
and c.location like 'Finished%'
-- This container could be found to be defective at a later date
-- but there is no way of knowing this
and cs.defective = 0  
--and cs.defective = 1  -- 95
and cc.last_action = 'Container Move'
-- This container was moved to a finished location on 1/2/20
-- and found to be defective on 1/14/20 
-- and c.serial_no = 'BM404062'
order by c.serial_no, cc.change_date  -- 77 
-- and cs.allow_ship = 1 -- 77
-- and cs.allow_ship = 0 -- 1000  This included shipped
--and cc.last_action = 'Container Move'
*/
/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int,
  year_week int,
  year_week_fmt varchar(20),
  week_fmt varchar(20),
  start_week datetime,
  end_week datetime,
  part_key int,
  part_no varchar (113)    
)


insert into #primary_key(primary_key,year_week,year_week_fmt,week_fmt,start_week,end_week,part_key,part_no)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY year_week,part_key
  ) primary_key,
  year_week,
  year_week_fmt,
  week_fmt,
  start_week,
  end_week,
  part_key,
  part_no  
  from 
  (
    select
    DATEPART(YEAR,sh.ship_date) * 100 + DATEPART(WEEK,sh.ship_date) year_week,
    
    case     
    when DATEPART(WEEK,sh.ship_date) < 10 then convert(varchar,DATEPART(YEAR,sh.ship_date)) +'-0' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + ' (Shipped)'
--    when DATEPART(WEEK,sh.ship_date) < 10 then 'W0' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + '-Shipped'
    else 
--     'W' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + '-Shipped'
    convert(varchar,DATEPART(YEAR,sh.ship_date)) +'-' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + ' (Shipped)'
    end year_week_fmt,
    case     
--    when DATEPART(WEEK,sh.ship_date) < 10 then convert(varchar,DATEPART(YEAR,sh.ship_date)) +'-0' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + ' (Shipped)'
    when DATEPART(WEEK,sh.ship_date) < 10 then 'W0' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + '-Shipped'
    else 
     'W' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + '-Shipped'
--    convert(varchar,DATEPART(YEAR,sh.ship_date)) +'-' + convert(varchar,DATEPART(WEEK,sh.ship_date)) + ' (Shipped)'
    end week_fmt,
    case 
    when DATEPART(WEEK,sh.ship_date) = 1 then datefromparts(DATEPART(YEAR,sh.ship_date), 1, 1)
    else DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 6) 
    end start_week, 
    case                                                        
    when DATEPART(WEEK,sh.ship_date) > 51 and  (DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 5))=1)  then DATEADD(second,-1,convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,sh.ship_date), 12, 31))))
    else DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 5)))
    end end_week,
    
--    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 6) start_week, 
--    DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 5))) end_week, 
    sl.part_key,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no  
    from sales_v_shipper sh 
    inner join sales_v_shipper_line sl 
    on sh.shipper_key=sl.shipper_key   --1 to many
    inner join part_v_part p
    on sl.part_key=p.part_key  --1 to 1
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    where sh.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.shipper_status='Shipped' 
  )s1 
  group by year_week,year_week_fmt,week_fmt,start_week,end_week,part_key,part_no

)  

--select count(*) #primary_key from #primary_key  --169
select top(100) * from #primary_key

/*
WORK AREA



  select 
  --top 500
  s1.part_no,
  sum(s1.quantity)
  from
  (
    select 
    p.part_no,
    sc.quantity
    from sales_v_shipper_container sc  --80558
    inner join sales_v_shipper_line sl
    on sc.shipper_line_key=sl.shipper_line_key  -- 1 to 1
    inner join sales_v_shipper sh
    on sl.shipper_key=sh.shipper_key  -- 1 to 1
    inner join part_v_part p
    on sl.part_key=p.part_key  --1 to 1
    where sh.ship_date between '05/01/2020 00:00:00' and '06/01/2020 00:00:00'
    and p.part_no = '48625-0C011'
  )s1
  group by s1.part_no
--  where sh.ship_date between '06/01/2020 00:00:00' and '07/01/2020 00:00:00'
--  and p.part_no = '48625-0C011'




*/