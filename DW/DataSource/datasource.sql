
create schema DataSource

/*
Script Name:
Script Type:
Web service: 
Data Source Key
Mobex authored procedure: 
Plex authored procedure:  
Data Warehouse:

Source Control
Author: 
Schedule: 
Notes:
Issue number range

Issue:
Issue Number:
Issue Type View:
Severity:
Filter condition:
Notes:
*/
-- drop table DataSource.base_source
create table DataSource.base_source
(
	base_source_key int primary key,
	base_source varchar(100) not null,
	base_source_type_key int not null,
)
select * from DataSource.base_source 
insert into DataSource.base_source 
values 
(1,'Plex',1)

create table DataSource.base_source_type 
(
	base_source_type_key int primary key,
	base_source_type varchar(100) not null,
)
select * from DataSource.base_source_type  
insert into DataSource.base_source_type  
values 
(1,'database'),
(2,'csv')

/*
 * A data source can be a Mobex or Plex procedure, Plex web service,
 * or CSV file
 */
-- drop table DataSource.datasource
-- truncate table DataSource.datasource
create table DataSource.datasource
(
	datasource_key int not null,
	name varchar(100) not null,	
	base_source_key int not null,
	datasource_type_key int null,
	note varchar(max) null,
	CONSTRAINT PK_datasource PRIMARY KEY (datasource_key)
)
-- truncate table DataSource.datasource 
insert into DataSource.datasource 
values 
(5,'AccountingPeriod',1,2,'start and end period dates and fiscal order info. I think period in the distant future get added periodically.'),
(4,'AccountingBalanceUpdatePeriodRange',1,2,'The period range to update the Trial Balance report calculated by a Mobex procedure.'),
(3,'AccountingYearCategoryType',1,2,'It is used to add account category records for each year.  This is needed in YTD calculations which rely on an account being a revenue/expense to determine whether to reset YTD values to 0 for every year. '),
(1,'AccountingAccount',1,2,'This is used to generate records in account_period_balance. Since the previous 12 months account_period_balance gets regenerated when a new period gets appended if the category type changes or an account gets added or removed the previous 12 months worth of records is affected.'),
(2,'Workcenter_Get',1,1,'This is where the labor cost per hour comes from.'),
(102,'CostGrossMarginDaily',1,1,'Contains sales quantity and price data.'),
(103,'CostModelsGet',1,1,'Used to determine the active cost model.'),
(104,'CostSubTypeBreakdownMatrix',1,1,'Used to determine the cost model material cost.'),
(105,'CustomerOrdersGet',1,1,'The customer orders.'),
(106,'CustomerPartsGet',1,1,'The customer part numbers.'),
(107,'DailyShiftReportGet',1,1,'Used to determine the parts produced and scrapped per day.'),
(108,'ItemUsageSummaryGet',1,1,'The item usage summary.'),
(109,'PartOperationGet',1,1,'Used to determine the shippable part operations.'),
(113,'WorkcentersGet',1,1,'Used to determine the labor cost per hour.')


-- drop table DataSource.datasource_datum
create table Datasource.datasource_datum
( 
	datasource_datum_key int not null,
	datasource_key int not null,
	name varchar(50)
	CONSTRAINT PK_datasource_datum PRIMARY KEY (datasource_datum_key)
)
select * from DataSource.datasource_datum
insert into DataSource.datasource_datum 
values 
--(1,2,'labor_cost_per_hour')  -- Workcenter_Get

select ds.name,dd.name 
from DataSource.datasource ds 
join DataSource.datasource_datum dd 
on ds.datasource_key = dd.datasource_key 

-- DROP TABLE mgdw.DataSource.datasource_script;
CREATE TABLE mgdw.DataSource.datasource_script (
	datasource_key int NOT NULL,
	script_key int NOT NULL,
	CONSTRAINT PK_datasource_script PRIMARY KEY (datasource_key,script_key)
);
-- truncate table Datasource.datasource_script 
insert into DataSource.datasource_script  
values 
--/* already inserted
(5,5),--'AccountingPeriod',1,2,'start and end period dates and fiscal order info. I think period in the distant future get added periodically.'),
(4,4),--'AccountingBalanceUpdatePeriodRange',1,2,'The period range to update the Trial Balance report calculated by a Mobex procedure.'),
(3,3),--'AccountingYearCategoryType',1,2,'It is used to add account category records for each year.  This is needed in YTD calculations which rely on an account being a revenue/expense to determine whether to reset YTD values to 0 for every year. '),
(1,1),--'AccountingAccount',1,2,'This is used to generate records in account_period_balance. Since the previous 12 months account_period_balance gets regenerated when a new period gets appended if the category type changes or an account gets added or removed the previous 12 months worth of records is affected.'),
(2,2),--'Workcenter_Get',1,1,'This is where the labor cost per hour comes from.'),
(102,102),--'CostGrossMarginDaily',1,1,'Contains sales quantity and price data.'),
(103,103),--'CostModelsGet',1,1,'Used to determine the active cost model.'),
(104,104),--'CostSubTypeBreakdownMatrix',1,1,'Used to determine the cost model material cost.'),
(105,105),--'CustomerOrdersGet',100,3),
(106,106),--'CustomerPartsGet',100,3),
(107,107),--'DailyShiftReportGet',1,1,'Used to determine the parts produced and scrapped per day.'),
(108,108),--'ItemUsageSummaryGet',100,3),
(109,109),--'PartOperationGet',1,1,'Used to determine the shippable part operations.'),
(113,113)--'WorkcentersGet',1,1,'Used to determine the labor cost per hour.')

--*/ 
select * from Datasource.datasource_script
select ds.name datasource 
--dd.name datum_name,
,s.name script,sch.schedule 
,p.name devop_project
,r.name repo
from DataSource.datasource ds 
join DataSource.datasource_script dsc 
on ds.datasource_key = dsc.datasource_key 
join ETL.script s
on dsc.script_key = s.script_key
join ETL.schedule sch
on s.schedule_key = sch.schedule_key 
--select r.name repo,p.name source_control_project  
join ETL.source_control_repo r 
on s.source_control_repo_key = r.source_control_repo_key  
join ETL.source_control_project p 
on r.source_control_project_key = p.source_control_project_key 

-- drop table DataSource.dw_server 
create table DataSource.dw_server   
( 
	dw_server_key int not null,
	name varchar(50) null,
	port int null,
	note varchar(max) null,
	CONSTRAINT PK_dw_server PRIMARY KEY (dw_server_key)
)

select * from DataSource.dw_server    
insert into DataSource.dw_server    
values 
--(1,'mgsqlmi.public.48d444e7f69b.database.windows.net',3342,'Azure SQL Managed Instance')
(2,'mgsqlsrv.database.windows.net',null,'Azure SQL Server')


-- drop table DataSource.dw_database
create table DataSource.dw_database  
( 
	dw_database_key int not null,
	dw_server_key int not null,
	name varchar(50) null,
	note varchar(max) null,
	CONSTRAINT PK_dw_database PRIMARY KEY (dw_database_key)
)

select * from DataSource.dw_database   
insert into DataSource.dw_database   
values 
(1,1,'mgdw','Mobex Global data warehouse')

-- drop table DataSource.dw_schema
create table DataSource.dw_schema  
( 
	dw_schema_key int not null,
	dw_database_key int not null,
	name varchar(50) null,
	note varchar(max) null,
	CONSTRAINT PK_dw_schema PRIMARY KEY (dw_schema_key)
)

select * from DataSource.dw_schema  
insert into DataSource.dw_schema  
values 
(1,1,'Plex','Plex ERP')

create table DataSource.dw_table  
( 
	dw_table_key int not null,
	dw_schema_key int not null,
	name varchar(50) null,
	note varchar(max) null,
	CONSTRAINT PK_dw_table PRIMARY KEY (dw_table_key)
)
insert into DataSource.dw_table 
values 
(1,1,'Workcenter','Workcenter' )--,

select dws.name dw_schema,dwt.name dw_table  
from DataSource.dw_schema dws
join DataSource.dw_table dwt 
on dws.dw_schema_key = dwt.dw_schema_key 

create table DataSource.dw_column  
( 
	dw_column_key int not null,
	dw_table_key int not null,
	name varchar(50) null,
	note varchar(max) null,
	CONSTRAINT PK_dw_column PRIMARY KEY (dw_column_key)
)
insert into DataSource.dw_column  
values 
(1,1,'Direct_Labor_Cost','Direct Labor Cost' )--,

select dws.name dw_schema,dwt.name dw_table,dwc.name dw_column 
from DataSource.dw_schema dws
join DataSource.dw_table dwt 
on dws.dw_schema_key = dwt.dw_schema_key 
join DataSource.dw_column dwc 
on dwt.dw_table_key = dwc.dw_table_key 


-- drop table DataSource.datasource_datum_column
-- truncate table DataSource.datasource_datum_column
create table Datasource.datasource_datum_column 
( 
	datasource_datum_column_key int not null,
	datasource_datum_key int not null,
	dw_column_key int not null,
	CONSTRAINT PK_datasource_datum_column PRIMARY KEY (datasource_datum_column_key)
)
select * from DataSource.datasource_datum_column 
insert into DataSource.datasource_datum_column  
values 
(1,1,1)  -- Workcenter_Get,'labor_cost_per_hour'

select ds.name datasource,dd.name datum_name
,dwc.name dw_column,dwt.name dw_table,dws.name dw_schema
,dwd.name dw_database,srv.name dw_server  
--,
from DataSource.datasource ds 
join DataSource.datasource_datum dd 
on ds.datasource_key = dd.datasource_key 
join DataSource.datasource_datum_column ddc 
on dd.datasource_datum_key = ddc.datasource_datum_key 
join DataSource.dw_column dwc 
on ddc.dw_column_key= dwc.dw_column_key  
join DataSource.dw_table dwt 
on dwc.dw_table_key = dwt.dw_table_key 
join DataSource.dw_schema dws 
on dwt.dw_schema_key = dws.dw_schema_key
join DataSource.dw_database dwd 
on dws.dw_database_key = dwd.dw_database_key 
join DataSource.dw_server srv 
on dwd.dw_server_key = srv.dw_server_key 

-- drop table DataSource.datasource_datum_column_issue
create table Datasource.datasource_datum_column_issue 
( 
	datasource_datum_column_issue_key int not null,
	datasource_datum_column_key int not null,
	name varchar(100) not null,
	descr varchar(max) not null,
	issue_view varchar(100) null,
	issue_severity_key int null,
	filter_issue tinyint not null,
	filter_regex varchar(100) null,
	highlight tinyint not null,
	highlight_color varchar(25) null,
	CONSTRAINT PK_datasource_datum_column_issue PRIMARY KEY (datasource_datum_column_issue_key)
)
insert into DataSource.datasource_datum_column_issue  
values 
(1,1,'no labor cost','no labor cost','Plex.workcenter_no_labor_rate',4,0,null,1,'red'),
(2,1,'Greater than 10% difference in labor cost per hour','Greater than 10% difference in labor cost per hour','Plex.labor_cost_percent_diff',4,0,null,1,'red')

select ds.name,dd.name datum_name
,dwc.name dw_column
,ddci.name dw_issue,ddci.highlight_color 
,sev.name severity
,dwt.name dw_table,dws.name dw_schema
--,dwd.name dw_database,srv.name dw_server  

--di.name issue_name,di.issue_view,di.filter_issue,
--di.filter_regex,di.highlight,di.highlight_color 
-- select count(*) 
from DataSource.datasource ds 
join DataSource.datasource_datum dd 
on ds.datasource_key = dd.datasource_key 
join DataSource.datasource_datum_column ddc 
on dd.datasource_datum_key = ddc.datasource_datum_key  
join DataSource.dw_column dwc 
on ddc.dw_column_key= dwc.dw_column_key  
join DataSource.dw_table dwt 
on dwc.dw_table_key = dwt.dw_table_key 
join DataSource.dw_schema dws 
on dwt.dw_schema_key = dws.dw_schema_key
join DataSource.dw_database dwd 
on dws.dw_database_key = dwd.dw_database_key 
join DataSource.dw_server srv 
on dwd.dw_server_key = srv.dw_server_key 
left outer join DataSource.datasource_datum_column_issue ddci 
on ddc.datasource_datum_column_key = ddci.datasource_datum_column_key  
left outer join DataSource.issue_severity sev   
on ddci.issue_severity_key = sev.issue_severity_key  
-- drop table DataSource.issue_severity
create table DataSource.issue_severity 
(
	issue_severity_key int,
	name varchar(100) not null,
	CONSTRAINT PK_issue_severity PRIMARY KEY (issue_severity_key)
)
select * from DataSource.issue_severity
insert into DataSource.issue_severity  
values 
(0,'ok'),
(1,'info'),
(2,'low'),
(3,'medium'),
(4,'high')

select ds.name,dd.name datum_name,
di.name issue_name,di.issue_view,di.filter_issue,
di.filter_regex,di.highlight,di.highlight_color,
isv.name issue_severity 
from DataSource.datasource ds 
join DataSource.datasource_datum dd 
on ds.datasource_key = dd.datasource_key 
join DataSource.datasource_datum_issue di 
on dd.datasource_datum_key = dd.datasource_datum_key  
join DataSource.issue_severity isv 
on di.issue_severity_key = isv.issue_severity_key 


/*
 * OLD SCHEMA START
 */

-- drop TABLE DataSource.datasource_plex_procedure
create table DataSource.datasource_plex_procedure
(  
	datasource_key int not null,
	plex_procedure_key int not null,
	CONSTRAINT PK_datasource_plex_procedure PRIMARY KEY (datasource_key,plex_procedure_key)
)
select * from DataSource.datasource_plex_procedure  
insert into DataSource.datasource_plex_procedure  
values 


-- drop TABLE DataSource.datasource_web_service
create table DataSource.datasource_web_service
(  
	datasource_key int not null,
	web_service_key int not null,
	CONSTRAINT PK_datasource_web_service PRIMARY KEY (datasource_key,web_service_key)
)
select * from DataSource.datasource_web_service  
insert into DataSource.datasource_web_service  
values 
(2,1)  --Workcenter_Get

-- drop TABLE DataSource.datasource_mobex_procedure
create table DataSource.datasource_mobex_procedure
(  
	datasource_key int not null,
	mobex_procedure_key int not null,
	CONSTRAINT PK_datasource_mobex_procedure PRIMARY KEY (datasource_key,mobex_procedure_key)
)
select * from DataSource.datasource_mobex_procedure  
insert into DataSource.datasource_mobex_procedure 
values 
(1,1),
(3,2),
(4,3)

-- drop table DataSource.mobex_procedure
create table DataSource.mobex_procedure 
( 
	mobex_procedure_key int primary key,
	system_name varchar(50),
	friendly_name varchar(100),
	source_control_repo_key int null,
)
select * from DataSource.mobex_procedure 
insert into DataSource.mobex_procedure 
values 
--(3,'sproc300758_11728751_1999565','accounting_balance_update_period_range_dw_import',2)
--(2,'sproc300758_11728751_1999909','accounting_year_category_type_dw_import',2)
--(1,'sproc300758_11728751_1978024','accounting_account_DW_Import',2)



-- drop table DataSource.data_warehouse 
create table DataSource.data_warehouse 
( 
	data_warehouse_key int primary key,
	dw_schema_key int null,
	object_type_key int null,
	name varchar(50) null,
)
select * from DataSource.data_warehouse 
insert into DataSource.data_warehouse 
values 
(4,1,1,'account_balance_update_period_range')
--(1,1,1,'accounting_account'),
--(2,1,1,'workcenter'),
--(3,1,2,'workcenter_view')

-- drop table DataSource.datasource_warehouse 
create table DataSource.datasource_warehouse 
( 
	datasource_warehouse_key int,
	datasource_key int not null,
	data_warehouse_key int not null,
	CONSTRAINT PK_datasource_warehouse PRIMARY KEY (datasource_key,data_warehouse_key)
)
select * from DataSource.datasource_warehouse 
insert into DataSource.datasource_warehouse
values 
(4,4,4),
(1,1,1),
(2,2,2),
(3,2,3)


-- drop table DataSource.web_service
create table DataSource.web_service 
( 
	web_service_key int,
	name varchar(50) null,
	datasource_key int null,
	soap_request varchar(max) null,
	source_control_repo_key int null,
	CONSTRAINT PK_web_service PRIMARY KEY (web_service_key)
)
select * from DataSource.web_service 
insert into DataSource.web_service 
values 
(1,'Workcenter_Get',4031,
'<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:dat="http://www.plexus-online.com/DataSource">
   <soap:Header />
   <soap:Body>
      <dat:ExecuteDataSource>
         <dat:ExecuteDataSourceRequest>
            <dat:DataSourceKey>4031</dat:DataSourceKey>
            <dat:InputParameters>
               <dat:InputParameter>
                  <dat:Value>$Active</dat:Value>
                  <dat:Name>Active</dat:Name>
               </dat:InputParameter >
            </dat:InputParameters>
         </dat:ExecuteDataSourceRequest>
      </dat:ExecuteDataSource>
   </soap:Body>
</soap:Envelope>
',3)




create table DataSource.datasource_type 
( 
	datasource_type_key int primary key,
	datasource_type varchar(50) null,
)
select * from DataSource.datasource_type 
insert into DataSource.datasource_type 
values 
(1,'web_service'),
(2,'mobex_procedure')

create table DataSource.dw_schema  
( 
	dw_schema_key int primary key,
	name varchar(50) null,
	note varchar(max) null,
)

select * from DataSource.dw_schema  
insert into DataSource.dw_schema  
values 
(1,'Plex','Plex ERP')
create table DataSource.object_type  
( 
	object_type_key int primary key,
	name varchar(50) null,
)
select * from DataSource.object_type  
insert into DataSource.object_type  
values 
(1,'table'),
(2,'view'),
(3,'procedure')

-- drop table DataSource.issue_type 
create table DataSource.issue_type 
(
	issue_type_key int primary key,
	name varchar(100) not null,
	issue_type_view varchar(100) null,
	issue_type_severity_key int null,
	filter_issue tinyint not null,
	filter_regex varchar(100) null,
	highlight tinyint not null,
	highlight_color varchar(25) null,
)
select * from DataSource.issue_type 
insert into DataSource.issue_type 
values 
(0,'valid','none',0,0,null,0,null),
(1,'no labor cost','Plex.workcenter_no_labor_rate',4,0,null,1,'red'),
(3,'Greater than 10% difference in labor cost per hour','Plex.labor_cost_percent_diff',4,0,null,1,'red')

create table DataSource.issue_type_severity 
(
	issue_type_severity_key int primary key,
	name varchar(100) not null,
	
)
select * from DataSource.issue_type_severity
insert into DataSource.issue_type_severity  
values 
(0,'ok')
(1,'info'),
(2,'low'),
(3,'medium'),
(4,'high')



select * from DataSource.datasource_view 
-- drop view DataSource.datasource_view 
create view DataSource.datasource_view 
as 
select
ds.name datasource_name,
--mp.friendly_name mobex_procedure,
--mpr.name mobex_procedure_repo,
--mpp.name mobex_project,
es.name etl_script, 
s.schedule, 
--esr.name etl_script_repo,
--esp.name etl_project
--ws.*,
--mp.*,
--dst.*,
--ob.*,
--sc.*,
dw.name dw_name
--dsw.*,
--bt.*,
--b.*,
--ds.*
from DataSource.datasource ds 
join DataSource.datasource_type dst 
on ds.datasource_type_key = dst.datasource_type_key 
join DataSource.base_source b 
on ds.base_source_key = b.base_source_key 
join DataSource.base_source_type bt
on b.base_source_type_key = bt.base_source_type_key 
join DataSource.datasource_warehouse dsw 
on ds.datasource_key = dsw.datasource_key 
join DataSource.data_warehouse dw 
on dsw.data_warehouse_key = dw.data_warehouse_key 
join DataSource.dw_schema sc 
on dw.dw_schema_key = sc.dw_schema_key 
join DataSource.object_type ob 
on dw.object_type_key = ob.object_type_key 
left outer join DataSource.mobex_procedure mp 
on ds.mobex_procedure_key = mp.mobex_procedure_key 
left outer join DataSource.web_service ws 
on ds.web_service_key = ws.web_service_key 
left outer join DataSource.etl_script es 
on ds.etl_script_key = es.elt_script_key  
left outer join DataSource.etl_script_type et 
on es.etl_script_type_key = et.etl_script_type_key 
left outer join ETL.schedule s 
on es.schedule_key = s.schedule_key 

left outer join DataSource.source_control_repo esr  
on es.source_control_repo_key = esr.source_control_repo_key  
left outer join DataSource.source_control_project esp   
on esr.source_control_project_key = esp.source_control_project_key  

left outer join DataSource.source_control_repo mpr  
on mp.source_control_repo_key = mpr.source_control_repo_key  
left outer join DataSource.source_control_project mpp   
on mpr.source_control_project_key = mpp.source_control_project_key  

(5,2,'AccountingPeriod',100,6),
(4,2,'AccountingBalanceUpdatePeriodRange',100,5),
(3,2,'AccountingYearCategoryType.dtsx',100,4),
(1,2,'AccountingAccount.dtsx',100,1),
(2,1,'Invoke-WorkcentersGet.ps1',100,3),

--/* already inserted
(102,1,'CostGrossMarginDaily',100,3),
(103,1,'CostModelsGet',100,3),
(104,1,'CostSubTypeBreakdownMatrix',100,3),
(105,1,'CustomerOrdersGet',100,3),
(106,1,'CustomerPartsGet',100,3),
(107,1,'DailyShiftReportGet',100,3),
(108,1,'ItemUsageSummaryGet',100,3),
(109,1,'PartOperationGet',100,3),
(110,1,'ReleasesGetDailyDue',100,3),
(111,1,'ReportShippingRevenue',100,3),
(112,1,'ShippersHistoryGet',100,3),
(113,1,'WorkcentersGet',100,3)

