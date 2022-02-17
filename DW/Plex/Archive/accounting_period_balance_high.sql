
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
CHANGE THIS AND LOW TO WORK WITH NEW Plex.accounting_account 



--drop view Plex.accounting_period_balance_high
	create view Plex.accounting_period_balance_high(period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
	as
	WITH account ()
	as 
	(
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    202101 period
		--select count(*) cnt
	    --select *
		from Plex.accounting_account a  -- high: 3,701 * 10 = 37,010 /// all: 4,362 X 10 = 43,620
		
		where pcn = 123681
		and a.low_account = 0
		union 
		
	)
	
	account_period (pcn,account_key,account_no,period)
	AS
	(
	    -- Anchor member
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    202101 period
		--select count(*) cnt
	    --select *
		from Plex.accounting_account a  -- high: 3,701 * 10 = 37,010 /// all: 4,362 X 10 = 43,620
		
		where pcn = 123681
		and a.low_account = 0
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Starting at 202101 make a period account record for each period upto 202110.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
	    p.period+1  -- this is ok if we do not want to include periods for multiple years.
	    from account_period p
	    where p.period < 202110
	),
--	select count(*) from account_period -- high:37,010 all:43,620
--	select * from account_period
	account_period_balance( pcn,account_key,account_no,period,debit,credit,balance)
	as 
	(
		select a.pcn,a.account_key,a.account_no,a.period,
		case 
		when b.pcn is null then 0 
		else b.debit 
		end debit,
		case 
		when b.pcn is null then 0 
		else b.credit 
		end credit,
		case 
		when b.pcn is null then 0 
		else b.balance 
		end balance
		-- if it exists join the balance record to each period account.
		--SELECT count(*)
		FROM   account_period a -- 198,110
		left outer join Plex.accounting_balance b
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	),
	-- select * from Plex.accounting_balance b
		-- references expression name
		--select *
	--	SELECT count(*) FROM   account_period_balance;  -- 37,010
	--select count(*) from Plex.accounting_period_balance_high  -- 37,010
	--select * from Plex.accounting_period_balance_high  -- 37,010
	--where account_no = '41100-000-0000'
	/*
select * 
--select count(*)
from Plex.accounting_account
where  
pcn = 123681 -- 4,362
select * from Plex.accounting_balance
	 */
calc_ytd_high (period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
AS
(
    -- Anchor member
    select 
    period,
    account_no, 
    debit,
    debit as ytd_debit,
    credit,
    credit as ytd_credit,
    balance,
    balance as ytd_balance
    --select count(*)
	from account_period_balance
	--where period between 202101 and 202102
	where period = 202101
	--and debit > 0
	--and account_no = '41100-000-0000'
	--and left(account_no,1) < '7' --1,886
    UNION ALL
    -- join each calc_ytd_high record to the next account_period_balance record to
    -- add the previous credit,debit, and balance ytd values to the next periods account_period_balance records values.
    select 
    y.period+1,
    y.account_no,
    b.debit,
    cast(y.ytd_debit+b.debit as decimal(19,5)) as ytd_debit,
    b.credit,
    cast(y.ytd_credit+b.credit as decimal(19,5)) as ytd_credit,
    b.balance,
    cast(y.ytd_balance+b.balance as decimal(19,5)) as ytd_balance
    from calc_ytd_high y
    inner join account_period_balance b 
    on y.period+1=b.period 
    and y.account_no=b.account_no
    where y.period < 202110
)
-- references expression name
--SELECT count(*) FROM   calc_ytd_high
SELECT period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM   calc_ytd_high

select * 
--into Plex.accounting_period_balance_high_2021_10_bak
from Plex.accounting_period_balance_high_2021_10
-- drop table Plex.accounting_period_balance_high_2021_10

select * 
--into Plex.accounting_period_balance_high_2021_10
from Plex.accounting_period_balance_high
where account_no = '47100-000-0000'
