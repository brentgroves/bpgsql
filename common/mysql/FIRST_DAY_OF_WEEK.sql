-- set @pDate = '2021-01-01 00:00:00';
-- set @pDate = '2020-12-31 00:00:00';


select FIRST_DAY_OF_WEEK(@pDate),LAST_DAY_OF_WEEK(@pDate); 

CREATE DEFINER=`brent`@`%` FUNCTION `mach2`.`FIRST_DAY_OF_WEEK`(pDay DATETIME) RETURNS datetime
    DETERMINISTIC
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
