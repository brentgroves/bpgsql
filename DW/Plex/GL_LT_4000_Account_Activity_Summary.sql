--GL_LT_4000_Account_Activity_Summary
-- drop table Plex.GL_LT_4000_Account_YTD_Summary
--truncate table Plex.GL_LT_4000_Account_YTD_Summary
CREATE TABLE Plex.GL_LT_4000_Account_YTD_Summary
(
  pcn INT NOT NULL,
  period int not NULL,
  account_no VARCHAR(20) NOT NULL,
--  account_name varchar(110),
--  category_type varchar(10),
  debit decimal(19,5),
  credit decimal(19,5),
  YTD decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_no,period
  )
);
-- select * from Plex.accounting_account aa 
-- select * from Plex.accounting_account aa 
--select * from Plex.Account_Balances_by_Periods abbp 
-- select count(*) from Plex.GL_LT_4000_Account_YTD_Summary  -- 366
select s.pcn,s.period,s.account_no,a.active,a.debit_main,s.debit,s.credit,s.YTD from Plex.GL_LT_4000_Account_YTD_Summary s 
inner join Plex.accounting_account a 
on s.pcn=a.pcn 
and s.account_no=a.account_no 
where s.account_no in ('10000-000-00000','10305-000-01704','10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','20100-000-0000')

/*
 * How many account values match between the trial balance and account activity detail
 * for 2019-12
 * Get Trial Balance values from account_v_balance.
 * select distinct pcn,period from Plex.Account_Balances_by_Periods where period = 202001
 * select * from Plex.
 * Get Account Activity Detail values from Plex.GL_Account_Activity_Summary
 * select distinct pcn,period from Plex.GL_Account_Activity_Summary
 * select * from Plex.GL_Account_Activity_Summary where period = 202001
 */
select s.pcn,s.period,s.account_no,a.active,a.debit_main,s.debit,s.credit,s.YTD 
from Plex.GL_Account_Activity_Summary d
Plex.GL_LT_4000_Account_YTD_Summary s 
inner join Plex.accounting_account a 
on s.pcn=a.pcn 
and s.account_no=a.account_no 
where s.account_no in ('10000-000-00000','10305-000-01704','10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','20100-000-0000')
Plex.GL_Account_Activity_Summary
10220-000-00000	772750612.53000	766397182.63000	6353429.90000
10250-000-00000	205936.48000	205936.48000	0.00000
11010-000-0000	58396150.35000	54716582.11000	3679568.24000
11900-000-0000	638633.22000	572277.51000	66355.71000
