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

select s.pcn,s.period, s.account_no,s.debit,s.credit,s.net
--select count(*)
from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
where s.period = 202001

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


