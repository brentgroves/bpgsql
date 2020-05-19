
/*
 * This has been my 'go-to' EXISTS procedure that checks both temp and normal tables. This procedure works in MySQL version 5.6 and above. 
 * The @DEBUG parameter is optional. The default schema is assumed, but can be concatenated to the table in the @s statement.
 */

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





-- set @startDate = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('03/01/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @startDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
set @startDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
-- set @endDate = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate =STR_TO_DATE('03/14/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @endDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @endDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
set @endDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
set @tableName = 'TempTable';
set @DEBUG = true;
TRUNCATE TABLE debugger; 
CALL Kors.Sproc200206(@startDate, @endDate, @tableName,@rec);
SELECT * from debugger;
SELECT @rec;


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
	-- set @startDate ='2020-02-15 00:00:00';
	-- set @endDate ='2020-02-09 23:59:59';	
	-- SET @tableName = 'TempTable';  -- Debug 
-- */
	SET @sql_query = CONCAT('DROP TABLE IF EXISTS ',@tableName);
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
	set @startWeekStartDate = FIRST_DAY_OF_WEEK(@startDate);
	set @endWeekEndDate = LAST_DAY_OF_WEEK(@endDate);
    IF @DEBUG then
      	INSERT INTO debugger VALUES (CONCAT('[Debug # ',@startYear,',',@startWeek,',',@endYear,',',@endWeek,',',@startWeekStartDate,',',@endWeekEndDate,']'));
	End If;
	set pRecordCount = 5;
end
-- START HERE
-- drop table #primary_key
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

