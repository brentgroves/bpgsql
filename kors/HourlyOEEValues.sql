-- DROP TABLE Kors.dbo.oee GO
select top 100 * from HourlyOEEValues 
select top 100 * 
from MyHourlyOEEValues 
order by id 



--select [mstest].* from [mstest] offset 2
select * from mstest LIMIT 2;
fetch next @p1 rows only
SELECT *
FROM mstest
ORDER BY id
OFFSET 2 ROWS;
--Invalid usage of the option next in the FETCH statement.
SELECT * 
FROM mstest
ORDER BY id 
OFFSET 2 ROWS FETCH NEXT 10 ROWS ONLY;
--ORDER BY (SELECT NULL) OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
--https://docs.microsoft.com/en-us/previous-versions/sql/compact/sql-server-compact-4.0/gg699618(v=sql.110)?redirectedfrom=MSDN
--https://dba.stackexchange.com/questions/167562/how-to-solve-invalid-usage-of-the-option-next-in-the-fetch-statement
--SELECT @@version
--Microsoft SQL Server 2014 (SP3) (KB4022619) - 12.0.6024.0 (X64) 
--https://github.com/feathersjs-ecosystem/feathers-sequelize#working-with-mssql