/*
Used for testing since most SPROCS which need this have code inserted already.
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
Declare @week_diff int  --WORKS ON WHOLE WEEKS ONLY.

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)
set @end_year = DATEPART(YEAR,@End_Date)
set @end_week = DATEPART(WEEK,@End_Date)


set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
set @end_of_week_for_end_date = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week

--BUG FIX ADDED 23 HOURS AND 59 MINS TO END DATE
set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

set @week_diff = DATEDIFF(wk, @start_of_week_for_start_date, @end_of_week_for_end_date)


--/* testing 0
select @start_of_week_for_start_date, @end_of_week_for_end_date, @week_diff
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
--This must be hard coded since plex sde does not allow dynamic queries
-- These are the top 20 revenu parts
--	top 20 part revenue from 20200101 to 20200303
	part_no	part_key	revenue
1	H2GC 5K652 AB	2684943	1770503.43
2	H2GC 5K651 AB	2684942	1766723.02
3	10103353_Rev_A	2794731	1134512.64
4	10103355_Rev_A	2794706	1133359.68
5	AA96128_Rev_B	2793953	760716.65
6	727110F	2807625	470113.32
7	10103357_Rev_A	2794748	343601.28
8	10103358_Rev_A	2794752	334984.32
9	A52092_Rev_T	2794182	277641.60
10	10103353CX_Rev_A	2820236	264720.00
11	68400221AA_Rev_08	2811382	259226.38
12	18190-RNO-A012-S10_Rev_02	2800943	256015.20
13	10103355CX_Rev_A	2820251	240986.88
14	R558149_Rev_E	2793937	214091.68
15	A92817_Rev_B	2794044	202662.00
16	R559324RX1_Rev_A	2795919	191594.72
17	10046553_Rev_N	2795866	167388.48
18	26088054_Rev_07B	2803944	158389.50
19	2017707_Rev_J	2795740	149811.84
20	2017710_Rev_J	2795739	148435.20

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
select 2684943 as part_key  --1
union
select 2684942	as part_key  --2
union
select 2794731	as part_key  --3
union
select 2794706	as part_key  --4
union
select 2793953	as part_key  --5
union
select 2807625	as part_key  --6
union
select 2794748	as part_key  --7
union
select 2794752	as part_key  --8
union
select 2794182	as part_key  --9
union
select 2820236	as part_key  --10
union
select 2811382	as part_key  --11
union
select 2800943	as part_key  --12
union
select 2820251	as part_key  --13
union
select 2793937	as part_key  --14
union
select 2794044	as part_key  --15
union
select 2795919	as part_key  --16
union
select 2795866	as part_key  --17
union
select 2803944	as part_key  --18
union
select 2795740	as part_key  --19
union
select 2795739	as part_key  --20
)
--select * from #filter

create table #year_week
(
  year_week int
)
--When does the sum of high revenue parts roughly equal 'other' parts?
--best match revenue @separator = 7 , top 7 aprox = sum of all other parts.
--When does the sum of volume of these high revenue parts roughly equal 'other' parts?
--best match volume @separator = 20
insert into #year_week (year_week)
(
select 202001 as year_week
union
select 202002 as year_week
)





select part_key,year_week
from #year_week
cross join #filter


/*
SELECT foods.item_name,foods.item_unit,
company.company_name,company.company_city 
FROM foods 
CROSS JOIN company;
*/


/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  primary_key int  --part_key
)


insert into #primary_key(primary_key)
(
  select 
  --top 10
  part_key as primary_key
  from 
  (
    select
    pl.part_key
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
    and ss.shipper_status='Shipped' and pl.part_key in (select * from #filter)
  )s1 
  group by part_key
)  

--select count(*) #primary_key from #primary_key  --169
--select top(1) * from #primary_key


--Use this set to calculate volume shipped and revenue.
--Although shipped is calculated from sales_release.quantity_shipped column
-- The revenue can only be calculated from the shipper_line since it has
-- the price that we charged customer.
-- select * from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??
create table #set2group
(
  primary_key int,
  quantity decimal (18,3),  
  price decimal (18,6)
)

insert into #set2group (primary_key,quantity,price)
(
  select
  pl.part_key as primary_key,
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
  and ss.shipper_status='Shipped' 

)

--select count(*) #set2groupC from #set2groupC  --324
--select top(100) * from #set2groupC
create table #volume_revenue
(
  primary_key int,
  volume  decimal (18,3),   
  revenue decimal (18,6),
  volume_revenue_rank int
  
)



insert into #volume_revenue (primary_key,volume,revenue,volume_revenue_rank)
(

  select 
  --sc.*
  vr.primary_key,
  vr.volume,
  vr.revenue,
  vr.volume_revenue_rank
  from
  (
    select 
    gr.primary_key,
    sum(gr.quantity) volume,
    sum(gr.price*gr.quantity) revenue,
    ROW_NUMBER() OVER (
        ORDER BY sum(gr.price*gr.quantity) desc
    ) volume_revenue_rank
    from #set2group gr
    group by gr.primary_key
  )vr
  --where vr.volume_revenue_rank < 15

)

--select count(*) #volume_revenue from #volume_revenue  --83
--select top(100) * from #volume_revenue




/*
Final set: Join of all intermediate sets.
*/

create table #sales_release_weekly_volume_revenue_rank
(
  primary_key int,
  part_key int,
  part_no varchar (113),
  volume  decimal,   
  revenue decimal (18,2),
  revenue_week_avg decimal (18,2),
  volume_revenue_rank int
)


insert into #sales_release_weekly_volume_revenue_rank (primary_key,part_key,part_no,volume,revenue,revenue_week_avg, volume_revenue_rank)
(
  select
  primary_key,
  part_key,
  part_no,
  volume,
  revenue,
  revenue_week_avg,
  volume_revenue_rank
  from
  (
    select 
    vr.primary_key,
    p.part_key,
    case 
    when p.revision = '' then p.part_no
    else p.part_no + '_Rev_' + p.revision 
    end part_no,  --The report says 10025543 RevD I can't find the Rev word
    volume,  -- NOT VALIDATED
    revenue,
    (revenue / @week_diff) revenue_week_avg,
    volume_revenue_rank
    from #volume_revenue vr
    inner join part_v_part p -- 1 to 1
    on vr.primary_key=p.part_key 
  )s1
  
)
--select * from #sales_release_weekly_volume_revenue_rank
select part_no,part_key,revenue, revenue_week_avg
--,volume,revenue,volume_revenue_rank 
from #sales_release_weekly_volume_revenue_rank
where volume_revenue_rank < 21
order by volume_revenue_rank

/*

declare @separator int
                    --          high volume  low volume
set @separator = 20 -- volume,	< 256584 >
--best match revenue @separator = 7
--best match volume @separator = 20

select 
--*
high_volume-low_volume as volume_diff
from
(
  select 
  (
  select 
  sum(volume) 
  from #sales_release_weekly_volume_revenue_rank
  where volume_revenue_rank <= @separator
  ) high_volume,
  (
  select 
  sum(volume) 
  from #sales_release_weekly_volume_revenue_rank
  where volume_revenue_rank > @separator
  ) low_volume
)s1



select 
high_revenue-low_revenue as revenue_diff
from
(
  select
  (
  select
  sum(revenue) 
  from #sales_release_weekly_volume_revenue_rank
  where volume_revenue_rank <= @separator
  ) high_revenue,
  (
  select 
  sum(revenue) 
  from #sales_release_weekly_volume_revenue_rank
  where volume_revenue_rank > @separator
  ) low_revenue
)s2
--order by volume_revenue_rank
*/
--select count(*) #sales_release_weekly from #sales_release_weekly
--select top(100) * from #sales_release_weekly 
--where qty_loaded > 0

--select * from  #volume_revenue_info

--order by primary_key


--insert into #sales_release_weekly (primary_key,customer_code,part_no,year_week,year_week_fmt,start_week,end_week,rel_qty,shipped,short)
--exec sproc300758_11728751_1681704 @Start_Date,@End_Date
--sales_release_diff_v2