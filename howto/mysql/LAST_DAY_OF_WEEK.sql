set @pDate = '2021-01-01 00:00:00';


select FIRST_DAY_OF_WEEK(@pDate),LAST_DAY_OF_WEEK(@pDate); 

CREATE DEFINER=`brent`@`%` FUNCTION `mach2`.`LAST_DAY_OF_WEEK`(pDay DATETIME) RETURNS datetime
    DETERMINISTIC
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
