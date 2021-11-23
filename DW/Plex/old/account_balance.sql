-- drop table Plex.account_balance
-- truncate table Plex.account_balance
Period,Category Type,Category Name,Sub Category Name,No,Name,Current Debit/(Credit),YTD Debit/(Credit)
CREATE TABLE Plex.account_balance (
	pcn int NOT NULL,
	period int NOT NULL,
	category_type varchar(10),
	category_name varchar(50),
	sub_category_name varchar(50),
	[no] varchar(20),
	name varchar(110),
	current_debit decimal(18,2),
	current_credit decimal(18,2),
	current_debit_credit decimal(18,2),
	ytd_debit decimal(18,2),
	ytd_credit decimal(18,2),
	ytd_debit_credit decimal(18,2),  -- for debug 
	PRIMARY KEY (pcn,period,[No])
);
select * from Plex.account_balance

select 
period,
category_type,
'' category_name,
'' sub_category_name, -- Albion does has all blanks.
[no],
name,
--current_debit,current_credit,

--ytd_debit,ytd_credit,
--ytd,
subtotal_after,'' subtotal_name
-- Period,Category Type,Category Name,Sub Category Name,No,Name,Current Debit/(Credit),YTD Debit/(Credit)
-- select count(*)
select *
from Plex.account_balance b --4362
where b.period=202001


select * from Plex.Account_Balances_by_Periods abbp 
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

 */
