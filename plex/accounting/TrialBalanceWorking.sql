/*
-- Try to reproduce the Account Activity Detail screen.
-- According to the \System Setup\Application Setup\Resource Search entry for this report
-- It uses the GL_Account_Activity_Detail_Report data source.
-- The following is the conversion of this database sql to Plex sql.
-- Goal: Duplicate the Trial Balance multiple periods entry for Albion's account#: 10120-000-0000,Cash Operating Wells Fargo-General-General
-- for period: 2021-09,
-- To do this convert first convert the data source for the 'Account Activity Detail' screen.
-- This is the corresponding detail report for the Trial Balance multiple periods summary report.

--What does this do: (CHARINDEX( '|' + RTRIM(Account_No) + '|' , '|' + ISNULL(NULLIF(@Account_No,''),'') + '|' , 0) > 0  )
--Maybe if the actual account number in plex has trailing spaces it strips then off before the comparison to the @Account_No param.
--declare @Account_No varchar(20)
--set @Account_No = '10120-000-0000'
set @Account_No = ''
select '|' + ISNULL(NULLIF(@Account_No,''),'') + '|'
*/


CREATE TABLE #Accounts
(
  PCN INT NOT NULL,
  Account_No VARCHAR(20) NOT NULL,
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

/*
-- we don't maintain this table so always use USD
DECLARE
  @PCN_Currency_Code CHAR(3);

SELECT 
  @PCN_Currency_Code = C.Currency_Code 
FROM Plexus_Control_v_Customer_Currency AS PC 
JOIN Common_v_Currency AS C  
  ON C.Currency_Key = PC.Currency_Key
WHERE PC.Plexus_Customer_No = @PCN;
select @PCN_Currency_Code PCN_Currency_Code
select * from Plexus_Control_v_Customer_Currency
*/

DECLARE @PCN_Currency_Code CHAR(3);
set @PCN_Currency_Code = 'USD'
-- select @PCN_Currency_Code

INSERT #Accounts
(
  PCN,
  Account_No
)
SELECT 
  @PCN,
  Account_No
FROM accounting_v_Account_e
WHERE Plexus_Customer_No = @PCN
  AND (CHARINDEX( '|' + RTRIM(Account_No) + '|' , '|' + ISNULL(NULLIF(@Account_No,''),'') + '|' , 0) > 0  );
--select * from #Accounts  


IF @Account_No_From != '' OR @Account_No_To != ''
BEGIN
  INSERT #Accounts
  (
    PCN,
    Account_No
  )
  SELECT 
    @PCN,
    Account_No
  FROM accounting_v_Account_e AS A
  WHERE A.Plexus_Customer_No = @PCN
    AND (@Account_No_From = '' OR A.Account_No >= @Account_No_From)
    AND (@Account_No_To = '' OR A.Account_No <= @Account_No_To)
    AND NOT EXISTS
    (  -- don't duplicate account from PCN parameter
      SELECT *
      FROM #Accounts AS A2
      WHERE A2.PCN = A.Plexus_Customer_No
        AND A2.Account_No = A.Account_No
    );
END;

--select * from #Accounts  




SELECT
--  P.Period_Display,
  t1.[Date],
  t1.[Type],
  t1.Link,
  t1.Number,
  t1.Account_No,
  t1.[Description],
  t1.Debit,
  t1.Credit,
--  CASE WHEN A.Category_Type IN ('Asset','Expense') THEN 'Debit' ELSE 'Credit' END AS Balance_Side,
  ROUND(t1.Currency_Debit, 2) AS Currency_Debit,
  ROUND(t1.Currency_Credit, 2) AS Currency_Credit,
  t1.Currency_Code,
  t1.Voucher_No,
  t1.Period
FROM (
  SELECT
    @PCN AS PCN,
    'AP' AS [Type],
    I.Invoice_Link AS Link,
    I.Period,
    I.Invoice_Date AS [Date],
    I.Invoice_No AS Number,
    D.Account_No AS Account_No,
    S.Name + '; ' + D.[Description] AS [Description],
    D.Debit AS Debit,
    D.Credit AS Credit,
    CASE 
      WHEN @PCN_Currency_Code = I.Currency_Code THEN D.Debit  
      WHEN D.Offset = 1 AND D.Debit != 0 THEN I.Foreign_Currency_Amount*-1
      ELSE (D.Debit * D.Exchange_Rate) 
    END AS Currency_Debit,
    CASE 
      WHEN @PCN_Currency_Code = I.Currency_Code THEN D.Credit 
      WHEN D.Offset = 1 AND D.Credit != 0 THEN I.Foreign_Currency_Amount
      ELSE (D.Credit * D.Exchange_Rate) 
    END AS Currency_Credit,
    I.Currency_Code,
    I.Voucher_No
  FROM accounting_v_AP_Invoice_Dist_e AS D 
  JOIN accounting_v_AP_Invoice_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A
    ON A.PCN = D.Plexus_Customer_No
    AND A.Account_No = D.Account_No
  LEFT OUTER JOIN Common_v_Supplier_e AS S 
    ON S.Plexus_Customer_No = I.Plexus_Customer_No
    AND S.Supplier_No = I.Supplier_No
  WHERE D.Plexus_Customer_No = @PCN
) t1
/*
JOIN accounting_v_account_e AS A 
  ON A.Plexus_Customer_No = t1.PCN
  AND A.Account_No = t1.Account_No
JOIN accounting_v_Period AS P
  ON P.Plexus_Customer_No = t1.PCN 
  AND P.Period = t1.Period
ORDER BY  
  t1.Period,
  t1.[Date],
  t1.Link;

*/








/*
This is a data source I started converting before I 
found out \System Setup\Application Setup\Resource Search
*/
-- Account_Activity_Summary_By_Period_Get
-- dskey 49156

/*
select 
D.Plexus_Customer_No,
D.Account_No AS Account_No,
D.Debit AS Debit,
D.Credit AS Credit
from accounting_v_ap_invoice_dist as d
inner join accounting_v_ap_invoice i 
ON I.Plexus_Customer_No = D.Plexus_Customer_No 
AND I.Invoice_Link = D.Invoice_Link
WHERE D.Plexus_Customer_No = @PCN
AND I.Period = @Period
and d.account_no = '10120-000-0000'

union

SELECT
jd.Plexus_Customer_No,
jd.Account_No AS Account_No,
jd.Debit AS Debit,
jd.Credit AS Credit
from accounting_v_gl_journal_dist_e jd 
inner join accounting_v_gl_journal_e j 
on jd.plexus_customer_no= j.plexus_customer_no
and jd.journal_link=j.journal_link
where jd.plexus_customer_no = @PCN
and j.period = 202109
and jd.account_no = '10120-000-0000'

*/


/*
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.AP_Invoice_Dist AS D 
    JOIN dbo.AP_Invoice AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Invoice_Link = D.Invoice_Link
    WHERE D.Plexus_Customer_No = @PCN
      AND I.Period = @Period
*/


/*
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.GL_Journal_Dist AS D 
    JOIN dbo.GL_Journal AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Journal_Link = D.Journal_Link
    WHERE D.Plexus_Customer_No = @PCN      
      AND I.Period = @Period
      AND I.Period_Adjustment = 0
*/