-- drop table Plex.account_balance
-- truncate table Plex.account_balance
CREATE TABLE Plex.account_balance (
	pcn int NOT NULL,
	revenue decimal(19,5) NULL,  -- Always null for now  
	expense decimal(19,5) NULL, -- Always null for now
	amount decimal(19,5) NULL, -- Always null for now
	period int NOT NULL,
	Period_Display varchar(10),
	Category_Type varchar(10),
	Category_No int NULL,
	Category_Name varchar(50),
	[No] varchar(20),
	Name varchar(110),
	Ytd_Debit decimal(18,2),
	Ytd_Credit decimal(18,2),
	Current_Debit decimal(18,2),
	Current_Credit decimal(18,2),
	Sub_Category_No int,
	Sub_Category_Name varchar(50),
	Subtotal_After int,
	Subtotal_Name varchar(50),
	PRIMARY KEY (pcn,period,[No])
);
select * from Plex.account_balance
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
