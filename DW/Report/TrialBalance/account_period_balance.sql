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

/*
 * BACKUP
 */
select * 

--into Archive.account_period_balance_06_01_2022 -- 132428
from mgdw.Plex.account_period_balance
where account_no = '39100-000-0000'
ORDER BY pcn,period
--SELECT count(*) FROM Archive.account_period_balance_06_01_2022 
select *
from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
where s.pcn = 123681 
and s.account_no = '39100-000-0000'
ORDER BY pcn,period
and s.period between 202101 and 202201  -- 2,462/2,718/2,975

SELECT DISTINCT pcn, period 
FROM Plex.account_period_balance

ORDER BY pcn, period
/*
 * For Power BI report
 */
drop PROCEDURE Report.trial_balance
exec Report.trial_balance 202105,202205
CREATE PROCEDURE Report.trial_balance
@start_period int,
@end_period int 
AS 
begin

select 
--b.period,
b.period_display,
a.category_type,
-- don't use legacy category type even though it is on the real TB report. I think it will be less confusing 
-- for the Southfield PCN which hass missing accounts.
-- b.category_type_legacy category_type,  
/*
 * The Plex TB report uses the category type of the category linked to the account via the  category_account view. 
 * I believe Plex now mostly uses the account category located directly on the accounting_v_account view so I used 
 * this column instead of the one linked via the account_category view. 
 */
a.category_name_legacy category_name,
a.sub_category_name_legacy sub_category_name,
a.account_no,
--a.account_no [no],
a.account_name,
b.balance current_debit_credit,
b.ytd_balance ytd_debit_credit
--select count(*)
--select distinct pcn,period from Plex.account_period_balance b order by pcn,period -- 123,681 (202101 to 202111)
from Plex.account_period_balance b -- 43,620
--where b.pcn = @pcn  -- 50,545
inner join Plex.accounting_account a -- 43,620
on b.pcn=a.pcn 
and b.account_no=a.account_no 
where b.pcn = 123681  -- 50,545,55,140
AND b.period BETWEEN @start_period AND @end_period
order by b.period,a.account_no 
--where a.category_type != a.category_type_legacy 
--where b.period_display is not NULL -- 40,940
--where b.period_display is NULL -- 40,940
--where a.account_no = '10220-000-00000' 
END;


