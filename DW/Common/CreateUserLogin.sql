*/
--select * from Kors.shift 
/*
-- do this from the master database
-- CREATE LOGIN kors
-- WITH PASSWORD = 't`8V8Uj\/*ht>;M6';
*/

/*
 * Do this from the database with the schema you want to access
 */
CREATE USER [kors]
FROM LOGIN [kors]
WITH DEFAULT_SCHEMA=Kors;
ALTER ROLE db_owner ADD MEMBER [kors];
