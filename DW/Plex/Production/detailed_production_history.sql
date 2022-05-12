create schema Validation
SELECT PCN, Plexus_Customer_Code
FROM mgdw.Plex.Enterprise_PCNs_Get;
-- mgdw.Validation.Detailed_Production_History definition

-- Drop table

-- DROP TABLE mgdw.Validation.Detailed_Production_History;

CREATE TABLE mgdw.Validation.Detailed_Production_History (
	PCN int NULL,
	Production_No int NULL,
	Workcenter_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Key int NULL,
	Revision varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--	Heat_Code_Heat_No varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, -- don't know what this is
--	Piece_Weight decimal(18,8) NULL,
--	Net_Weight decimal(19,5) NULL,
--	Material_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Serial_No varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Record_Date datetime2 NULL,
--	Sample_Weight decimal(19,5) NULL,
	Quantity decimal(19,5) NULL,
--	Gross_Weight decimal(19,5) NULL,
--	Tare_Weight decimal(19,5) NULL,
	Shift varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Workcenter_Type varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Standard_Production_Rate decimal(18,0) NULL, -- dont know
	Operation_Code varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Note varchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Job_No varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Tracking_No varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Master_Unit_No varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Location varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Add_By varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
);
-- truncate table Validation.Detailed_Production_History
select *
--select count(*)
from Validation.Detailed_Production_History  -- 587
where record_date < '2022-04-25 00:00:00.000'
172.20.88.16 
172.20.88.17
172.20.88.18
172.20.88.19

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
--select distinct pcn,period 
--from Plex.account_period_balance b order by pcn,period -- 123,681 (202101 to 202111)
from Plex.account_period_balance b -- 43,620
--where b.pcn = @pcn  -- 50,545
inner join Plex.accounting_account a -- 43,620
on b.pcn=a.pcn 
and b.account_no=a.account_no 
where b.pcn = 123681  -- 50,545,55,140
AND b.period BETWEEN @start_period AND @end_period
order by b.period_display,a.account_no 


insert into Validation.Detailed_Production_History (pcn,Production_No) 
values (12345,2)

INSERT INTO mgdw.Validation.Detailed_Production_History
--  If this fails it may be because all the input is a string.
--  may need to check for empty strings when converting to int.
SELECT
FROM @Xml.nodes('Row') AS tbl1(T1)
    CROSS APPLY T1.nodes('Columns') AS tbl2(T2)
"@