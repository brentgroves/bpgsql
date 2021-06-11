-- delete from AlbSPS.Jobs where DESCR like 'DANA%'
--truncate table AlbSPS.Jobs  
select * from AlbSPS.Jobs j 

-- myDW.AlbSPS.Jobs definition

-- Drop table

-- DROP TABLE myDW.AlbSPS.Jobs;
/*
CREATE TABLE myDW.AlbSPS.Jobs (
	ID int not null,
	PCN int NOT NULL,
	VMID int NOT NULL,
	JOBENABLE int NOT NULL,
	JOBNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	DESCR nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);
*/
