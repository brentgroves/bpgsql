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

/*
 * Parameters
@PCN INT = 300758,
@Period_Start INT =202109,
@Account_No VARCHAR(20) = '10120-000-0000',
@Exclude_Period_13 SMALLINT = 0,
@Period_End INT= 202109,
@Account_No_From VARCHAR(20) = '10120-000-0000',
@Account_No_To VARCHAR(20) = '10120-000-0000',
  @Exclude_Period_Adjustments BIT = 0
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
  UNION ALL
  --++--
  SELECT
    @PCN,
    'Check' AS [Type],
    I.Check_Link AS Link,
    I.Period,
    I.Check_Date AS [Date],
    I.Check_No AS Number,
    D.Account_No AS Account_No,
    S.Name AS [Description],
    D.Debit AS Debit,
    D.Credit AS Credit,
    CASE
      WHEN A.Account_No IS NOT NULL THEN 0
      WHEN D.Debit = 0 THEN 0     
      WHEN D.Debit > 0 THEN ABS(I.Foreign_Currency_Amount)     
      ELSE I.Foreign_Currency_Amount     
    END AS Currency_Debit,
    CASE
      WHEN A.Account_No IS NOT NULL THEN 0 
      WHEN D.Credit = 0 THEN 0     
      WHEN D.Credit > 0 THEN ABS(I.Foreign_Currency_Amount)     
      ELSE I.Foreign_Currency_Amount     
    END AS Currency_Credit,
    ISNULL(DE.Currency_Code,@PCN_Currency_Code),
    I.Voucher_No
  FROM accounting_v_AP_Check_Dist2_e AS D 
  JOIN accounting_v_AP_Check_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Check_Link = D.Check_Link
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A2
    ON A2.PCN = D.Plexus_Customer_No
    AND A2.Account_No = D.Account_No
  LEFT OUTER JOIN Common_v_Supplier AS S 
    ON S.Plexus_Customer_No = I.Plexus_Customer_No
    AND S.Supplier_No = I.Supplier_No
  OUTER APPLY -- WE DON'T WANT TO JOIN ALL OF THE RECORDS FROM THIS SET JUST 1 OF THEM.
  (
    SELECT TOP(1)
      AP.Currency_Code
    FROM accounting_v_AP_Check_Dist_e AS A
    JOIN accounting_v_AP_Invoice_e AS AP
      ON AP.Plexus_Customer_No = A.Plexus_Customer_No
      AND AP.Invoice_Link = A.Invoice_Link
    WHERE A.Plexus_Customer_No = I.Plexus_Customer_No
      AND A.Check_Link = I.Check_Link
  ) AS DE
  OUTER APPLY
  (
    SELECT TOP(1)
      S.Account_No
    FROM accounting_v_Standard_Account_e AS S
    WHERE S.PCN = D.Plexus_Customer_No
      AND S.Account_No = D.Account_No
      AND S.[Standard] = 'FE'
  ) AS A
  WHERE D.Plexus_Customer_No = @PCN
  --++--
  UNION ALL  
  --++--
  SELECT
    @PCN,
    'AR' AS [Type],     I.Invoice_Link AS Link,
    I.Period,
    I.Invoice_Date AS [Date],
    I.Invoice_No AS Number,
    D.Account_No AS Account_No,
    C.Name  + '; ' + D.[Description] AS [Description],
    D.Debit AS Debit,
    D.Credit AS Credit,
    D.Debit * I.Exchange_Rate AS Currency_Debit,
    D.Credit * I.Exchange_Rate AS Currency_Credit,
    I.Currency_Code,
    I.Voucher_No
  FROM accounting_v_AR_Invoice_Dist_e AS D 
  JOIN accounting_v_AR_Invoice_e AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Invoice_Link = D.Invoice_Link
    AND I.Void = 0
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A3
    ON A3.PCN = D.Plexus_Customer_No
    AND A3.Account_No = D.Account_No
  LEFT OUTER JOIN Common_v_Customer AS C 
    ON C.Plexus_Customer_No = I.Plexus_Customer_No
    AND C.Customer_No = I.Customer_No
  WHERE D.Plexus_Customer_No = @PCN 
  --++--
  UNION ALL
  --++--
  SELECT
    @PCN,
    'AR' AS [Type],
    I.Invoice_Link AS Link,
    I.Period,
    A.Applied_Date AS [Date],
    I.Invoice_No AS Number,
    D.Account_No AS Account_No,
    C.Name + ' ' +  'Applied' AS [Description],
    D.Debit AS Debit,
    D.Credit AS Credit,
    D.Debit * I.Exchange_Rate AS Currency_Debit,
    D.Credit * I.Exchange_Rate AS Currency_Credit,
    I.Currency_Code,
    I.Voucher_No
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
  LEFT OUTER JOIN Common_v_Customer AS C 
    ON C.Plexus_Customer_No = I.Plexus_Customer_No
    AND C.Customer_No = I.Customer_No
  WHERE D.Plexus_Customer_No = @PCN
 --++--
  UNION ALL
  --++--
  SELECT
    @PCN,
    'Deposit' AS [Type],
    I.Deposit_Link AS Link,
    I.Period,
    I.Deposit_Date AS [Date],
    CAST(I.Deposit_Date AS VARCHAR(11)) AS Number,
    D.Account_No AS Account_No,
    'Deposit' AS [Description],
    D.Debit AS Debit,
    D.Credit AS Credit,
    CASE
      WHEN A.Account_No IS NOT NULL THEN 0 
      ELSE 
        CASE
          WHEN D.Debit != 0 AND (ROUND(ABS((D.Debit * I.Exchange_Rate) - I.Currency_Amount), 2) = .01)
            THEN I.Currency_Amount
          ELSE D.Debit * I.Exchange_Rate
        END
    END AS Currency_Debit,
    CASE
      WHEN A.Account_No IS NOT NULL THEN 0 
      ELSE D.Credit * I.Exchange_Rate
    END AS Currency_Credit,
    I.Currency_Code,
    I.Voucher_No
  FROM accounting_v_AR_Deposit_Dist AS D 
  JOIN accounting_v_AR_Deposit AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Deposit_Link = D.Deposit_Link
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN #Accounts AS A5
    ON A5.PCN = D.Plexus_Customer_No
    AND A5.Account_No = D.Account_No
  OUTER APPLY
  (
    SELECT TOP(1)
      S.Account_No
    FROM accounting_v_Standard_Account AS S
    WHERE S.PCN = D.Plexus_Customer_No
      AND S.Account_No = D.Account_No
      AND S.[Standard] = 'FE'
  ) AS A
  WHERE D.Plexus_Customer_No = @PCN  

  --++--
  UNION ALL
  --++--
  SELECT
    @PCN,
    'Journal' AS [Type],
    I.Journal_Link AS Link,
    I.Period,
    I.Post_Date AS [Date],
    CAST(I.Journal_Link  AS VARCHAR(50)) AS Number,
    D.Account_No AS Account_No,
    D.[Description] AS [Description],
    D.Debit AS Debit,
    D.Credit AS Credit,
    D.Currency_Debit,
    D.Currency_Credit,
    C.Currency_Code,
    I.Voucher_No
  FROM accounting_v_GL_Journal_Dist AS D 
  JOIN accounting_v_GL_Journal AS I 
    ON I.Plexus_Customer_No = D.Plexus_Customer_No 
    AND I.Journal_Link = D.Journal_Link
    AND ( @Exclude_Period_13 = 0 OR I.Period_13 = 0 )
    AND ( @Exclude_Period_Adjustments = 0 OR I.Period_Adjustment = 0 )
    AND I.Period BETWEEN @Period_Start AND @Period_End
  JOIN Common_v_Currency AS C
    ON C.Currency_Key = I.Currency_Key    
  JOIN #Accounts AS A6
    ON A6.PCN = D.Plexus_Customer_No
    AND A6.Account_No = D.Account_No
  WHERE D.Plexus_Customer_No = @PCN

) t1
JOIN accounting_v_account_e AS A 
  ON A.Plexus_Customer_No = t1.PCN
  AND A.Account_No = t1.Account_No
JOIN accounting_v_Period_e AS P
  ON P.Plexus_Customer_No = t1.PCN 
  AND P.Period = t1.Period
ORDER BY  
  t1.Period,
  t1.[Date],
  t1.Link;

DROP TABLE #Accounts;




