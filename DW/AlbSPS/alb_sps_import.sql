select * from albsps.import
/*
update albsps.import
set LastSuccess='2021-04-27 00:00:00'
where id=1
 */

-- myDW.AlbSPS.Import definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.Import;
-- truncate TABLE myDW.AlbSPS.Import;
CREATE TABLE myDW.AlbSPS.Import (
	ID int NOT NULL,
	Description varchar(100) NULL,
	LastSuccess datetime NULL,
	PRIMARY KEY (ID)
);
declare @start_date datetime
set @start_date = '2021-04-27 00:00:00'
insert into myDW.AlbSPS.Import (ID,Description,LastSuccess)
values (1,'AlbMSCTransactions',@start_date)
select * from myDW.AlbSPS.Import