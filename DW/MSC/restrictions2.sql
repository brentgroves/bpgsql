-- drop TABLE MSC.Restrictions2
-- TRUNCATE TABLE MSC.Restrictions2
/*
-- drop TABLE MSC.Restrictions2
CREATE TABLE MSC.Restrictions2 (
	id int,
	pcn int,
	R_JOB nvarchar(50),
	R_ITEM nvarchar(50)
	primary key(id,pcn)
);
*/
-- truncate table MSC.Restrictions2
select * from MSC.Restrictions2

--truncate table MSC.ItemSummary;
select * from MSC.ItemSummary
-- truncate table Kors.recipient
select * from Kors.recipient
select * from SSIS.ScriptComplete
-- truncate table mgdw.MSC.Jobs 
select * from MSC.Jobs 
--update SSIS.ScriptComplete set Done = 0
