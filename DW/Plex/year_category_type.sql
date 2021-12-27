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
select pcn,account_no,2020,category_type,revenue_or_expense 
--select distinct pcn,[year]
--select count(*)  
from Plex.accounting_account_year_category_type 
where pcn = 123681  -- 4363,8726

u