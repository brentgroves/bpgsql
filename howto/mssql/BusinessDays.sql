/*
DECLARE @DateFrom DATETIME;
DECLARE @DateTo DATETIME;
SET @DateFrom = '2017-06-03 11:19:11.287';
SET @DateTo = '2017-06-11 13:53:14.750';


1. total number of days between a date range
-- Excludes @DateFrom so add 1  
DECLARE @TotDays INT= DATEDIFF(DAY, @DateFrom, @DateTo) + 1;
select @TotDays as TotalDays
*/


/*
 2.  Total full weekends. 
 The WEEK interval in DATEDIFF does not actually calculate the number of weeks, instead it 
 calculates the number of instances that a complete weekend appears (combination of Saturday and Sunday) 
 within the specified date range. Consequently, for a more accurate week calculation, we should always 
 multiply the output by 2 – the number of days in a weekend. 
-- Calculate the total number of weeks between a date range
DECLARE @TotWeeks INT= (DATEDIFF(WEEK, @DateFrom, @DateTo) * 2)

select @TotWeeks as TotalWeeks
*/
/*
3. Exclude Incomplete Weekends
The final steps involve the exclusion of incomplete weekend days from being counted as part of working days. 
Incomplete weekend days refer to instances whereby the Date From parameter value falls on a Sunday or the Date
To parameter value is on a Saturday. 
SELECT DATENAME(weekday, '20170611') [US];
*/
/*

DECLARE @DateFrom DATETIME;
DECLARE @DateTo DATETIME;
SET @DateFrom = '2017-06-03 11:19:11.287';
SET @DateTo = '2017-06-11 13:53:14.750';

DECLARE @TotDays INT= DATEDIFF(DAY, @DateFrom, @DateTo) + 1;
DECLARE @TotWeeks INT= DATEDIFF(WEEK, @DateFrom, @DateTo) * 2;
DECLARE @IsSunday INT= CASE
				 WHEN DATENAME(WEEKDAY, @DateFrom) = 'Sunday'
				 THEN 1
				 ELSE 0
			  END;
DECLARE @IsSaturday INT= CASE
				   WHEN DATENAME(WEEKDAY, @DateTo) = 'Saturday'
				   THEN 1
				   ELSE 0
			    END;
			    
select @TotDays,@TotWeeks,@IsSunday,@IsSaturday			    
*/
/*
CREATE FUNCTION [dbo].[fn_GetTotalWorkingDays]
(
    @DateFrom Date,
    @DateTo Date
)
RETURNS INT
AS
BEGIN
    DECLARE @TotDays INT= DATEDIFF(DAY, @DateFrom, @DateTo) + 1;
    DECLARE @TotWeeks INT= DATEDIFF(WEEK, @DateFrom, @DateTo) * 2;
    DECLARE @IsSunday INT= CASE
						 WHEN DATENAME(WEEKDAY, @DateFrom) = 'Sunday'
						 THEN 1
						 ELSE 0
					  END;
    DECLARE @IsSaturday INT= CASE
						   WHEN DATENAME(WEEKDAY, @DateTo) = 'Saturday'
						   THEN 1
						   ELSE 0
					    END;
    DECLARE @TotWorkingDays INT= @TotDays - @TotWeeks - @IsSunday + @IsSaturday;
    RETURN @TotWorkingDays;
END
*/