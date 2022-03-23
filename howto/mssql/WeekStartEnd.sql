
Declare @Start_Date datetime 
set @Start_Date = '20200101'
--set @Start_Date = '20191231'
Declare @End_Date datetime 
set @End_Date = '20200101'
--set @End_Date = '20191231'

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
  part_key int
)

--ISO WEEK
    --FORMAT ( pk.start_week, 'd', 'en-US' ) start_week, 
		--FORMAT ( pk.end_week, 'd', 'en-US' ) end_week, 
--    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, year)) + (week-1), 6) start_week, 
--    DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, year)) + (week-1), 5) end_week, 
--https://savvytime.com/week-number/united-states/2020
--ISOWK - ALWAYS STARTS ON MONDAY. BY DESIGN -- https://stackoverflow.com/questions/36340144/sql-server-change-first-day-of-week-to-sunday-using-datepart-with-isowk-paramet

--I DON'T THINK WE SHOULD USE TSQL ISOWEEKS BECAUSE THEY ALWAYS START ON A MONDAY.
--TSQL WEEKS DON'T FOLLOW THE ISO STANDARD WEEKS, AND THEY DO SOMETIMES HAVE 53 WEEK YEARS WITH A SHORT NUMBER OF DAYS.
--*/

--The primary_key should contain all parts with sales release items even if they don't have any quantity shipped.
--If quantity shipped is 0 for a part it still should be included in the report.
insert into #primary_key(primary_key,year_week,year_week_fmt,week_fmt,start_week,end_week,part_key)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY year_week
  ) primary_key,
  year_week,
  year_week_fmt,
  week_fmt,
  start_week,
  end_week,
  part_key


  from 
  (
    select
    --BUG: THIS WAS SR.SHIP_DATE SHOULD BE SH.SHIP_DATE
--    DATEPART(YEAR,DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 6)) * 100 + 
--    DATEPART(WEEK,DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 6)) year_week,
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
    pl.part_key
--set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);    
    --as Num2   DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    from sales_v_release sr
    left outer join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    left outer join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    inner join sales_v_shipper_line sl 
    on sr.release_key=sl.release_key --1 to many
    inner join sales_v_shipper sh 
    on sl.shipper_key=sh.shipper_key   --1 to 1
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    --BUG: THIS WAS SR.SHIP_DATE SHOULD BE SH.SHIP_DATE
    where sh.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.shipper_status='Shipped'
    --where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    --and pl.part_key not in (select * from #filter)
  )s1 
  group by year_week,year_week_fmt,week_fmt,start_week,end_week,part_key  -- sales release to shipper_line is a 1 to many relationship so make sure these records are distinct

  --BUG: The primary key was based upon the sr.ship_date and the set to group was based on the sh.ship_date 
  --so some records could be dropped. Changed the primary key and set to group both to be based upon sh.ship_date
)
   
select * from #primary_key    
-- https://stackoverflow.com/questions/14133816/how-do-i-build-iso-week-number-table-programatically-in-t-sql-query
--https://www.epochconverter.com/weeks/2020
/*
Select date '2012-12-31' + level*7  WK_STARTS_DT
 , to_char(date '2012-12-31' + level*7, 'IW') ISO_WEEK
 , to_char(date '2012-12-31' + level*7, 'WW') WEEK
From dual
Connect By Level <= 
(
 Select Round( (ADD_MONTHS(TRUNC(SYSDATE,'Y'),12)-TRUNC(SYSDATE,'Y') )/7, 0) From dual
) --365/7 

*/

/*
declare @Year int;
set @Year = 2020;

with C as
(
  select datefromparts(@Year, 1, 1) as D
  union all
  select dateadd(day, 1, C.D)
  from C
  where C.D < datefromparts(@Year, 12, 31)
)
select datepart(iso_week, C.D) as ISOWeekNo,
       convert(varchar(101), min(C.D), 106)+' To '+convert(varchar(101), max(C.D), 106) as WeekName
from C
group by datepart(iso_week, C.D),
         case when datepart(month, C.D) = 12 and
                   datepart(iso_week, C.D) > 50
           then 1
           else 0 
         end
order by min(C.D)
option (maxrecursion 0);

*/