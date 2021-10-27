/*
 * drop table Plex.accounting_account
create table Plex.accounting_account
(
pcn int,
account_key int,  -- identity
Account_No	varchar (20),
Account_Name	varchar (110),
active bit,
Category_Type	varchar (10),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_no 
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
select count(*)
from Plex.accounting_account
where  
pcn = 123681 -- 4,362
and active = 1 --3,327
