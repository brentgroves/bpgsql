/*
convert months to an actual datetime.
*/
 SELECT DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) AS StartOfMonth,
 DATEADD(year,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) startOfMonthLastYear,
 getdate() today
