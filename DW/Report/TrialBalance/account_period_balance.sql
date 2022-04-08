-- mgdw.Plex.account_period_balance definition

-- Drop table

-- DROP TABLE mgdw.Plex.account_period_balance;

CREATE TABLE mgdw.Plex.account_period_balance (
	pcn int NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NULL,
	period_display varchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	debit decimal(19,5) NULL,
	ytd_debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	ytd_credit decimal(19,5) NULL,
	balance decimal(19,5) NULL,
	ytd_balance decimal(19,5) NULL
);

select * from mgdw.Plex.account_period_balance
where account_no = '39100-000-0000'
ORDER BY pcn,period

select *
from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
where s.pcn = 123681 
and s.account_no = '39100-000-0000'
ORDER BY pcn,period
and s.period between 202101 and 202201  -- 2,462/2,718/2,975

SELECT DISTINCT pcn, period 
FROM Plex.account_period_balance

ORDER BY pcn, period