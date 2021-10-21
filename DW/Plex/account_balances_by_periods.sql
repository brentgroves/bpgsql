-- drop table Plex.Account_Balances_by_Periods
create table Plex.Account_Balances_by_Periods
(
 pcn int,
 revenue decimal(19,5),
 expense decimal(19,5),
 amount decimal(19,5),
 period int,
 Period_Display VARCHAR(10),
 Category_Type VARCHAR(10),
 Category_No INT,
 Category_Name VARCHAR(50),
 [No] VARCHAR(20),
 [Name] VARCHAR(110),
 Ytd_Debit DECIMAL(18,2),
 Ytd_Credit DECIMAL(18,2),
 Current_Debit DECIMAL(18,2),
 Current_Credit DECIMAL(18,2),
 Sub_Category_No INT ,
 Sub_Category_Name VARCHAR(50) ,
 Subtotal_After INT, -- Unused
 Subtotal_Name VARCHAR(50) -- Unused
)
select * from Plex.Account_Balances_by_Periods

-- delete from Plex.Account_Balances_by_Periods WHERE pcn in (123681,300758)
