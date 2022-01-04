/*
 * Does the values in this view match with the CSV download and the TB PP?
 */
select b.pcn,b.account_no,
b.period,
a.revenue_or_expense,
b.debit,b.credit,b.balance,d.current_debit_credit TB_balance,b.ytd_debit,p.ytd_debit PP_ytd_debit,
b.ytd_credit,p.ytd_credit PP_ytd_credit,
b.ytd_balance,
d.ytd_debit_credit TB_ytd_balance,
p.ytd_debit-p.ytd_credit PP_ytd_balance
--b.balance -d.current_debit_credit  diff
-- select *
--select count(*) 
from Plex.account_period_balance b -- 43,630
inner join Plex.accounting_account a 
on b.pcn=a.pcn 
and b.account_no=a.account_no -- 43,630 
--from Plex.account_period_balance_view b -- 43,620  -- This view made the query non-responsive
--inner join Plex.trial_balance_multi_level d -- 42,040, 43,620 - 42,040 = 1,580 account periods do not show up on TB CSV download. TB download does not show the plex period for a multi period month, you must link to period_display
left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
-- select * from Plex.Account_Balances_by_Periods p 
left outer join Plex.Account_Balances_by_Periods p -- 43,620
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
--inner join 
left outer join 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
	where s.pcn = 123681 
	and s.period between 202101 and 202110  -- 2,462
) s
on b.pcn=s.pcn 
and b.account_no=s.account_no
and b.period=s.period  
--where p.pcn is null and s.pcn is not null  -- 33  account periods with activity not on the TB report.
--where s.pcn is not null  -- 2,462
--where b.debit=s.debit -- 2,462
--where b.credit = s.credit -- 2,462
--where b.balance =s.balance  -- 2,462
--where b.balance !=s.balance -- 0
--where b.balance != d.current_debit_credit  -- 23
--where (b.balance - d.current_debit_credit) >  0.01 -- 0
--where b.credit != p.current_credit  -- 0 
--where b.debit != p.current_debit  -- 0 
--where (b.balance != p.Current_Debit - p.Current_Credit)   -- 0
/*
 * 'Revenue' or 'Expense' low accounts have no credit/debit values. 
 */
--where a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 22
--and ((b.credit = 0) and (b.debit = 0) and (b.balance =0))  -- 220
--where a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 22
--and ((b.credit != 0) or (b.debit != 0) or (b.balance !=0))  -- 0
--where b.ytd_debit != p.ytd_debit  -- 10 73100-000-0000 changed to a 'Revenue' or 'Expense' after the beginning of the year so PP_ytd_debit and PP_ytd_credit did not get reset on 2021-01. 
-- but our code only saw the current category so it reset the YTD values.
-- reset all Plex.account_period_balance for this account
-- UPDATE Plex.account_period_balance !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
-- update Plex.account_period_balance set ytd_debit=18912.67,ytd_credit=18912.67 where account_no = '73100-000-0000'
--where b.ytd_credit != p.ytd_credit  
--order by b.account_no,b.period
--where (d.ytd_debit_credit != (p.ytd_debit-p.ytd_credit))  -- 137
--where ((p.ytd_debit-p.ytd_credit) - d.ytd_debit_credit) > 0.01  -- 0
--where (b.ytd_balance - d.ytd_debit_credit) > 0.01  -- 0
--where (s.credit = b.credit) -- 2,462
--where (s.balance = b.balance) -- 0
-- where (s.debit = b.debit) -- 2,462
where (s.debit != b.debit) -- 0
--where ((s.ytd_balance - s.TB_ytd_balance) > .01)  -- 0

order by b.account_no,b.period




-- mgdw.Plex.accounting_balance definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance;

CREATE TABLE mgdw.Plex.accounting_balance (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NOT NULL,
	debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	balance decimal(19,5) NULL,
	--CONSTRAINT PK__accounti__34E7554F34C584AF PRIMARY KEY (pcn,account_key,period)
	-- etl script fails with this constraint 
	-- maybe because there is large delete command first.
);
ALTER TABLE Plex.accounting_balance
ADD CONSTRAINT PK__accounti__34E7554F34C584AF PRIMARY KEY (pcn,account_key,period);

CREATE TABLE mgdw.Archive.accounting_balance (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NOT NULL,
	debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	balance decimal(19,5) NULL
);
select pcn,account_key,period,count(*)
from 
(
select distinct pcn,account_key,period from Archive.accounting_balance  --order by pcn,period-- 2963
) b 
group by pcn,account_key,period
having count(*) > 1
/*
 * Create a procedure to record pcn,account_no, year, category, and revenue_or_expense value.
 * What category do we use?  
 */

/*
select 
@current_period current_period,
(@current_period - 3) period_min_3,
(((@current_period/100)-1) * 100) + 12, 
(((@current_period/100)-1) * 100) + 11, 
(((@current_period/100)-1) * 100) + 10 
*/
/*
 * Max fiscal period previous year
 */

declare @prev_year_max_fiscal_period int
select @prev_year_max_fiscal_period=(max_fiscal_period%100) 
from Plex.max_fiscal_period m
where m.pcn = 123681
--and m.[year] = 2010
and m.[year] =  ((@current_period/100)-1);

--select @prev_year_max_fiscal_period
/*
 * 3 periods ago?
 */
/*
select 
case 
when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
end start_period,
case 
when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
end next_period,
p.*
from Plex.accounting_period p
where pcn = 123681  -- 200601 to > 204103
*/
declare @start_period int 
set @start_period = 
	case 
	when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
	when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
declare @next_period int 
set @next_period =
	case 
	when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
	when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
--select @start_period,@next_period
