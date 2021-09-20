--select * from Kors.shift 
/*

-- do this from the master database
/*
-- do this from the master database
CREATE LOGIN kors
WITH PASSWORD = 't`8V8Uj\/*ht>;M6';
*/

/*
 * Do this from the database with the schema you want to access
 */
CREATE USER [kors]
FROM LOGIN [kors]
WITH DEFAULT_SCHEMA=Kors;
ALTER ROLE db_owner ADD MEMBER [kors];

-- CREATE LOGIN kors
-- WITH PASSWORD = 't`8V8Uj\/*ht>;M6';
create login mgadmin2
WITH PASSWORD = 'WeDontSharePasswords1!';

create user mgadmin2
from login mgadmin2
with default_schema=dbo;

ALTER SERVER ROLE sysadmin  ADD MEMBER mgadmin2;  -- cant do this 
ALTER ROLE dbmanager ADD MEMBER mgadmin2;
ALTER ROLE loginmanager add member mgadmin2;
*/

/*
 * Do this from the database with the schema you want to access
 */
CREATE USER [kors]
FROM LOGIN [kors]
WITH DEFAULT_SCHEMA=Kors;
ALTER ROLE db_owner ADD MEMBER [kors];


*/
--select * from Kors.shift 
/*
-- do this from the master database
CREATE LOGIN mgssis
WITH PASSWORD = 'WeDontSharePasswords1!';
*/

/*
 * Do this from the database with the schema you want to access
 */
--SWITCH DATABASE!!!!!!!!!!!!!
/*
CREATE USER [mgssis]
FROM LOGIN [mgssis]
WITH DEFAULT_SCHEMA=dbo;
ALTER ROLE db_owner ADD MEMBER [mgssis];
ALTER SERVER ROLE  sysadmin  ADD MEMBER [mgssis];  
ALTER SERVER ROLE diskadmin ADD MEMBER mgssis;  
SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name;  


*/
/*
 * AAD user
CREATE USER [kyoung@buschecnc.com] FROM EXTERNAL PROVIDER;  
 */

