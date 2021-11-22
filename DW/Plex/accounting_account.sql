/*
 * drop table Plex.accounting_account
create table Plex.accounting_account
(
	pcn int,
	account_key int,
	account_no	varchar (20),
	account_name	varchar (110),
	active bit,
	category_type	varchar (10),
	category_type_in varchar(6),
	category_no_legacy int,
	category_name_legacy varchar(50),
	category_type_legacy varchar(10),
	category_type_in_legacy varchar(6),
	sub_category_no_legacy int,
	sub_category_name_legacy varchar(50),
	sub_category_type_legacy varchar(10),
	sub_category_type_in_legacy varchar(6),
	debit_balance smallint,
	debit_balance_legacy smallint,
	low_account bit,
	start_period int,
	PRIMARY KEY CLUSTERED
	(
	   PCN,account_key 
	)
)	
Param 
@PCNList varchar(max) = '123681,300758'
*/

/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681 / Southfield
2	295932 FruitPort
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
	*/
select account_no,account_name,active,category_type old_category_type, account_category_type new_category_type 
--select count(*)
from Plex.accounting_account 
where pcn = 123681  -- 4362
--and account_category_type = category_type -- 4,199
and account_category_type != category_type -- 163
and category_type = ''
--and category_type != ''

--where account_no like '27800-000%'
--where category_type_in = 'Debit'  -- 3,998
--and debit_balance = 1 -- 3,998
--where category_type_in = 'Credit'  -- 206
--and debit_balance = 0 -- 206
where  
pcn = 123681 -- 4,362
and active = 1 --3,327
-- select * from Plex.account_balance where [no] like '27800-000%' and period = 201812 -- odd 27800-000-9806
-- select distinct pcn,period from Plex.account_balance where [no] like '27800-000%' and period = 201812 -- odd 27800-000-9806


