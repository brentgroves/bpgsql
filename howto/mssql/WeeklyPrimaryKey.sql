

/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int,
  year_week int,
  year_week_fmt varchar(20),
  start_week datetime,
  end_week datetime,
  part_key int
)
-- Reports: SalesReleaseVolumeRevenue
-- release_status: Any 
-- release_type: Any. 
-- Quantity shipped: from sales_release.quantity_shipped field.
-- Revenue and Volume: shipper_status='Shipped'
-- Primary Key: year_week,year_week_fmt,start_week,end_week,customer_no,part_key 
-- Order: customer_code,part_no,year_week
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

--/* testing 0
--select @start_of_week_for_start_date, @end_of_week_for_end_date
--*/ end testing 0 


--@Start_Date must be less at least 2 weeks for comparison to make sense
IF @start_of_week_for_start_date > @end_of_week_for_end_date
BEGIN
  RETURN
END


/*
Use the ‘Forecast’ sales release to calculate current and future week revenue. 
You must filter for release type = ‘Forecast’ in this case since there are ‘ship_schedule’ 
sales release items that you do not want to include in this estimate.  The idea is that the 
future weeks sum of ‘Forecast’ sales release should be a good estimate of what the quantity_shipped sum will equal.    

Use ‘Ship_schedule’ sales release to calculate revenue for previous weeks revenue; Since all sales releases with 
a shipped_quantity are of type ‘ship_schedule’ you do not need to check the sales release type only sum the quantity_shipped. 
*/

insert into #primary_key(primary_key,year_week,year_week_fmt,start_week,end_week,part_key)
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
  part_key

    --FORMAT ( pk.start_week, 'd', 'en-US' ) start_week, 
		--FORMAT ( pk.end_week, 'd', 'en-US' ) end_week, 
--    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, year)) + (week-1), 6) start_week, 
--    DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, year)) + (week-1), 5) end_week, 

  from 
  (
    select
    --BUG: THIS WAS SR.SHIP_DATE SHOULD BE SH.SHIP_DATE
    --DATEPART(YEAR,DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 6)) * 100 + 
    --DATEPART(isowk,DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 6)) year_week,
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    case     
    when DATEPART(WEEK,sr.ship_date) < 10 then convert(varchar,DATEPART(YEAR,sr.ship_date)) +'-0' + convert(varchar,DATEPART(WEEK,sr.ship_date)) + ' (Release)'
    else 
    convert(varchar,DATEPART(YEAR,sr.ship_date)) +'-' + convert(varchar,DATEPART(WEEK,sr.ship_date)) + ' (Releases)'
    end year_week_fmt,

    case 
    when DATEPART(WEEK,sr.ship_date) = 1 then datefromparts(DATEPART(YEAR,sr.ship_date), 1, 1)
    else DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 6) 
    end start_week, 
    case                                                        
    when DATEPART(WEEK,sr.ship_date) > 51 and  (DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 5))=1)  then DATEADD(second,-1,convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,sr.ship_date), 12, 31))))
    else DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 5)))
    end end_week,
    pl.part_key
    from sales_v_release sr
    inner join sales_v_release_type rt
    on sr.release_type_key=rt.release_type_key  --1 to 1
    inner join sales_v_release_status rs
    on sr.release_status_key = rs.release_status_key  --1 to 1
    inner join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    inner join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and pl.part_key in (select * from #filter)
    and rt.release_type ='Forecast'
    and rs.release_status != 'Canceled'
  )s1 
  group by year_week,year_week_fmt,start_week,end_week,part_key

)