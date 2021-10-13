/*
Trial Balance Multiple periods
Account Activity Detail.  This gives the detail records of the summaries found on Trial Balance. 

*/
select a.account_no,a.account_name,
jd.journal_link,
j.period, -- Defaults to the period the post date falls within - as long as the period is open. If the period is not open, the system will default to the next open period.
jd.line_item_no, -- identity
jd.description,
jd.debit,
jd.credit
from accounting_v_account_e a
inner join accounting_v_gl_journal_dist_e jd 
on a.plexus_customer_no=jd.plexus_customer_no
and a.account_no=jd.account_no
inner join accounting_v_gl_journal_e j 
on jd.plexus_customer_no= j.plexus_customer_no
and jd.journal_link=j.journal_link
where a.account_no = '10120-000-0000'
and a.plexus_customer_no = 300758
and j.period = 202109


-- Account_Activity_Summary_By_Period_Get
-- dskey 49156
/*
CREATE PROCEDURE [dbo].[Account_Activity_Summary_By_Period_Get]
(
  @PCN INT,
  @Period INT
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Created: 04/24/17 cherberg
-- Purpose: Basic Account Activity Summary by Period that is used to dump financial data into Workday
-- Used in: VP Export for Workday

DECLARE
  @PCN_Currency VARCHAR(3) = '',
  @Period_End_Date DATETIME;
  
SELECT 
  @PCN_Currency = C.Currency_Code
FROM Plexus_Control.dbo.Plexus_Customer AS PC
JOIN Common.dbo.Currency AS C
  ON C.Currency_Key = PC.Currency_Key
WHERE PC.Plexus_Customer_No = @PCN;

SELECT
  @Period_End_Date = AD.Adjusted_Date
FROM dbo.Period AS P
CROSS APPLY Plexus_Control.dbo.Date_To_Customer_Adjust(P.Plexus_Customer_No,P.End_Date) AS AD
WHERE P.Plexus_Customer_No = @PCN
  AND P.Period = @Period;

SELECT
  T.JournalKey,
  'Company_Reference_ID' AS CompanyReferenceIDType,
  T.CompanyReferenceID,
  @PCN_Currency AS Currency,
  'ACTUALS' AS LedgerType,
  '' AS BookCode,
  T.AccountingDate,
  'MANUAL_JOURNAL' AS JournalSource,
  'CURRENT' AS CurrencyRate,
  ROW_NUMBER() OVER(PARTITION BY JournalKey ORDER BY JournalKey) AS JournalLineOrder,
  T.Debit AS DebitAmount,
  T.Credit AS CreditAmount,
  @PCN_Currency AS LineCurrency,
  1 AS LineCurrencyRate,
  T.Debit LedgerDebitAmount,
  T.Credit LedgerCreditAmount,
  T.ExternalCode_LedgerAccount,
  T.ExternalCode_Location,
  T.Worktag_Cost_Center_Reference_ID
FROM
(
  SELECT
    'Journal' + CONVERT(VARCHAR(10), DENSE_RANK() OVER (ORDER BY LW.Workday_Entity ASC)) AS JournalKey,
    ISNULL(LW.Workday_Entity, '') AS CompanyReferenceID,
    CONVERT(VARCHAR(10), @Period_End_Date, 126) AS AccountingDate,
    CASE 
		  WHEN A.Category_Type IN ('Asset','Expense') 
		  THEN SUM(AA.Debit) - SUM(AA.Credit)
		  ELSE NULL
	  END AS Debit,
    CASE 
		  WHEN A.Category_Type NOT IN ('Asset','Expense') 
		  THEN SUM(AA.Credit) - SUM(AA.Debit)
		  ELSE NULL
	  END AS Credit,
    A.Base_No AS ExternalCode_LedgerAccount,
    A.Location_No AS ExternalCode_Location,
    A.Cost_Center_No AS Worktag_Cost_Center_Reference_ID,
    AA.Account_No,
    A.Category_Type
  FROM 
  (
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
    --++--
    UNION ALL
    --++--
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.AP_Check_Dist2 AS D 
    JOIN dbo.AP_Check AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Check_Link = D.Check_Link
    WHERE D.Plexus_Customer_No = @PCN
      AND I.Period = @Period
    --++--
    UNION ALL
    --++--
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.AR_Invoice_Dist AS D 
    JOIN dbo.AR_Invoice AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Invoice_Link = D.Invoice_Link
    WHERE D.Plexus_Customer_No = @PCN
      AND I.Period = @Period
      AND I.Void = 0
    --++--
    UNION ALL
    --++--
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.AR_Invoice_Applied_Dist2 AS D 
    JOIN dbo.AR_Invoice_Applied AS A 
      ON A.Plexus_Customer_No = D.Plexus_Customer_No 
      AND A.Applied_Link = D.Applied_Link
    JOIN dbo.AR_Invoice AS I 
      ON I.Plexus_Customer_No = A.Plexus_Customer_No
      AND I.Invoice_Link = A.Invoice_Link
    WHERE D.Plexus_Customer_No = @PCN
      AND I.Period = @Period
    --++--
    UNION ALL
    --++--
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.AR_Deposit_Dist AS D 
    JOIN dbo.AR_Deposit AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Deposit_Link = D.Deposit_Link
    WHERE D.Plexus_Customer_No = @PCN
      AND I.Period = @Period
    --++--
    UNION ALL
    --++--
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
  ) AS AA
  JOIN dbo.Account AS A 
    ON A.Plexus_Customer_No = AA.Plexus_Customer_No
    AND A.Account_No = AA.Account_No
  JOIN dbo.Location AS L
    ON L.Plexus_Customer_No = A.Plexus_Customer_No
    AND L.Location_No = A.Location_No
  LEFT OUTER JOIN dbo.Location_Workday AS LW
    ON LW.PCN = L.Plexus_Customer_No
    AND LW.Location_Key = L.Location_Key
  WHERE AA.Plexus_Customer_No = @PCN
  GROUP BY
    AA.Account_No,
    A.Base_No,
    A.Cost_Center_No,
    A.Location_No,
    LW.Workday_Entity,
    A.Category_Type
) AS T
WHERE T.Debit != 0
  OR T.Credit != 0
ORDER BY
  T.JournalKey,
  T.Account_No;
  
RETURN;
*/
