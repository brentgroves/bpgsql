/*
 * NOT USED
 */

select * from MSC.import
/*
update MSC.import
set LastSuccess='2021-04-27 00:00:00'
where id=1
 */

-- 


-- DROP TABLE mgdw.MSC.Import;
-- truncate TABLE mgdw.MSC.Import;
/*
CREATE TABLE mgdw.MSC.Import (
	ID int NOT NULL,
	Description varchar(100) NULL,
	AlbionLastSuccess datetime NULL,
	AvillaLastSuccess datetime NULL,
	EdonLastSuccess datetime NULL,
	PRIMARY KEY (ID)
);
*/
-- select AlbionLastSuccess from MSC.Import where id=1
declare @start_date datetime
set @start_date = '2021-04-27 00:00:00'
insert into mgdw.MSC.Import (ID,Description,AlbionLastSuccess,AvillaLastSuccess,EdonLastSuccess)
values (1,'MSCTransactions',@start_date,@start_date,@start_date)
select * from mgdw.MSC.Import

-- truncate table MSC.Restrictions2
select * from MSC.Restrictions2

--truncate table MSC.ItemSummary;
select * from MSC.ItemSummary
-- truncate table Kors.recipient
select * from Kors.recipient
select * from SSIS.ScriptComplete
-- truncate table mgdw.MSC.Jobs 
select * from mgdw.MSC.Jobs 
--update SSIS.ScriptComplete set Done = 0