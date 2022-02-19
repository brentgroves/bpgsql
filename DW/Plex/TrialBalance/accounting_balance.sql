-- drop table Plex.accounting_balance
/*
CREATE TABLE Plex.accounting_balance (
	pcn int,
	account_key int,
	account_no varchar(20),
	period int,
	debit decimal(19,5),
	credit decimal(19,5),
	balance decimal(19,5),
--	balance_legacy decimal(19,5),
	PRIMARY KEY (pcn,account_key,period)
);
select distinct pcn,period from Plex.accounting_balance ab order by pcn,period
select count(*) from Plex.accounting_balance ab -- 52,749

select count(*) from Plex.accounting_balance_ ab -- 52,749
select * 
--into Archive.accounting_balance_2022_01_24
from Plex.accounting_balance ab 
select count(*) from Archive.accounting_balance_2022_01_24 -- 52,749
select distinct pcn,period from Archive.accounting_balance_2022_01_24 order by pcn,period
*/
/*
Are there the same number of accounts returned by Accounting_p_Account_Balances_by_Periods_Get
in the account_balance set?
and s.period between 200812 and 200912 
*/

	WITH account_period (pcn,account_key,account_no,period)
	AS
	(
	    -- Anchor member
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    200812 period
		--select count(*) cnt
	    --select *
		from Plex.accounting_account a  -- 4,362 X 13 = 43620 + 13086 = 56,706
		where pcn = 123681
		--and a.low_account = 0
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Recursive member that references expression_name.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
	    case 
	    when p.period%100 < 12 then p.period+1
	    else ((p.period/100 + 1)*100) + 1 
	    end period
	    from account_period p
	    where p.period < 201810
--	    where p.period < 200912
	),
--	select count(*) from account_period 
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
		
		--SELECT count(*)
		FROM   account_period a -- 198,110
		left outer join Plex.accounting_balance b
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	)
	-- select distinct pcn,period from Plex.accounting_balance order by pcn,period  -- 200812 to 202110
	-- select distinct pcn,period from Plex.trial_balance_multi_level order by pcn,period  -- 200812 to 200912
	-- select distinct pcn,period from Plex.Account_Balances_by_Periods order by pcn,period  -- 200812 to 202110
	-- select count(*) from (select distinct [no] from Plex.Account_Balances_by_Periods) s  order by pcn,period  -- 200812 to 202110
	-- select distinct pcn,period from Plex.GL_Account_Activity_Summary order by pcn,period  -- 202001 to 202111
	-- select count(*) from Plex.GL_Account_Activity_Summary where period = 201807  -- 202001 to 202111
	-- start at -47 for period 201712
	-- 
		select count(*)
		from Plex.accounting_account a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
		left outer join
		( 
			select distinct pcn,[no] from Plex.Account_Balances_by_Periods
		)p
		on a.pcn = p.pcn 
		and a.account_no = p.[no]
		where a.pcn = 123681
		and p.pcn is null  -- 158

		select count(*)
		from Plex.accounting_account a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
		left outer join
		( 
			select distinct pcn,account_no from Plex.GL_Account_Activity_Summary
		)s
		on a.pcn = s.pcn 
		and a.account_no = s.account_no 
		where a.pcn = 123681
		and s.pcn is null  -- 158
				
	-- select count(*) from 
	--	(
	--		select distinct [no] from Plex.Account_Balances_by_Periods p
	--		where ((p.Current_Debit != 0.0) or (p.Current_Credit != 0.0))
	--	) s  -- 1,520
		
	-- select count(*) from 
	--	(
	--		select distinct [no] from Plex.Account_Balances_by_Periods p
	--		where ((p.Current_Debit = 0.0) and (p.Current_Credit = 0.0))
	--	) s  -- 4,428		
	
	-- select distinct pcn,period from Plex.GL_Account_Activity_Summary order by pcn,period -- 202001 to 202111
	-- select count(*) from (select distinct account_no from Plex.GL_Account_Activity_Summary)s  -- 202001 to 202111
	
	select count(*)
	select distinct p.[no]
	from Plex.Account_Balances_by_Periods p
	left outer join Plex.accounting_balance b
	on p.pcn = b.pcn 
	and p.[no] = b.account_no 
	and p.period = b.period 
--	where p.period = 202110
	where p.period between 200812 and 202110
	--and b.pcn is not null 
	-- 	p.period = 200812 = 49
	--  p.period = 202110 = 260
	--and ((p.Current_Debit != 0.0) or (p.Current_Credit != 0.0))  -- 39,917
	and b.pcn is null 
	-- 	p.period = 200812 = 4,155
	--  p.period between 200812 and 202110 = 622,917
	and ((p.Current_Debit != 0.0) or (p.Current_Credit != 0.0))  -- 0
	--select * 
	--into Plex.accounting_balance_11_29  
	--from Plex.accounting_balance b 
	-- select * from Plex.GL_Account_Activity_Summary s
	-- select * from Plex.accounting_balance b 
	/*
	--select b.pcn,b.account_no,b.period,b.debit,s.debit,b.credit,s.credit
	-- select distinct b.pcn,b.account_no 
	-- select count(*)
	--select distinct pcn,period
	from Plex.accounting_balance b  -- all periods
	join  Plex.GL_Account_Activity_Summary s -- 202001 - 202111
	on s.pcn = b.pcn 
	and s.account_no = b.account_no 
	and s.period = b.period 
	where b.pcn = 123681 
--	and  b.period between 202001 and 202110
	and  b.period between 202006 and 202110
	--and ((b.debit=s.debit) and (b.credit=s.credit))  -- 5056
	and ((b.debit!=s.debit)or (b.credit!=s.credit))  -- 60
	order by b.pcn,b.account_no,b.period
	*/ 
	/*
	--select *
	-- select count(*)
	--select distinct pcn,period
	from Plex.accounting_balance b  -- all periods
	left outer join  Plex.GL_Account_Activity_Summary s -- 202001 - 202111
	on s.pcn = b.pcn 
	and s.account_no = b.account_no 
	and s.period = b.period 
	where s.pcn is null
	and b.period between 202001 and 202110
--	where b.period = 202001
--	and s.pcn is null
--	order by s.pcn,s.account_no,s.period	
*/
	/*
	--select *
	-- select count(*)
	--select distinct pcn,period
	from Plex.GL_Account_Activity_Summary s -- 202001 - 202111
	left outer join Plex.accounting_balance b  -- all periods
	on s.pcn = b.pcn 
	and s.account_no = b.account_no 
	and s.period = b.period 
	where b.pcn is null
	and s.period between 202001 and 202110  --0
	where s.period = 202001
	and b.pcn is not null
	and b.pcn is null
	order by s.pcn,s.account_no,s.period
	*/	
	/*
	--select *
	-- select count(*)
	--select distinct pcn,period
	from Plex.GL_Account_Activity_Summary -- 202001 - 202111
	where period between 202001 and 202110  --5,116
	--from Plex.Account_Balances_by_Periods p 
	--from Plex.accounting_balance b  -- all periods
	where period = 202001
	--order by pcn,period
	*/
	/*
	--select b.*
	--select count(*)
	select distinct account_no
	from account_period_balance b-- 56,706
	left outer join Plex.Account_Balances_by_Periods p 
	on b.pcn=p.pcn 
	and b.account_no=p.[no]
	and b.period=p.period
	where p.pcn is null  -- 2054
	and ((b.debit != 0.0) or (b.credit!=0.0)) -- 38
	order by pcn,account_no,period
	*/
--	/*
	--select *
	select count(*) 
	--from account_period_balance -- 56,706
	from account_period_balance b 
	join 
	(
	   select * from Plex.Account_Balances_by_Periods p where p.period between 200812 and 201811  -- 512,888
	   --select count(*) from Plex.Account_Balances_by_Periods p where p.period between 200812 and 201811
	) p
	on b.pcn=p.pcn 
	and b.account_no=p.[no]
	and b.period=p.period
	where (b.debit != p.current_debit) or (b.credit!=p.current_credit) -- 0
--	where (b.debit = p.current_debit) and (b.credit=p.current_credit) -- 54,652,500,276
	OPTION (MAXRECURSION 210)

--	where (b.debit != p.current_debit) or (b.credit!=p.current_credit) -- 0
--*/
	/*
	select count(*)
	from 
	(
	   select * from Plex.Account_Balances_by_Periods p where p.period between 200812 and 200912
	) p
	left outer join account_period_balance b-- 56,706
	on b.pcn=p.pcn 
	and b.account_no=p.[no]
	and b.period=p.period
	where b.pcn is null  -- 0
*/
	/*
	select count(*)
	from account_period_balance b-- 56,706
	left outer join Plex.Account_Balances_by_Periods p 
	on b.pcn=p.pcn 
	and b.account_no=p.[no]
	and b.period=p.period
	where p.pcn is null  -- 2054
*/		
