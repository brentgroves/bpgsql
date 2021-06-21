DECLARE @StartDate  date = DATEADD(DAY, -400, getdate());

 

DECLARE @CutoffDate date = getdate();

 

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(date) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
)
SELECT convert(varchar, date, 23) FROM d
ORDER BY date
OPTION (MAXRECURSION 0);

/*
David said for HMDYYS format change convert statement
d(caldate) AS
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
)
SELECT convert(datetime, caldate) as date FROM d
ORDER BY date
OPTION (MAXRECURSION 0);
*/