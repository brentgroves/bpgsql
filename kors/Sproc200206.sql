select top 100 * from HourlyOEEValues 
--drop procedure Sproc200206 
CREATE PROCEDURE Sproc200206
	@start_date DATETIME,
	@end_date DATETIME,
	@report_name varchar(12)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

EXEC('select top(10) * into ' + @report_name + ' from HourlyOEEValues')
--EXEC('select * from ' + @report_name)
   
END;


DECLARE	@return_value int,
@start_date DATETIME,
@end_date DATETIME,
@report_name varchar(12);
--2004-05-23T14:25:10
set @start_date ='2019-12-15T09:00:00';
set @end_date ='2019-12-15T09:00:00';
set @report_name = 'rpt0207558'
EXEC	@return_value = [dbo].[Sproc200206] @start_date,@end_date,@report_name

SELECT	'Return Value' = @return_value

GO

select * from rpt0207558

SELECT * 
FROM rpt0207558
ORDER BY id 
OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;
