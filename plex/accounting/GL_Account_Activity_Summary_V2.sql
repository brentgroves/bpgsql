/*
This is a modified version of GL_Account_Activity_Detail_Report that returns 1 record 
for each account that has any activitity for the specified period.
V2 changes: Used CTE instead of temp tables. Takes 30 seconds instead of 60 with CTE for 1 period and 2 pcn.
*/


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
end;
--select tuple from #list

/*
If the period spans years this does not make sense.
*/
declare @year int;
set @year = @Period / 100;
--select @year;


DECLARE @PCN_Currency_Code CHAR(3);
set @PCN_Currency_Code = 'USD'
-- select @PCN_Currency_Code
CREATE TABLE #Accounts
(
  pcn INT NOT NULL,
  account_no VARCHAR(20) NOT NULL,
  account_name varchar(110),
--  category_type varchar(10),
  --/*  -- 17
  PRIMARY KEY CLUSTERED
  (
    pcn,account_no
  )
  --*/
);
--CREATE NONCLUSTERED INDEX IX_Accounts ON #Accounts(pcn, account_no);  -- same time as primary key clustered with 2 pcn

-- https://www.sqlservertutorial.net/sql-server-basics/sql-server-cte/
-- Make a view of all invoice distribution records filtered by period.
-- Min columns in filtered expression.
-- This detail record view will be used retrieve summary data.
with cte_accounts(pcn,account_no,account_name,category_type) as
(
SELECT 
  a.plexus_customer_no pcn,
  account_no,
  account_name,
  category_type
FROM accounting_v_Account_e a
--WHERE Plexus_Customer_No = @PCN
where a.plexus_customer_no in
(
 select tuple from #list
)
),
CTE_AP_Invoice_Dist(pcn,account_no,debit,credit) AS
--with CTE_AP_Invoice_Dist AS
(
  select i.plexus_customer_no pcn,D.Account_No,d.debit,d.credit
  FROM accounting_v_AP_Invoice_Dist_e AS D 
  join cte_accounts a
  on d.plexus_customer_no=a.pcn
  and d.account_no=a.account_no 
  JOIN accounting_v_AP_Invoice_e AS I  
--  join Accelerated_AP_Invoice_v_e I -- no invoice_link so cant use
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
    AND I.Period BETWEEN @Period AND @Period
--    AND I.Period = @Period  -- VERY SLOW COMPARED TO BETWEEN
),
CTE_AP_Check_Dist2(pcn,account_no,debit,credit) AS
--with CTE_AP_Invoice_Dist AS
(
  select i.plexus_customer_no pcn,D.Account_No,d.debit,d.credit
  FROM accounting_v_AP_Check_Dist2_e AS D 
  join cte_accounts a
  on d.plexus_customer_no=a.pcn
  and d.account_no=a.account_no
  JOIN accounting_v_AP_Check_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Check_Link = D.Check_Link
    AND I.Period BETWEEN @Period AND @Period
--    AND I.Period = @Period
),
CTE_AR_Invoice_Dist(pcn,account_no,debit,credit) AS
--with CTE_AP_Invoice_Dist AS
(
  select i.plexus_customer_no pcn,D.Account_No,d.debit,d.credit
  FROM accounting_v_AR_Invoice_Dist_e AS D 
  join cte_accounts a
  on d.plexus_customer_no=a.pcn
  and d.account_no=a.account_no
  JOIN accounting_v_AR_Invoice_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
    AND I.Void = 0
    AND I.Period BETWEEN @Period AND @Period
--    AND I.Period = @Period
),
CTE_AR_Invoice_Applied_Dist2(pcn,account_no,debit,credit) AS
--with CTE_AP_Invoice_Dist AS
(
  select a.plexus_customer_no pcn,D.Account_No,d.debit,d.credit
  FROM accounting_v_AR_Invoice_Applied_Dist2_e AS D 
  join cte_accounts a
  on d.plexus_customer_no=a.pcn
  and d.account_no=a.account_no
  JOIN accounting_v_AR_Invoice_Applied_e AS A 
    ON A.Plexus_Customer_No = D.Plexus_Customer_No 
    AND A.Applied_Link = D.Applied_Link
    AND A.Period BETWEEN @Period AND @Period
  JOIN accounting_v_AR_Invoice_e AS I 
    ON I.Plexus_Customer_No = A.Plexus_Customer_No
    AND I.Invoice_Link = A.Invoice_Link
--    AND I.Period = @Period
),
CTE_AR_Deposit_Dist(pcn,account_no,debit,credit) AS
--with CTE_AP_Invoice_Dist AS
(
  select i.plexus_customer_no pcn,D.Account_No,d.debit,d.credit
  FROM accounting_v_AR_Deposit_Dist_e AS D 
  join cte_accounts a
  on d.plexus_customer_no=a.pcn
  and d.account_no=a.account_no
  JOIN accounting_v_AR_Deposit_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Deposit_Link = D.Deposit_Link
    AND I.Period BETWEEN @Period AND @Period
--    AND I.Period = @Period
),
CTE_GL_Journal_Dist(pcn,account_no,debit,credit) AS
--with CTE_AP_Invoice_Dist AS
(
  select i.plexus_customer_no pcn,D.Account_No,d.debit,d.credit
  FROM accounting_v_GL_Journal_Dist_e AS D 
  join cte_accounts a
  on d.plexus_customer_no=a.pcn
  and d.account_no=a.account_no
  JOIN accounting_v_GL_Journal_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Journal_Link = D.Journal_Link
    AND ( @Exclude_Period_13 = 0 OR I.Period_13 = 0 )
    AND ( @Exclude_Period_Adjustments = 0 OR I.Period_Adjustment = 0 )
    AND I.Period BETWEEN @Period AND @Period
--    AND I.Period = @Period
)

/*
  SELECT     i.plexus_customer_no pcn,i.period,d.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_GL_Journal_Dist_e AS D 
  JOIN accounting_v_GL_Journal_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Journal_Link = D.Journal_Link
    AND ( @Exclude_Period_13 = 0 OR I.Period_13 = 0 )
    AND ( @Exclude_Period_Adjustments = 0 OR I.Period_Adjustment = 0 )
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A6
    ON A6.PCN = D.Plexus_Customer_No
    AND A6.Account_No = D.Account_No
    group by i.plexus_customer_no,i.period,d.Account_No   
    having i.plexus_customer_no in
    (
     select tuple from #list
    )

*/
--/*
/*
Add revenue,expense,amount
*/
select
--s.period,
--p.period_display,
--a.category_type,
--0 category_no,
--'' category_name,
s.pcn,
@year year,  
@Period period,
s.account_no,
--a.account_name,
s.debit,
s.credit
from 
(
SELECT
  ap.pcn,
  ap.account_no,
--  ap.account_name,
  sum(ap.debit) debit,sum(ap.credit) credit  
from CTE_AP_Invoice_Dist ap
group by ap.pcn,ap.account_no  
union
SELECT
  ac.pcn,
  ac.account_no,
--  ap.account_name,
  sum(ac.debit) debit,sum(ac.credit) credit  
from CTE_AP_Check_Dist2 ac
group by ac.pcn,ac.account_no  
union
SELECT
  ai.pcn,
  ai.account_no,
--  ap.account_name,
  sum(ai.debit) debit,sum(ai.credit) credit  
from CTE_AR_Invoice_Dist ai
group by ai.pcn,ai.account_no  
union
SELECT
  ia.pcn,
  ia.account_no,
--  ap.account_name,
  sum(ia.debit) debit,sum(ia.credit) credit  
from CTE_AR_Invoice_Applied_Dist2 ia
group by ia.pcn,ia.account_no  
union
SELECT
  dd.pcn,
  dd.account_no,
--  ap.account_name,
  sum(dd.debit) debit,sum(dd.credit) credit  
from CTE_AR_Deposit_Dist dd
group by dd.pcn,dd.account_no  
union
SELECT
  jd.pcn,
  jd.account_no,
--  ap.account_name,
  sum(jd.debit) debit,sum(jd.credit) credit  
from CTE_GL_Journal_Dist jd
group by jd.pcn,jd.account_no  
--CTE_GL_Journal_Dist

)s
--ORDER BY  s.pcn,s.Period,a.account_no

--*/
--select count(*) CTE_AP_Invoice_Dist from CTE_AP_Invoice_Dist;
--select * from #Accounts;