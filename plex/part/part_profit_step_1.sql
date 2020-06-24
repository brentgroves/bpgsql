/*
NOT DONE.
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

--Produced: Sum of all quantities created via reporting of production control panel. This can be several different Operations all added together for the 'Produced' quantity. 
--To limit the number of times the Production Records are included, turn on the Setting: Primary Production Only. 
--This will limit the records to only the first Operation in the Process Routing for the Parts listed. 


-- Can we determine when a container was moved to a finished location? 
Declare @sd datetime 
set @sd = '20200301'
--set @Start_Date = '20191231'
Declare @ed datetime 
set @ed = '20200314'

select 
--count(*)
top(100)
pc.serial_no,
pc.add_date,
pc.update_date
--*
--pc.location
--pc.quantity
from part_v_container pc
where pc.location like '%Finish%'
and pc.add_date between @sd and @ed
-- Are shipped container quantities, group by PARTS, equal to production counts ? 


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

select
s2.part_no,
sum(s2.quantity)
from
(
  select 
  -- top 500
  p.part_no,
  --pr.*
  pr.quantity  
  --sum(pr.quantity) production_quantity
  from part_v_production pr  
  inner join part_v_part p
  on pr.part_key=p.part_key  --1 to 1
  where p.part_no = '48625-0C011'
  and pr.report_date between '05/01/2020 00:00:00' and '06/01/2020 00:00:00'
    
)s2
group by s2.part_no 
-- screen history says 1076 this query says 1268
select top 1 * from sales_v_shipper_line

select
---count(*),
--sum(sales_shipper_container_quantity) #sales_shipper_container_quantity,
--sum(pc.quantity) #part_container_quantity
top 500
sc.serial_no,
pr.serial_no,
sc.sales_shipper_container_quantity,
pr.production_quantity
from
(
  select 
  top 500
  p.part_no,
  sc.serial_no,
  sc.quantity,
  sh.ship_date
  --sum(sc.quantity) sales_shipper_container_quantity
  from sales_v_shipper_container sc  --80558
  inner join sales_v_shipper_line sl
  on sc.shipper_line_key=sl.shipper_line_key  -- 1 to 1
  inner join sales_v_shipper sh
  on sl.shipper_key=sh.shipper_key  -- 1 to 1
  inner join part_v_part p
  on sl.part_key=p.part_key  --1 to 1
  where sh.ship_date between '06/01/2020 00:00:00' and '07/01/2020 00:00:00'
  and p.part_no = '48625-0C011'

)sc
inner join
(
  select 
  top 500
  serial_no,
  --quantity
  sum(pr.quantity) production_quantity
  from part_v_production pr  
  group by pr.serial_no 

)pr
on sc.serial_no=pr.serial_no


-- Are shipped container quantities, remember to group by serial no, equal to production counts? 
select
---count(*),
--sum(sales_shipper_container_quantity) #sales_shipper_container_quantity,
--sum(pc.quantity) #part_container_quantity
top 500
sc.serial_no,
pr.serial_no,
sc.sales_shipper_container_quantity,
pr.production_quantity
from
(
  select 
  --top 500
  serial_no,
  sum(sc.quantity) sales_shipper_container_quantity
  from sales_v_shipper_container sc  --80558
  group by sc.serial_no  -- part_containers may be satisfying multiple sales release items.
)sc
inner join
(
  select 
  top 500
  serial_no,
  --quantity
  sum(pr.quantity) production_quantity
  from part_v_production pr  
  group by pr.serial_no 

)pr
on sc.serial_no=pr.serial_no





-- Are shipped container quantities, remember to group by serial no, equal to part container quantities
select
count(*),
sum(sales_shipper_container_quantity) #sales_shipper_container_quantity,
sum(pc.quantity) #part_container_quantity
--top 500
--sc.sales_shipper_container_quantity,
--pc.quantity part_container_quantity
from
(
  select 
  --top 500
  serial_no,
  sum(sc.quantity) sales_shipper_container_quantity
  from sales_v_shipper_container sc  --80558
  group by sc.serial_no  -- part_containers may be satisfying multiple sales release items.
)sc
inner join part_v_container pc
on sc.serial_no=pc.serial_no
--where sc.sales_shipper_container_quantity<>pc.quantity  -- 0
--where sc.sales_shipper_container_quantity=pc.quantity  -- 80077

-- Are part container quantities set to 0 after they are shipped? 
select 
count(*)
--top(100)
--pc.location
--pc.quantity
from sales_v_shipper_container sc  --80558
inner join part_v_container pc
on sc.serial_no=pc.serial_no  --80558
where pc.quantity = 0  -- 0

-- What are the container locations of shipped containers? 
select 
count(*)
--top(100)
--pc.location
from sales_v_shipper_container sc  --80558
inner join part_v_container pc
on sc.serial_no=pc.serial_no  --80558
where location not like '%Finis%' -- 3 records, {Raw 21, Raw 6-1, CNC 67}

--Are container serial numbers ever duplicated yes.
select count(*) from sales_v_shipper_container sc  --80558
select count(*) 
from 
(
select distinct serial_no from sales_v_shipper_container sc  --79954
)s1

select serial_no,count(*) 
from sales_v_shipper_container sc 
group by serial_no
having count(*) > 1  --583

select *
from sales_v_shipper_container sc 
where serial_no = 'BM006386'  --2 with quantity adding up to 36
-- One line for each sales release key

select *
from part_v_container sc 
where serial_no = 'BM006386'  --0  -- there is just 1 with quantity of 36

select *
from part_v_shipper_container sc 
where serial_no = 'BM006386'  --0


-- Which production records should I keep?
1. If it's container status is shipped.
2. If it's location is Finish

select 
--top 10 
--p.serial_no
--p.quantity prod_quantity,
--pc.quantity container_qty,
--pc.location,
--pc.container_status
count(*)
from part_v_production p
inner join sales_v_shipper_container sc
on p.serial_no=sc.serial_no  --314726
--where pc.location like '%Finish%'  --337491


select 
--top 10 
--p.serial_no
--p.quantity prod_quantity,
--pc.quantity container_qty,
--pc.location,
--pc.container_status
--count(*)
from part_v_production p
inner join part_v_container pc
on p.serial_no=pc.serial_no  --807561
where pc.location like '%Finish%'  --337491

--where pc.quantity = 0 --479627
--BM006650  -- This container has production records
--where p.serial_no in ('BM514601') 
select * from part_v_Container_Transaction  --18
select 
ct.*
from part_v_container pc
inner join part_v_Container_Trace ct
on pc.serial_no=ct.serial_no
where pc.serial_no = 'BM514601'

select 
ct.*
from part_v_container pc
inner join part_v_Container_Trace ct
on pc.serial_no=ct.serial_no
where pc.serial_no = 'BM514647'

select 
ct.*
from part_v_container pc
inner join part_v_Container_Trace ct
on pc.serial_no=ct.serial_no
where pc.serial_no = 'BM514730'

select 
-- top 10 
--pc.serial_no,
--sc.quantity ship_quantity,
--pc.quantity container_qty,
--pc.location,
--pc.container_status
count(*)
from sales_v_shipper_container sc
inner join part_v_container pc
on sc.serial_no=pc.serial_no
where sc.quantity=pc.quantity --79338 
--where sc.quantity<>pc.quantity  --1187  -- Could some of these been returned to busche?
--where p.serial_no in ('BM514601') 

-- Production records record 38 parts being put into this container 
select top 10 
p.serial_no,
p.quantity prod_quantity,
pc.quantity container_qty,
pc.location,
pc.container_status
from part_v_production p
inner join part_v_container pc
on p.serial_no=pc.serial_no
where p.serial_no in ('BM514601') 


-- 2 parts were merged into BM514647 from BM514601
select * from
part_v_container pc
where pc.serial_no in ('BM514647') 

-- There are no production records for BM514647.
select top 10 p.* 
from part_v_production p
inner join part_v_container pc
on p.serial_no=pc.serial_no
where p.serial_no in ('BM514647') 


-- there is no shipping containers for BM514647.
select * from part_v_shipper_container  -- these come back from subcontractor?
where serial_no = 'BM514647'
select * from sales_v_shipper_container  --these don't come back.
where serial_no = 'BM514647'


-- BM514601 location was changed to EPC location. 
-- The remaining 36 parts from BM514601 were merged into container BM514730
-- This container has a production record of 36 parts.  It has a location of Finished 5-1 and a container_status of OK.
select top 10 
p.serial_no,
p.quantity prod_quantity,
pc.quantity container_qty,
pc.location,
pc.container_status
from part_v_production p
inner join part_v_container pc
on p.serial_no=pc.serial_no
where p.serial_no in ('BM514730') 
--and pc.location like 'Fini%'

-- there is no shipping containers for BM514730.
select * from part_v_shipper_container
where serial_no = 'BM514730'


--The Story
--Looks like 2 parts were merged to BM514647, this container's location  is the same CNC as BM514601.  
-- Laramie then set it's quantity to 0 and made it inactive. BM514601 was then moved to an EPC location.  
-- All 36 remaining parts where merged into BM514730 and it was made inactive. 
-- BM514730 was then moved to finished 5-1.

-- Find a shipper_container and check it's part_container quantity has not been set to 0.
select
--top 100
--count(*)
sc.serial_no,
pc.serial_no,
sc.Original_Quantity,
sc.Shipped_Quantity,
sc.Return_Quantity,
pc.quantity container_quantity
from part_v_shipper_container sc  --3483
inner join part_v_container pc
on sc.serial_no=pc.serial_no  --3483
where pc.quantity = sc.Original_Quantity  --76
and pc.active = 1  --52
--where pc.quantity = 0  -- 3399
--and pc.add_date > '02-01-2020 00:00:00'
--where pc.quantity <> 0  -- 84
--and pc.active = 1  -- 58
--and pc.active = 0  -- 26

select
--top 100
--count(*)
sc.loaded_date
--sc.serial_no,
--pc.serial_no,
--sc.Original_Quantity,
--sc.Shipped_Quantity,
--sc.Return_Quantity,
--pc.quantity container_quantity
from sales_v_shipper_container sc  --80484
--order by Loaded_Date  --Earliest is 2/21/19
inner join part_v_container pc
on sc.serial_no=pc.serial_no  --80484
where pc.quantity = sc.Quantity  --79297
and pc.active = 1  --52


select * from part_v_shipper_container
where serial_no = 'BM098730'  -- 


select count(*) from part_v_container  --547809
select count(*) from part_v_shipper_container  --3483

select count(*) from sales_v_shipper  --10620
select count(*) from sales_v_shipper_line   --16627
select count(*) from sales_v_shipper_container  --80484
select top 100 * from sales_v_shipper order by Add_Date  --Earliest 2/21/19
-- and pc.location like 'Fini%'
select add_date from part_v_container order by add_date  --Earliest 5/28/2018, but there are only 5 before 2/21/19

*/