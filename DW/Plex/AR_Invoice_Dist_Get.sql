CREATE PROCEDURE [dbo].[AR_Invoice_Dist_Get]
(
  @Plexus_Customer_No INT,
  @Invoice_Link INT,
  @PUN INT = 0,
  @Offset SMALLINT = 0,
  @Customer_Inventory_Usage BIT = 0
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--------------------------------------------------------------------------------------------------------------------------------
-- BY JALI-- Purpose: get detail of AR_Invoice_Dist-- Used in these files: AR_Invoice_Dist_Form.asp, AR_Invoice_Form.asp
-- 08/25/00 JFOS-- Now check Offset field instead of Line_Item_No of 0 for the offsetting entry
-- 09/27/00 JFOS-- Added AR_Invoice to query in order to check the Credit Memo to determine what gets sent back
-- 11/10/00 JFOS-- Switched Case I.Credit_Memo.  We now explicitly check for Credit_Memo = 1 instead of it being the ELSE, because non-credit memos can now have a value of 2 (see AR_Invoice_Add).
-- 12/05/01 MSTO Added I.Credit_Memo <> 3 to prevent return of any records.  This is similar to Credit_Memo's = 1 if they're also 'On Account', but in this case exclude here rather than check on the calling .asp page.
-- 08/22/02 MSTO Added I.System_Created to SELECT and removed I.Credit_Memo <> 3  from WHERE.
-- 10/09/02 MSTO Added I.Reference_Key to SELECT, dropped I.System_Created.
-- 08/25/03 MSTO Added D.Reference_Key to SELECT which required indicating a Reference_Key_Header alias.  Eliminate f_Period_Status_Get UDF call.  Added Tool_Order_Key to SELECT.
-- 04/07/04 MSTO Removed UDF to return if payments against invoice.  This led to derived table so we subquery once.
-- 07/15/04 MSTO Added @PUN parameter too treat invoices in periods 'unchecked' for display as though they are closed.
-- 11/16/04 KDAL Added @Offest parameter
-- 12/03/04 MSTO No longer need subquery's as AR_Invoice_Form_v2_1.asp will pass this necessary info to AR_Invoice_Dist_Form_v2_1.asp.  
-- 04/22/05 MSTO US#43366 new column Group_With
-- 07/28/05 MYOU Add Currency_Amount, Tax, Currency_Code to SELECT.
-- 10/19/05 MYOU Added support for Accounting_Job_Key field (US Nos: 54209, 54210, 54211)
-- 01/11/06 MYOU Added Fields to support Quantity and Unit_Price updates
-- 11/16/07 MSTO US#123532 Add Tax and Sort_Order to ORDER BY.  Add Ship_To_Address and 'Tax_Code_No' and 'Tax_Code' to SELECT.
-- 11/21/08 STANG Add Voucher Description to SELECT
-- 12/10/08 MYOU SR#138611 Add Part detail to SELECT
-- 07/29/10 MSTO USR#480935 Add new columns to appropriately format the decimal places for quantity and unit price.'
-- 11/03/2010 MMEDWITH USR#469175 Added Customer_Inventory_Usage_Reference_Nos based on optional paramter @Customer_Inventory_Usage
-- 02/14/2011 MMEDWITH USR#542912 Adding Item_Tax_Code & _Key
-- 05/06/11 RGRI USR#512210 Adding Account.Active select
-- 05/24/11 MYOU USR#469175 Modify Customer Inventory details to return Customer Reference and Usage Nos.
-- 05/28/2011 MYOU US#469175 Correct querying of Customer Inventory Usage No data.
-- 10/15/12 DJJOHNSTON 739448 Adding tax rate and compound tax to AR invoice 
-- 01/15/13 ABARD USR#754187 Add Taxable_Amount to SELECT
-- 04/16/13 ABARD USR#508213 Add Price_Element_Key to SELECT
-- 05/04/16 rgri USR#2005000 Add Expense_Project to SELECT
-- 10/23/17 azhuk AC-4239 Fix Tax_Code type casting for tax line
--------------------------------------------------------------------------------------------------------------------------------

SELECT
  D.Line_Item_No,
  D.Account_No,
  D.[Description],
  D.Reference_No,
  D.Reference_Key ,
  CASE I.Credit_Memo  WHEN 1 THEN D.Debit  ELSE D.Credit END AS 'Amount',
  I.Credit_Memo,
  I.Reference_Key AS 'Reference_Key_Header',
  I.Consolidated_Link,
  I.Customer_No ,
  D.Group_With,
  D.Currency_Amount,
  D.Tax,
  I.Currency_Code,
  AJ.Accounting_Job_Key,
  AJ.Accounting_Job_No,
  D.Quantity,
  CASE 
  WHEN CHARINDEX( '0.', CAST( REVERSE( ABS( ISNULL( D.Quantity, 0 )) ) AS DECIMAL(18,9) )) = 1 THEN 2
  WHEN CHARINDEX( '.', CAST( REVERSE( ABS( D.Quantity ) ) AS DECIMAL(18,9) ))-1 <= 0 THEN 2
  ELSE CHARINDEX( '.', CAST( REVERSE( ABS( D.Quantity ) ) AS DECIMAL(18,9) ))-1
  END AS Quantity_Decimal_Places,
  D.Unit_Price,
  CASE 
  WHEN CHARINDEX( '0.', CAST( REVERSE( ABS( ISNULL( D.Unit_Price, 0 )) ) AS DECIMAL(18,9) )) = 1 THEN 2
  WHEN CHARINDEX( '.', CAST( REVERSE( ABS( D.Unit_Price ) ) AS DECIMAL(18,9) ))-1 <= 0 THEN 2
  ELSE CHARINDEX( '.', CAST( REVERSE( ABS( D.Unit_Price ) ) AS DECIMAL(18,9) ))-1
  END AS Unit_Price_Decimal_Places,
  I.Ship_To_Address,
  CASE D.Tax WHEN 0 THEN
    REPLACE(ISNULL( 'start' + 
      (SELECT ISNULL( ',' + CAST( T.Tax_Code_No AS VARCHAR(50) ), '' ) 
      FROM dbo.[AR_Invoice_Dist_Tax] AS T
      WHERE T.PCN = D.Plexus_Customer_No
        AND T.Invoice_Link = D.Invoice_Link
        AND T.Line_Item_No = D.Line_Item_No
      FOR XML PATH('') 
    ), '' ),'start,','') 
  ELSE    
    CAST(D.Tax_Code_No AS VARCHAR(10))    
  END AS 'Tax_Code_No' ,
  -- USR 739448 Changed to point at tax_code on dist table instead of dist_tax
  CASE D.Tax WHEN 0 THEN
    REPLACE(ISNULL( 'start' + 
      (SELECT ISNULL( ',' + CAST( TC.Tax_Code AS VARCHAR(50) ), '' ) 
      FROM dbo.[AR_Invoice_Dist_Tax] AS T
      JOIN Purchasing.dbo.Tax_Code AS TC
        ON TC.Plexus_Customer_No = T.PCN
        AND TC.Tax_Code_No = T.Tax_Code_No
      WHERE T.PCN = D.Plexus_Customer_No
        AND T.Invoice_Link = D.Invoice_Link
        AND T.Line_Item_No = D.Line_Item_No
      FOR XML PATH('') 
    ), '' ),'start,','') 
  ELSE    
    CAST(TC.Tax_Code AS VARCHAR(100))    
  END AS 'Tax_Code' ,
  D.Voucher_Description,
  D.Part_Key,
  -- Optional to load Consignment Data for performance reasons
  t2.Customer_Inventory_Customer_Reference_Nos,
  D.Item_Tax_Key,
  IT.Item_Tax_Code,
  A.Active,
  t2.Customer_Inventory_Usage_Nos,
  -- USR 739448 Adding tax rate and compound tax to AR invoice
  D.Tax_Rate,
  REPLACE(ISNULL( 'start' +  
  (SELECT ISNULL( '| ' + CAST( TC.Tax_Code AS VARCHAR(50)), '' )  
   FROM dbo.AR_Invoice_Dist_Tax AS ART
   JOIN Purchasing.dbo.Tax_Code AS TC 
     ON TC.Plexus_Customer_No = ART.PCN 
     AND TC.Tax_Code_No = ART.Tax_Code_No 
   WHERE ART.PCN = D.Plexus_Customer_No 
     AND ART.Invoice_Link = D.Invoice_Link 
     AND ART.Line_Item_No = D.Line_Item_No 
     AND D.Tax = 1
   FOR XML PATH('') 
  ), '' ),'start|','') AS Compound_Tax,
  D.Taxable_Amount,
  PE.Price_Element_Key,
  D.Expense_Project_Key,
  EP.Project_Code AS Expense_Project_Code
FROM dbo.AR_Invoice AS I 
JOIN dbo.AR_Invoice_Dist AS D 
  ON D.Plexus_Customer_No = I.Plexus_Customer_No
  AND D.Invoice_Link = I.Invoice_Link
  AND D.Offset = @Offset
JOIN dbo.Account AS A
  ON A.Plexus_Customer_No = D.Plexus_Customer_No
  AND A.Account_No = D.Account_No  
LEFT OUTER JOIN dbo.Accounting_Job AS AJ
  ON AJ.PCN = D.Plexus_Customer_No
  AND AJ.Accounting_Job_Key = D.Accounting_Job_Key
LEFT OUTER JOIN Purchasing.dbo.Item_Tax AS IT
  ON IT.PCN = D.Plexus_Customer_No
  AND IT.Item_Tax_Key = D.Item_Tax_Key
LEFT OUTER JOIN Purchasing.dbo.Tax_Code AS TC    
  ON TC.Plexus_Customer_No = D.Plexus_Customer_No    
  AND TC.Tax_Code_No = D.Tax_Code_No 
OUTER APPLY
(
  SELECT
  (
    SELECT
    REPLACE(ISNULL( 'start' + 
    (SELECT DISTINCT ISNULL( ',' + CIU.Customer_Reference_No, '' ) 
    FROM AR_Invoice_Dist_Customer_Inventory_Usage AS U
    JOIN Part.dbo.Customer_Inventory_Usage AS CIU
      ON CIU.PCN = U.PCN
      AND CIU.Usage_Key = U.Usage_Key
    WHERE U.PCN = D.Plexus_Customer_No
      AND U.Invoice_Link = D.Invoice_Link
      AND U.Line_Item_No = D.Line_Item_No
      AND NULLIF(CIU.Customer_Reference_No,'') != ''
    FOR XML PATH('') 
    ), '' ),'start,','')
  ) AS Customer_Inventory_Customer_Reference_Nos,
  (
    SELECT
    REPLACE(ISNULL( 'start' + 
    (SELECT DISTINCT ISNULL( ',' + CIU.Usage_No, '' ) 
    FROM AR_Invoice_Dist_Customer_Inventory_Usage AS U
    JOIN Part.dbo.Customer_Inventory_Usage AS CIU
      ON CIU.PCN = U.PCN
      AND CIU.Usage_Key = U.Usage_Key
    WHERE U.PCN = D.Plexus_Customer_No
      AND U.Invoice_Link = D.Invoice_Link
      AND U.Line_Item_No = D.Line_Item_No
      AND NULLIF(CIU.Usage_No,'') != ''
    FOR XML PATH('') 
    ), '' ),'start,','')
  ) AS Customer_Inventory_Usage_Nos
) AS t2
LEFT OUTER JOIN dbo.AR_Invoice_Dist_Price_Element AS DPE
  ON DPE.PCN = D.Plexus_Customer_No
  AND DPE.Invoice_Link = D.Invoice_Link
  AND DPE.Line_Item_No = D.Line_Item_No
LEFT OUTER JOIN Sales.dbo.Price_Element AS PE
  ON PE.PCN = DPE.PCN
  AND PE.Price_Element_Key = DPE.Price_Element_Key
  AND PE.Fixed_Price = 0
LEFT OUTER JOIN dbo.Expense_Project AS EP
  ON EP.PCN = D.Plexus_Customer_No
  AND EP.Expense_Project_Key = D.Expense_Project_Key
WHERE I.Plexus_Customer_No = @Plexus_Customer_No
  AND I.Invoice_Link = @Invoice_Link
ORDER BY 
  D.Tax,
  D.Sort_Order,
  D.Line_Item_No


RETURN