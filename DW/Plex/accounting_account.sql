/*
 * drop table Plex.accounting_account
create table Plex.accounting_account
(
	pcn int,
	account_key int,
	account_no	varchar (20),
	account_name	varchar (110),
	active bit,
	account_category_type	varchar (10),
	category_no int,
	category_name varchar(50),
	category_type varchar(10),
	category_type_in varchar(6),
	sub_category_no int,
	sub_category_name varchar(50),
	sub_category_type varchar(10),
	sub_category_type_in varchar(6),
	debit_balance bit,
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
select * 
--select count(*)
from Plex.accounting_account
where  
pcn = 123681 -- 4,362
and active = 1 --3,327
