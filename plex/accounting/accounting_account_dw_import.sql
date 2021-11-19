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
end
--select tuple from #list
select 
a.plexus_customer_no pcn,
a.account_key,
a.account_no,
a.account_name,
a.active,
a.category_type,
--t.[in],
case
when t.[in] = 'Debit' then 1
else 0
end debit_main,
case
when left(a.account_no,1) in (1,2,3) then 1
else 0
end left_digit_123
-- select count(*)
from accounting_v_account_e  a -- 36,636
-- select * from accounting_v_category_type
/*
asset/equity/expense/liability/revenue
Assets naturally have debit balances, so they should normally appear as positive numbers
Liabilities and Equity naturally have credit balances, so would normally appear as negative numbers
Revenue accounts naturally have credit balances, so normally these would be negative
Expense accounts naturally have debit balances, so normally would be positive numbers
there are exceptions in every category for a variety of reasons (of course)
*/

join accounting_v_category_type t 
on a.category_type=t.category_type
--where a.plexus_customer_no = 123681  -- 4362
where a.plexus_customer_no in
(
 select tuple from #list
)
--and a.account_no like '27800-000%'
-- and a.active is null  --0
-- and a.active= 1 -- 3327

/*
select 
a.plexus_customer_no pcn,
a.account_key,
a.account_no,
a.account_name,
a.active,
a.category_type account_category_type,  --  Trial balance report does not use this type go through category_account->category->category_type
case 
when c.plexus_customer_no is null then 0
else c.category_no
end category_no,
case
when c.plexus_customer_no is null then ''
else c.category_name
end category_name,
case
when t.category_type is null then ''
else t.category_type 
end category_type,
case
when t.category_type is null then ''
else t.[in] 
end category_type_in,
case
when sc.plexus_customer_no is null then 0
else sc.sub_category_no
end sub_category_no,
case
when c2.plexus_customer_no is null then ''
else c2.category_name 
end sub_category_name,
case
when t2.category_type is null then ''
else t2.category_type 
end sub_category_type,
case
when t2.category_type is null then ''
else t2.[in] 
end sub_category_type_in,
case
when t.[in] is null then -1
when t.[in] = 'Debit' then 1
else 0
end debit_balance,
case
when left(a.account_no,1) in (1,2,3) then 1
else 0
end left_digit_123
--ca.*,
--ca.category_name,
--b.*,
--sa.*,
--cc.*,
--t.*,
--a.*
-- select count(*)
from accounting_v_account_e  a -- 36,636
--where a.plexus_customer_no=123681  -- 4362 
--join accounting_v_category_type t -- DONT DO THIS
--on a.category_type=t.category_type
join accounting_v_category_account_e ca  --
on a.plexus_customer_no=ca.plexus_customer_no
and a.account_no=ca.account_no
--where a.plexus_customer_no=123681  -- 4204

join accounting_v_category_e c  --
on ca.plexus_customer_no=c.plexus_customer_no
and ca.category_no=c.category_no
join accounting_v_category_type t 
on c.category_type=t.category_type
--where a.plexus_customer_no=123681  -- 4204


join accounting_v_sub_category_account_e sca  --
on a.plexus_customer_no=sca.plexus_customer_no
and a.account_no=sca.account_no
join accounting_v_sub_category_e sc  --
on sca.plexus_customer_no=sc.plexus_customer_no
and sca.sub_category_no=sc.sub_category_no
join accounting_v_category_e c2  --
on sc.plexus_customer_no=c2.plexus_customer_no
and sc.category_no=c2.category_no
join accounting_v_category_type t2 
on c2.category_type=t2.category_type


where a.plexus_customer_no=123681  -- 4204
--and a.account_no like '27800-000%'
--and t.[in] = t2.[in]  -- 4204
and t.[in] != t2.[in]  -- 0
--join accounting_v_base_e b 
--on a.plexus_customer_no=b.plexus_customer_no
--and a.base_no=b.base_no
--select distinct category_type from accounting_v_category_e where plexus_customer_no=123681
--select * from accounting_v_category_e where plexus_customer_no=123681 and category_type='asset'
-- select * from accounting_v_project_type_e -- 0 records.
-- select * from accounting_v_Allocation_To_Account_e	o records
--select * from  accounting_v_consolidation_account_e 0 
left outer join accounting_v_standard_account_e sa  --no record
on a.plexus_customer_no=sa.pcn
and a.account_no=sa.account_no
join accounting_v_cost_center_e cc 
on a.plexus_customer_no=cc.plexus_customer_no
and a.cost_center_no=cc.cost_center_no -- 36,636
where a.plexus_customer_no=123681
and a.account_no like '27800-000%'
*/