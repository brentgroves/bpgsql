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

-- Drop table

https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourceGroups/azure-datafactory-selfhosted-ir
/providers/Microsoft.DataFactory/factories/mgirdemo/integrationRuntimes/AzureIRWithSelfHostedProxy/start?api-version=2018-06-01 

/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/azure-datafactory-selfhosted-ir/providers/Microsoft.DataFactory/factories/mgirdemo/integrationruntimes/AzureIRWithSelfHostedProxy
start:
https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/azure-datafactory-selfhosted-ir/providers/Microsoft.DataFactory/factories/mgirdemo/integrationruntimes/AzureIRWithSelfHostedProxy/start?api-version=2018-06-01
stop:
https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/azure-datafactory-selfhosted-ir/providers/Microsoft.DataFactory/factories/mgirdemo/integrationruntimes/AzureIRWithSelfHostedProxy/stop?api-version=2018-06-01
{"message":"Stopping AzureIRWithSelfHostedProxy IR"}
https://management.azure.com/subscriptions/f7d0cfcb-65b9-4f1c-8c9d-f8f993e4722a/resourcegroups/azure-datafactory-selfhosted-ir/providers/Microsoft.DataFactory/factories/mgirdemo/integrationRuntimes/AzureIRWithSelfHostedProxy/start?api-version=2018-06-01


-- DROP TABLE mgdw.MSC.Import;
-- truncate TABLE mgdw.MSC.Import;
CREATE TABLE mgdw.MSC.Import (
	ID int NOT NULL,
	Description varchar(100) NULL,
	AlbionLastSuccess datetime NULL,
	AvillaLastSuccess datetime NULL,
	EdonLastSuccess datetime NULL,
	PRIMARY KEY (ID)
);
declare @start_date datetime
set @start_date = '2021-04-27 00:00:00'
insert into mgdw.MSC.Import (ID,Description,AlbionLastSuccess,AvillaLastSuccess,EdonLastSuccess)
values (1,'MSCTransactions',@start_date,@start_date,@start_date)
select * from mgdw.MSC.Import

