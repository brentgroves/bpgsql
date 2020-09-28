-- Find the start and end of the week

set @pDate = '2021-01-01 00:00:00';


select STD_WEEK(@pDate),FIRST_DAY_OF_WEEK(@pDate),LAST_DAY_OF_WEEK(@pDate); 

CREATE DEFINER=`brent`@`%` PROCEDURE `Kors`.`Sproc200206`(
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
	) ENGINE = MEMORY;

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
	) ENGINE = MEMORY;

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
	  downtime_minutes varchar(20)
	) ENGINE = MEMORY;
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
