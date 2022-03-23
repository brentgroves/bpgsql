set @pDate = '2021-01-01 00:00:00';


select DAYOFWEEK(@pDate),WEEK(@pDate),STD_WEEK(@pDate); 

CREATE DEFINER=`brent`@`%` FUNCTION `mach2`.`STD_WEEK`(pDay DATETIME) RETURNS int
    DETERMINISTIC
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
