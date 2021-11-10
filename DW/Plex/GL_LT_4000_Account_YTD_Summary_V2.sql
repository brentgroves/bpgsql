/*
This is a modified version of GL_Account_Activity_Detail_Report that returns 1 record 
for each account that has any activitity for the specified period.
For accounts starting with 4 or above you can sum the prior periods.
*/
/*
PARAMETERS
@PCNList varchar(max) = '123681',
@PeriodStart INT =200812,
@PeriodEnd INT =201912,
@Exclude_Period_13 SMALLINT = 0,
@Exclude_Period_Adjustments BIT = 0*/

-- CREATE NONCLUSTERED INDEX IX_Invoices ON #Invoices (Plexus_Customer_No, Part_Key, Ship_To_Address);
-- I dont thing we need to create an index if we put a primary key clustered in the table definition.
/*
Clustered indexes only sort tables. Therefore, they do not consume extra storage. 
Non-clustered indexes are stored in a separate place from the actual table claiming more storage space. 
Clustered indexes are faster than non-clustered indexes since they don't involve any extra lookup step.Aug 28, 2017
*/

/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681 / Southfield
2	295932 FruitPort
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
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

--select count(*) accounts from #Accounts  -- 661

select a.pcn,a.account_no,min(b.period) start_period
into #Start_Period
from #Accounts a
inner join accounting_v_balance_e b
on a.pcn=b.plexus_customer_no
and a.account_no=b.account_no
group by a.pcn,a.account_no
order by a.pcn,a.account_no

select 
a.*,
isnull(s.start_period,201812) start_period -- accounts with no start period have no activity
into #AccountsWithStartPeriod
from #Accounts a
left outer join #Start_Period s 
on a.pcn=s.pcn 
and a.account_no=s.account_no 

--select count(*) Start_Period from #Account_with_Start_Period  -- 398
select * from #AccountsWithStartPeriod s  -- 398
where s.account_no in ('10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','20100-000-0000','41100-000-0000','50100-200-0000','51450-200-0000')

/*
What period should we start in if there are no accounting_v_account_balance records?
like in account: 10305-000-00817
Joined #No_Account_Balance_Recs with #final_summary and found there is no activity for these accounts?

select a.*
into #No_Account_Balance_Recs
from #Accounts a 
left outer join #Start_Period s 
on a.pcn=s.pcn 
and a.account_no=s.account_no 
where s.pcn is null
*/
--and a.account_no > '40000-000-0000' 
--and a.account_no between '40000-000-0000' and '99999-000-0000'
--  AND (CHARINDEX( '|' + RTRIM(Account_No) + '|' , '|' + ISNULL(NULLIF(@Account_No,''),'') + '|' , 0) > 0  );
--select count(*) accounts from #Accounts  -- 3413/Albion
--select * from #Accounts  -- 3413/Albion

/*
CREATE TABLE GL_Account_Activity_Summary_Report
(
  pcn INT NOT NULL,
  period int not null,
  account_no VARCHAR(20) NOT NULL,
  account_name varchar(110),
  debit decimal(19,5),
  credit decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,period,account_no
  )
);
select min(period) from accounting_v_AP_Invoice_e  --200903
*/

/*
--DEBUG #AccountsWithStartPeriod JOIN FOR 20100-000-000
*/
SELECT
  t1.pcn,
  a.Account_No,
  a.account_name,
  sum(t1.debit) debit,sum(t1.credit) credit  
--  t1.[Description],
into #Final_Summary
FROM (
  SELECT
  i.plexus_customer_no pcn,D.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_AP_Invoice_Dist_e AS D 
  JOIN accounting_v_AP_Invoice_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
--    select count(*) from accounting_v_AP_Invoice_e AS I  where i.period > 202111 - 0 records
--    AND I.Period BETWEEN @PeriodStart AND @PeriodEnd -- faster than =
  JOIN #AccountsWithStartPeriod AS A
    ON A.PCN = D.Plexus_Customer_No
    AND A.Account_No = D.Account_No
    AND I.Period BETWEEN a.start_period AND @PeriodEnd -- faster than =
--  LEFT OUTER JOIN Common_v_Supplier_e AS S 
--    ON S.Plexus_Customer_No = I.Plexus_Customer_No
--    AND S.Supplier_No = I.Supplier_No

    group by i.plexus_customer_no,D.Account_No
    having i.plexus_customer_no in
    (
     select tuple from #list
    )
    --AND I.Period BETWEEN @PeriodStart AND @PeriodEnd -- faster than =

    --having i.plexus_customer_no = @PCN
--  group by @PCN,I.Period,D.Account_No,S.Name,D.[Description]   
--  having D.Plexus_Customer_No = @PCN

  UNION ALL
  --++--
  SELECT i.plexus_customer_no pcn,d.Account_No,sum(d.debit) debit,sum(d.credit) credit

  FROM accounting_v_AP_Check_Dist2_e AS D 
  JOIN accounting_v_AP_Check_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Check_Link = D.Check_Link
--    select count(*) from accounting_v_AP_Check_e AS I  where i.period > 202111 -- 0 records
 --   AND I.Period BETWEEN @PeriodStart AND @PeriodEnd -- faster than =
  JOIN #AccountsWithStartPeriod AS A2
    ON A2.PCN = D.Plexus_Customer_No
    AND A2.Account_No = D.Account_No
    AND I.Period BETWEEN a2.start_period AND @PeriodEnd -- faster than =

    group by i.plexus_customer_no,d.Account_No   
    having i.plexus_customer_no in
    (
     select tuple from #list
    )
) t1
JOIN #Accounts AS A 
  ON A.PCN = t1.PCN
  AND A.Account_No = t1.Account_No
group by t1.pcn,A.Account_No,A.account_name   
ORDER BY  
  t1.pcn,a.account_no
  
select 
s.pcn,
@PeriodEnd period,
s.account_no,
--a.category_type,
s.debit,
s.credit,
--s.credit-s.debit CreditMinusDebit,s.debit-s.credit DebitMinusCredit 
case
when a.multiplier=1 then s.debit-s.credit 
when a.multiplier=-1 then s.credit-s.debit
when a.multiplier=0 then 0
end YTD
from #Final_Summary s
--join #No_Account_Balance_Recs a -- Debug, Is there any activity for these accounts? NO
join #Accounts a  -- 225
on s.pcn=a.pcn
and s.account_no=a.account_no
--where s.account_no in ('20100-000-0000')
where s.account_no in ('10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','20100-000-0000','41100-000-0000','50100-200-0000','51450-200-0000')
/*
@PeriodStart INT =200812,
@PeriodEnd INT =201912,
*/