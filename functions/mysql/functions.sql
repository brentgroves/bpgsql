/*
 * Find first day of WEEK
 */


	-- set @startDate = STR_TO_DATE('02/09/2020 23:59:59','%m/%d/%Y %H:%i:%s');
	-- set @startDate = STR_TO_DATE('01/01/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
	set @startDate = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
	-- set @startDate = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
	-- set @startDate =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
	-- SELECT @startDate;
	SELECT FIRST_DAY_OF_WEEK(@startDate);
drop function FIRST_DAY_OF_WEEK;
CREATE FUNCTION FIRST_DAY_OF_WEEK(day DATETIME)
RETURNS DATETIME DETERMINISTIC
BEGIN

	set @day = day;
	set @week = week(@day);
	if @week = 0 then
	 	set @year = year(@day);
		set @dayOne = concat('01/01/',@year,' 00:00:00');
		set @firstDay = STR_TO_DATE(@dayOne,'%m/%d/%Y %H:%i:%s');
	else
		set @floorDate = ADDDATE(DATE(@day),INTERVAL 0 second);
		set @firstDay = subdate(@floorDate, INTERVAL DAYOFWEEK(@floorDate)-1 DAY);
	end if;
	return @firstDay;
END;	

-- set @startDate = STR_TO_DATE('01/01/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
SET @msg := '';
-- set @day = STR_TO_DATE('01/04/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 0
-- set @day = STR_TO_DATE('01/05/2020 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 1
set @day =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
SELECT LAST_DAY_OF_WEEK(@day);
SELECT @msg;

drop function LAST_DAY_OF_WEEK;
CREATE FUNCTION LAST_DAY_OF_WEEK(day DATETIME)
RETURNS DATETIME DETERMINISTIC
BEGIN
	set @day = day;
	set @week = week(@day);
	set @floorDate = ADDDATE(DATE(@day),INTERVAL 0 second);
	set @lastDay = ADDDATE(@floorDate,INTERVAL 7 - DAYOFWEEK(@floorDate) DAY );
	set @nextDay = ADDDATE(DATE(@lastDay),INTERVAL 1 DAY);
	set @endWeek = week(subdate(@nextDay, INTERVAL 1 second));
-- set @lastDay = STR_TO_DATE(concat('12/31/',@year,' 00:00:00'),'%m/%d/%Y %H:%i:%s');
-- SELECT CONCAT('[Debug #',@week,',',@endWeek,']') INTO @msg;
-- if the week of @day > 51 and the end of week for @day is in week 0 then 
	-- make the last day = 12/13 
	if @week > @endWeek then
	 	set @year = year(@day);
	 	set @lastDay = STR_TO_DATE(concat('12/31/',@year,' 00:00:00'),'%m/%d/%Y %H:%i:%s');
  		SELECT CONCAT('[Debug # @week > @endWeek]') INTO @msg;
	else
  		SELECT CONCAT('[Debug # @week <= @endWeek]') INTO @msg;
	 	set @lastDay = subdate(@nextDay, INTERVAL 1 second);
	end if;
	return @lastDay;
END;
	set @day =STR_TO_DATE('12/31/2019 23:59:59','%m/%d/%Y %H:%i:%s'); -- week 52
	set @week = week(@day);
	set @floorDate = ADDDATE(DATE(@day),INTERVAL 0 second);
	set @lastDay = ADDDATE(@floorDate,INTERVAL 7 - DAYOFWEEK(@floorDate) DAY );
	set @nextDay = ADDDATE(DATE(@lastDay),INTERVAL 1 DAY);
	select week(subdate(@nextDay, INTERVAL 1 second));




  
