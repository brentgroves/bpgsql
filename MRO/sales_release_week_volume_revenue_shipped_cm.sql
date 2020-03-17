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


create table bt_sales_release_week_tooling_cost_m2m
(
	PartNumber nvarchar(25),
	TotalQty int,
	TotalCost decimal(18,2)
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
from bt_sales_release_week_tooling_cost_m2m --0
