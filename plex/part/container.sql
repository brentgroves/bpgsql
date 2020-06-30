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

/*
Can we say that if a container is currently in a finished location that it is ready to ship?
If we can say it is ready to ship then when exactly was it ready?
Was it ready to ship when the container was last moved?
Can we conclude that we completed X amount of parts on the last moved date of this container?
select distinct left(last_action,5) from part_v_container_change2
select distinct container_status from part_v_container
1	Consignment Accepted
2	Hold
3	Impreg
4	Loaded
5	OK
6	Receiving
7	Rework
8	Scrap
9	Setup Part
10	Shipped
11	Supplier Labeled
12	Supplier Shipped

select * from part_v_container_status
select distinct location from part_v_container_change2
*/

select
s1.serial_no,
s1.finished_date,
s1.location,
s1.ship_date,
DATEDIFF(day,s1.finished_date,s1.ship_date) finished_to_shipped
from
(
  select
--  top 100
  sc.serial_no,
  min(cc.change_date) finished_date,
  cc.location,
  sh.ship_date
  from sales_v_shipper_container sc
  inner join sales_v_shipper_line sl
  on sc.shipper_line_key=sl.shipper_line_key -- 1 to 1
  inner join sales_v_shipper sh
  on sl.shipper_key=sh.shipper_key -- 1 to 1
  inner join part_v_container_change2 cc 
  on sc.serial_no=cc.serial_no  --1 to many
  where 
  --cc.last_action = 'Container Move'
  cc.location like 'Finished%'
  group by sc.serial_no,sh.ship_date,cc.location
)s1
where DATEDIFF(day,s1.finished_date,s1.ship_date) > 100
order by s1.serial_no


/*
--does we use sales shippers to send scrap parts? NO
  select 
  --distinct c.location
  count(*) cnt
  from part_v_container c
  inner join part_v_container_status cs
  on c.container_status=cs.container_status --1 to 1
  left outer join sales_v_shipper_container sc
  on c.serial_no=sc.serial_no  --1 to 1
  where cs.container_status = 'Scrap'  --71,634
  and sc.serial_no is not null  -- 0 Records
*/
/*
-- DOES EVER PART CONTAINER WITH A STATUS OF SHIPPED HAVE A CORRESPONDING SHIPPER_CONTAINER: YES
select 
count(*) cnt
from
(
  select
  --top 10
  c.serial_no
  from part_v_container c
  inner join part_v_container_status cs
  on c.container_status=cs.container_status --1 to 1
  left outer join sales_v_shipper_container sc
  on c.serial_no=sc.serial_no
  where cs.container_status = 'Shipped'  --84539
  -- and sc.serial_no is null  -- 0 records
  --and c.serial_no = sc.serial_no   -- 84539 records
)s1
*/
/*
select
top 10
c.serial_no,
max(cc.Change_Date) change_date,
from part_v_container c
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
