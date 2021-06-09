-- DROP TABLE myDW.MSC.Info;

CREATE TABLE myDW.MSC.Import (
	ID int NOT NULL,
	LastImportAlbion datetime NULL
);

select * from myDW.MSC.Import  where id = 1

--truncate table myDW.MSC.Import
--INSERT into myDW.MSC.Import
-- values (1,'2021-05-15 00:00:00') -- Data Plant 6 tool boss came online
 values (1,'2021-04-27 00:00:00') -- Data Plant 6 tool boss came online
 --2021-05-17 19:51:52 -04:00

update myDW.MSC.Import
set LastImportAlbion = '2021-04-27 00:00:00'
-- set LastImportSPSAlb = GETDATE() 
-- set LastImportSPSAlb = CONVERT(DATETIME,GETDATE() AT TIME ZONE 
-- (SELECT CURRENT_TIMEZONE_ID()) AT TIME ZONE 'US Eastern Standard Time')
 where ID = 1
 select * from myDW.MSC.Import  where id = 1
