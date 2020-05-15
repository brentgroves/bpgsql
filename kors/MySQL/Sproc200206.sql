
/*
 * This has been my 'go-to' EXISTS procedure that checks both temp and normal tables. This procedure works in MySQL version 5.6 and above. 
 * The @DEBUG parameter is optional. The default schema is assumed, but can be concatenated to the table in the @s statement.
 */

drop procedure if exists prcDoesTableExist;
delimiter #
CREATE PROCEDURE prcDoesTableExist(IN pin_Table varchar(100), OUT pout_TableExists BOOL)
BEGIN
    DECLARE boolTableExists TINYINT(1) DEFAULT 1;
    DECLARE CONTINUE HANDLER FOR 1243, SQLSTATE VALUE '42S02' SET boolTableExists = 0;
        SET @s = concat('SELECT null FROM `', pin_Table, '` LIMIT 0 INTO @resultNm');
    PREPARE stmt1 FROM @s;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
    set pout_TableExists = boolTableExists; -- Set output variable
    IF @DEBUG then
        select IF(boolTableExists
            , CONCAT('TABLE `', pin_Table, '` exists: ', pout_TableExists)
            , CONCAT('TABLE `', pin_Table, '` does not exist: ', pout_TableExists)
        ) as result;
    END IF;
END 
set @DEBUG = true;
call prcDoesTableExist('tempTable', @tblExists);
select @tblExists as '@tblExists';


CREATE TABLE TempTable (
	ID int NOT NULL AUTO_INCREMENT,
	Workcenter_Code varchar(50),
	Job_number varchar(20),
	Part_number varchar(60),
	Data_hour int,
	Hourly_planned_production_count int,
	Hourly_actual_production_count int,
	Cumulative_planned_production_count int,
	Cumulative_actual_production_count int,
	scrap_count int,
	Downtime_minutes float,
	Date_time_stamp datetime,
  	CONSTRAINT HOV_pk PRIMARY KEY (ID)
)

DROP PROCEDURE Test;
CREATE PROCEDURE Test
(
	_start_date DATETIME,
	_end_date DATETIME,
	_table_name varchar(12),
	OUT _record_count INT 
)
BEGIN
    DECLARE credit DECIMAL DEFAULT 0;
	call prcDoesTableExist(_table_name, @tblExists);
	IF @tblExists = 1 THEN
	    -- SET @table_name = _table_name;
	    SET @sql_query = CONCAT('DROP TABLE ',_table_name);
	    PREPARE stmt1 FROM @sql_query;
	   	execute stmt1;
	END IF;
	set _record_count = 2;

END 

set @start_date = '2020-02-09T00:00:00';
set @end_date = '2020-02-15T00:00:00';
set @table_name = 'TempTable';

CALL Kors.Sproc200206(@start_date, @end_date, @table_name,@rec);
select @rec

DROP PROCEDURE Sproc200206;
CREATE PROCEDURE Sproc200206
(
	pStartDate DATETIME,
	pEndDate DATETIME,
	pTableName varchar(12),
	OUT pRecordCount INT 
)
BEGIN
	SET @table_name = pTableName;
	set @startDate =pStartDate;
	set @endDate =pEndDate;
	SET @tableName = pTableName;  
-- /* 
    -- https://www.w3resource.com/mysql/date-and-time-functions/mysql-week-function.php
    -- Week 1 is the first week with a sunday; range: 0 - 53
	-- 52 -- set @startDate ='2019-12-31 00:00:00';  
	-- 0 -- set @startDate ='2020-01-01 00:00:00';  
	-- 1 -- set @startDate ='2020-01-05 00:00:00';  
	set @startDate ='2020-02-09 00:00:00';
	set @endDate ='2020-02-15 23:59:59';	
	SET @tableName = 'TempTable';  -- Debug 
-- */
	SET @sql_query = CONCAT('DROP TABLE IF EXISTS ',@table_name);
   	PREPARE stmt1 FROM @sql_query;
	execute stmt1;
	
	set @startWeek = WEEK(@startDate);
	set @startYear = YEAR(@startDate);
	set @endYear = YEAR(@endDate);
	set @endWeek = WEEK(@endDate);
	-- THIS IS NEEDED TO MAKE SURE MSSQL WEEKS ARE THE SAME AS MYSQL DATES
	set @startYearJan1 = CONCAT(@startYear,'-01-01T00:00:00');
	set @startYearJan1DOW = DAYOFWEEK(@startYearJan1);
	set @endYearJan1 = CONCAT(@endYear,'-01-01T00:00:00');
	set @endYearJan1DOW = DAYOFWEEK(@endYearJan1);

	set @startWeek = if(@startYearJan1DOW = 1,@startWeek,@startWeek + 1); 
	set @endWeek = if(@endYearJan1DOW = 1,@endWeek,@endWeek + 1); 

	-- START HERE
	-- set @startWeekStartDate = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
	-- set @endWeekEndDate = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week
	
	-- set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
	-- set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

-- set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week

-- SELECT DATE_ADD("2017-06-15", INTERVAL 10 DAY);
select @startYear,@startWeek,@endYear,@endWeek;

/*		
	Declare _start_year char(4)
	Declare _start_week int
	Declare @end_year char(4)
	Declare @end_week int
	Declare @start_of_week_for_start_date datetime
	Declare @end_of_week_for_end_date datetime
*/
	set _record_count = 2;
END 
-- https://www.mysqltutorial.org/mysql-drop-table/
set @start_date = '2020-02-09T00:00:00';
set @end_date = '2020-02-15T00:00:00';
set @table_name = 'TempTable';

CALL Kors.Sproc200206(@start_date, @end_date, @table_name,@rec);
select @rec

/* TESTING ONLY
DECLARE _start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT
set @start_date ='2020-02-09T00:00:00';
set @end_date ='2020-02-15T23:59:59';
set @table_name = 'rpt0213test'
*/ -- END TESTING ONLY
	
CREATE PROCEDURE Sproc200206
	@start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT OUTPUT
AS
BEGIN

set @start_year = DATEPART(YEAR,@Start_Date)
set @start_week = DATEPART(WEEK,@Start_Date)
set @end_year = DATEPART(YEAR,@End_Date)
set @end_week = DATEPART(WEEK,@End_Date)


set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
set @end_of_week_for_end_date = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)  --end of week

set @end_of_week_for_end_date = DATEADD(day, 1, @end_of_week_for_end_date);
set @end_of_week_for_end_date = DATEADD(second,-1,@end_of_week_for_end_date);

/* may be necessary if multiple calls are done on the same connection
decdrop table #resultslare @sqlDropPK nvarchar(4000)
declare @PKTable nvarchar(50)
set @PKTable = quotename(@table_name + 'PK')
--select @PKTable
set @sqlDropPK = N'DROP Table ' + @PKTable 
--select @sqlDropPK
IF OBJECT_ID(@PKTable) IS NOT NULL
EXEC sp_executesql @sqlDropPK
*/
--drop table #primary_key
create table #primary_key
(
  primary_key int,
  year_week int,
  start_week datetime,
  end_week datetime,
  part_number varchar(60),
  workcenter_code varchar(50)
)
insert into #primary_key(primary_key,year_week,start_week,end_week,part_number,workcenter_code)
(
  select 
  --top 10
  ROW_NUMBER() OVER (
    ORDER BY year * 100 + week,part_number,workcenter_code
  ) primary_key,
  year * 100 + week year_week,
  DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + CONVERT(varchar, year)) + (week-1), 6) start_week, 
  DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, year)) + (week-1), 5) end_week, 
  part_number,
  workcenter_code
  from 
  (
    select
    DATEPART(YEAR,date_time_stamp) year,
    DATEPART(WEEK,date_time_stamp) week,
    part_number,
    workcenter_code
    from HourlyOEEValues 
    where date_time_stamp between @start_of_week_for_start_date and @end_of_week_for_end_date
  )s1 
  group by year,week,part_number,workcenter_code
)  

--drop table #set2group
--select count(*) #primary_key from #primary_key  --16
--select top(100) * from #primary_key
--FORMAT ( @d, 'd', 'en-US' ) 
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
  DATEPART(YEAR,date_time_stamp) * 100 + DATEPART(WEEK,date_time_stamp) year_week,
    part_number,
    workcenter_code,
	Hourly_planned_production_count,
	Hourly_actual_production_count,
	scrap_count,
	Downtime_minutes
  from HourlyOEEValues 
  where date_time_stamp between @start_of_week_for_start_date and @end_of_week_for_end_date
) hv
on pk.year_week=hv.year_week
and pk.part_number=hv.Part_number 
and pk.workcenter_code=hv.Workcenter_Code 
)
--select top(100) * from #set2group 
--select count(*) #set2group from #set2group  --1404
--drop table #primary_key
--drop table #set2group
--drop table #results
create table #results
(
  primary_key int,
  start_week varchar(12),
  end_week varchar(12),
  part_number varchar(60),
  workcenter_code varchar(50),
  planned_production_count nvarchar(10),
  actual_production_count nvarchar(10),
  actual_vrs_planned_percent varchar(10),
  scrap_count varchar(10),
  scrap_percent varchar(10),
  downtime_minutes varchar(10)
)

insert into #results (primary_key,start_week,end_week,part_number,workcenter_code,planned_production_count,actual_production_count,actual_vrs_planned_percent,scrap_count,scrap_percent,downtime_minutes)
(
		select
		primary_key,
		start_week,
		end_week,
		--FORMAT ( pk.start_week, 'd', 'en-US' ) start_week, 
		--FORMAT ( pk.end_week, 'd', 'en-US' ) end_week, 
		part_number,
		workcenter_code,
		format(planned_production_count, 'N0'),
		format(actual_production_count, 'N0'),
		CONVERT(varchar(10),actual_vrs_planned_percent) + '%' as actual_vrs_planned_percent,  
		format(scrap_count, 'N0'),
		CONVERT(varchar(10),scrap_percent) + '%' as scrap_percent,  
		format(downtime_minutes, 'N0') + ' mins'
		from
		(
			select
			pk.primary_key,
			CONVERT(VARCHAR, start_week ,101) start_week,
			CONVERT(VARCHAR, end_week ,101) end_week,
			--FORMAT ( pk.start_week, 'd', 'en-US' ) start_week, 
			--FORMAT ( pk.end_week, 'd', 'en-US' ) end_week, 
			pk.part_number,
			pk.workcenter_code,
			planned_production_count,
			actual_production_count,
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
		)s1
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
