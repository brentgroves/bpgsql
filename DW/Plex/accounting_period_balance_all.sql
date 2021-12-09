select * 
-- drop table Plex.accounting_period_balance_all
into Plex.accounting_period_balance_all
from 
(
select l.pcn,l.period,l.account_no,l.debit,l.ytd_debit,l.credit,l.ytd_credit,l.balance,l.ytd_balance 
-- select count(*)
from Plex.accounting_period_balance_low l  -- 3,710
where l.period between 202101 and 202110
union
select * 
-- select count(*)
from Plex.accounting_period_balance_high  -- 37,230 + 3,710 = 40,940
)s  -- 40,940
-- select distinct pcn,period from Plex.accounting_period_balance_low b order by pcn,period --goes from 200701 to 202111
-- select distinct pcn,period from Plex.accounting_period_balance_high b order by pcn,period --goes from 202101 to 202110
