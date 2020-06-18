--https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-union/


declare @Year int;
set @Year = 2020;

with cte_days_of_year(day_of_year) as
(
  select datefromparts(@Year, 1, 1) day_of_year --1/1/2020 12:00:00 AM
  union all
  select dateadd(day, 1, day_of_year)
  from cte_days_of_year
  where day_of_year < datefromparts(@Year, 12, 31)
)
select datepart(iso_week, day_of_year) as ISOWeekNo
--       convert(varchar(101), min(C.D), 106)+' To '+convert(varchar(101), max(C.D), 106) as WeekName
from cte_days_of_year
option (maxrecursion 400);

--select  day_of_year 
--from cte_days_of_year
--option (maxrecursion 400);

--declare @Year int;
--set @Year = 2020;

with C as
(
  select datefromparts(@Year, 1, 1) as D  --1/1/2020 12:00:00 AM
  union all
  select dateadd(day, 1, C.D)
  from C
  where C.D < datefromparts(@Year, 12, 31)
)
select datepart(iso_week, C.D) as ISOWeekNo,
       convert(varchar(101), min(C.D), 106)+' To '+convert(varchar(101), max(C.D), 106) as WeekName
from C
group by datepart(iso_week, C.D),
         case when datepart(month, C.D) = 12 and
                   datepart(iso_week, C.D) > 50
           then 1
           else 0 
         end
order by min(C.D)
option (maxrecursion 0);

--WEEKDAYS

WITH cte_numbers(n, weekday) 
AS (
    SELECT 
        0, 
        DATENAME(DW, 0) --0,Monday
    union all    
    SELECT    
        n + 1, 
        DATENAME(DW, n + 1)
    FROM    
        cte_numbers
    WHERE n < 6
)
SELECT 
    weekday
FROM 
    cte_numbers;
    

/* The following shows the syntax of a recursive CTE:

-- An initial query that returns the base result set of the CTE. The initial query is called an anchor member.
-- To include the duplicate row, you use the UNION ALL as shown in the following query:
-- A recursive query that references the common table expression, therefore, it is called the recursive member. The recursive member is union-ed with the anchor member using the UNION ALL operator.

WITH expression_name (column_list)
AS
(
    -- Anchor member
    initial_query  
    UNION ALL
    -- Recursive member that references expression_name.
    recursive_query  
)
-- references expression name
SELECT *
FROM   expression_name


*/