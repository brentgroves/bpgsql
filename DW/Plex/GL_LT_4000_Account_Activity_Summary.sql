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
--select * from Plex.Account_Balances_by_Periods abbp 
-- 
--select * from Plex.GL_LT_4000_Account_YTD_Summary where account_no in ('10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000')
