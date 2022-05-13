/*
 * If the category_type is 'Revenue' or 'Expense' NO reset of YTD credit/debit values will occur in the TB report.
 */
/*
account
(
pcn,account_key,account_no,account_name,active,
category_type,
category_no_legacy,
category_name_legacy,
category_type_legacy,
sub_category_no_legacy,
sub_category_name_legacy,
sub_category_type_legacy,
revenue_or_expense,start_period
)
-- mgdw.Plex.accounting_account definitionF

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_account;

CREATE TABLE mgdw.Plex.accounting_account (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20),
	account_name varchar(110),
	active bit NULL,
	category_type varchar(10),
	category_no_legacy int NULL,
	category_name_legacy varchar(50),
	category_type_legacy varchar(10),
	sub_category_no_legacy int,
	sub_category_name_legacy varchar(50),
	sub_category_type_legacy varchar(10),
	revenue_or_expense bit NULL,
	start_period int NULL,
	PRIMARY KEY (pcn,account_key)
);
 */
-- select count(*) cnt from Scratch.accounting_account_12_15  -- 18,010

		select r.pcn,r.account_no 
		from Plex.Reset_YTD_balance_yearly r
		where r.pcn = 123681
		order by r.pcn,r.account_no
SELECT count(*)
from Plex.accounting_account a 	-- 19,176	
/*
 * What are the new accounts?
 */		
select a.* 
-- select count(*)
--into Archive.accounting_account_2022_03_21 -- 19,176
-- into Archive.accounting_account_2022_02_16 
--into Scratch.accounting_account_12_15
-- select count(*) from Archive.accounting_account_pre_additions_01_07
-- select * from Archive.accounting_new_accounts_01_07
--into Archive.accounting_account_pre_additions_01_07
-- into Archive.accounting_new_accounts_01_07
from Plex.accounting_account a -- 19,176
left outer join Archive.accounting_account_pre_additions_01_07 o
on a.pcn = o.pcn 
and a.account_no = o.account_no 
where a.pcn = 123681 -- 4,362/4,595 -- one more has been added since 12/15
and o.pcn is null  -- 232 new accounts

		
select * 
-- select count(*)
--into Scratch.accounting_account_12_15
-- select count(*) from Archive.accounting_account_pre_additions_01_07
--into Archive.accounting_account_pre_additions_01_07
from Plex.accounting_account aa -- 18,015, 
WHERE account_no like '73250%' --0 
where pcn = 123681 -- 4,362/4,595 -- one more has been added since 12/15
and category_type in ('Revenue','Expense') -- 3,723
and left(account_no,1) < '4'  -- 22
order by aa.account_no -- 20104-300-00000 to 30600-300-00000
where pcn = 123681 -- 4,362 -- one more has been added since 12/15
and category_type not in ('Revenue','Expense') -- 3,723
and left(account_no,1) > '3'  -- 0

where pcn = 123681 -- 4,362 -- one more has been added since 12/15
and category_type NOT in ('Revenue','Expense') -- 639  -- one more has been added since 12/15
and left(account_no,1) > '4'  -- 0


where pcn = 123681 
and category_type in ('Revenue','Expense')
and left(account_no,1) > '4'  -- 0

/*
 * If the category_type is not 'Revenue' or 'Expense' a reset of YTD credit/debit values will occur in the TB report.
 */
select * from Plex.accounting_account aa 
where category_type not in ('Revenue','Expense')
and left(account_no,1) > '3'  -- 0 records
where account_no like '27800-000%'  -- debit balance/old debit_balance diff 27800-000-9806
and pcn = 123681