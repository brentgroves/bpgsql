--drop table Plex.accounting_account_year_category_type 
create table Plex.accounting_account_year_category_type 
(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	pcn int,
	account_no varchar(20),
	[year] int,
	category_type varchar(10),
	revenue_or_expense bit,
	UNIQUE (pcn,account_no,[year])
)
--insert into Plex.accounting_account_year_category_type 
select pcn,account_no,2021,category_type,revenue_or_expense 
-- select *
--select distinct pcn,[year]
--select count(*)  
--into Archive.accounting_account_year_category_type_01_07_2021 -- 8726
from Plex.accounting_account_year_category_type -- 24,723
where pcn = 123681  -- 13,785
and [year] = 2022 -- 4,595

/*
 * Insert prev year account category records from current years values
 * There was some account category changes in 2021 so some account categories
 * in 2020 are probably not the actual values they had in 2020.
 * Remember this incase any ytd calculations are being made.  
 */ 

--delete from Plex.accounting_account_year_category_type 
--where [year] < 2022

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