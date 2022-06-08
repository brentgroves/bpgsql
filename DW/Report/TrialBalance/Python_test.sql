-- mgdw.Plex.accounting_account_year_category_type definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_account_year_category_type;

CREATE TABLE mgdw.Plex.accounting_account_year_category_type (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[year] int NULL,
	category_type varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	revenue_or_expense bit NULL,
	CONSTRAINT PK__accounti__3213E83FF126C7A5 PRIMARY KEY (id),
	CONSTRAINT UQ__accounti__22DAE7B5B1F76486 UNIQUE (pcn,account_no,[year])
);
CREATE UNIQUE NONCLUSTERED INDEX UQ__accounti__22DAE7B5B1F76486 ON mgdw.Plex.accounting_account_year_category_type (pcn, account_no, [year]);

-- truncate table Scratch.accounting_account_year_category_type
select *
--select count(*)
from Scratch.accounting_account_year_category_type  -- 8,285
where pcn in (123681,300758)
and [year] = 2022  -- 8,285

--insert into Scratch.accounting_account_year_category_type (pcn,account_no,[year],category_type,revenue_or_expense)
values(123681,10000-000-00000,2022,'Asset',0)

Scratch.accounting_account_year_category_type 

select * 
--into Scratch.accounting_account_year_category_type  -- 24,811
--select count(*)
from Plex.accounting_account_year_category_type
where pcn in (123681,300758)
and [year] = 2022  -- 8,285


CREATE TABLE mgdw.Scratch.accounting_account_06_03 (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20),
	account_name varchar(110),
	active bit NULL,
	category_type varchar(10),
	category_no_legacy int NULL,
	category_name_legacy varchar(50),
	category_type_legacy varchar(10),
	sub_category_no_legacy int,
	sub_category_name_legacy varchar(50),
	sub_category_type_legacy varchar(10),
	revenue_or_expense bit NULL,
	start_period int NULL,
	PRIMARY KEY (pcn,account_key)
);

select * 
--into Scratch.accounting_account_06_03
select count(*)
from Plex.accounting_account aa -- 19,286
where pcn in (123681) -- 4617
where account_key = 400825 

select * from ETL.Script s where script_key = 1
select * from ETL.Script_History sh where script_key = 1
order by end_time desc 
--truncate table Scratch.accounting_account_06_03
--delete from Scratch.accounting_account_06_03 where pcn in (99999)
select distinct(pcn) from Scratch.accounting_account_06_03
select count(*) from Scratch.accounting_account_06_03
--set @PCNList = '123681,300758,310507,306766,300757'
where pcn in (123681) -- 4,617
--insert into Scratch.accounting_account_06_03
values 
(123681,629753,'10000-000-00000','Cash - Comerica General',0,'Asset',0,'category-name-legacy','cattypeleg',0,'subcategory-name-legacy','subcattleg',0,201604)
--(123681,629753,"10000-000-00000","Cash - Comerica General",0,"Asset",0,"category-name-legacy","category-type-legacy",0,"subcategory-name-legacy","subcategory_type_legacy",0,201604)
select * 
--into Scratch.accounting_account_06_03
from Plex.accounting_account aa where account_key = 400825 