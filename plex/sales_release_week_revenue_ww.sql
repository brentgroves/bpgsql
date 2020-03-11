Bulk insert sales_release_week_revenue_ww
from 'c:\sales_release_week_revenue_ww10.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select
--count(*)
top 1000 * 
from sales_release_week_revenue_ww --0
create PROCEDURE dbo.Sproc200311 
AS
begin
select * from sales_release_week_revenue_ww10 --0
end


/*
 * drop table sales_release_week_revenue_ww
 */
create table sales_release_week_revenue_ww
(
	part_no varchar(113),
	[W01-Shipped] decimal(18,2),
	[W02-Shipped] decimal(18,2),
	[W03-Shipped] decimal(18,2),
	[W04-Shipped] decimal(18,2),
	[W05-Shipped] decimal(18,2),
	[W06-Shipped] decimal(18,2),
	[W07-Shipped] decimal(18,2),
	[W08-Shipped] decimal(18,2),
	[W09-Shipped] decimal(18,2),
	[W10-Avg] decimal(18,2),
	[W10-Forecast] decimal(18,2),
	[W11-Avg] decimal(18,2),
	[W11-Forecast] decimal(18,2),
	[W12-Avg] decimal(18,2),
	[W12-Forecast] decimal(18,2),
	[W13-Avg] decimal(18,2),
	[W13-Forecast] decimal(18,2)
)
/*
 * drop table sales_release_week_revenue_ww10
 */

create table sales_release_week_revenue_ww10
(
	primary_key int IDENTITY(1,1), 
	part_no varchar(113),
	[W01-Shipped] decimal(18,2),
	[W02-Shipped] decimal(18,2),
	[W03-Shipped] decimal(18,2),
	[W04-Shipped] decimal(18,2),
	[W05-Shipped] decimal(18,2),
	[W06-Shipped] decimal(18,2),
	[W07-Shipped] decimal(18,2),
	[W08-Shipped] decimal(18,2),
	[W09-Shipped] decimal(18,2),
	[W10-Avg] decimal(18,2),
	[W10-Forecast] decimal(18,2),
	[W11-Avg] decimal(18,2),
	[W11-Forecast] decimal(18,2),
	[W12-Avg] decimal(18,2),
	[W12-Forecast] decimal(18,2),
	[W13-Avg] decimal(18,2),
	[W13-Forecast] decimal(18,2)
)
insert into sales_release_week_revenue_ww10(
	part_no,
	[W01-Shipped],
	[W02-Shipped],
	[W03-Shipped],
	[W04-Shipped],
	[W05-Shipped],
	[W06-Shipped],
	[W07-Shipped],
	[W08-Shipped],
	[W09-Shipped],
	[W10-Avg],
	[W10-Forecast],
	[W11-Avg],
	[W11-Forecast],
	[W12-Avg],
	[W12-Forecast],
	[W13-Avg],
	[W13-Forecast]
)
select 
	part_no,
	[W01-Shipped],
	[W02-Shipped],
	[W03-Shipped],
	[W04-Shipped],
	[W05-Shipped],
	[W06-Shipped],
	[W07-Shipped],
	[W08-Shipped],
	[W09-Shipped],
	[W10-Avg],
	[W10-Forecast],
	[W11-Avg],
	[W11-Forecast],
	[W12-Avg],
	[W12-Forecast],
	[W13-Avg],
	[W13-Forecast]
from sales_release_week_revenue_ww 

select * 
from sales_release_week_revenue_ww10 
ORDER BY primary_key OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY

*/