/*
@PCNList varchar(max) = '123681',
@Period_Range VARCHAR(20)='200812|202111'
*/

/*
create PCN table from param
*/
create table #list
(
 tuple int
)
declare @delimiter varchar(1)
set @delimiter = ','
declare @in_string varchar(max)
set @in_string = @PCNList
WHILE LEN(@in_string) > 0
BEGIN
    INSERT INTO #list
    SELECT cast(left(@in_string, charindex(@delimiter, @in_string+',') -1) as int) as tuple

    SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
end
--select tuple from #list
declare @Period_Min int
declare @Period_Max int
IF CHARINDEX('|',@Period_Range) < 8
BEGIN 
  SET
    @Period_Min = CAST( LEFT ( @Period_Range, 6 ) AS INT );
  SET
    @Period_Max = CAST( RIGHT( @Period_Range, 6 ) AS INT );
END 
ELSE
BEGIN
  SET
    @Period_Min = CAST( LEFT ( @Period_Range, 8 ) AS INT );
  SET
    @Period_Max = CAST( RIGHT( @Period_Range, 8 ) AS INT );
END;
select @Period_Min period_min,@Period_Max period_max
DECLARE @PCN_Currency_Code CHAR(3);
set @PCN_Currency_Code = 'USD'
-- select @PCN_Currency_Code

CREATE TABLE #Accounts
(
  pcn INT NOT NULL,
  account_no VARCHAR(20) NOT NULL,
  account_name varchar(110),
  category_type varchar(10),
  multiplier int, 
  --/*  -- 17
  PRIMARY KEY CLUSTERED
  (
    pcn,account_no
  )
  --*/
);
--CREATE NONCLUSTERED INDEX IX_Accounts ON #Accounts(pcn, account_no);  -- same time as primary key clustered with 2 pcn
INSERT #Accounts
(
  pcn,
  account_no,
  account_name,
  category_type,
  multiplier
)
SELECT 
  a.plexus_customer_no pcn,
  Account_No,
  Account_Name,
  a.category_type,
  case
  when t.[in] = 'Debit' then 1
  when t.[in] = 'Credit' then -1
  else 0 -- this should never happen.
  end multiplier
FROM accounting_v_Account_e a
--select * from accounting_v_category_type
join accounting_v_category_type t
on a.category_type=t.category_type -- 36,636
--WHERE Plexus_Customer_No = @PCN
where a.plexus_customer_no in
(
 select tuple from #list
)
and left(a.account_no,1) < '4'  -- 661


declare @account_count int
select @account_count=count(*) from #Accounts
--select count(*) accounts from #Accounts  -- 661

/*
-- DEBUG ONLY
-- FIND starting account balance period.
--select count(*) from @Periods_All pa 
select a.pcn,a.account_no,min(b.period) start_period
into #StartPeriod
from #Accounts a
inner join accounting_v_balance_e b
on a.pcn=b.plexus_customer_no
and a.account_no=b.account_no
group by a.pcn,a.account_no
order by a.pcn,a.account_no
*/
--select * from #StartPeriod p where p.start_period != 201812


CREATE TABLE #accounting_account_balance
-- account_no	start_period	debit	credit	YTD
(
  pcn INT NOT NULL,
  account_no VARCHAR(20) NOT NULL,
  period int not null,
  debit decimal(19,5),
  credit decimal(19,5),
  balance decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_no,period
  )
);
insert into #accounting_account_balance
select b.plexus_customer_no pcn,b.account_no,b.period,b.debit,b.credit, 
(b.debit-b.credit) * a.multiplier balance
from accounting_v_balance_e b
join #Accounts a
on b.plexus_customer_no=a.pcn
and b.account_no=a.account_no
where b.plexus_customer_no in
(
   select tuple from #list
)
and b.period between @Period_Min and @Period_Max

--where p.account_no in ('10000-000-00000','10220-000-00000','10250-000-00000','10305-000-01704','11900-000-0000','11010-000-0000','20100-000-0000','41100-000-0000','50100-200-0000','51450-200-0000')

select * from #accounting_account_balance
