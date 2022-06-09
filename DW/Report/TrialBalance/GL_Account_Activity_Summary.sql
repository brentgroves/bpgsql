-- drop table Plex.GL_Account_Activity_Summary
-- truncate table Plex.GL_Account_Activity_Summary
CREATE TABLE Plex.GL_Account_Activity_Summary
(
  pcn INT NOT NULL,
  period int not null,
  account_no VARCHAR(20) NOT NULL,
  debit decimal(19,5),
  credit decimal(19,5),
  net decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,period,account_no
  )
);
/*
	a.pcn,
	'' revenue,  -- the account_balances_by_periods plex authored procedure shows only blank values in the query and csv file for Albion and Southfield.
	'' expense, -- the account_balances_by_periods plex authored procedure shows only blank values in the query and csv file for Albion and Southfield.
	'' amount, -- the account_balances_by_periods plex authored procedure shows only blank values in the query and csv file for Albion and Southfield.
	s.period, 
	--cast(s.year as varchar) + '-' + cast(s.period as varchar),
	'2021-09' period_display,  
	a.category_type,
	0 category_no,  -- Albion has all zeros.
	'' category_name, -- Albion has all blanks.
	a.account_no [no],
	a.account_name name,
	0 ytd_debit,--GL_Account_Activity_Summary_YTD
	0 ytd_credit,--GL_Account_Activity_Summary_YTD
	case
	when s.pcn is null then 0 
	else s.debit 
	end current_debit,
	case
	when s.pcn is null then 0 
	else s.credit 
	end current_credit,
	0 sub_category_no,  -- Albion has all zeros. select * from Plex.Account_Balances_by_Periods b where b.pcn = 300758
	'' sub_category_name, -- Albion does has all blanks.
	0 subtotal_after, -- Albion has all zeros. select distinct(subtotal_after) from Plex.Account_Balances_by_Periods b where b.pcn = 300758
	'' subtotal_name -- Albion has all zeros.
select * from Plex.accounting_period
where period between 202202 and 202204 and pcn = 123681
 */
/*
 * Make a backup
 */
select s.pcn,s.period, s.account_no,s.debit,s.credit,s.net
-- select distinct pcn,period
--select count(*)
--select *
--into Archive.GL_Account_Activity_Summary_06_04_2022 --39,836
--into Archive.GL_Account_Activity_Summary_06_01_2022 --39,612
--into Archive.GL_Account_Activity_Summary_05_13_2022 --39,355
--into Archive.GL_Account_Activity_Summary_04_08_2022 --39,356
--into Archive.GL_Account_Activity_Summary_04_07_2022 --38,876
--into Archive.GL_Account_Activity_Summary_01_27_2022 38,377
from Plex.GL_Account_Activity_Summary s  --(),(221,202010)  -- 38,208/38,377/38,634
where s.period = 202205  -- 223

--where s.period = 202201  --243/242
--where s.period = 202202  --230
--where s.period = 202203  --251/250
--where s.period = 202204  -- 254
where s.account_no like '73250%' --0 
left outer join Archive.GL_Account_Activity_Summary_04_08_2022 a --39,356
on s.pcn = a.pcn
and s.period = a.period 
and s.account_no = a.account_no
where s.period = 202203  --250
--and s.debit != a.debit  -- 3
and s.credit != a.credit  -- 1


select *
--into Archive.GL_Account_Activity_Summary_04_07_2022  -- 38,876
--into Archive.GL_Account_Activity_Summary_01_07_2022  -- 38,208
from Plex.GL_Account_Activity_Summary s  --(),(221,202010)

select s.pcn,s.period, s.account_no,s.debit,s.credit,s.net
-- select distinct pcn,period
--select count(*)
--select *
--into Archive.GL_Account_Activity_Summary_04_08_2022 --39,356
--into Archive.GL_Account_Activity_Summary_04_07_2022 --38,876
--into Archive.GL_Account_Activity_Summary_01_27_2022 38,377
from Plex.GL_Account_Activity_Summary s  --(),(221,202010)  -- 39,845/38,208/38,377/38,634
where s.period = 202205  --233/224
--where s.period = 202204  --254
--where s.period = 202203  --250
--where s.period = 202202  --229
--where s.period = 202111  --87/256
order by pcn,period

-- join select * from Plex.accounting_account as the primary set
select s.pcn,s.period, s.account_no,s.account_name,s.debit,s.credit,s.debit-credit period_diff,
b.current_debit,b.current_credit,b.ytd_debit,b.ytd_credit,b.ytd_debit-b.ytd_credit ytd_diff
--select count(*)
from Plex.GL_Account_Activity_Summary s
left outer join Plex.Account_Balances_by_Periods_View b 
on s.pcn=b.pcn
and s.account_no=b.no
--where s.pcn = 300758  -- 364/Albion
where s.pcn = 123681  -- 74
and s.account_no = '12400-000-0000' --	Raw Materials - Purchased Components
and s.account_no = '11010-000-0000' --	AR - Trade, Products
and s.account_no = '10120-000-0000' --	Cash Operating Wells Fargo-General-General


--select count(*)
--select b.*
from Plex.GL_Account_Activity_Summary s
--left outer join Plex.Account_Balances_by_Periods_View b -- 264
-- left outer join Plex.Account_Balances_by_Periods b -- 525 contains total
on s.pcn=b.pcn
and s.account_no=b.no
--where s.pcn = 300758  -- 364/Albion
where s.pcn = 123681  -- 74

select count(*)
--select s.*
from Plex.GL_Account_Activity_Summary s
where s.pcn = 123681  -- 264

select * 
select count(*)
from Plex.GL_Account_Activity_Summary s
--where account_no = '10120-000-0000'
where s.pcn = 123681  -- 264
and s.period = 202101
and s.period = 202109
where s.pcn = 300758  -- 364
and s.period = 202109 -- 364


