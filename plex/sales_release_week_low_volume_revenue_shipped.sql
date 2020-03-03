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

--sales_release_weekly_lower_volume_revenue

/* 
--This must be hard coded since plex sde does not allow dynamic queries
-- These are the top 20 revenu parts
--	top 20 part revenue from 20200101 to 20200303
	part_no,part_key,revenue
1	H2GC 5K652 AB	2684943	1662323.05
2	H2GC 5K651 AB	2684942	1658554.70
3	10103355_Rev_A	2794706	1093006.08
4	10103353_Rev_A	2794731	1082629.44
5	AA96128_Rev_B	2793953	711030.65
6	727110F	2807625	493896.52
7	10103357_Rev_A	2794748	328521.60
8	10103358_Rev_A	2794752	320981.76
9	A52092_Rev_T	2794182	258307.20
10	68400221AA_Rev_08	2811382	253344.42
11	10103353CX_Rev_A	2820236	230835.84
12	18190-RNO-A012-S10_Rev_02	2800943	227278.80
13	10103355CX_Rev_A	2820251	221961.60
14	R558149_Rev_E	2793937	212013.12
15	A92817_Rev_B	2794044	187650.00
16	R559324RX1_Rev_A	2795919	176837.92
17	26088054_Rev_07B	2803944	154415.10
18	10046553_Rev_N	2795866	148300.32
19	2017707_Rev_J	2795740	125648.64
20	10035421_Rev_A	2795852	124891.20
*/

create table #filter
(
  part_key int
)
--When does the sum of high revenue parts roughly equal 'other' parts?
--best match revenue @separator = 7 , top 7 aprox = sum of all other parts.
--When does the sum of volume of these high revenue parts roughly equal 'other' parts?
--best match volume @separator = 20
insert into #filter (part_key)
(
select 2684943 as part_key
union
select 2684942	as part_key
union
select 2794706	as part_key
union
select 2794731	as part_key
union
select 2793953	as part_key
union
select 2807625	as part_key
union
select 2794748	as part_key
union
select 2794752	as part_key
/*
union
select 2794182	as part_key
union
select 2811382	as part_key
union
select 2820236	as part_key
union
select 2800943	as part_key
union
select 2820251	as part_key
union
select 2793937	as part_key
union
select 2794044	as part_key
union
select 2795919	as part_key
union
select 2803944	as part_key
union
select 2795866	as part_key
union
select 2795740	as part_key
union
select 2794752	as part_key
union
select 2795852	as part_key
*/

)
--select * from #filter
/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int,
  year_week int,
  year_week_fmt varchar(20),
  start_week datetime,
  end_week datetime
)


insert into #primary_key(primary_key,year_week,year_week_fmt,start_week,end_week)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY year_week
  ) primary_key,
  year_week,
  year_week_fmt,
  start_week,
  end_week

    --FORMAT ( pk.start_week, 'd', 'en-US' ) start_week, 
		--FORMAT ( pk.end_week, 'd', 'en-US' ) end_week, 
--    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, year)) + (week-1), 6) start_week, 
--    DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, year)) + (week-1), 5) end_week, 

  from 
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    case     
    when DATEPART(WEEK,sr.ship_date) < 10 then CONVERT(varchar(4),DATEPART(YEAR,sr.ship_date)) + '-0' + CONVERT(varchar(2),DATEPART(WEEK,sr.ship_date)) + ' (Shipped)'
    else CONVERT(varchar(4),DATEPART(YEAR,sr.ship_date))  + '-' +  CONVERT(varchar(2),DATEPART(WEEK,sr.ship_date)) + ' (Shipped)'
    end year_week_fmt,
    DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 6) start_week, 
    DATEADD(second,-1,DATEADD(day, 1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,sr.ship_date))) + (DATEPART(WEEK,sr.ship_date)-1), 5))) end_week
    
--set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);    
    --as Num2   DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    from sales_v_release sr
    left outer join sales_v_po_line pl --1 to 1
    on sr.po_line_key=pl.po_line_key 
    left outer join sales_v_po po  -- 1 to 1
    on pl.po_key = po.po_key  
    where ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and pl.part_key not in (select * from #filter)
  )s1 
  group by year_week,year_week_fmt,start_week,end_week

)

--select * from #primary_key


create table #set2group
(
  primary_key int,
  quantity decimal (18,3),  
  price decimal (18,6)
)

insert into #set2group (primary_key,quantity,price)
(
  select 
  pk.primary_key,
  sl.quantity,
  sl.price
  from
  (
    select
    DATEPART(YEAR,sr.ship_date) * 100 + DATEPART(WEEK,sr.ship_date) year_week,
    sl.quantity,
    sl.price
    from sales_v_release sr  
    inner join sales_v_po_line pl 
    on sr.po_line_key=pl.po_line_key --1 to 1
    inner join sales_v_po po  
    on pl.po_key = po.po_key  --1 to 1
    inner join sales_v_shipper_line sl 
    on sr.release_key=sl.release_key --1 to many
    inner join sales_v_shipper sh 
    on sl.shipper_key=sh.shipper_key   --1 to 1
    inner join sales_v_shipper_status ss --1 to 1
    on sh.shipper_status_key=ss.shipper_status_key  --
    where sr.ship_date between @start_of_week_for_start_date and @end_of_week_for_end_date
    and ss.shipper_status='Shipped' and pl.part_key not in (select * from #filter)
  )sl
  inner join #primary_key pk
  on pk.year_week=sl.year_week

)

create table #volume_revenue
(
  primary_key int,
  volume  decimal (18,3),   
  revenue decimal (18,6)
  
)

--isert lower revenue parts.
insert into #volume_revenue (primary_key,volume,revenue)
(

  select 
  --sc.*
  pk.primary_key,
  sum(gr.quantity) volume,
  sum(gr.price*gr.quantity) revenue
  from #primary_key pk  
  inner join #set2group gr
  on pk.primary_key=gr.primary_key
  group by pk.primary_key

)



--select * from #volume_revenue



create table #sales_release_week_low_volume_revenue
(
  primary_key int,
  part_key int,
--  revenue_rank int,  Plex does not allow dynamic queries.
  year_week int,
  year_week_fmt varchar(20),
  start_week datetime,
  end_week datetime,
  part_no varchar (113),
  volume decimal,
  revenue decimal (18,2)
)

insert into #sales_release_week_low_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
(
  select
  primary_key,
  99999 as part_key,
  year_week,
  year_week_fmt,
  start_week,
  end_week,
  'Other' part_no,
  volume,
  revenue
  from
  (
    select 
    pk.primary_key,
    pk.year_week,
    pk.year_week_fmt,
    pk.start_week,
    pk.end_week,
    case
      when vr.volume is null then 0
      else vr.volume
    end volume,  -- NOT VALIDATED
    case
      when vr.revenue is null then 0
      else vr.revenue
    end revenue
    from #primary_key pk
    left outer join #volume_revenue vr
    on pk.primary_key=vr.primary_key
  )s1
  
)
select * from  #sales_release_week_low_volume_revenue

