DECLARE	@return_value int,
@start_date DATETIME,
@end_date DATETIME,
@table_name varchar(12),
@record_count int;
--2004-05-23T14:25:10
--YYYYMMDD or YYYY-MM-DD
--YYYY-MM-DDThh:mm:ss.nnn
set @start_date ='2020-03-01T00:00:00';
--select @start_date
set @end_date ='2020-03-14T23:59:59';
--HH:MM:SS.SSS
set @table_name = 'TempTable';
EXEC	@return_value = [dbo].[Sproc200221] @start_date,@end_date,@table_name,@record_count OUTPUT
select @record_count; 
select * from TempTable;

GO
select * from rpt04010 order by primary_key
--drop table rpt04010
select top(10) * from rpt04010 order by id

--drop PROCEDURE  sproc200221
CREATE PROCEDURE Sproc200221
	@start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT OUTPUT
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
IF OBJECT_ID(@table_name) IS NOT NULL
	EXEC ('DROP Table ' + @table_name)

/* TESTING ONLY
DECLARE @start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT
set @start_date ='2020-03-29T00:00:00';
set @end_date ='2020-04-18T23:59:59';
--drop table rpt0221test
set @table_name = 'rpt0221test'
*/-- END TESTING ONLY
	
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

set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

/* may be necessary if multiple calls are done on the same connection
declare @sqlDropPK nvarchar(4000)
declare @PKTable nvarchar(50)
set @PKTable = quotename(@table_name + 'PK')
--select @PKTable
set @sqlDropPK = N'DROP Table ' + @PKTable 
--select @sqlDropPK
IF OBJECT_ID(@PKTable) IS NOT NULL
EXEC sp_executesql @sqlDropPK
*/
--drop table #primary_key
IF OBJECT_ID('tempdb.dbo.#primary_key', 'U') IS NOT NULL
	EXEC ('DROP Table #primary_key')

create table #primary_key
(
  primary_key int,
  part_number varchar(60)
)
insert into #primary_key(primary_key,part_number)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY part_number
  ) primary_key,
  part_number
  from 
  (
    select
    part_number
    from HourlyOEEValues 
    where date_time_stamp between @start_of_week_for_start_date and @end_of_week_for_end_date
  )s1 
  group by part_number
)  

--drop table #primary_key
--select count(*) #primary_key from #primary_key  --16
--select top(100) * from #primary_key
--FORMAT ( @d, 'd', 'en-US' ) 
IF OBJECT_ID('tempdb.dbo.#set2group', 'U') IS NOT NULL
	EXEC ('DROP Table #set2group')
	
create table #set2group
(
	primary_key int,
	Hourly_planned_production_count int,
	Hourly_actual_production_count int,
	scrap_count int,
	Downtime_minutes float
)

insert into #set2group (primary_key,Hourly_planned_production_count,Hourly_actual_production_count,scrap_count,Downtime_minutes)
(
select
pk.primary_key, 
hv.Hourly_planned_production_count,
hv.Hourly_actual_production_count,
hv.scrap_count,
hv.Downtime_minutes
from #primary_key pk
inner join
(
  select
    part_number,
    workcenter_code,
	Hourly_planned_production_count,
	Hourly_actual_production_count,
	scrap_count,
	Downtime_minutes
  from HourlyOEEValues 
  where date_time_stamp between @start_of_week_for_start_date and @end_of_week_for_end_date
) hv
on pk.part_number=hv.Part_number 
)
--select top(100) * from #set2group 
--select count(*) #set2group from #set2group  --1404
--drop table #primary_key
--drop table #set2group
--drop table #results
IF OBJECT_ID('tempdb.dbo.#results', 'U') IS NOT NULL
	EXEC ('DROP Table #results')
	
create table #results
(
  primary_key int,
  part_number varchar(60),
  actual_vrs_planned_percent decimal(18,2),
  scrap_count int,
  scrap_percent int,
  downtime_minutes int
)



insert into #results (primary_key,part_number,actual_vrs_planned_percent,scrap_count,scrap_percent,downtime_minutes)
(
select
pk.primary_key,
pk.part_number,
case
when planned_production_count = 0 then cast(0.00 as decimal(18,2))
else cast (actual_production_count*100./planned_production_count as decimal(18,2))
end actual_vrs_planned_percent, 
scrap_count,
case
when actual_production_count = 0 then cast(0.00 as decimal(18,2))
else cast (scrap_count*100./actual_production_count as decimal(18,2))
end scrap_percent, 
downtime_minutes 
from
(
select
primary_key,
sum(Hourly_planned_production_count) planned_production_count,
sum(Hourly_actual_production_count) actual_production_count,
sum(scrap_count) scrap_count,
floor(sum(Downtime_minutes)) Downtime_minutes 
from #set2group 
group by primary_key
) sg
inner join #primary_key pk
on sg.primary_key = pk.primary_key
)
--select * from #results 
--DECLARE @table_name varchar(12),
--	@record_count INT
--set @table_name = 'rpt0213test'
--*/ -- END TESTING ONLY
--drop table rpt0213test
declare @sql nvarchar(4000)
select @sql = N'SELECT * into ' + quotename(@table_name) + N' from #results order by primary_key'

--select @sql = N'SELECT start_week,end_week,part_number,workcenter_code,planned_production_count,actual_production_count,actual_vrs_planned_percent,scrap_count,downtime_minutes into ' + quotename(@table_name) + N' from #results order by primary_key'

EXEC sp_executesql @sql
    
SELECT @record_count = @@ROWCOUNT;
--select @record_count
END; 
select * from rpt0401test

