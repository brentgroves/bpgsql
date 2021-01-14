/*
 * Make sure to disable debugging in production because this will overload MySql running in a docker container
 */
/*
 * Find first day of WEEK
 */
set @DEBUG = true;
TRUNCATE TABLE debugger; 
-- set @day = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @day = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
set @day =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
SELECT FIRST_DAY_OF_WEEK(@day);
SELECT * from debugger;
set @startDate ='2020-02-15 00:00:00';
set @endDate ='2020-02-09 23:59:59';	
-- benchmark(1000000, FIRST_DAY_OF_WEEK(@startDate)); 
select FIRST_DAY_OF_WEEK(@startDate)
drop function FIRST_DAY_OF_WEEK;
CREATE FUNCTION FIRST_DAY_OF_WEEK(pDay DATETIME)
RETURNS DATETIME DETERMINISTIC
BEGIN
	DECLARE day,firstDay,floorDate DATETIME;
	DECLARE week,year int;
	DECLARE dayOne char(20);
	set day = pDay;
	set week = week(day);
	if week = 0 then
	 	set year = year(day);
		set dayOne = concat('01/01/',year,' 00:00:00');
		set firstDay = STR_TO_DATE(dayOne,'%m/%d/%Y %H:%i:%s');
	else
		set floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
		set firstDay = subdate(floorDate, INTERVAL DAYOFWEEK(floorDate)-1 DAY);
	end if;
	-- IF @DEBUG then
	--   INSERT INTO debugger VALUES (CONCAT('[FIRST_DAY_OF_WEEK: day=',day,',week=',week,',firstDay=',firstDay,']'));
	-- End If;
	
	return firstDay;
END;	

select 'first'
set @Shift = Shift_Start(NOW());
select @Shift;
drop function Shift_Start; 
CREATE FUNCTION Shift_Start(pDateTime DATETIME)
RETURNS DATETIME DETERMINISTIC
BEGIN
	-- set @pDateTime = NOW();
	set @Hour = hour(pDateTime);

	set @Shift_Start = case 
		when ((@Hour>=7) and (@Hour < 15)) then concat(month(pDateTime),'/',day(pDateTime),'/',year(pDateTime),' 07:00:00')
		when ((@Hour>=15) and (@Hour < 23)) then concat(month(pDateTime),'/',day(pDateTime),'/',year(pDateTime),' 15:00:00')
		else concat(month(pDateTime),'/',day(pDateTime),'/',year(pDateTime),' 23:00:00')
	end;

	-- select @Shift_Start;
	return STR_TO_DATE(@Shift_Start,'%m/%d/%Y %H:%i:%s');
	-- return @Shift_Start;
END;

-- SELECT If(COALESCE(`price`, 0) < 5, 5, `price`) AS `Item_Price'
set @startDate ='2020-02-15 00:00:00';
set @endDate ='2020-02-09 23:59:59';	
-- benchmark(1000000, FIRST_DAY_OF_WEEK(@startDate)); 
select FIRST_DAY_OF_WEEK(@startDate); 
select TEST_FIRST_DAY_OF_WEEK(@startDate); 
drop function TEST_FIRST_DAY_OF_WEEK;
CREATE FUNCTION TEST_FIRST_DAY_OF_WEEK(pDay DATETIME)
RETURNS DATETIME DETERMINISTIC
BEGIN
	DECLARE day,firstDayWk0,firstDay,floorDate DATETIME;
	DECLARE week,year int;
	DECLARE dayOne char(20);
	set day = pDay;
	set week = week(day);

	set year = year(day);
	set dayOne = concat('01/01/',year,' 00:00:00');
	set firstDayWk0 = STR_TO_DATE(dayOne,'%m/%d/%Y %H:%i:%s');
	set floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
	set firstDay = if(week = 0,firstDayWk0,subdate(floorDate, INTERVAL DAYOFWEEK(floorDate)-1 DAY));
	return firstDay;
/*
	if week = 0 then
	 	set year = year(day);
		set dayOne = concat('01/01/',year,' 00:00:00');
		set firstDay = STR_TO_DATE(dayOne,'%m/%d/%Y %H:%i:%s');
	else
		set floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
		set firstDay = subdate(floorDate, INTERVAL DAYOFWEEK(floorDate)-1 DAY);
	end if;
	-- IF @DEBUG then
	--   INSERT INTO debugger VALUES (CONCAT('[FIRST_DAY_OF_WEEK: day=',day,',week=',week,',firstDay=',firstDay,']'));
	-- End If;
	
	return firstDay;
	*/
END;	

-- set @startDate = STR_TO_DATE('01/01/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
set @DEBUG = true;
TRUNCATE TABLE debugger; 
set @day =STR_TO_DATE('03/1/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @day =STR_TO_DATE('03/14/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @day = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @day = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
-- set @day =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
-- set @day = STR_TO_DATE('02/09/2020 00:00:00','%m/%d/%Y %H:%i:%s'); -- week 0

SELECT LAST_DAY_OF_WEEK(@day);
SELECT * from debugger;

CREATE TABLE debugger
( debug_comment CHAR(255)) ENGINE=MEMORY;

drop function LAST_DAY_OF_WEEK;
CREATE FUNCTION LAST_DAY_OF_WEEK(pDay DATETIME)
RETURNS DATETIME DETERMINISTIC
BEGIN
	DECLARE day,lastDay,nextDay,floorDate DATETIME;
	DECLARE week,year,endWeek int;
	set day = pDay;
	set week = week(day);
	set floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
	set lastDay = ADDDATE(floorDate,INTERVAL 7 - DAYOFWEEK(floorDate) DAY );
	set nextDay = ADDDATE(DATE(lastDay),INTERVAL 1 DAY);
	set lastDay = subdate(nextDay, INTERVAL 1 second);
	set endWeek = week(lastDay);
	-- make the last day = 12/31 if endWeek goes into the next year. 
	if week > endWeek then
	 	set year = year(day);
	 	set lastDay = STR_TO_DATE(concat('12/31/',year,' 23:59:59'),'%m/%d/%Y %H:%i:%s');
	end if;
	-- IF @DEBUG then
	-- 	INSERT INTO debugger VALUES (CONCAT('[LAST_DAY_OF_WEEK: day=',day,',week=',week,',floorDate=',floorDate,',lastDay=',lastDay,',nextDay=',nextDay,',endWeek=',endWeek,']'));
	-- End If;
	return lastDay;
END;

set @DEBUG = true;
TRUNCATE TABLE debugger; 
-- set @day = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @day = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
set @day =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
SELECT LAST_DAY_OF_WEEK(@day);
SELECT * from debugger;

CREATE TABLE debugger
( debug_comment CHAR(255)) ENGINE=MEMORY;


set @DEBUG = true;
TRUNCATE TABLE debugger; 
-- set @day = STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s');
-- set @day = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
set @day = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
SELECT STD_WEEK(@day);
SELECT * from debugger;

/*
-- THIS IS NEEDED TO MAKE SURE MSSQL WEEKS ARE THE SAME AS MYSQL DATES
-- MySQL datetime formats 'YYYY-MM-DD hh:mm:ss'
*/
drop function STD_WEEK;
CREATE FUNCTION STD_WEEK(pDay DATETIME)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE day,yearJan1 DATETIME;
	DECLARE week,year,yearJan1DOW int;
	set day = pDay;
	set week = WEEK(day);
	set year = YEAR(day);

-- THIS IS NEEDED TO MAKE SURE MSSQL WEEKS ARE THE SAME AS MYSQL DATES
	-- MySQL datetime formats 'YYYY-MM-DD hh:mm:ss'
	set yearJan1 = STR_TO_DATE(concat('01/01/',year,' 00:00:00'),'%m/%d/%Y %H:%i:%s');
	set yearJan1DOW = DAYOFWEEK(yearJan1);

	set week = if(yearJan1DOW = 1,week,week + 1);
	-- IF @DEBUG then
	-- 	INSERT INTO debugger VALUES (CONCAT('[STD_WEEK:day=',day,',week=',week,',year=',year,',yearJan1=',yearJan1,',yearJan1DOW=',yearJan1DOW,']'));
	-- End If;

	return week;
END;

CREATE PROCEDURE check_table_exists(table_name VARCHAR(100)) 
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02' SET @err = 1;
    SET @err = 0;
    SET @table_name = table_name;
    SET @sql_query = CONCAT('SELECT 1 FROM ',@table_name);
    PREPARE stmt1 FROM @sql_query;
   	execute b;
    IF (@err = 1) THEN
        SET @table_exists = 0;
    ELSE
        SET @table_exists = 1;
        DEALLOCATE PREPARE stmt1;
    END IF;
END; 

call check_table_exists('HourlyOEEValues');




