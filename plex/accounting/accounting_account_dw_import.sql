/*
create table Plex.accounting_account
(
pcn int,
account_key int,
Account_No	varchar (20),
Account_Name	varchar (110),
active bit,
Category_Type	varchar (10),
debit_main bit,
first_digit_123 bit
)
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
end;
--select tuple from #list

WITH account_balance (pcn,account_key,account_no,period)
as
(
	select plexus_customer_no pcn,account_key,account_no,period
	from accounting_v_balance_e b
  where b.plexus_customer_no in
  (
   select tuple from #list
  )
),
--select count(*) from account_balance  -- 52,140
--select * from account_balance
account_balance_start (pcn,account_key,account_no,start_period)
as
(
	select pcn,account_key,account_no,min(period) start_period
	from account_balance b
	group by b.pcn,b.account_key,b.account_no 	
),
--select count(*) from account_balance_start   -- 2131
--select * from account_balance_start 
--where pcn=123681  -- 4204
--and account_no like '27800-000%'
--and t.[in] = t2.[in]  -- 4204
--and t.[in] != t2.[in]  -- 0
account
(
pcn,account_key,account_no,account_name,active,
category_type,category_type_in,
category_no_legacy,category_name_legacy,category_type_legacy,category_type_in_legacy,
sub_category_no_legacy,sub_category_name_legacy,sub_category_type_legacy,sub_category_type_in_legacy,
debit_balance,debit_balance_legacy,
low_account,start_period
)

as
(
select 
a.plexus_customer_no pcn,a.account_key,a.account_no,a.account_name,a.active,
a.category_type category_type,  --  This is new way of identifying the category type.  The old method used the following views category_account->category->category_type
-- The Trial balance report uses the old method of determining the category type.
act.[in] category_type_in,--  This is new way of identifying the category type.  The old method used the following views category_account->category->category_type
case 
when c.plexus_customer_no is null then 0
else c.category_no
end category_no_legacy, -- legacy method of categorizing accounts
case
when c.plexus_customer_no is null then ''
else c.category_name
end category_name_legacy, -- legacy method of categorizing accounts
case
when t.category_type is null then ''
else t.category_type 
end category_type_legacy, -- legacy method of categorizing accounts
case
when t.category_type is null then ''
else t.[in] 
end category_type_in_legacy, -- legacy method of categorizing accounts
case
when sc.sub_category_no is null then 0
else sc.sub_category_no
end sub_category_no_legacy, -- legacy method of categorizing accounts
case
when c2.category_name is null then ''
else c2.category_name 
end sub_category_name_legacy, -- legacy method of categorizing accounts
case
when t2.category_type is null then ''
else t2.category_type 
end sub_category_type_legacy, -- legacy method of categorizing accounts
case
when t2.category_type is null then ''
else t2.[in] 
end sub_category_type_in_legacy, -- legacy method of categorizing accounts 
-- select distinct [in] from accounting_v_category_type -- Credit/Debit
-- select count(*) from accounting_v_category_type where [in] = 'Credit' -- 3
-- select count(*) from accounting_v_category_type where [in] = 'Debit' -- 2
case
when act.[in] = 'Debit' then 1
when act.[in] = 'Credit' then 0
when ((act.[in] is null) or (act.[in] = '')) then -1  -- should never happen
end debit_balance,
case
when t.[in] = 'Debit' then 1
when t.[in] = 'Credit' then 0
when ((t.[in] is null) or (t.[in] = '')) then -1 
end debit_balance_legacy,  -- old way of categorizing accounts.
case
when left(a.account_no,1) in (1,2,3) then 1
else 0
end low_account,
case 
when b.pcn is null then 0 
else b.start_period 
end start_period
--ca.*,
--ca.category_name,
--b.*,
--sa.*,
--cc.*,
--t.*,
--a.*
-- select count(*)
--select *
from accounting_v_account_e  a -- 36,636
--where a.plexus_customer_no=123681  -- 4362 
join accounting_v_category_type act -- This is the value used by the new method of configuring plex accounts. 
on a.category_type=act.category_type  -- 36,636

-- Category numbers linked to an account by the a category_account record will no longer be supported by Plex
left outer join accounting_v_category_account_e ca  --
on a.plexus_customer_no=ca.plexus_customer_no
and a.account_no=ca.account_no
--where a.plexus_customer_no=123681  -- 4204
left outer join accounting_v_category_e c  --
on ca.plexus_customer_no=c.plexus_customer_no
and ca.category_no=c.category_no
left outer join accounting_v_category_type t -- This is the value used by the old method of configuring plex accounts. 
on c.category_type=t.category_type
--where a.plexus_customer_no=123681  -- 4204
--and t.[in] = 'Debit' -- 3998
--and t.[in] = 'Credit' -- 206

-- sub category numbers linked to an account by the sub category_account record will no longer be supported by Plex
left outer join accounting_v_sub_category_account_e sca  --
on a.plexus_customer_no=sca.plexus_customer_no
and a.account_no=sca.account_no
left outer join accounting_v_sub_category_e sc  --
on sca.plexus_customer_no=sc.plexus_customer_no
and sca.sub_category_no=sc.sub_category_no
left outer join accounting_v_category_e c2  --
on sc.plexus_customer_no=c2.plexus_customer_no
and sc.category_no=c2.category_no
left outer join accounting_v_category_type t2 -- This is another value used by the old method of configuring plex accounts. 
on c2.category_type=t2.category_type

left outer join account_balance_start b 
on a.plexus_customer_no = b.pcn
and a.account_key=b.account_key

where a.plexus_customer_no in
(
 select tuple from #list
)
)
-- ALL TESTS WITH PCN=123681
--select count(*) from account   -- 4362 -- albion+edon:7775
--where start_period !=0 -- 1323 -- albion+edon:2131
--where start_period =0 -- 3039 -- albion+edon:5644
--select count(*) from account_ext where debit_balance =1 -- 4083=7289-- albion+edon:486
--select count(*) from account_ext where debit_balance =0 --279=4362-- albion+edon:486
--select b.period,b.debit,b.credit, a.*
/*
select count(*)
from account_ext a 
join accounting_v_balance_e b
on a.pcn=b.plexus_customer_no
and a.account_key=b.account_key -- 40700 
where a.debit_balance in (1,0)  --40700
*/
--select start_period,* from account where start_period !=0
--select * from account where debit_balance = -1  -- 0 
--select * from account where debit_balance_legacy = -1 -- 158
--select * from account where debit_balance != debit_balance_legacy  -- 0 
--and debit_balance_legacy !=-1
select * from account 
/*
asset/equity/expense/liability/revenue
Assets naturally have debit balances, so they should normally appear as positive numbers
Liabilities and Equity naturally have credit balances, so would normally appear as negative numbers
Revenue accounts naturally have credit balances, so normally these would be negative
Expense accounts naturally have debit balances, so normally would be positive numbers
there are exceptions in every category for a variety of reasons (of course)
--and a.account_no like '27800-000%'

@PCNList varchar(max) = '123681,300758'
*/

