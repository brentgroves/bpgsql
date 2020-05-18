/*
 * Find first day of WEEK
 */
-- START HERE MODIFY MSSQL CODE TO INCLUDE THIS PLEX SECTION I FORGOT
/*
if DATEPART(WEEK,@Start_Date) = 1
set @start_of_week_for_start_date = datefromparts(DATEPART(YEAR,@Start_Date), 1, 1)
else
set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
-- MODIFY FIRST_DAY_OF_WEEK CODE AND LAST_DAY_OF_WEEK TO INCLUDE THIS PLEX SECTION I FORGOT
if DATEPART(WEEK,@End_Date) > 51 and  (  DATEPART(MONTH,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + CONVERT(varchar, DATEPART(YEAR,@End_Date))) + (DATEPART(WEEK,@End_Date)-1), 5))   =1)
set @end_of_week_for_end_date = DATEADD(second,-1,convert(datetime,DATEADD(day, 1,datefromparts(DATEPART(YEAR,@End_Date), 12, 31))))
else
set @end_of_week_for_end_date = DATEADD(second,-1,DATEADD(day,1,DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @end_year) + (@end_week-1), 5)))  --end of week
*/

drop function FIRST_DAY_OF_WEEK;
CREATE FUNCTION FIRST_DAY_OF_WEEK(day DATE)
RETURNS DATETIME DETERMINISTIC
BEGIN
	set @floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
	return subdate(@floorDate, INTERVAL DAYOFWEEK(@floorDate)-1 DAY);
END

drop function LAST_DAY_OF_WEEK;
CREATE FUNCTION LAST_DAY_OF_WEEK(day DATE)
RETURNS DATETIME DETERMINISTIC
BEGIN
	set @floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
	set @lastDay = ADDDATE(@floorDate,INTERVAL 7 - DAYOFWEEK(@floorDate) DAY );
	set @nextDay = ADDDATE(DATE(@lastDay),INTERVAL 1 DAY);
	return subdate(@nextDay, INTERVAL 1 second);
END;

set @startDate ='2020-02-16 01:00:00';
set @endDate ='2020-02-09 23:59:59';

	set @floorDate = ADDDATE(DATE(day),INTERVAL 0 second);
	set @lastDay = ADDDATE(@floorDate,INTERVAL 7 - DAYOFWEEK(@floorDate) DAY );
	set @nextDay = ADDDATE(DATE(day),INTERVAL 1 DAY);
	select subdate(@nextDay, INTERVAL 1 second);

-- SELECT FIRST_DAY_OF_WEEK(@startDate);
 SELECT LAST_DAY_OF_WEEK(@endDate);

-- select WEEKDAY(@startDate);
-- select DAYOFWEEK(@startDate);
-- SELECT FIRST_DAY_OF_WEEK(@startDate);

-- select DATE_ADD(@startDate, INTERVAL(1-DAYOFWEEK(@startDate)) DAY);
-- SELECT subdate(now(), INTERVAL 7-DAYOFWEEK(now()) DAY)
-- SELECT INTERVAL weekday(now()) day
SELECT INTERVAL (7 - DAYOFWEEK(@startDate));
SELECT subdate(now(), INTERVAL weekday(now()) DAY)
SELECT adddate(now(), INTERVAL 6-weekday(now()) DAY)
SELECT  
  DATETIME(@startDate + INTERVAL (1 - DAYOFWEEK(@startDate)) DAY) as start_date,  
  DATE(@endDate + INTERVAL (7 - DAYOFWEEK(@endDate)) DAY) as end_date
  
--  set @start_of_week_for_start_date = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @start_year) + (@start_week-1), 6)  --start of week
