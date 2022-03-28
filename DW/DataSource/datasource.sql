
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

-- drop table DataSource.datasource
create table DataSource.datasource
(
	datasource_key int PRIMARY KEY,
	name varchar(100) not null,	
	base_source_key int not null,
	datasource_type_key int null,
	web_service_key int null,
	mobex_procedure_key int null,
	plex_procedure_key int null,
	etl_script_key int null,
	note varchar(max) null

)
select * from DataSource.datasource 
-- truncate table DataSource.datasource 
insert into DataSource.datasource 
values 
--(1,'AccountingAccount',1,2,null,1,null,1,'This is used to generate records in account_period_balance. Since the previous 12 months account_period_balance gets regenerated when a new period gets appended if the category type changes or an account gets added or removed the previous 12 months worth of records is affected.'),
(2,'Workcenter_Get',1,1,1,null,null,2,'This is where the labor cost per hour comes from.')
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
--(1,1,1,'accounting_account'),
(2,1,1,'workcenter'),
(3,1,2,'workcenter_view')

create table DataSource.datasource_warehouse 
( 
	datasource_warehouse_key int primary key,
	datasource_key int not null,
	data_warehouse_key int not null,
)
select * from DataSource.datasource_warehouse 
insert into DataSource.datasource_warehouse
values 
--(1,1,1),
(2,2,2),
(3,2,3)


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
(1,'sproc300758_11728751_1978024','accounting_account_DW_Import',2)




-- drop table DataSource.web_service
create table DataSource.web_service 
( 
	web_service_key int,
	name varchar(50) null,
	datasource_key int null,
	soap_request varchar(max) null,
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
')
-- drop table DataSource.etl_script 
create table DataSource.etl_script 
(
	elt_script_key int primary key,
	etl_script_type_key int null, 
	name varchar(100) null,
	schedule_key int null,
	source_control_repo_key int null,
	
)
select * from DataSource.etl_script 
-- truncate table DataSource.etl_script 
insert into DataSource.etl_script 
values
(1,2,'AccountingAccount.dstx',100,1),
(2,1,'Invoke-WorkcentersGet.ps1',100,1)


create table DataSource.etl_script_type  
(
	etl_script_type_key int PRIMARY KEY,
	script_type varchar(50) null,
)
select * from DataSource.etl_script_type
insert into DataSource.etl_script_type 
values 
(1,'powershell'),
(2,'ssis')

create table DataSource.source_control_repo  
(
	source_control_repo_key int primary key,
	source_control_project_key int not null,
	name varchar(100) not null,
)
select * from DataSource.source_control_repo
insert into DataSource.source_control_repo  
values 
--(1,1,'AccountingAccount'),
--(2,2,'MobexSQL'),
(3,1,'PlexETLScripts')

create table DataSource.source_control_project 
(
	source_control_project_key int primary key,
	name varchar(100) not null,
)
select * from DataSource.source_control_project
insert into DataSource.source_control_project 
values 
--(1,'PlexETLScripts'),
(2,'MobexSQL')

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

