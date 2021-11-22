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
--select @Period_Min period_min,@Period_Max period_max
DECLARE @PCN_Currency_Code CHAR(3);
set @PCN_Currency_Code = 'USD';
-- select @PCN_Currency_Code
/*
pcn,account_key,account_no,account_name,active,
category_type,category_type_in,
category_no_legacy,category_name_legacy,category_type_legacy,category_type_in_legacy,
sub_category_no_legacy,sub_category_name_legacy,sub_category_type_legacy,sub_category_type_in_legacy,
debit_balance,debit_balance_legacy,
low_account,start_period
*/
DECLARE @account TABLE
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
	debit_balance int,
	debit_balance_legacy int,
	low_account bit,
	start_period int,
	PRIMARY KEY CLUSTERED
	(
	   PCN,account_key 
	)
)
INSERT INTO @account       
-- accounting_account_DW_Import
exec sproc300758_11728751_1978024 @PCNList;  -- cant call from cte

--select * from @account
-- @PCNList varchar(max) = '123681,300758',
--select count(*) from @account; -- 4362/all;7775

with account_balance
as 
(
  select b.plexus_customer_no pcn,b.account_key,b.account_no,
  --a.start_period,
  b.period,
  b.debit,b.credit,
  case 
  when a.debit_balance=1 then b.debit-b.credit 
  else b.credit-b.debit
  end balance,
  case 
  when a.debit_balance_legacy=1 then b.debit-b.credit 
  else b.credit-b.debit
  end balance_legacy
  --select *
  from accounting_v_balance_e b  -- 263:all, 45 : <4 and in same period
  join @account a  
  on b.plexus_customer_no=a.pcn
  and b.account_key=a.account_key
  --and b.account_no=a.account_no
  and b.period between @Period_Start and @Period_End
)
--select count(*) from account_balance  -- 40698
select * from account_balance
--where account_no like '27800-000%'  -- debit balance/old debit_balance diff 27800-000-9806
--and period = 201812
--order by pcn,period,account_no

