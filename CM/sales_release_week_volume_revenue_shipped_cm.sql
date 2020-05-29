--drop table bt_sales_release_week_volume_revenue
create table bt_sales_release_week_volume_revenue
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
  revenue decimal(18,2)
)

Bulk insert bt_sales_release_week_volume_revenue
from 'c:\Volume_Revenue.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select
--count(*)
top 1000 * 
from bt_sales_release_week_volume_revenue --0




/*
Final set: Join of all intermediate sets.
*/
--drop table bt_sales_release_week_tooling_cost_m2m
create table bt_sales_release_week_tooling_cost_m2m
(
  	primary_key int,
  	year_week int,
  	year_week_fmt varchar(20),
  	start_week datetime,
  	end_week datetime,
  	part_no varchar (25),
	total_cost decimal(18,2)
)
Bulk insert bt_sales_release_week_tooling_cost_m2m
from 'c:\ToolingCost.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select
--count(*)
top 1000 * 
from bt_sales_release_week_tooling_cost_m2m --213


select 
distinct year_week
from bt_sales_release_week_volume_revenue 
order by year_week desc 


select
--count(*)
--top 1000 * 
DISTINCT tran
from bt_sales_release_week_tooling_cost_m2m --0

select
--count(*)
vr.year_week,
vr.part_no,
tc.year_week,
tc.part_no, 
'USD' as Currency,
vr.year_week as Period,
vr.volume as [Actual Volume],
vr.revenue as [Actual Revenue (Local)],
vr.revenue as [Actual Revenue (USD)],
tc.total_cost [Actual Material Cost (Local)],
tc.total_cost [Actual Material Cost (USD)]
from bt_sales_release_week_volume_revenue vr 
full join bt_sales_release_week_tooling_cost_m2m tc 
on vr.part_no = tc.part_no 
and vr.year_week = tc.year_week
--where vr.part_no is null
--and tc.PartNumber !=''

select
--count(*)
distinct tc.part_no,tc.year_week 
from bt_sales_release_week_volume_revenue vr 
full join bt_sales_release_week_tooling_cost_m2m tc 
on vr.part_no = tc.part_no 
where vr.part_no is null
order by tc.part_no,tc.year_week asc

select 
tc.part_no tc_part_no,
vr.part_no vr_part_no
from 
(
	select
	--count(*)
	distinct tc.part_no
	from bt_sales_release_week_tooling_cost_m2m tc 
)tc 
full join 
(
	select
	--count(*)
	distinct vr.part_no
	from bt_sales_release_week_volume_revenue vr 
)vr 
on tc.part_no=vr.part_no 




order by tc.part_no

/*
select 
vr.part_no,
'USD' as Currency,
vr.year_week as Period,
vr.volume as [Actual Volume],
vr.revenue as [Actual Revenue (Local)],
vr.revenue as [Actual Revenue (USD)]
from #sales_release_week_volume_revenue vr
order by vr.revenue desc
*/

