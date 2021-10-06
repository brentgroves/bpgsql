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
--where pcn = 300758 and vmid = 4 
--where pcn = 300758 and vmid = 5 
--where pcn = 300758 and vmid = 6 -- none
where pcn = 310507 and vmid = 3
--where pcn = 306766 and vmid = 3
where pcn = 306766 and vmid = 3
--truncate table MSC.ItemSummary;
select * from MSC.ItemSummary
-- truncate table Kors.recipient
select * from Kors.recipient
select * from SSIS.ScriptComplete
-- truncate table mgdw.MSC.Jobs 
select * from MSC.Jobs 
--update SSIS.ScriptComplete set Done = 0
