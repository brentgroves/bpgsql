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
-- https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/rg-useast-dataservices/providers/Microsoft.DataFactory/factories/mg-adf/integrationRuntimes/mgsqlsrv-ir/start?api-version=2018-06-01
-- https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/rg-useast-dataservices/providers/Microsoft.DataFactory/factories/mg-adf/integrationRuntimes/mgsqlsrv-ir/stop?api-version=2018-06-01
-- select * from ssis.ScriptComplete sc 
--TRUNCATE table mgdw.MSC.Jobs 

--https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/rg-useast-dataservices/providers/Microsoft.DataFactory/factories/mg-adf/integrationRuntimes/mgsqlsrv-ir/start?api-version=2018-06-01

select * from mgdw.AlbSPS.jobs where jobnumber = '-'
-- truncate table mgdw.MSC.Jobs 
select * from mgdw.MSC.Jobs 
where pcn = 300758 and vmid = 4 -- plant 6
-- where pcn = 300758 and vmid = 5 -- plant 8
-- where pcn = 300758 and vmid = 6 -- plant 9 
where pcn = 310507 and vmid = 3
where pcn = 306766 and vmid = 3
-- delete from AlbSPS.Jobs where DESCR like 'DANA%'
--truncate table AlbSPS.Jobs  
select '"' + jobnumber + '"' JOBNUMBER ,DESCR from AlbSPS.Jobs j 

-- myDW.AlbSPS.Jobs definition

-- Drop table

-- DROP TABLE MSC.Jobs;
/*
CREATE TABLE myDW.AlbSPS.Jobs (
	ID int not null,
	PCN int NOT NULL,
	VMID int NOT NULL,
	JOBENABLE int NOT NULL,
	JOBNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	DESCR nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	
);
*/
/*
--Need changed in MSC not in Ples
10037973H P558 6K LH KNUCKLES
10013354 P558 6k RH KNUCKLES
10103344 P558 7k RH KNUCKLES
*/
--CREATE TABLE MSC.Jobs (ID INT NOT NULL, PCN INT NOT NULL, VMID INT NOT NULL, JOBENABLE INT NOT NULL, JOBNUMBER NVARCHAR(32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, 
DESCR NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,primary key(ID,PCN));
