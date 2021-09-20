/*
Albion
VMID in (4,5,6)
Avilla
VMID in (3)
Edon
VMID in (3,4) both have the same jobs
 */
/*
 * USED BY AlbMSCJobs ETL script
 */
/*
 select *
 into AlbSPS.JobsNO
 from AlbSPS.Jobs 
 where JOBNUMBER not like '%[A-Z]%'
*/ 
select * from myDW.MSC.Jobs
-- delete from AlbSPS.Jobs where DESCR like 'DANA%'
--truncate table AlbSPS.Jobs  
select '"' + jobnumber + '"' JOBNUMBER ,DESCR from AlbSPS.Jobs j 

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
/*
--Need changed in MSC not in Ples
10037973H P558 6K LH KNUCKLES
10013354 P558 6k RH KNUCKLES
10103344 P558 7k RH KNUCKLES
*/