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
  part_key int,
  part_no varchar (113)    
)


insert into #primary_key(primary_key,year_week,year_week_fmt,start_week,end_week,part_key,part_no)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY year_week,part_key
  ) primary_key,
  year_week,
  year_week_fmt,
  start_week,
  end_week,
  part_key,
  part_no  
  from 
  (
    select
    DATEPART(YEAR,sh.ship_date) * 100 + DATEPART(WEEK,sh.ship_date) year_week,
    CONVERT(varchar(10),DATEPART(YEAR,sh.ship_date)) + '-' + CONVERT(varchar(10),DATEPART(WEEK,sh.ship_date)) year_week_fmt,
    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 6) start_week, 
    DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sh.ship_date))) + (DATEPART(WEEK,sh.ship_date)-1), 5))) end_week, 
    sl.part_key,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no  
    from sales_v_shipper sh 
    inner join sales_v_shipper_line sl 
    on sh.shipper_key=sl.shipper_key   --1 to many
    inner join part_v_part p
    on sl.part_key=p.part_key
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    where sh.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.shipper_status='Shipped' 
  )s1 
  group by year_week,year_week_fmt,start_week,end_week,part_key,part_no

)  

--select count(*) #primary_key from #primary_key  --169
select top(100) * from #primary_key

