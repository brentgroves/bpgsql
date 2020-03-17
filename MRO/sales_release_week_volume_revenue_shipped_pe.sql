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
from 'c:\volume_revenue.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select
count(*)
--top 1000 * 
from PlxSupplyItemLocation0316 --0