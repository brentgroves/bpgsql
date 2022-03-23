-- MYSQL STORES DATETIME IN UTC FORM
SELECT @@GLOBAL.time_zone, @@SESSION.time_zone;
-- America/Fort_Wayne
-- https://dev.mysql.com/doc/refman/8.0/en/time-zone-support.html
-- https://stackoverflow.com/questions/2187593/can-mysql-convert-a-stored-utc-time-to-local-timezone
SELECT
  CONVERT_TZ('2007-03-11 2:00:00','GMT','SYSTEM') AS time1,
  CONVERT_TZ('2007-03-11 3:00:00','US/Eastern','US/Central') AS time2;
  
set @startDate = '2020-07-09 11:30:00';
set @endDate = '2020-07-09 15:30:00';
-- set @startDate = '2020-07-09T11:30:00.000Z';  -- 1
-- set @endDate = '2020-07-09T15:30:00.000Z'; -- 234
select 
CONVERT_TZ(TransDate ,'US/Eastern','US/Central'),
convert_tz(TransDate ,'UTC','@@session.time_zone'),
*
from CompareContainer where transDate between @startDate and @endDate ORDER BY CompareContainer_Key;

select convert_tz(now(),@@session.time_zone,'+03:00')

set @startDate = '2020-07-09 11:30:00';
set @endDate = '2020-07-09 15:30:00';
-- SELECT CONVERT_TZ( TransDate, 'UTC',@@session.time_zone )
SELECT CONVERT_TZ( TransDate, 'UTC','America/Fort_Wayne' )
-- SELECT CONVERT_TZ( TransDate, 'UTC', 'Europe/Stockholm' )
from CompareContainer where transDate between @startDate and @endDate ORDER BY CompareContainer_Key;

SELECT * FROM mysql.time_zone;
SELECT * FROM mysql.time_zone_name;