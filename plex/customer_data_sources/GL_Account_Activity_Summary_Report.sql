/* THIS IS NOT A CUSTOMER DATA SOURCE
This is a modified version of GL_Account_Activity_Detail_Report that returns 1 record 
for each account that has any activitity for the specified period.
*/


CREATE TABLE #Accounts
(
  PCN INT NOT NULL,
  Account_No VARCHAR(20) NOT NULL,
  account_name varchar(110),
  PRIMARY KEY CLUSTERED
  (
    Account_No
  )
);
-- CREATE NONCLUSTERED INDEX IX_Invoices ON #Invoices (Plexus_Customer_No, Part_Key, Ship_To_Address);
-- I dont thing we need to create an index if we put a primary key clustered in the table definition.
/*
Clustered indexes only sort tables. Therefore, they do not consume extra storage. 
Non-clustered indexes are stored in a separate place from the actual table claiming more storage space. 
Clustered indexes are faster than non-clustered indexes since they don't involve any extra lookup step.Aug 28, 2017
*/



DECLARE @PCN_Currency_Code CHAR(3);
set @PCN_Currency_Code = 'USD'
-- select @PCN_Currency_Code

INSERT #Accounts
(
  PCN,
  Account_No,
  Account_Name
)
SELECT 
  @PCN,
  Account_No,
  Account_Name
FROM accounting_v_Account_e
WHERE Plexus_Customer_No = @PCN
--  AND (CHARINDEX( '|' + RTRIM(Account_No) + '|' , '|' + ISNULL(NULLIF(@Account_No,''),'') + '|' , 0) > 0  );
--select * from #Accounts  

SELECT
  t1.pcn,
  t1.Period,
  t1.Account_No,sum(t1.debit) debit,sum(t1.credit) credit  
--  t1.[Description],
FROM (
  SELECT
  i.plexus_customer_no pcn,i.period,D.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_AP_Invoice_Dist_e AS D 
  JOIN accounting_v_AP_Invoice_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A
    ON A.PCN = D.Plexus_Customer_No
    AND A.Account_No = D.Account_No
--  LEFT OUTER JOIN Common_v_Supplier_e AS S 
--    ON S.Plexus_Customer_No = I.Plexus_Customer_No
--    AND S.Supplier_No = I.Supplier_No
    group by i.plexus_customer_no,i.period,D.Account_No
    having i.plexus_customer_no = @PCN
--  group by @PCN,I.Period,D.Account_No,S.Name,D.[Description]   
--  having D.Plexus_Customer_No = @PCN

  UNION ALL
  --++--
  SELECT     i.plexus_customer_no pcn,i.period,d.Account_No,sum(d.debit) debit,sum(d.credit) credit

  FROM accounting_v_AP_Check_Dist2_e AS D 
  JOIN accounting_v_AP_Check_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Check_Link = D.Check_Link
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A2
    ON A2.PCN = D.Plexus_Customer_No
    AND A2.Account_No = D.Account_No
    group by i.plexus_customer_no,i.period,d.Account_No   
    having i.plexus_customer_no = @PCN
  --++--
  UNION ALL  
  --++--
  SELECT     i.plexus_customer_no pcn,i.period,d.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_AR_Invoice_Dist_e AS D 
  JOIN accounting_v_AR_Invoice_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
    AND I.Void = 0
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A3
    ON A3.PCN = D.Plexus_Customer_No
    AND A3.Account_No = D.Account_No
    group by i.plexus_customer_no,i.period,d.Account_No   
    having i.plexus_customer_no = @PCN
  UNION ALL
  --++--
  SELECT     i.plexus_customer_no pcn,i.period,d.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_AR_Invoice_Applied_Dist2_e AS D 
  JOIN accounting_v_AR_Invoice_Applied_e AS A 
    ON A.Plexus_Customer_No = D.Plexus_Customer_No 
    AND A.Applied_Link = D.Applied_Link
    AND A.Period BETWEEN @Period_Start AND @Period_End
  JOIN accounting_v_AR_Invoice_e AS I 
    ON I.Plexus_Customer_No = A.Plexus_Customer_No
    AND I.Invoice_Link = A.Invoice_Link
  JOIN #Accounts AS A4
    ON A4.PCN = D.Plexus_Customer_No
    AND A4.Account_No = D.Account_No
    group by i.plexus_customer_no,i.period,d.Account_No   
    having i.plexus_customer_no = @PCN
 --++--
  UNION ALL
  --++--
  SELECT     i.plexus_customer_no pcn,i.period,d.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_AR_Deposit_Dist AS D 
  JOIN accounting_v_AR_Deposit AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Deposit_Link = D.Deposit_Link
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A5
    ON A5.PCN = D.Plexus_Customer_No
    AND A5.Account_No = D.Account_No
    group by i.plexus_customer_no,i.period,d.Account_No   
    having i.plexus_customer_no = @PCN

  --++--
  UNION ALL
  --++--
  SELECT     i.plexus_customer_no pcn,i.period,d.Account_No,sum(d.debit) debit,sum(d.credit) credit
  FROM accounting_v_GL_Journal_Dist AS D 
  JOIN accounting_v_GL_Journal AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Journal_Link = D.Journal_Link
    AND ( @Exclude_Period_13 = 0 OR I.Period_13 = 0 )
    AND ( @Exclude_Period_Adjustments = 0 OR I.Period_Adjustment = 0 )
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A6
    ON A6.PCN = D.Plexus_Customer_No
    AND A6.Account_No = D.Account_No
    group by i.plexus_customer_no,i.period,d.Account_No   
    having i.plexus_customer_no = @PCN
) t1
JOIN accounting_v_account_e AS A 
  ON A.Plexus_Customer_No = t1.PCN
  AND A.Account_No = t1.Account_No
JOIN accounting_v_Period_e AS P
  ON P.Plexus_Customer_No = t1.PCN 
  AND P.Period = t1.Period
group by t1.pcn,t1.period,t1.Account_No   
ORDER BY  
  t1.pcn,t1.Period,t1.account_no


