/*
 * How to identify missing accounts.
 */

declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202101;
--set @period_end = 202110;



--select distinct b.pcn,b.account_no,b.category_type,a.active,a.revenue_or_expense,a.category_type_legacy,a.sub_category_name_legacy 
select count(*)
--into Archive.tb_missing_accounts_after_new_accounts_added_01_2022
from 
(
	select b.pcn,b.period,b.period_display,b.account_no,a.account_name, 
	a.category_type,
	a.category_type_legacy, 
	a.category_name_legacy,
	a.sub_category_name_legacy,
	b.balance,
	b.ytd_balance
	-- select count(*)
--	from Archive.account_period_balance_01_03_2022 b -- 43,630 
	from Plex.account_period_balance b -- 43,630 
	--select * from Plex.accounting_account a
	inner join Plex.accounting_account a
	on b.pcn=a.pcn 
	and b.account_no=a.account_no 
--	where category_type = ''  -- 0
--	where category_type_legacy = ''  -- 1,590
--	where category_name_legacy = ''  -- 1,590
--	where sub_category_name_legacy = ''  -- 1,590
)b 
--order by b.pcn,b.period_display,b.account_no

-- select count(*) from Plex.trial_balance_multi_level d where pcn = 123681 and d.period between 202101 and 202110  -- 42,040
-- select * from Plex.trial_balance_multi_level d where pcn = 123681 and d.period between 202101 and 202110  -- 42,040
left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
--inner join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 

left outer join Plex.accounting_account a
on b.pcn = a.pcn 
and b.account_no=a.account_no 
-- select * from Plex.missing_accounts_2021_09  -- 158
where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_name_legacy = ''  -- 1,590/3,910/There are now 159+232=391 TB missing accounts


/*
 * Missing from Albion PCN?  All Albions accounts have a sub_category_no of 0.
 * While Southfield does not create a category or sub_category record at all.
 */
select distinct pcn,period from Plex.Account_Balances_by_Periods p order by pcn,period -- 123,681 (200812-202110)

select *
--select count(*)
from Plex.Account_Balances_by_Periods p
--where p.pcn = 123681  -- 3,413 = 0
--and p.Sub_Category_No = 0  -- 0
where p.pcn = 300758  -- 3,413 
and p.Sub_Category_No = 0  -- 3,413
and p.[No] in  -- 136 out of 159 appear on TB report. 23 may be missing.
( 
'10000-000-00000',
'10001-000-00000',
'10002-000-00000',
'10010-000-00000',
'10020-000-00000',
'10030-000-00000',
'10100-000-0000', 
'10110-000-0000', 
'10110-000-00000',
'10120-000-0000', 
'10120-000-00000',
'10125-000-0000', 
'10125-000-00000',
'10135-000-00000',
'10140-000-00000',
'10150-000-00000',
'10160-000-00000',
'10170-000-00000',
'10180-000-00000',
'10190-000-00000',
'10200-000-0000', 
'10210-000-0000', 
'10300-000-0000', 
'10310-000-0000', 
'10400-000-0000', 
'10500-000-0000', 
'10600-000-0000', 
'11050-000-9813', 
'14100-000-00000',
'14300-000-00000',
'14500-000-00000',
'15110-000-00000',
'15200-000-00000',
'18300-000-0000', 
'18811-000-9802', 
'18811-000-9803', 
'18811-000-9804', 
'18811-000-9805', 
'18811-000-9806', 
'18811-000-9807', 
'18811-000-9808', 
'18811-000-9809', 
'18811-000-9810', 
'18811-000-9811', 
'18811-000-9812', 
'18811-000-9813', 
'18865-000-9802', 
'18865-000-9803', 
'18865-000-9804', 
'18865-000-9805', 
'18865-000-9806', 
'18865-000-9807', 
'18865-000-9808', 
'18865-000-9809', 
'18865-000-9810', 
'18865-000-9811', 
'18865-000-9812', 
'18865-000-9813', 
'18871-000-9802', 
'18871-000-9803', 
'18871-000-9804', 
'18871-000-9805', 
'18871-000-9806', 
'18871-000-9807', 
'18871-000-9808', 
'18871-000-9809', 
'18871-000-9810', 
'18871-000-9811', 
'18871-000-9812', 
'18871-000-9813', 
'20150-000-9813', 
'31100-000-0000', 
'31170-000-0000', 
'31200-000-0000', 
'32100-000-0000', 
'33100-000-0000', 
'33150-000-0000', 
'33150-000-9802', 
'33150-000-9803', 
'33150-000-9804', 
'33150-000-9805', 
'33150-000-9806', 
'33150-000-9807', 
'33150-000-9808', 
'33150-000-9809', 
'33150-000-9810', 
'33150-000-9812', 
'33150-000-9813', 
'34100-000-0000', 
'35100-000-0000', 
'36100-000-0000', 
'39100-000-0000', 
'40100-000-0000', 
'40160-000-9800', 
'40160-000-9801', 
'40160-000-9802', 
'40160-000-9803', 
'40160-000-9804', 
'40160-000-9805', 
'40160-000-9806', 
'40160-000-9807', 
'40160-000-9808', 
'40160-000-9809', 
'40160-000-9810', 
'40160-000-9811', 
'40160-000-9812', 
'42100-000-9806', 
'42100-000-9807', 
'42100-000-9808', 
'43150-000-0000', 
'43150-000-9800', 
'43150-000-9801', 
'43150-000-9802', 
'43150-000-9803', 
'43150-000-9804', 
'43150-000-9805', 
'43150-000-9806', 
'43150-000-9807', 
'43150-000-9808', 
'43150-000-9809', 
'43150-000-9810', 
'43150-000-9811', 
'43150-000-9812', 
'43160-000-9800', 
'43160-000-9801', 
'43160-000-9802', 
'43160-000-9803', 
'43160-000-9804', 
'43160-000-9805', 
'43160-000-9806', 
'43160-000-9807', 
'43160-000-9808', 
'43160-000-9809', 
'43160-000-9810', 
'43160-000-9811', 
'43160-000-9812', 
'49100-000-9807', 
'49100-000-9808', 
'49100-000-9810', 
'70450-000-0000', 
'70450-100-0000', 
'70450-200-0000', 
'70450-300-0000', 
'70450-310-0000', 
'70450-320-0000', 
'70450-330-0000', 
'70450-340-0000', 
'70450-350-0000', 
'70450-360-0000', 
'70450-370-0000', 
'70450-810-0000', 
'70450-820-0000', 
'70450-850-0000', 
'70450-855-0000', 
'70450-860-0000', 
'70450-865-0000', 
'70450-870-0000', 
'70450-875-0000', 
'70450-880-0000'

)
/*
 * All missing TB accounts as of date.
 */
select *
-- select char(39) + account_no + char(39) + ','
-- select count(*)
--from Archive.tb_158_missing_accounts_2021_09 
from Archive.tb_159_missing_accounts_2021_11  -- 159 
from Archive.tb_391_missing_accounts_2022_01  -- 159+232=391

/*
 * New account added sometime in 2021-11
 */
-- select *
-- select count(*) 
from Archive.tb_159_missing_accounts_2021_11 m2 -- 159
left outer join Archive.tb_158_missing_accounts_2021_09 m3
on m2.pcn = m3.pcn 
and m2.account_no=m3.account_no
where m3.pcn is null

/*
 * New accounts added sometime after 2021-11
 */
-- select *
-- select '"' + m1.account_no + '",'
-- select count(*) 
from Archive.tb_391_missing_accounts_2022_01 m1 -- 391 - 159 = 232
left outer join Archive.tb_159_missing_accounts_2021_11 m2 -- 159
on m1.pcn = m2.pcn 
and m1.account_no=m2.account_no
where m2.pcn is null
order by m1.pcn,m1.account_no
