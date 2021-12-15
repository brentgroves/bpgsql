

--drop view Plex.accounting_period_balance_high_view
	create view Plex.account_period_balance_high_view(pcn,account_no,period,debit,credit,balance)
--	create view Plex.accounting_period_balance_high_view(pcn,period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
	as
	WITH account(pcn,account_no)
	as 
	(
	    select 
	    a.pcn,
	    a.account_no
		--select count(*) cnt
	    --select *
		from Plex.accounting_account a  
		
		where pcn = 123681 -- 4,363
		and a.revenue_or_expense = 1  -- 3,723
	),
	-- select count(*) from account --3,723
	-- select * from account
	account_period(pcn,account_no,period)
	AS
	(
	    -- Anchor member
	    select 
	    a.pcn,
	    a.account_no,
	    202101 period
		--select count(*) cnt
	    --select *
		from account a  -- high: 3,701 * 10 = 37,010 /// all: 4,362 X 10 = 43,620
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Starting at 202101 make a period account record for each period upto 202110.
	    select
	    p.pcn,
	    p.account_no,
	    p.period+1  -- this is ok if we do not want to include periods for multiple years.
	    from account_period p
	    where p.period < 202110
	),
	--select count(*) from account_period -- 37,230
--	select * from account_period
	account_period_balance_high( pcn,account_no,period,debit,credit,balance)
	as 
	(
		select a.pcn,a.account_no,a.period,
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
		
	)
	select *
	--SELECT count(*) 
	FROM   account_period_balance_high;  -- new=37,230
	
	select *
	-- drop table Plex.accounting_period_balance_high
	into Scratch.accounting_period_balance_high_12_15 
	from Plex.accounting_period_balance_high 
	
	select *
	--SELECT count(*) 
	into Plex.account_period_balance_high 
	FROM   Plex.account_period_balance_high_view;  -- new=37,230


create view Plex.accounting_period_balance_high_view(pcn,period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
as
with calc_ytd_high (pcn,period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
AS
(
    -- Anchor member
    select
    pcn,
    period,
    account_no, 
    debit,
    debit as ytd_debit,
    credit,
    credit as ytd_credit,
    balance,
    balance as ytd_balance
    -- select distinct pcn,period -- 202101 to 202110
    --select count(*)
	from Plex.account_period_balance_high
	--order by period
	where period = 202101 -- 3,723
    UNION ALL
    -- join each calc_ytd_high record to the next account_period_balance record to
    -- add the previous credit,debit, and balance ytd values to the next periods account_period_balance records values.
    select 
    y.pcn,
    y.period+1,
    y.account_no,
    b.debit,
    cast(y.ytd_debit+b.debit as decimal(19,5)) as ytd_debit,
    b.credit,
    cast(y.ytd_credit+b.credit as decimal(19,5)) as ytd_credit,
    b.balance,
    cast(y.ytd_balance+b.balance as decimal(19,5)) as ytd_balance
    from calc_ytd_high y
    inner join Plex.account_period_balance_high b
    on y.period+1=b.period 
    and y.account_no=b.account_no
    where y.period < 202110
)
-- references expression name
--SELECT count(*) FROM   calc_ytd_high  -- 37,230
SELECT pcn,period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM   calc_ytd_high

select *
into Scratch.accounting_period_balance_high_12_15
from Plex.accounting_period_balance_high

select * 
-- drop table Plex.accounting_period_balance_high
into Plex.accounting_period_balance_high  -- 37,230
from Plex.accounting_period_balance_high_view
where account_no = '47100-000-0000'

select count(*) from Plex.accounting_period_balance_high
