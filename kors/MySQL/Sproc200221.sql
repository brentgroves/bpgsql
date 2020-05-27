
-- set @startDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @startDate = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
set @startDate = STR_TO_DATE('03/01/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('03/29/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
-- set @endDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @endDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
-- set @endDate = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @endDate = STR_TO_DATE('02/15/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('03/01/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @startDate = STR_TO_DATE('03/14/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0
set @endDate = STR_TO_DATE('04/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
set @tableName = 'TempTable';
set @DEBUG = true;
TRUNCATE TABLE debugger; 
CALL Kors.Sproc200221(@startDate, @endDate, @tableName,@recordCount);
SELECT * from debugger;
SELECT @recordCount;
select * from rpt05270 order by primary_key;

--drop PROCEDURE  Sproc200221
CREATE PROCEDURE Sproc200221
(
	pStartDate DATETIME,
	pEndDate DATETIME,
	pTableName varchar(12),
	OUT pRecordCount INT 
)
BEGIN

	DECLARE startDate,endDate,startWeekStartDate,endWeekEndDate DATETIME;
	DECLARE tableName varchar(12);
	DECLARE startWeek,endWeek,debugCount INT;

	SET tableName = pTableName;
	set startDate =pStartDate;
	set endDate =pEndDate;
	SET tableName = pTableName;  
	SET @sqlQuery = CONCAT('DROP TABLE IF EXISTS ',tableName);
   	PREPARE stmt FROM @sqlQuery;
	execute stmt;
    DEALLOCATE PREPARE stmt;
 
   	set startWeek = STD_WEEK(startDate);
	set endWeek = STD_WEEK(endDate);

	set startWeekStartDate = FIRST_DAY_OF_WEEK(startDate);
	set endWeekEndDate = LAST_DAY_OF_WEEK(endDate);
    IF @DEBUG then
      	INSERT INTO debugger VALUES (CONCAT('[Sproc200221:startDate=',startDate,',endDate=',endDate,',startWeek=',startWeek,',endWeek=',endWeek,',startWeekStartDate=',startWeekStartDate,',endWeekEndDate=',endWeekEndDate,']'));
	End If;
	
	DROP TABLE IF EXISTS PrimaryKey;
	create temporary table PrimaryKey
	(
	  primary_key int,
	  part_number varchar(60)
	);
	
	insert into PrimaryKey(primary_key,part_number)
	(
	  select 
	  ROW_NUMBER() OVER (
	    ORDER BY part_number
	  ) primary_key,
	  part_number
	  from 
	  (
	    select
	    part_number
	    from HourlyOEEValues 
	    where date_time_stamp between startWeekStartDate and endWeekEndDate
	  )s1 
	  group by part_number
	);  

    IF @DEBUG then
    	select count(*) 
    	into debugCount
    	from PrimaryKey;  
    	-- set debugCount = ROW_COUNT();
      	INSERT INTO debugger VALUES (CONCAT('[Sproc200221:PrimaryKey.count()=',debugCount,']'));
	End If;

   	-- set pRecordCount = ROW_COUNT(); -- 0

	DROP TABLE IF EXISTS Set2Group;
	create table Set2Group
	(
		primary_key int,
		Hourly_planned_production_count int,
		Hourly_actual_production_count int,
		scrap_count int,
		Downtime_minutes float
	);

	insert into Set2Group(primary_key,Hourly_planned_production_count,Hourly_actual_production_count,scrap_count,Downtime_minutes)
	(
		select
		pk.primary_key, 
		hv.Hourly_planned_production_count,
		hv.Hourly_actual_production_count,
		hv.scrap_count,
		hv.Downtime_minutes
		from PrimaryKey pk
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
		  where date_time_stamp between startWeekStartDate and endWeekEndDate
		) hv
		on pk.part_number=hv.part_number 
	);

    IF @DEBUG then
    	select count(*) 
    	into debugCount
    	from Set2Group;  
    	-- set debugCount = ROW_COUNT();
      	INSERT INTO debugger VALUES (CONCAT('[Sproc200221:Set2Group.count()=',debugCount,']'));
	End If;

	DROP TABLE IF EXISTS Results;

	create table Results
	(
	  primary_key int,
	  part_number varchar(60),
	  actual_vrs_planned_percent decimal(18,2),
	  scrap_count int,
	  scrap_percent int,
	  downtime_minutes int
	);

	insert into Results (primary_key,part_number,actual_vrs_planned_percent,scrap_count,scrap_percent,downtime_minutes)
	(
		select
		pk.primary_key,
		pk.part_number,
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
			from Set2Group 
			group by primary_key
		) sg
		inner join PrimaryKey pk
		on sg.primary_key = pk.primary_key
	);


	IF @DEBUG then
    	select count(*) 
    	into debugCount
    	from Results;  
    	-- set debugCount = ROW_COUNT();
      	INSERT INTO debugger VALUES (CONCAT('[Sproc200221:Results.count()=',debugCount,']'));
	End If;

	set @sqlQuery = CONCAT('create table ',tableName,' select * from Results order by primary_key');
	PREPARE stmt FROM @sqlQuery;
	execute stmt;
    DEALLOCATE PREPARE stmt;

   	set pRecordCount = FOUND_ROWS();
end;	
	



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

