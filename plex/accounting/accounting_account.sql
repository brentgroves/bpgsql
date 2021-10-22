/*
create table Plex.accounting_account
(
pcn int,
account_key int,
Account_No	varchar (20),
Account_Name	varchar (110),
Category_Type	varchar (10),
  PRIMARY KEY CLUSTERED
  (
    PCN,period,account_no
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
/*
create PCN table from param
*/
create table #list
(
 tuple int
)
declare @delimiter varchar(1)
set @delimiter = ','
declare @in_string varchar(max)
set @in_string = @PCNList
WHILE LEN(@in_string) > 0
BEGIN
    INSERT INTO #list
    SELECT cast(left(@in_string, charindex(@delimiter, @in_string+',') -1) as int) as tuple

    SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
end
--select tuple from #list
select 
plexus_customer_no pcn,
account_key,
account_no,
account_name,
--active,
category_type
-- select count(*)
from accounting_v_account_e  a -- 36,636
--where a.plexus_customer_no = 123681  -- 4362
where a.plexus_customer_no in
(
 select tuple from #list
)
and a.active= 1 -- 3327

/*
-- There is not a 1 to 1 relationship here
left outer join accounting_v_category_account_e ca 
on a.plexus_customer_no=ca.plexus_customer_no
and a.account_no=ca.account_no -- 36,636
where ca.account_no is null  -- 32422
*/
