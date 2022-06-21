Period,Category Type,Category Name,Sub Category Name,No,Name,Current Debit/(Credit),YTD Debit/(Credit)
"10-2021","Asset","Current Assets","Receivables","10220-000-00000","Accounts Receivable","0","6353429.89999998",
-- drop table Plex.trial_balance_multi_level
create table Plex.trial_balance_multi_level
(
 pcn int null,
 period int null,
 period_display varchar(7),
 category_type VARCHAR(10),
 category_name VARCHAR(50),
 sub_category_name VARCHAR(50) ,
 account_no VARCHAR(20),
 account_name VARCHAR(110),
 current_debit_credit DECIMAL(18,2),
 ytd_debit_credit DECIMAL(18,2)
 primary key (period_display,account_no)  -- when this gets imported there is a period_display but no period.
)
select distinct pcn,period from Plex.trial_balance_multi_level
select count(*) from Plex.trial_balance_multi_level  -- 58,856

select * 
-- select count(*)
from Plex.trial_balance_multi_level  -- 58,856
where account_no = '10220-000-00000'
where period_display like '%Total%'  -- 4204  
/*
 * The last account_no record contains a total record with a YTD debit_credit value 
 * which is the same as that found in the last periods ytd_debit_credit column
 */

select s1.*,s2.current_debit_credit 
-- select count(*)
from Plex.trial_balance_multi_level s1  -- 58,856
join Plex.trial_balance_multi_level s2
on s1.account_no=s2.account_no
and s1.ytd_debit_credit=s2.current_debit_credit
and s2.period_display='Total'
and s1.period_display='12-2009'  -- 4,204
order by s1.account_no

select 
cast (right(period_display,4) + left(period_display,2) as int) period
from Plex.trial_balance_multi_level


update Plex.trial_balance_multi_level
set period = cast (right(period_display,4) + left(period_display,2) as int),
pcn = 123681
where pcn is null
