-- mgdw.Plex.accounting_balance_update_period_range definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance_update_period_range;

CREATE TABLE mgdw.Plex.accounting_balance_update_period_range (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	period_start int NULL,
	period_end int NULL,
	PRIMARY KEY (id)
);
select * from Plex.accounting_balance_update_period_range

select *
-- drop table Archive.accounting_balance
into Archive.accounting_balance 
--select count(*) 
from Plex.accounting_balance  -- 52,138

select * 
select distinct pcn,period
from Archive.accounting_balance order by pcn,period


update Plex.accounting_balance_update_period_range 
set period_start = 202104,
period_end = 202105
where pcn = 123681

update Plex.accounting_balance_update_period_range 
set period_start = 202106,
period_end = 202107
where pcn = 300758


select * from Archive.accounting_balance ab -- 52,138
select count(*) from Archive.accounting_balance ab -- 52,138/45,459/52,749
select distinct pcn,period from Archive.accounting_balance ab order by pcn,period
select * from Plex.accounting_balance ab -- 52,138
select count(*) from Plex.accounting_balance ab --45,459/52,749
select distinct pcn,period from Archive.accounting_balance ab order by pcn,period

-- 52,138/45,459/52,749
select distinct pcn,period from Plex.accounting_balance ab order by pcn,period

select *
--into Archive.accounting_balance_12_30 -- 52,138
from Plex.accounting_balance

/*
 * Backup 
 */
select * 
-- select count(*) from Archive.account_period_balance_12_30  -- 43,630
--into Archive.account_period_balance_12_30
from Plex.account_period_balance b -- 43,630

/*
 * Format to be like CSV download
 */
--select * from Plex.accounting_account a where a.account_no = '10220-000-00000' 
select 
b.period,
b.period_display,
a.category_type,
-- b.category_type_legacy category_type,  -- use legacy category type for the report.
/*
 * The Plex TB report uses the category type of the category linked to the account via the  category_account view. 
 * I believe Plex now mostly uses the account category located directly on the accounting_v_account view so I used 
 * this column instead of the one linked via the account_category view. 
 */
a.category_name_legacy category_name,
--a.sub_category_name_legacy sub_category_name,
a.account_no [no],
a.account_name,
b.balance current_debit_credit,
b.ytd_balance ytd_debit_credit
--select count(*)
from Plex.account_period_balance b -- 43,620
inner join Plex.accounting_account a -- 43,620
on b.pcn=a.pcn 
and b.account_no=a.account_no 
--order by b.period_display,a.account_no 
--where a.category_type != a.category_type_legacy 
--where b.period_display is not NULL -- 40,940
--where b.period_display is NULL -- 40,940
where a.account_no = '10220-000-00000' 

/*
 * Backup Plex.accounting_balance and Plex.account_period_balance
 */
--select distinct pcn,period from Plex.account_period_balance order by pcn,period --(123,681,202101 to 202110)
select *
--into Archive.account_period_balance_01_03_2022  -- 43630
from Plex.account_period_balance

select *
--into Archive.accounting_balance_01_03_2022  -- 43630
from Plex.accounting_balance


/*
 * Start the append procedure for
 * Plex.account_period_balance b
 */

/*
* What is the 
*/
declare @pcn int;
set @pcn=123681;
with ending_period(pcn,ending_period)
as 
(
	select pcn,max(period) ending_period from  Plex.account_period_balance group by pcn
),
--select * from ending_period
next_period(pcn,ending_period,next_period,first_period)
as 
(
	select e.pcn,
	e.ending_period,
    case 
    when e.ending_period < m.max_fiscal_period then e.ending_period+1
 --   when y.period%100 < 12 then y.period+1
    else ((e.ending_period/100 + 1)*100) + 1 
    end next_period,
    case 
    when e.ending_period < m.max_fiscal_period then 0
    else 1 
    end first_period
	from  ending_period e
	inner join Plex.max_fiscal_period m 
    on e.pcn=m.pcn
    and (e.ending_period/100) = m.[year]
),
--select * from next_period;
account_periods(pcn,account_no,period,next_period)
as 
(
    select 
    a.pcn,
    a.account_no,
	n.next_period period,
    case 
    when n.next_period < m.max_fiscal_period then n.next_period+1
    else ((n.next_period/100 + 1)*100) + 1 
    end next_period
    -- select count(*) from Plex.accounting_account where pcn = 123681  -- 4,363
	from Plex.accounting_account a   
	inner join next_period n 
	on a.pcn=n.pcn 
	-- select * from Plex.max_fiscal_period m
	inner join Plex.max_fiscal_period m 
    on a.pcn=m.pcn
    and (n.next_period/100) = m.[year]
	where a.pcn = @pcn  
	
	union all 
	--select * from Plex.accounting_balance_update_period_range
	select 
	p.pcn,
	p.account_no,
    case 
    when p.period < m.max_fiscal_period then p.period+1
    else ((p.period/100 + 1)*100) + 1 
    end period,
    case 
    when p.next_period < n.max_fiscal_period then p.next_period+1
    else ((p.next_period/100 + 1)*100) + 1 
    end next_period
	from account_periods p 
	inner join Plex.accounting_balance_update_period_range r 
	on p.pcn = r.pcn 
	inner join Plex.max_fiscal_period m 
    on p.pcn=m.pcn
    and (p.period/100) = m.[year]
	inner join Plex.max_fiscal_period n 
    on p.pcn=n.pcn
    and (p.next_period/100) = n.[year]
	where p.period < r.period_end 
),
--select distinct pcn,period from account_periods order by pcn,period
--select count(*) from account_periods -- 43,630
period_balances(pcn,account_no,period,next_period,debit,credit,balance)
as 
(
	select p.pcn,p.account_no,p.period,p.next_period,
	case 
	when b.debit is null then 0 
	else b.debit 
	end debit,
	case 
	when b.credit is null then 0 
	else b.credit 
	end credit,
	case 
	when b.balance is null then 0 
	else b.balance 
	end balance
	from account_periods p 
	left outer join Plex.accounting_balance b 
	on p.pcn=b.pcn 
	and p.account_no=b.account_no 
	and p.period=b.period 
),
--select count(*) from period_balances;  -- 43,630
account_period_balance(pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
--,ending_period,ending_ytd_debit,ending_ytd_credit,ending_ytd_balance,next_period)
as 
(	
--select * from Plex.accounting_period ap where pcn = 300758
	select b.pcn,p.account_no,n.next_period period,ap.period_display,
	case 
	when b.debit is null then 0
	else b.debit
	end debit,
	cast(
		case 
		when (n.first_period=0) and (a.revenue_or_expense = 1) and (b.debit is null) then p.ytd_debit 
		when (n.first_period=0) and (a.revenue_or_expense = 1) and (b.debit is not null) then p.ytd_debit + b.debit 
		when (n.first_period=0) and (a.revenue_or_expense = 0) and (b.debit is null) then p.ytd_debit 
		when (n.first_period=0) and (a.revenue_or_expense = 0) and (b.debit is not null) then p.ytd_debit + b.debit
		when (n.first_period=1) and (a.revenue_or_expense = 1) and (b.debit is null) then 0 
		when (n.first_period=1) and (a.revenue_or_expense = 1) and (b.debit is not null) then b.debit 
		when (n.first_period=1) and (a.revenue_or_expense = 0) and (b.debit is null) then p.ytd_debit 
		when (n.first_period=1) and (a.revenue_or_expense = 0) and (b.debit is not null) then p.ytd_debit + b.debit 
		end as decimal(19,5) 
	) ytd_debit, 
	case 
	when b.credit is null then 0
	else b.credit
	end credit,
	cast(
		case 
		when (n.first_period=0) and (a.revenue_or_expense = 1) and (b.credit is null) then p.ytd_credit 
		when (n.first_period=0) and (a.revenue_or_expense = 1) and (b.credit is not null) then p.ytd_credit + b.credit 
		when (n.first_period=0) and (a.revenue_or_expense = 0) and (b.credit is null) then p.ytd_credit 
		when (n.first_period=0) and (a.revenue_or_expense = 0) and (b.credit is not null) then p.ytd_credit + b.credit
		when (n.first_period=1) and (a.revenue_or_expense = 1) and (b.credit is null) then 0 
		when (n.first_period=1) and (a.revenue_or_expense = 1) and (b.credit is not null) then b.credit 
		when (n.first_period=1) and (a.revenue_or_expense = 0) and (b.credit is null) then p.ytd_credit 
		when (n.first_period=1) and (a.revenue_or_expense = 0) and (b.credit is not null) then p.ytd_credit + b.credit 
		end as decimal(19,5)
	) ytd_credit, 	
	case 
	when b.balance is null then 0
	else b.balance
	end balance,
	cast(
		case 
		when (n.first_period=0) and (a.revenue_or_expense = 1) and (b.balance is null) then p.ytd_balance 
		when (n.first_period=0) and (a.revenue_or_expense = 1) and (b.balance is not null) then p.ytd_balance + b.balance 
		when (n.first_period=0) and (a.revenue_or_expense = 0) and (b.balance is null) then p.ytd_balance 
		when (n.first_period=0) and (a.revenue_or_expense = 0) and (b.balance is not null) then p.ytd_balance + b.balance
		when (n.first_period=1) and (a.revenue_or_expense = 1) and (b.balance is null) then 0 
		when (n.first_period=1) and (a.revenue_or_expense = 1) and (b.balance is not null) then b.balance 
		when (n.first_period=1) and (a.revenue_or_expense = 0) and (b.balance is null) then p.ytd_balance 
		when (n.first_period=1) and (a.revenue_or_expense = 0) and (b.balance is not null) then p.ytd_balance + b.balance 
		end as decimal(19,5)
	) ytd_balance	
	-- below this line is columns used for debugging.
--	n.ending_period,p.ytd_debit ending_ytd_debit,p.ytd_credit ending_ytd_credit, p.balance ending_ytd_balance,n.next_period
	--select *
	from Plex.account_period_balance p
	-- select * from Plex.accounting_account aa 
	-- select * from Plex.accounting_account_year_category_type aayct 
	-- select distinct pcn,year from Plex.accounting_account_year_category_type aayct 
	inner join next_period n 
	on p.pcn=n.pcn 
	and p.period = n.ending_period
	-- select distinct pcn,period from Plex.accounting_balance b order by pcn,period (123681,200812,202111)
	inner join period_balances b 
	on p.pcn = b.pcn 
	and n.next_period=b.period 
	and p.account_no = b.account_no 
	inner join Plex.accounting_period ap 
	on n.pcn=ap.pcn 
	and n.next_period=ap.period 
	inner join Plex.accounting_account_year_category_type a
	on p.pcn = a.pcn 
	and p.account_no =a.account_no
	and (n.ending_period/100)=a.[year]

	union all

	select 
	pb.pcn,
	pb.account_no,
	pb.period,
	p.period_display,
	case 
	when b.debit is null then 0
	else b.debit
	end debit,
	cast ( 
		case 
		when (pb.first_period=0) and (pb.revenue_or_expense = 1) and (b.debit is null) then pb.prev_ytd_debit 
		when (pb.first_period=0) and (pb.revenue_or_expense = 1) and (b.debit is not null) then pb.prev_ytd_debit + b.debit 
		when (pb.first_period=0) and (pb.revenue_or_expense = 0) and (b.debit is null) then pb.prev_ytd_debit 
		when (pb.first_period=0) and (pb.revenue_or_expense = 0) and (b.debit is not null) then pb.prev_ytd_debit + b.debit
		when (pb.first_period=1) and (pb.revenue_or_expense = 1) and (b.debit is null) then 0 
		when (pb.first_period=1) and (pb.revenue_or_expense = 1) and (b.debit is not null) then b.debit 
		when (pb.first_period=1) and (pb.revenue_or_expense = 0) and (b.debit is null) then pb.prev_ytd_debit 
		when (pb.first_period=1) and (pb.revenue_or_expense = 0) and (b.debit is not null) then pb.prev_ytd_debit + b.debit 
		end as decimal(19,5)
	) ytd_debit,
	case 
	when b.credit is null then 0
	else b.credit
	end credit,
	cast ( 
		case 
		when (pb.first_period=0) and (pb.revenue_or_expense = 1) and (b.credit is null) then pb.prev_ytd_credit 
		when (pb.first_period=0) and (pb.revenue_or_expense = 1) and (b.credit is not null) then pb.prev_ytd_credit + b.credit 
		when (pb.first_period=0) and (pb.revenue_or_expense = 0) and (b.credit is null) then pb.prev_ytd_credit 
		when (pb.first_period=0) and (pb.revenue_or_expense = 0) and (b.credit is not null) then pb.prev_ytd_credit + b.credit
		when (pb.first_period=1) and (pb.revenue_or_expense = 1) and (b.credit is null) then 0 
		when (pb.first_period=1) and (pb.revenue_or_expense = 1) and (b.credit is not null) then b.credit 
		when (pb.first_period=1) and (pb.revenue_or_expense = 0) and (b.credit is null) then pb.prev_ytd_credit 
		when (pb.first_period=1) and (pb.revenue_or_expense = 0) and (b.credit is not null) then pb.prev_ytd_credit + b.credit 
		end as decimal(19,5)
	) ytd_credit,
	case 
	when b.balance is null then 0
	else b.balance 
	end balance,
	cast ( 
		case 
		when (pb.first_period=0) and (pb.revenue_or_expense = 1) and (b.balance is null) then pb.prev_ytd_balance 
		when (pb.first_period=0) and (pb.revenue_or_expense = 1) and (b.balance is not null) then pb.prev_ytd_balance + b.balance 
		when (pb.first_period=0) and (pb.revenue_or_expense = 0) and (b.balance is null) then pb.prev_ytd_balance 
		when (pb.first_period=0) and (pb.revenue_or_expense = 0) and (b.balance is not null) then pb.prev_ytd_balance + b.balance
		when (pb.first_period=1) and (pb.revenue_or_expense = 1) and (b.balance is null) then 0 
		when (pb.first_period=1) and (pb.revenue_or_expense = 1) and (b.balance is not null) then b.balance 
		when (pb.first_period=1) and (pb.revenue_or_expense = 0) and (b.balance is null) then pb.prev_ytd_balance 
		when (pb.first_period=1) and (pb.revenue_or_expense = 0) and (b.balance is not null) then pb.prev_ytd_balance + b.balance 
		end as decimal(19,5)
	) ytd_balance
	from
	(
--pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance,
--ending_period,ending_ytd_debit,ending_ytd_credit,ending_ytd_balance,next_period	
		select 
		pb.pcn,
		pb.account_no,
		pb.period prev_period,	
	    case 
	    when pb.period < m.max_fiscal_period then pb.period+1
	    else ((pb.period/100 + 1)*100) + 1 
	    end period,
	    case 
	    when pb.period < m.max_fiscal_period then 0
	    else 1 
	    end first_period,
	    a.revenue_or_expense, 
		pb.debit prev_debit,
		pb.ytd_debit prev_ytd_debit,
		pb.credit prev_credit,
		pb.ytd_credit prev_ytd_credit,
		pb.balance prev_balance,
		pb.ytd_balance prev_ytd_balance
		from account_period_balance pb
		inner join Plex.max_fiscal_period m 
	    on pb.pcn=m.pcn
	    and (pb.period/100) = m.[year]
		inner join Plex.accounting_account_year_category_type a
		on pb.pcn = a.pcn 
		and pb.account_no =a.account_no
		and (pb.period/100)=a.[year]
	) pb
	inner join Plex.accounting_period p 
	on pb.pcn=p.pcn 
	and pb.period=p.period 
	inner join period_balances b 
	on pb.pcn=b.pcn 
	and pb.account_no=b.account_no 
	and pb.period=b.period 
	
	where pb.period < 202111
	-- select * from Plex.accounting_period p 
	
)




select count(*) from account_period_balance -- 8,726
--select 8726/2 -- 4363
--select * from account_period_balance


-- select count(*) from anchor_member -- 4,363
/*
 * Does the values in this view match with the CSV download and the TB PP?
 */
/*
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
*/
select count(*) 
from account_period_balance b -- 43,630
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
--where p.pcn is null and s.pcn is not null  -- 2/33  account periods with activity not on the TB report.
--where s.pcn is not null  -- 231/2,462
--where b.debit=s.debit -- 231/2,462
--where b.credit = s.credit -- 231/2,462
--where b.balance =s.balance  -- 231/2,462
--where b.balance !=s.balance -- 0
--where b.balance != d.current_debit_credit  -- 4/23
--where (b.balance - d.current_debit_credit) >  0.01 -- 0/0
--where b.credit != p.current_credit  -- 0/0 
--where b.debit != p.current_debit  -- 0/0 
--where (b.balance != p.Current_Debit - p.Current_Credit)   -- 0/0
/*
 * 'Revenue' or 'Expense' low accounts have no credit/debit values. 
 */
--where a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 0/22
--and ((b.credit = 0) and (b.debit = 0) and (b.balance =0))  -- 220
--where a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 0/22
--and ((b.credit != 0) or (b.debit != 0) or (b.balance !=0))  -- 0
--where b.ytd_debit != p.ytd_debit  -- 0/10 73100-000-0000 changed to a 'Revenue' or 'Expense' after the beginning of the year so PP_ytd_debit and PP_ytd_credit did not get reset on 2021-01. 
-- but our code only saw the current category so it reset the YTD values.
-- reset all Plex.account_period_balance for this account
-- UPDATE Plex.account_period_balance !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
-- update Plex.account_period_balance set ytd_debit=18912.67,ytd_credit=18912.67 where account_no = '73100-000-0000'
--where b.ytd_credit != p.ytd_credit  
--order by b.account_no,b.period
--where (d.ytd_debit_credit != (p.ytd_debit-p.ytd_credit))  -- 5/137
--where ((p.ytd_debit-p.ytd_credit) - d.ytd_debit_credit) > 0.01  -- 0/0
--where (b.ytd_balance - d.ytd_debit_credit) > 0.01  -- 0/0
--where (s.credit = b.credit) -- 231/2,462
--where (s.balance = b.balance) -- 231/?
-- where (s.debit = b.debit) -- 231/2,462
--where (s.debit != b.debit) -- 0/0

order by b.account_no,b.period



CREATE TABLE Plex.account_period_balance_append(
	pcn int,
	account_key int,
	account_no varchar(20),
	period int,
	next_period int,
	debit decimal(19,5),
	credit decimal(19,5),
	balance decimal(19,5),
--	balance_legacy decimal(19,5),
	PRIMARY KEY (pcn,account_key,period)
);

insert into Plex.account_period_balance_append
exec Plex.account_period_balance_create

select * from Plex.account_period_balance_append


create procedure Plex.calc_ytd
as
begin
/*
 * What will be the starting period? 3 periods ago.
 */
declare @todays_date datetime;
set @todays_date = getdate();
--select @todays_date;
/*
 * What period is it today?
 */
declare @current_period int;

select @current_period = period 
--select pcn,year(begin_date) year,period,* 
--select distinct pcn,period
from Plex.accounting_period p
where pcn = 123681  -- 200601 to > 204103
and @todays_date between p.begin_date and p.end_date 

--select @current_period

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
with calc_ytd (pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
as
(
    -- Anchor member
    select
    b.pcn,
    b.period,
    b.next_period,
    b.account_no, 
    b.debit,
    b.debit as ytd_debit,
    b.credit,
    b.credit as ytd_credit,
    b.balance,
    b.balance as ytd_balance
    --select count(*)
	from Plex.account_period_balance_append b  -- 34,508,
	join Plex.accounting_account a  -- 34,508 
	on b.pcn=a.pcn
	and b.account_key=a.account_key
	-- Only get 1 balance record for each account.  That is the balance record with the 1st period for the account.
	where b.period = @start_period  -- 376  
    UNION ALL
    -- Recursive member that references expression_name.
    select 
    	y.pcn,
	    case 
	    when y.period < m.max_fiscal_period then y.period+1
	 --   when y.period%100 < 12 then y.period+1
	    else ((y.period/100 + 1)*100) + 1 
	    end period,
	    case 
	    when y.next_period < n.max_fiscal_period then y.next_period+1
	    else ((y.next_period/100 + 1)*100) + 1 
	    end next_period,
	    y.account_no,
	    b.debit,
	    cast(y.ytd_debit+b.debit as decimal(19,5)) as ytd_debit,
	    b.credit,
	    cast(y.ytd_credit+b.credit as decimal(19,5)) as ytd_credit,
	    b.balance,
	    cast(y.ytd_balance+b.balance as decimal(19,5)) as ytd_balance
    from calc_ytd y
    -- join the calc_ytd_low record with the accounts next account_period_balance_low record and 
    -- create a new calc_ytd_low record for this next period.
    --select * from Plex.account_period_balance_low b  -- 37970
    --select count(*) from Plex.account_period_balance_low b  -- 37970
    --select distinct next_period from Plex.account_period_balance_low b order by next_period  -- 200702 to 202111
    --select distinct period from Plex.account_period_balance_low b order by period  -- 200701 to 202110
--    inner join Plex.account_period_balance b 
    inner join Plex.account_period_balance_append b 
--    select dinner join Plex.account_period_balance_low b 
    on y.pcn=b.pcn
    and y.next_period=b.period 
    and y.account_no=b.account_no
    --select * from max_fiscal_period m 
	inner join Plex.max_fiscal_period m 
    on y.pcn=m.pcn
    and (y.period/100) = m.[year]
	inner join Plex.max_fiscal_period n 
    on y.pcn=n.pcn
    and (y.next_period/100) = n.[year]
   	where y.period < @current_period
)
-- references expression name
--SELECT count(*) FROM   calc_ytd-- OPTION (MAXRECURSION 210);  -- 34,508
SELECT pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd
end

exec Plex.calc_ytd

/*
 * Make backup of Plex.accounting_balance before appending records to it 
 */

create schema Archive

select *
--select distinct pcn,period -- 200812 to 202110
--select count(*)  -- 52,138
from Archive.account_balance_12_21 b
--from Plex.accounting_balance b
where b.pcn = 123681  -- 40,698
and b.period = 202110
order by period 


