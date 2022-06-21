
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
-- drop table DataSource.datasource
create table DataSource.datasource
(
	datasource_key int PRIMARY KEY,
	datasource_type int null,
	etl_script_key int null,
	web_service_key int null,
	mobex_procedure_key int null,
	plex_procedure_key int null,
)
select * from DataSource.datasource 
-- truncate table DataSource.datasource 
insert into DataSource.datasource 
values 
(1,2,1,null,1,null)

-- drop table DataSource.data_warehouse 
create table DataSource.data_warehouse 
( 
	data_warehouse_key int primary key,
	dw_schema_key int null,
	object_type int null,
	name varchar(50) null,
)
select * from DataSource.data_warehouse 
insert into DataSource.data_warehouse 
values 
(1,1,1,'accounting_account')

create table DataSource.datasource_warehouse 
( 
	datasource_warehouse_key int primary key,
	datasource_key int not null,
	data_warehouse_key int not null,
)
select * from DataSource.datasource_warehouse 
insert into DataSource.datasource_warehouse
values 
(1,1,1)


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
)
select * from DataSource.mobex_procedure 
insert into DataSource.mobex_procedure 
values 
(1,'sproc300758_11728751_1978024','accounting_account_DW_Import')

-- drop table DataSource.web_service
create table DataSource.web_service 
( 
	web_service_key int,
	name varchar(50) null,
	soap_request varchar(max) null,
	datasource_key int null,
	
)
select * from DataSource.web_service 

create table DataSource.etl_script 
(
	elt_script_key int primary key,
	etl_script_type_key int null, 
	etl_script varchar(100) null,
)
select * from DataSource.etl_script 
-- truncate table DataSource.etl_script 
insert into DataSource.etl_script 
values
(1,2,'AccountingAccount')

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