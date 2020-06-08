
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
create table t1 (
startDate datetime
)

insert into t1 (startDate)
values('2020-06-08T12:06:26.938')

select * from t1
--  TRUNCATE TABLE debugger; -- table debugger is full error?
-- select * from debugger d2


-- set @startDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @startDate = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
 set @startDate = STR_TO_DATE('03/01/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('03/29/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
-- set @startDate = STR_TO_DATE('05/31/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week with no records test
-- set @startDate ='Sun May 31 2020 00:00:00 GMT-0400 (Eastern Daylight Time)';
-- set @endDate = 'Sat Jun 06 2020 23:59:59 GMT-0400 (Eastern Daylight Time)';
-- set @endDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @endDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
-- set @endDate = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('03/14/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
set @endDate = STR_TO_DATE('04/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @endDate = STR_TO_DATE('06/06/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week with no records test
set @tableName = 'TempTable';
set @DEBUG = true;
-- TRUNCATE TABLE debugger; -- table debugger is full error?

CALL Kors.Sproc200206(@startDate, @endDate, @tableName,@rec);
-- SELECT * from debugger;
SELECT @rec;
select * from TempTable;
select * from debugger d2

SELECT * FROM TempTable order by primary_key LIMIT 20 OFFSET 1
drop table TempTable;

-- drop table rpt05260;
select * from rpt06047;
select Data_hour AS solution from HourlyOEEValues

DROP PROCEDURE Sproc200206;
CREATE PROCEDURE Sproc200206
(
	pStartDate DATETIME,
	pEndDate DATETIME,
	pTableName varchar(12),
	OUT pRecordCount INT 
)
BEGIN
	DECLARE startDate,endDate,startWeekStartDate,endWeekEndDate DATETIME;
	DECLARE tableName varchar(12);
	DECLARE startWeek,endWeek INT;

	SET tableName = pTableName;
	set startDate =pStartDate;
	set endDate =pEndDate;
	SET tableName = pTableName;  
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
	SET @sqlQuery = CONCAT('DROP TABLE IF EXISTS ',tableName);
   	PREPARE stmt FROM @sqlQuery;
	execute stmt;
    DEALLOCATE PREPARE stmt;
 
   	set startWeek = STD_WEEK(startDate);
	set endWeek = STD_WEEK(endDate);

	set startWeekStartDate = FIRST_DAY_OF_WEEK(startDate);
	set endWeekEndDate = LAST_DAY_OF_WEEK(endDate);
    IF @DEBUG then
      	INSERT INTO debugger VALUES (CONCAT('[Sproc200206:startDate=',startDate,',endDate=',endDate,',startWeek=',startWeek,',endWeek=',endWeek,',startWeekStartDate=',startWeekStartDate,',endWeekEndDate=',endWeekEndDate,']'));
	End If;

	DROP TABLE IF EXISTS primary_key;
	create temporary table primary_key
	(
	  primary_key int,
	  year_week int,
  	  year_week_fmt varchar(10),
      start_week datetime,
	  end_week datetime,
	  part_number varchar(60),
	  workcenter_code varchar(50)
	);

	insert into primary_key(primary_key,year_week,year_week_fmt,start_week,end_week,part_number,workcenter_code)
	(
	  select 
	  ROW_NUMBER() OVER (
	    ORDER BY year * 100 + week,part_number,workcenter_code
	  ) primary_key,
	  year * 100 + week year_week,
	  CASE 
	  when week < 10 then CONCAT(year,'-0',week)
	  else CONCAT(year,'-',week) 
	  end year_week_fmt,
	  start_week,
	  end_week,
	  part_number,
	  workcenter_code
	  from 
	  (
	    select
	    YEAR(date_time_stamp) year,
	    STD_WEEK(date_time_stamp) week,
		FIRST_DAY_OF_WEEK(date_time_stamp) start_week,
	  	LAST_DAY_OF_WEEK(date_time_stamp) end_week,
	    part_number,
	    workcenter_code
	    from HourlyOEEValues 
	    where date_time_stamp between startWeekStartDate and endWeekEndDate
	  )s1 
	  group by year,week,start_week,end_week,part_number,workcenter_code
	);  
	-- select * from primary_key;
	DROP TABLE IF EXISTS set2group;
	create temporary table set2group
	(
		primary_key int,
		Hourly_planned_production_count int,
		Hourly_actual_production_count int,
		scrap_count int,
		Downtime_minutes float
	);

	insert into set2group (primary_key,Hourly_planned_production_count,Hourly_actual_production_count,scrap_count,Downtime_minutes)
	(
	select
	pk.primary_key, 
	hv.Hourly_planned_production_count,
	hv.Hourly_actual_production_count,
	hv.scrap_count,
	hv.Downtime_minutes
	from primary_key pk
	inner join
	(
	  select
	    YEAR(date_time_stamp) * 100 + STD_WEEK(date_time_stamp) year_week,
	    part_number,
	    workcenter_code,
		Hourly_planned_production_count,
		Hourly_actual_production_count,
		scrap_count,
		Downtime_minutes
	  from HourlyOEEValues 
	  where date_time_stamp between startWeekStartDate and endWeekEndDate
	) hv
	on pk.year_week=hv.year_week
	and pk.part_number=hv.Part_number 
	and pk.workcenter_code=hv.Workcenter_Code 
	);
	-- select * from set2group limit 100;

	DROP TABLE IF EXISTS results;
	create temporary table results
	(
	  primary_key int,
  	  year_week_fmt varchar(10),
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
	);
	insert into results (primary_key,year_week_fmt,start_week,end_week,part_number,workcenter_code,planned_production_count,actual_production_count,actual_vrs_planned_percent,scrap_count,scrap_percent,downtime_minutes)
	(
		select
		primary_key,
		year_week_fmt,
		start_week,
		end_week,
		part_number,
		workcenter_code,
		format(planned_production_count, 0) as planned_production_count,  
		format(actual_production_count, 0) as actual_production_count,
		-- CONVERT(varchar(10),actual_vrs_planned_percent) + '%' as actual_vrs_planned_percent,  
		concat(format(actual_vrs_planned_percent,2),'%') as actual_vrs_planned_percent, 
		format(scrap_count,0) as scrap_count,
		concat(format(scrap_percent,2),'%') as scrap_percent, 
		concat(format(downtime_minutes, 0),' mins') as downtime_minutes
		from
		(
			select
			pk.primary_key,
			pk.year_week_fmt,
			DATE_FORMAT(start_week,'%m/%d/%Y') start_week,
			DATE_FORMAT(end_week,'%m/%d/%Y') end_week,
			pk.part_number,
			pk.workcenter_code,
			planned_production_count,
			actual_production_count,
			case
			when planned_production_count = 0 then cast(0.00 as decimal(18,2))
			else cast(actual_production_count*100/planned_production_count as decimal(18,2))
			end actual_vrs_planned_percent, 
			scrap_count,
			case
			when actual_production_count = 0 then cast(0.00 as decimal(18,2))
			else cast(scrap_count*100/actual_production_count as decimal(18,2))
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
				from set2group 
				group by primary_key
			) sg
			inner join primary_key as pk
			on sg.primary_key = pk.primary_key
		) s2
	);	
	set @sqlQuery = CONCAT('create table ',tableName,' select * from results order by primary_key');
	PREPARE stmt FROM @sqlQuery;
	execute stmt;
    DEALLOCATE PREPARE stmt;

   	-- SELECT ROW_COUNT(); -- 0
   	set pRecordCount = FOUND_ROWS();
end;	

	declare @sql nvarchar(4000)
	select @sql = N'SELECT * into ' + quotename(@table_name) + N' from #results order by primary_key'
	
	--select @sql = N'SELECT start_week,end_week,part_number,workcenter_code,planned_production_count,actual_production_count,actual_vrs_planned_percent,scrap_count,downtime_minutes into ' + quotename(@table_name) + N' from #results order by primary_key'
	
	EXEC sp_executesql @sql
	    
	SELECT @record_count = @@ROWCOUNT;
-- select * from HourlyOEEValues limit 100; 
distinct date_time_stamp
from HourlyOEEValues
	set startWeekStartDate = FIRST_DAY_OF_WEEK(startDate);
	set endWeekEndDate
	
/*	  
set @actual_production_count = 100;
set @planned_production_count = 110;
set @m = @actual_production_count*100/@planned_production_count;
select cast(@actual_production_count*100/@planned_production_count as decimal(18,2));
select cast(@m as decimal(18,2));
*/
-- select cast ((@actual_production_count*100/@planned_production_count) as decimal(18,2));

