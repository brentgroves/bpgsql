-- Use Plex procedure: accounting_balance_dw_import
-- drop table Plex.accounting_balance
CREATE TABLE Plex.accounting_balance
-- account_no	start_period	debit	credit	YTD
(
  pcn INT NOT NULL,
  account_key int not null,
  account_no VARCHAR(20) NOT NULL,
  period int not null,
  debit decimal(19,5),
  credit decimal(19,5),
  balance decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_key,period
  )
);
select distinct pcn,period from Plex.accounting_balance ORDER by pcn,period
select * from Plex.accounting_balance

/*
 * Does the balances snapshots give the same values as the Accounting_p_Account_Balances_by_Periods_Get plex procedure? YES
 */
select p.pcn,p.period,p.Current_Debit,b.debit,p.Current_Credit,b.credit
--select distinct p.pcn,p.period -- Albion/2021-09,Southfield/2021-10
from Plex.Account_Balances_by_Periods p 
join Plex.accounting_balance b 
on p.pcn = b.pcn
and p.period = b.period
and p.[no]=b.account_no
where p.Current_Debit != b.debit or p.Current_Credit != b.credit  -- 0

/*
 * Does Accounting_p_Account_Balances_by_Periods_Get give us the same number of accounts as the Plex balance snapshots
 * The Plex balance snapshot gives us 3 more accounts.
'10110-000-0000',
'10120-000-0000',
'10125-000-0000'
 * 
 */
--select p.pcn,p.[no],p.Current_Debit,p.Current_Credit 
select count(*)
from Plex.Account_Balances_by_Periods p 
--where p.pcn = 123681 and p.period = 202110  -- 4,204
--and (p.Current_Debit != 0  or p.Current_Credit != 0)-- 260
--and left(p.[no],1) < '4'  -- 
--and (p.Current_Debit = 0 and p.Current_Credit = 0)  -- 
join Plex.accounting_balance b 
--select count(*)
--from Plex.accounting_balance b
--where b.pcn = 123681 and b.period = 202110  
--and (b.Debit != 0  or b.Credit != 0)-- 263
on p.pcn = b.pcn
and p.period = b.period
and p.[no]=b.account_no  
where p.pcn = 123681 and p.period = 202110  -- 260 -- all Account_Balances_by_Periods plex procedure accounts are in the balance snapshot set.

select b.*
--select count(*)
from Plex.accounting_balance b
--where b.pcn = 123681 and b.period = 202110  -- 45
left outer join Plex.Account_Balances_by_Periods p  
on b.pcn =p.pcn
and b.period=p.period 
and p.[no]=b.account_no  
where b.pcn = 123681 and b.period = 202110  
and p.pcn is null
order by b.pcn,b.period,b.account_no
/*
10110-000-0000
10120-000-0000
10125-000-0000
*/

/*
 * Do the balance snapshot values match the Trial Balance Plex procedure Account_Balances_by_Periods? 
 * Yes, except for the 3 accounts that are missing from the Trial Balance Plex procedure Account_Balances_by_Periods procedure.
 * 
 */

select b.*
--select count(*)
from Plex.accounting_balance b
--where b.pcn = 123681 and b.period = 202110  -- 45
left outer join Plex.Account_Balances_by_Periods p  
on b.pcn =p.pcn
and b.period=p.period 
and p.[no]=b.account_no  
where b.pcn = 123681 and b.period = 202110  
--and ((b.debit = p.Current_Debit) and (b.credit=p.Current_Credit))  -- 260
and ((p.pcn is null) or (b.debit != p.Current_Debit) or (b.credit!=p.Current_Credit))  -- 3 nulls 
--and p.pcn is null
order by b.pcn,b.period,b.account_no


select * from Plex.accounting_account a 
where a.account_no in (
'10110-000-0000',
'10120-000-0000',
'10125-000-0000'
)

select * from Plex.Account_Balances_by_Periods p 
where p.[no] in (
'10110-000-0000',
'10120-000-0000',
'10125-000-0000'
)

/*
 * We know the account '20100-000-0000' has different debit/credit values for periods < 2020-06
 * for the Trial Balance - Multiple Periods report and the Account Activity Detail report.
 * But do these 2 reports produce equivalant debit/credit values for all accounts for
 * periods >= 2020-06
 */

select d.pcn,d.period,d.account_no,a.active,a.debit_main,d.debit detail_debit,b.debit TB_debit,d.debit-b.debit debit_diff,d.credit detail_credit,b.credit TB_credit,d.credit-b.credit credit_diff 
--couunt_Activity_Summary d  where d.pcn = 123681 and d.period = 202001)s  -- 221
--select count(*) from Plex.GL_Account_Activity_Summary d  where d.pcn = 123681  -- 5203, 202001 - 202111
--select count(*) from Plex.GL_Account_Activity_Summary d  where d.pcn = 123681  and d.period between 202001 and 202110 -- 5,116
-- select distinct d.account_no 
-- select count(*)
from Plex.GL_Account_Activity_Summary d  -- 5203
--select count(*) from Plex.accounting_balance b where b.pcn = 123681 and b.period between 202001 and 202110  -- 5,117
--select count(*) from Plex.accounting_balance b where b.pcn = 123681 and b.period=202001  -- 221
--select count(*) from Plex.accounting_balance b where b.pcn = 123681  -- 40,698, 200812-2021-10
inner join Plex.accounting_balance b 
on d.pcn =b.pcn
and d.account_no =b.account_no
and d.period = b.period
inner join Plex.accounting_account a 
on d.pcn=a.pcn 
and d.account_no=a.account_no 
where d.pcn = 123681 
--and d.period between 202006 and 202110 -- 4077 
--and ((d.debit = b.debit) and (d.credit=b.credit))  -- 
--and ((d.debit != b.debit) or (d.credit!=b.credit))  -- 0
--and d.period = 202001
and d.period between 202001 and 202005 -- 1,039 
--and ((d.debit = b.debit) and (d.credit=b.credit))  -- 
and ((d.debit != b.debit) or (d.credit!=b.credit))  -- 60
order by d.period,d.account_no 
--and d.period between 202001 and 202110 -- 5,116 
--and ((d.debit = b.debit) and (d.credit=b.credit))  -- 5,056
--and ((d.debit != b.debit) or (d.credit!=b.credit))  -- 60
and ((p.pcn is null) or (b.debit != p.Current_Debit) or (b.credit!=p.Current_Credit))  -- 3 nulls 

inner join Plex.accounting_account a 
on s.pcn=a.pcn 
and s.account_no=a.account_no 
where s.account_no in ('10000-000-00000','10305-000-01704','10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','20100-000-0000')

--select distinct pcn,period
--from Plex.accounting_balance b

/* 
 * How to add YTD value to balance records for account starting with 123?
 * 
 */
/*
 * get set of 123accounts
 */
--https://www.sqlshack.com/sql-server-common-table-expressions-cte/
-- drop view Plex.accounting_account123
create view Plex.accounting_account123
as
(
	select *
	--select count(*) cnt
	from Plex.accounting_account a
	where a.first_digit_123 =1  --661
)
;with account123 as
(
	select *
	--select count(*) cnt
	from Plex.accounting_account a
	where a.pcn =123681
	and a.first_digit_123 =1  --661
)
select * from account123
select * from Plex.accounting_account123
/*
 * Calc YTD values for account123 
 * https://learnsql.com/blog/sql-subquery-cte-difference/
 */

	--drop view Plex.accounting_period_balance
	create view Plex.accounting_period_balance_2021(pcn,account_key,account_no,period,debit,credit,balance)
	as

	WITH account_period (pcn,account_key,account_no,period)
	AS
	(
	    -- Anchor member
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    202101 period
		--select count(*) cnt
		from Plex.accounting_account a  -- 4,362 X 10 = 43,620
		where pcn = 123681
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Recursive member that references expression_name.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
	    p.period+1
	    from account_period p
	    where p.period < 202110
	),
	--select count(*) from account_period -- 4,362
--	select * from account_period -- 4,362
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
		-- references expression name
		select *
		--SELECT count(*)
		FROM   account_period_balance;  -- 43,620

	select * from Plex.accounting_period_balance_2021
	
	

WITH calc_ytd (period,account_no,balance,ytd)
AS
(
    -- Anchor member
    select 
    period,
    account_no, 
    balance,
    balance as ytd
	from Plex.accounting_period_balance_2021 
	--where period between 202101 and 202102
	where period = 202101
	--and debit > 0
	and account_no = '41100-000-0000'
    UNION ALL
    -- Recursive member that references expression_name.
    select 
    y.period+1,
    y.account_no,
    b.balance,
    cast(y.ytd+b.balance as decimal(19,5)) as ytd
    from calc_ytd y
    inner join Plex.accounting_period_balance_2021 b 
    on y.period+1=b.period 
    and y.account_no=b.account_no
    where y.period < 202110
)
-- references expression name
SELECT *
FROM   calc_ytd
/*
 * Verified calc_ytd with just 1 ytd account.
 * Next create view for account123 and determine its ytd value.
 */

202101	11010-000-0000	2392605.71000	2392605.71000
202102	11010-000-0000	986341.72000	986341.72000



select *
select a.pcn,a.account_no,b.period, 
b.debit current_debit,
(
select sum(b2.debit) 
from Plex.accounting_balance b2
where b.period between 202001 and b2.p
)
--select a.pcn,a.account_no,b.* 
--select distinct b.pcn,b.period  -- 157
--select count(*)
from Plex.accounting_account123 a
--where a.pcn = 123681  -- 661
inner join Plex.accounting_balance b 
on a.pcn = b.pcn
and a.account_no = b.account_no
where a.pcn = 123681 -- 10,426
order by b.pcn,b.period



/*
 * 
 */
select s.pcn,s.period,s.account_no,a.active,a.debit_main,s.debit,s.credit,s.YTD 
--select distinct d.pcn,d.period -- 202001 - 202111
from Plex.GL_Account_Activity_Summary d
inner join Plex.accounting_balance b 
on d.pcn =b.pcn
and d.account_no =b.account_no
and d.period = b.period
--Plex.GL_LT_4000_Account_YTD_Summary s 
inner join Plex.accounting_account a 
on s.pcn=a.pcn 
and s.account_no=a.account_no 
where s.account_no in ('10000-000-00000','10305-000-01704','10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','20100-000-0000')
Plex.GL_Account_Activity_Summary
10220-000-00000	772750612.53000	766397182.63000	6353429.90000
10250-000-00000	205936.48000	205936.48000	0.00000
11010-000-0000	58396150.35000	54716582.11000	3679568.24000
11900-000-0000	638633.22000	572277.51000	66355.71000
