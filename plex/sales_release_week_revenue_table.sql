-- Reports: SalesReleaseDiff
-- release_status: Any 
-- release_type: Any. 
-- Quantity shipped: from sales_release.quantity_shipped field.
-- Revenue and Volume: shipper_status='Shipped'
-- Primary Key: year_week,year_week_fmt,start_week,end_week,customer_no,part_key 
-- Order: customer_code,part_no,year_week
Declare @Start_Date datetime
Declare @start_year char(4)
Declare @start_week int
Declare @end_year char(4)
Declare @end_week int
Declare @start_of_week_for_start_date datetime
Declare @end_of_week_for_end_date datetime
Declare @start_of_current_week datetime
Declare @end_of_previous_week datetime
Declare @current_year char(4)
Declare @current_week int


--set @end_year = DATEPART(YEAR,@End_Date)
--set @end_week = DATEPART(WEEK,@End_Date)
set @current_year = DATEPART(YEAR,getdate())
set @current_week = DATEPART(WEEK,getdate())

--No matter what day is the start of the year this date is in the first ISO week
set @Start_Date = '1/7/' + @current_year

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)

set @start_of_current_week = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @current_year) + (@current_week-1), 6)  --start of week
set @end_of_previous_week = DATEADD(second,-1,@start_of_current_week)

--select @start_of_current_week,@end_of_previous_week

set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
set @end_of_week_for_end_date =  DATEADD(wk, 14,@start_of_week_for_start_date)
set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week

--BUG FIX ADDED 23 HOURS AND 59 MINS TO END DATE
--set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
--set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

--/* testing 0
--select @start_of_week_for_start_date, @end_of_week_for_end_date
--*/ end testing 0 


--@Start_Date must be less at least 2 weeks for comparison to make sense

create table #sales_release_week_volume_revenue
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


--The ranking fluctuates so if you want to display the top 10 revenue producing parts on chart then pass a 20 to the sproc.
insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1681826 @start_of_week_for_start_date, @end_of_previous_week  --sales_release_week_high_volume_revenue_shipped

insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1686509 @start_of_week_for_start_date, @end_of_previous_week  --sales_release_week_low_volume_revenue_shipped

insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1687505 @start_of_current_week,@end_of_week_for_end_date  --sales_release_week_high_volume_revenue_releases

insert into #sales_release_week_volume_revenue (primary_key,part_key,year_week,year_week_fmt,start_week,end_week,part_no,volume,revenue)
exec sproc300758_11728751_1685871 @start_of_current_week,@end_of_week_for_end_date --sales_release_week_low_volume_revenue_releases
/*
select year_week_fmt,revenue  
from #sales_release_week_volume_revenue vr
where year_week_fmt = '2020-07 (Shipped)'
*/
--select * from  #sales_release_week_volume_revenue


create table #primary_key
(
  primary_key int,
  part_key int,
  part_no varchar (113)
)

insert into #primary_key (primary_key,part_key,part_no)
select 1,2684943, 'H2GC 5K652 AB'
union
select 2,2684942, 'H2GC 5K651 AB'
union
select 3,2794706, '10103355_Rev_A'
union
select 4,2794731, '10103353_Rev_A'
union
select 5,2793953, 'AA96128_Rev_B'
union
select 6,2807625, '727110F'
union
select 7,2794748, '10103357_Rev_A'
union
select 8,2794752, '10103358_Rev_A'
union
select 9,2794182, 'A52092_Rev_T'
union
select 10,2811382, '68400221AA_Rev_08'
union
select 11,2820236, '10103353CX_Rev_A'
union
select 12,2800943, '18190-RNO-A012-S10_Rev_02'
union
select 13,2820251, '10103355CX_Rev_A'
union
select 14,2793937, 'R558149_Rev_E'
union
select 15,2794044, 'A92817_Rev_B'
union
select 16,2795919, 'R559324RX1_Rev_A'
union
select 17,2803944, '26088054_Rev_07B'
union
select 18,2795866, '10046553_Rev_N'
union
select 19,2795740, '2017707_Rev_J'
union
select 20,2795852, '10035421_Rev_A'
union
select 21,99999, 'Other'


create table #year_week
(
  id INT PRIMARY KEY IDENTITY,
  year_week int
)

insert into #year_week (year_week)
select distinct year_week
from #sales_release_week_volume_revenue
order by year_week


--select * from #year_week
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
--select top(1) year_week,year_week_fmt
--from #sales_release_week_volume_revenue 
--where year_week_fmt like '%Ship%'

select pk.part_no,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 1
)week1,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 2
)week2,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 3
)week3,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 4
)week4,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 5
)week5,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 6
)week6,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 7
)week7,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 8
)week8,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 9
)week9,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 10
)week10,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 11
)week11,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 12
)week12,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 13
)week13,
(
select revenue  
from 
#sales_release_week_volume_revenue vr
inner join #year_week yw
on vr.year_week=yw.year_week
where part_no = pk.part_no
--and year_week_fmt = '2020-08 (Shipped)'
and yw.id = 14
)week14
from 
#primary_key pk


/*
select pk.year_week_fmt,
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = 'H2GC 5K652 AB'
and year_week_fmt = pk.year_week_fmt
) [H2GC_5K652_AB],
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = 'H2GC 5K651 AB'
and year_week_fmt = pk.year_week_fmt
) [H2GC_5K651_AB],
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = '10103355_Rev_A'
and year_week_fmt = pk.year_week_fmt
) [10103355_Rev_A],
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = '10103353_Rev_A'
and year_week_fmt = pk.year_week_fmt
) [10103353_Rev_A],
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = 'AA96128_Rev_B'
and year_week_fmt = pk.year_week_fmt
) [AA96128_Rev_B],
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = '727110F'
and year_week_fmt = pk.year_week_fmt
) [727110F],(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = '10103357_Rev_A'
and year_week_fmt = pk.year_week_fmt
) [10103357_Rev_A],(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = '10103358_Rev_A'
and year_week_fmt = pk.year_week_fmt
) [10103358_Rev_A],
(
select revenue  
from #sales_release_week_volume_revenue vr
where part_no = 'Other'
and year_week_fmt = pk.year_week_fmt
) [Other]
from #primary_key pk
*/