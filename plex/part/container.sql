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
--select count(*) cnt from (
  select
  s1.part_key,
  s1.part_no,
  sum(s1.quantity) quantity
  from 
  (
-- select count(*) cnt from (
    select
    sc.shipper_container_key,
    sc.serial_no,
    sc.quantity,
    p.part_key,
    p.part_no,
    sh.ship_date,
    min(cc.change_date) finished_date,
    DATEDIFF(day,min(cc.change_date),sh.ship_date) finished_to_shipped
    -- select count(*) cnt from (
    -- select count(*) cnt
    from sales_v_shipper_container sc  -- 84,868
    inner join part_v_container pc  -- THERE CAN BE MANY SHIPPER_CONTAINER BUT ONLY 1 PART CONTAINER WITH THE SAME SERIAL_NO
    on sc.serial_no=pc.serial_no --1 to 1
    inner join part_v_part p
    on pc.part_key=p.part_key  -- 1 to 1
    inner join sales_v_shipper_line sl
    on sc.shipper_line_key=sl.shipper_line_key -- 1 to 1 (84,868)
    inner join sales_v_shipper sh
    on sl.shipper_key=sh.shipper_key -- 1 to 1 (84,868)
    inner join part_v_container_change2 cc 
    on sc.serial_no=cc.serial_no  --1 to many
    where cc.location like 'Finished%' and sh.ship_date is not null  -- this will reduce the set
    -- ship date is null when the part container is 'Loaded' to a shipper.
    group by sc.shipper_container_key,sc.serial_no,sc.quantity, p.part_key,p.part_no,sh.ship_date  -- 84,689 -- some shipper_containers are loaded but have not been shipped.
    having min(cc.change_date) between @Start_Date and @End_Date
    -- some serial_no are on more than 1 release_keys
    -- )s1
    -- The container could have been in multiple Finished locations. Look at them all and pick the one with the earliest date
  )s1 
  group by s1.part_key,s1.part_no
--)s2  --320
  -- There can be multiple shipper containers with the same serial numbers so add the quantities.
  -- Also one shipper_container may have shipped and the other may not have.
  
 -- where DATEDIFF(day,s1.finished_date,s1.ship_date) > 200 -- 19
  --where DATEDIFF(day,s1.finished_date,s1.ship_date) > 100 -- 200
  -- where DATEDIFF(day,s1.finished_date,s1.ship_date) > 50 -- 1109
  -- where DATEDIFF(day,s1.finished_date,s1.ship_date) <= 21 -- 80,720
 --  where DATEDIFF(day,s1.finished_date,s1.ship_date) <= 14 -- 78,738
  -- where DATEDIFF(day,s1.finished_date,s1.ship_date) <= 7 -- 72,965
  -- where DATEDIFF(day,s1.finished_date,s1.ship_date) <= 3 -- 58,090
  -- where DATEDIFF(day,s1.finished_date,s1.ship_date) <= 2-- 50,601
 --  where DATEDIFF(day,s1.finished_date,s1.ship_date) <= 1 -- 40081
--  where pc.location not like 'Finished%' --3 (BM000008,BM413557,BM465522)

  --order by s1.serial_no
--)s2
-- where (s2.finished_date is null) or (s2.ship_date is null) -- 0

/*   
select count(*) cnt
from sales_v_shipper_container sc  -- 84,868
group by shipper_container_key
having count(*) > 1
select serial_no,quantity from sales_v_shipper_container 
where serial_no = 'BM014709'
    A single part_v_container can correspond to multiple sales_v_shipper_containers 
    if the quantity of the sales_release is less than the part containers quantity.
     	PCN	Shipper_Line_Key	Serial_No	Release_Key	Quantity	Loaded_Date	Shipper_Container_Key
Below 1 part container was able to satisfy 2 sales release.
	PCN	Shipper_Line_Key	Serial_No	Release_Key	Quantity	Loaded_Date	Shipper_Container_Key
1	300758	24893283	BM006386	89514640	6.000	3/31/2019 12:15:28 PM	206788668
2	300758	24893283	BM006386	89541839	30.000	3/31/2019 12:15:28 PM	206788667
    
    select * from sales_v_shipper_container
    where serial_no in ('BM006386','BM006387','BM006389')
    select * from part_v_container
    where serial_no in ('BM006386','BM006387','BM006389')
*/


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