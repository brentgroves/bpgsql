select top 100 * from HourlyOEEValues 


select top 100 * 
from MyHourlyOEEValues 
order by id 


SELECT * 
FROM mstest
ORDER BY id 
OFFSET 2 ROWS FETCH NEXT 10 ROWS ONLY;
--ORDER BY (SELECT NULL) OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
--https://docs.microsoft.com/en-us/previous-versions/sql/compact/sql-server-compact-4.0/gg699618(v=sql.110)?redirectedfrom=MSDN
--Invalid usage of the option next in the FETCH statement.
--https://dba.stackexchange.com/questions/167562/how-to-solve-invalid-usage-of-the-option-next-in-the-fetch-statement
--SELECT @@version
--Microsoft SQL Server 2014 (SP3) (KB4022619) - 12.0.6024.0 (X64) 
--https://github.com/feathersjs-ecosystem/feathers-sequelize#working-with-mssql