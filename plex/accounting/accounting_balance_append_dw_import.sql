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
	category_no_legacy int,
	category_name_legacy varchar(50),
	category_type_legacy varchar(10),
	sub_category_no_legacy int,
	sub_category_name_legacy varchar(50),
	sub_category_type_legacy varchar(10),
	revenue_or_expense smallint,
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

DECLARE @pcn_period_range TABLE
(
	id int IDENTITY(1,1) NOT NULL,
	pcn int,
	period_start int,
	period_end int
)
insert into @pcn_period_range
exec sproc300758_11728751_1999565 @PCNList;
--select * from @pcn_period_range

	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from @pcn_period_range
	declare @id int;
	set @id=@start_id;
--	select @start_id start_id,@end_id end_id,@id id
	-- select * from Plex.accounting_balance_update_period_range
	declare @pcn int;
	declare @period_start int;
	declare @period_end int;
	--	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = 4
	while @id <=@end_id
	begin
		select @pcn=pcn,@period_start=period_start,@period_end=period_end from @pcn_period_range where id = @id
		select N'pcn=' + cast(@pcn as varchar(6)) + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6))
		--select distinct pcn,period from Archive.accounting_balance order by pcn,period
--		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end; 

with account_balance
as 
(

  select b.plexus_customer_no pcn,b.account_key,b.account_no,
  --a.start_period,
  b.period,
  cast(right(p.period_display,4) + left(p.period_display,2) as int) tb_period,
  b.debit,b.credit,
  b.debit-b.credit balance
 --THIS IS WRONG YOU ALWAY TAKE p.current_debit-p.current_credit
--   case 
--  when a.debit_balance=1 then b.debit-b.credit 
--  when a.debit_balance=0 then b.credit-b.debit 
--  else 9999999999
--  end balance,
--  case 
--  when a.debit_balance_legacy=1 then b.debit-b.credit 
--  when a.debit_balance_legacy=0 then b.credit-b.debit 
--  else -1.00
--  end balance_legacy

  --select *
  from accounting_v_balance_e b  -- 263:all, 45 : <4 and in same period
  join accounting_v_period_e p -- 150,164
  on  b.plexus_customer_no=p.plexus_customer_no
  and b.period=p.period
  join @account a  
  on b.plexus_customer_no=a.pcn
  and b.account_key=a.account_key
  --and b.account_no=a.account_no
  and b.period between @Period_Start and @Period_End
)
--select count(*) from account_balance  -- 40698
select * from account_balance
--where period = 202111  --256
--where period = 202112  --0

/*
select distinct period,add_date,update_date
--select *
--select count(*)
from accounting_v_balance_e b  -- 263:all, 45 : <4 and in same period
where b.plexus_customer_no = 123681
--order by period
and period = 202001  --256
where period = 202111  --256
where period = 202112  --0

select distinct period
from accounting_v_balance_e b
where b.plexus_customer_no = 123681
order by b.period
*/
--select distinct period_status
--select *
--from accounting_v_period_e p
--where p.plexus_customer_no = 123681
--and period in (202110,202111,202112)  --3
--and period = 201812  --8
--order by pcn,period,account_no

/*
-- mgdw.Plex.accounting_balance definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance;

CREATE TABLE mgdw.Plex.accounting_balance (
	pcn int,
	account_key int,
	account_no varchar(20),
	period int,
	debit decimal(19,5),
	credit decimal(19,5),
	balance decimal(19,5),
	PRIMARY KEY (pcn,account_key,period)
);
*/