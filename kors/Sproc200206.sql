select top 100 * from HourlyOEEValues 
--drop procedure Sproc200206 
CREATE PROCEDURE Sproc200206
	@start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT OUTPUT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	IF OBJECT_ID(@table_name) IS NOT NULL
    	EXEC ('DROP Table ' + @table_name)

    EXEC('select top(1000) * into ' + @table_name + ' from HourlyOEEValues where Date_time_stamp BETWEEN ' + @start_date + ' and ' + @end_date )
    
    SELECT @record_count = @@ROWCOUNT;

--EXEC('select * from ' + @report_name)
   
END;

--drop procedure Sproc200206 
CREATE PROCEDURE Sproc200206
	@start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT OUTPUT
AS
BEGIN
	declare @sql nvarchar(4000)
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	IF OBJECT_ID(@table_name) IS NOT NULL
    	EXEC ('DROP Table ' + @table_name)

--    EXEC('select top(1000) * into ' + @table_name + ' from HourlyOEEValues where Date_time_stamp BETWEEN ' + @start_date + ' and ' + @end_date )
 --   EXEC('select * from HourlyOEEValues where Date_time_stamp BETWEEN ''' + CONVERT(VARCHAR(10),@start_date, 101) + ''' and ''' + CONVERT(VARCHAR(10),@end_date, 101) + '''')
--	select * from HourlyOEEValues where Date_time_stamp BETWEEN @start_date and @end_date

select @sql = N'SELECT * into ' + quotename(@table_name) + N' from hourlyoeevalues  WHERE Date_time_stamp BETWEEN cast(floor(cast(@fromDate as float)) as datetime) AND cast(floor(cast(@toDate as float)) as datetime)'

EXEC sp_executesql @sql, N'@fromDate datetime, @toDate datetime', @start_date, @end_date
    
SELECT @record_count = @@ROWCOUNT;
--EXEC('select * from ' + @report_name)
   
END;


DECLARE	@return_value int,
@start_date DATETIME,
@end_date DATETIME,
@table_name varchar(12),
@record_count int;
--2004-05-23T14:25:10
--YYYYMMDD or YYYY-MM-DD
--YYYY-MM-DDThh:mm:ss.nnn
set @start_date ='2020-02-09T00:00:00';
--select @start_date
set @end_date ='2020-02-10T23:59:59';
--HH:MM:SS.SSS
set @table_name = 'rpt02080';
EXEC	@return_value = [dbo].[Sproc200206] @start_date,@end_date,@table_name,@record_count OUTPUT
select '@record_count' = @record_count
SELECT	'Return Value' = @return_value

--drop procedure SprocTest
CREATE PROCEDURE SprocTest
	@start_date DATETIME,
	@end_date DATETIME,
	@table_name varchar(12),
	@record_count INT OUTPUT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	IF OBJECT_ID(@table_name) IS NOT NULL
    	EXEC ('DROP Table ' + @table_name)

--    EXEC('select top(1000) * into ' + @table_name + ' from HourlyOEEValues where Date_time_stamp BETWEEN ' + @start_date + ' and ' + @end_date )
 --   EXEC('select * from HourlyOEEValues where Date_time_stamp BETWEEN ''' + CONVERT(VARCHAR(10),@start_date, 101) + ''' and ''' + CONVERT(VARCHAR(10),@end_date, 101) + '''')
--	select * from HourlyOEEValues where Date_time_stamp BETWEEN @start_date and @end_date
	declare @sql nvarchar(4000)

select @sql = N'SELECT * into ' + quotename(@table_name) + N' from myhourlyoeevalues  WHERE Date_time_stamp BETWEEN cast(floor(cast(@fromDate as float)) as datetime) AND cast(floor(cast(@toDate as float)) as datetime)'

EXEC sp_executesql @sql, N'@fromDate datetime, @toDate datetime', @start_date, @end_date
    
SELECT @record_count = @@ROWCOUNT;
--EXEC('select * from ' + @report_name)
   
END;
select count(*) cnt from MyHourlyOEEValues mho 
DECLARE	@return_value int,
@start_date DATETIME,
@end_date DATETIME,
@table_name varchar(12),
@record_count int;
--2004-05-23T14:25:10
--YYYYMMDD or YYYY-MM-DD
--YYYY-MM-DDThh:mm:ss.nnn
set @start_date ='2019-12-09T00:00:00';
--select @start_date
set @end_date ='2020-02-15T23:59:59';
--HH:MM:SS.SSS
set @table_name = 'rpt02080';
EXEC	@return_value = [dbo].[SprocTest] @start_date,@end_date,@table_name,@record_count OUTPUT
select '@record_count' = @record_count
SELECT	'Return Value' = @return_value

GO
--drop table rpt02080
select top(10) * from rpt02080 order by id

DECLARE	@return_value int,
@start_date DATETIME,
@end_date DATETIME,
@table_name varchar(12),
@record_count int;
--2004-05-23T14:25:10
set @start_date ='2020-02-09T00:00:00';
set @end_date ='2020-02-15T23:59:59';
select 
--top(1000) *
count(*) cnt 
from HourlyOEEValues where Date_time_stamp BETWEEN @start_date and @end_date


set @table_name = 'rpt02080'
--Select “Valid Years are: ” & DatePart(“yyyy”, orderDate) WHERE DatePart(“yyyy”,orderDate) > 2001

SELECT 
m,d,h
from
(
	SELECT 
	--distinct Data_hour 
	DATEPART(month, Date_time_stamp ) m,
	DATEPART(day, Date_time_stamp ) d, 
	DATEPART(hour, Date_time_stamp ) h 
	FROM HourlyOEEValues 
	where Date_time_stamp BETWEEN @start_date and @end_date
)s1
group by m,d,h

GROUP BY DATEPART(month, Date_time_stamp ),DATEPART(day, Date_time_stamp ), DATEPART(hour, Date_time_stamp )
having Date_time_stamp BETWEEN @start_date and @end_date
order by DATEPART(month, Date_time_stamp ),DATEPART(day, Date_time_stamp ), DATEPART(hour, Date_time_stamp ) 


SELECT 
--distinct Data_hour 
distinct Date_time_stamp 
FROM HourlyOEEValues 
where Date_time_stamp BETWEEN @start_date and @end_date
order by Data_time_stamp 

SELECT 
Data_hour,Date_time_stamp 
FROM HourlyOEEValues 
group by Data_hour,Date_time_stamp 
having Date_time_stamp BETWEEN @start_date and @end_date
order by Data_hour 
ORDER BY id 
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;
/*

DECLARE @sql nvarchar(4000)

select @sql = N'
  SELECT B.FacId 
       , B.FacName
       , B.BookCode
       , B.BookName
       , B.Quantity
       , CONVERT(VARCHAR(10), B.TillDate, 104) AS TILLDATE 
    FROM ' + quotename(@TABLE) + N' B
   WHERE B.TillDate BETWEEN cast(floor(cast(@fromDate as float)) as datetime)
                        AND cast(floor(cast(@toDate as float)) as datetime)'

EXEC sp_executesql @sql, N'@fromDate datetime, @toDate datetime', @FROMDATE, @TODATE
*/