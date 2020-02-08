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

    EXEC('select top(10) * into ' + @table_name + ' from HourlyOEEValues')
    
    SELECT @record_count = @@ROWCOUNT;
--EXEC('select * from ' + @report_name)
   
END;


DECLARE	@return_value int,
@start_date DATETIME,
@end_date DATETIME,
@table_name varchar(12),
@record_count int;
--2004-05-23T14:25:10
set @start_date ='2019-12-15T09:00:00';
set @end_date ='2019-12-15T09:00:00';
set @table_name = 'rpt02080'
EXEC	@return_value = [dbo].[Sproc200206] @start_date,@end_date,@table_name,@record_count OUTPUT
select '@record_count' = @record_count
SELECT	'Return Value' = @return_value

GO
--drop table rpt02080
select * from rpt02080

SELECT * 
FROM rpt0207558
ORDER BY id 
OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;
