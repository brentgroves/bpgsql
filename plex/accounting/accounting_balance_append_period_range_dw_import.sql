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
-- exec accounting_balance_update_period_range_dw_import
--select * from @pcn_period_range

declare @accounting_balance TABLE
(
	pcn int,
	account_key int,
	account_no varchar(20),
	period int,
--	tb_period int,
	debit decimal(19,5),
	credit decimal(19,5),
	balance decimal(19,5)
--	PRIMARY KEY (pcn,account_key,period)
);
--exec sproc300758_11728751_1992030 cast(@pcn as varchar),@period_start,@period_end

  declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from @pcn_period_range
	declare @id int;
	set @id=@start_id;
	--select @start_id start_id,@end_id end_id,@id id

	declare @pcn int;
	declare @string_pcn varchar(6);
	declare @period_start int;
	declare @period_end int;
	
--	select @period_start=202109,@period_end=202112,@pcn=123681
--	set @string_pcn = cast(@pcn as varchar);
	--select @pcn,@string_pcn,@period_start,@period_end

--		select @pcn=pcn,@string_pcn=cast(@pcn as varchar),@period_start=period_start,@period_end=period_end from @pcn_period_range where id = 1;
--		select N'pcn=' + @string_pcn + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6));
--		select @pcn=pcn,@string_pcn=cast(@pcn as varchar),@period_start=period_start,@period_end=period_end from @pcn_period_range where id = 2;
--		select N'pcn=' + @string_pcn + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6));


	
	--	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = 4
	while @id <=@end_id
	begin
		select @pcn=pcn,@string_pcn=cast(@pcn as varchar),@period_start=period_start,@period_end=period_end from @pcn_period_range where id = @id;
--		select N'pcn=' + @string_pcn + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6));
-- /*
    with accounting_balance
    as 
    (
      select b.plexus_customer_no pcn,b.account_key,b.account_no,
      --a.start_period,
      b.period,
--      case
  --      when b.plexus_customer_no in (300578) then cast(left(p.period_display,4) + right(p.period_display,2) as int)
    --    when b.plexus_customer_no in (123681) then cast(right(p.period_display,4) + left(p.period_display,2) as int) 
      --end tb_period,
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
    
      --select distinct b.plexus_customer_no,p.period_display
      from accounting_v_balance_e b  -- 263:all, 45 : <4 and in same period
      join accounting_v_period_e p -- 150,164
      on  b.plexus_customer_no=p.plexus_customer_no
      and b.period=p.period
--      where b.plexus_customer_no = 300758
--      order by b.plexus_customer_no,p.period_display
      join @account a  
      on b.plexus_customer_no=a.pcn
      and b.account_key=a.account_key
      --and b.account_no=a.account_no
      where b.plexus_customer_no=@pcn
      and b.period between @period_start and @period_end
      -- In Albion there was a 202201 balance record but no 202112 and 
      -- I decided to include 202201 although we were only in December
      -- for no particular reason.
    )
    --select pcn,account_key,account_no,period,tb_period from accounting_balance;  -- 40698/783
    --select count(*) from accounting_balance;  -- 40698/783
    insert into @accounting_balance
    	select * from accounting_balance
--    		*/
--    select count(*) from @accounting_balance			
		--select distinct pcn,period from Archive.accounting_balance order by pcn,period
--		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end; 
select * from @accounting_balance
--select count(*) from @accounting_balance
--where pcn=300758;  -- 123681=2742, 300758=3938 , both=6680 @PCNList varchar(max) = '123681,300758'

/*
-- how many balance records in the period range?
select count(*) cnt
from accounting_v_balance_e b  -- 263:all, 45 : <4 and in same period
join accounting_v_period_e p -- 150,164
on  b.plexus_customer_no=p.plexus_customer_no
and b.period=p.period
where b.plexus_customer_no=123681 -- 2742
--and b.period = 202111  --256
where b.plexus_customer_no=300758 -- 3938
and b.period between 202102 and 202112 
*/
 

/*
select pcn,account_key,period,count(*)
from 
(
select distinct pcn,account_key,period from @accounting_balance  --order by pcn,period-- 2963
) b 
group by pcn,account_key,period
having count(*) > 1

*/

--select distinct pcn,period from @accounting_balance  order by pcn,period-- 2963
select * from @accounting_balance  order by pcn,period,account_no-- 2963
--select * from @accounting_balance where period is null
-- @PCNList varchar(max) = '123681,300758'
--where period = 202111  --256
--where period = 202112  --0

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