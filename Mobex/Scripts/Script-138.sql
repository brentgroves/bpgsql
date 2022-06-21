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

--truncate table Scratch.accounting_account_06_03
select * from Scratch.accounting_account_06_03
select count(*) from Scratch.accounting_account_06_03
where pcn in (123681) -- 4,617
--insert into Scratch.accounting_account_06_03
values 
(123681,629753,'10000-000-00000','Cash - Comerica General',0,'Asset',0,'category-name-legacy','cattypeleg',0,'subcategory-name-legacy','subcattleg',0,201604)
--(123681,629753,"10000-000-00000","Cash - Comerica General",0,"Asset",0,"category-name-legacy","category-type-legacy",0,"subcategory-name-legacy","subcategory_type_legacy",0,201604)
select * 
--into Scratch.accounting_account_06_03
from Plex.accounting_account aa where account_key = 400825 