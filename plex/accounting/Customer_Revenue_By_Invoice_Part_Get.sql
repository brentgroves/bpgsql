CREATE PROCEDURE [dbo].[Customer_Revenue_By_Invoice_Part_Get]
(
  @Plexus_Customer_No INT,
  @Part_Key INT = -1,
  @Period_Start INT = 0,
  @Period_End INT = 0,
  @Date_Start DATETIME = NULL,
  @Date_End DATETIME = NULL,
  @Cost_Model_Key INT = -1,
  @Customer_No INT = -1,
  @Exclude_No_Part BIT = 0,
  @Display_by_Product_Type BIT = 0
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--Created: 11/13/09 JBlac
--Purpose: Created when Customer_Revenue_By_Part_Get was turned into a router sproc
--Used In: Accounting/Report_Customer_Revenue_By_Part.asp
-- 07/15/2010 MSTO USR#479560 Increase table var column width.
-- 01/04/2010 MSTO USR#522944 Rewrite for performance (1M to 27k).
-- 01/06/2010 MSTO USR#522944 Add index hint [PCN_Serial_No].
-- 01/31/2010 MSTO USR#525366 More timeouts.  Move table var to temp table.
-- 05/29/2012 CJANELLO USR#653958 Add part name for enhancement. 
-- 06/15/2012 CSCHWARTZ  Added second check to @Exclude_No_Part to properly exclude no part no  
-- 07/06/2012 LTDavis Changed Cost_Sub_Type to LEFT OUTER JOIN
-- 06/19/13 ABARD USR#818327 Move Quantity calculation to OUTER APPLY
-- 07/01/13 ABARD USR#818327 Add @Part_Key to WHERE clause
-- 07/22/13 ABARD USR#835447 Adjust Quantity Calc
-- 08/15/13 ABARD USR#818327 Accomodate for duplicate Cost_Types
-- 09/14/13 abard USR#846107 Accomodate for duplicate Cost_Types; Standards
-- 10/09/13 cschwartz USR#864788 Remove JOIN to Revenue_Account_v view and replace with JOIN to Accounting.dbo.Account, 
---                              remove group by quantity and changed to sum 
-- 02/11/14 RGRI USR#864788 Qualify 10/9/13 changes for Usage check; found difference in Acme without qualification.
-- 03/07/14 RGRI USR#879077 Add Product_Type breakdown Sort option
-- 04/10/14 RGRI USR#897653 Adjust Usage Quantity check to avoid inflating quantity (introduced 10/9 with sum change)
-- 03/28/16 cjersey 2410492: Removed the index hint on Shipper_Container since it was preventing a much better index choice.
--                           Added option recompile to the insert into #ctePart so that an optimal plan can be generated for
--                           both period-filtered queries and date-filtered queries.
-- 03/29/16 cjersey 2410492: Added Part_Key predicate in the cross apply that finds the Part_Operation_Key.  This eliminates a table spool and allows for better seeking.
-- 05/10/16 cjersey 2410492: Added index hint to Container table.
-- 06/26/18 mbhuiyan: Added condition when @Exclude_No_Part is 0 or 1 to get @Grand_Total
-- 08/29/18 molson CR-6949: Makes sure subtotal section excludes the same parts as grandtotal section.  One was excluding based on null part the other based on null part op.
--                          Null part lines up with the original functionality of the report.
-- 09/12/18 ssharma2 CR-9753 Remove max from Invoice_Link in AR_Invoice_Dist_Customer_Inventory_Usage, exists clause of quantity
-- 09/18/18 ssharma2 CR-9837 Set quantity to negative if invoice is credit memo 
-- 07/03/19 nwoisnet CR-14063: Improved the performance by using index hints and a loop join.

CREATE TABLE dbo.#ctePart
(
  PCN INT,
  Invoice_Link INT,
  Shipper_Line_Key INT,
  Customer_No INT,
  Part_No VARCHAR(100),
  Part_Key INT,
  Part_Operation_Key INT,
  Quantity DECIMAL(18,5),
  Part_Total_Revenue DECIMAL(18,2),
  Part_Name VARCHAR(100),
  Product_Type VARCHAR(50)
);


DECLARE
  @Today DATETIME = GETDATE(),
  @Grand_Total DECIMAL(18,2),
  @Cost_Type_Valuation_Columns VARCHAR(800);


SELECT @Cost_Type_Valuation_Columns =
  LEFT(F.OrdIDList, LEN(F.OrdIDList) - 1)
  FROM
  (
    SELECT
      T.Cost_Type + ','
    FROM
    (
      SELECT DISTINCT
        Sort_Order,
        ISNULL(NULLIF(CONVERT(VARCHAR(50), CT.Abbreviated_Cost_Type), ''), CT.Cost_Type) AS Cost_Type
      FROM Common.dbo.Cost_Type AS CT
      WHERE CT.PCN = @Plexus_Customer_No
        AND CT.Valuation_Column = 1
    ) AS T
    ORDER BY
      T.Sort_Order,
      T.Cost_Type
    FOR XML PATH('')
  ) AS F(OrdIdList);



-- Safety net: This should only happen when the PIT screen accessed from Plexus when the user chooses the customer
IF @Cost_Model_Key = -1
BEGIN
  SELECT TOP (1)
    @Cost_Model_Key = Cost_Model_Key
  FROM Part.dbo.Cost_Model
  WHERE PCN = @Plexus_Customer_No
    AND Primary_Model = 1;
END;

IF @Date_Start IS NOT NULL OR @Date_End IS NOT NULL
BEGIN
  DECLARE
    @Current_Date DATETIME;
    
  SELECT
    @Current_Date = CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 101));
  
  SELECT
    @Period_Start = 0,
    @Period_End = 0,
    @Date_Start = ISNULL(@Date_Start, ISNULL(DATEADD(D, -1, DATEADD(M, -1, @Date_End)), @Current_Date)),
    @Date_End = ISNULL(@Date_End, ISNULL(DATEADD(D, -1, DATEADD(M, 1, @Date_Start)), DATEADD(D, -1, DATEADD(M, 1, @Current_Date))));
END;

INSERT dbo.#ctePart
(
  PCN,
  Invoice_Link,
  Shipper_Line_Key,
  Customer_No,
  Part_No ,
  Part_Key,
  Part_Operation_Key ,
  Quantity ,
  Part_Total_Revenue,
  Part_Name,
  Product_Type
)
SELECT
  @Plexus_Customer_No,
  I.Invoice_Link,
  AID.Shipper_Line_Key,
  I.Customer_No,
  P.Part_No,
  P.Part_Key,
  CASE WHEN P.Part_Key IS NULL THEN NULL ELSE DT_Container.Part_Operation_Key END,
  CASE 
    WHEN 
      EXISTS
      (  SELECT TOP(1)
           DCIU.Invoice_Link
         FROM dbo.AR_Invoice_Dist_Customer_Inventory_Usage AS DCIU
         WHERE  DCIU.PCN = MAX(I.Plexus_Customer_No)
           AND DCIU.Invoice_Link = I.Invoice_Link
           AND DCIU.Line_Item_No = MAX(AID.Line_Item_No)
      ) THEN
      SUM(Q.Quantity * CASE WHEN I.Credit_Memo = 1 THEN -1 ELSE 1 END) 
    ELSE 
      MAX(Q.Quantity)
  END,
  ISNULL(SUM(AID.Credit - AID.Debit),0),
  P.Name AS Part_Name,
  PPT.Product_Type
FROM dbo.AR_Invoice AS I
JOIN dbo.AR_Invoice_Dist AS AID
  ON AID.Plexus_Customer_No = I.Plexus_Customer_No
  AND AID.Invoice_Link = I.Invoice_Link
CROSS APPLY
(
  SELECT
    A1.Plexus_Customer_No AS PCN,
    A1.Account_No,
    A1.Account_Name
  FROM dbo.Account AS A1
  WHERE A1.Plexus_Customer_No = AID.Plexus_Customer_No
    AND A1.Account_No = AID.Account_No
    AND A1.Category_Type = 'Revenue'
) AS A
LEFT OUTER JOIN Part.dbo.Part AS P
  ON P.Plexus_Customer_No = AID.Plexus_Customer_No
  AND P.Part_Key = AID.Part_Key
LEFT OUTER JOIN Part.dbo.Part_Product_Type AS PPT
  ON PPT.PCN = P.Plexus_Customer_No
  AND PPT.Product_Type_Key = P.Product_Type_Key 
LEFT OUTER JOIN Common.dbo.Building AS B
  ON B.Plexus_Customer_No = P.Plexus_Customer_No
  AND B.Building_Key = P.Building_Key   
CROSS APPLY
(
  SELECT
    MAX(C.Part_Operation_Key) AS Part_Operation_Key
  FROM Sales.dbo.Shipper_Container AS SC WITH (INDEX(IX_Shipper_Line_Key))
  
  -- There were certain cases where the optimizer wanted to select
  -- from Container before Shipper_Container.  
  -- Example: exec dbo.Customer_Revenue_By_Part_Get 162263,-1,201604,201604,NULL,NULL,-1,-1,0,0,0
  -- Adding this index hint helps fix this join order without forcing the order in the entire query.
  INNER LOOP JOIN Part.dbo.Container AS C WITH (INDEX(IX_Container_PT_Cost_History))
    ON C.Plexus_Customer_No = SC.PCN
    AND C.Serial_No = SC.Serial_No
  WHERE SC.PCN = AID.Plexus_Customer_No
    AND SC.Shipper_Line_Key = AID.Shipper_Line_Key
    
    -- Added Part_Key to where clause which helps prevent SQL Server from 
    -- thinking a spool is useful.  This extra equality is implied anyway 
    -- since the Part_Operation_Key returned in the result set is assumed to 
    -- be for the Part_Key.
    AND C.Part_Key = P.Part_Key
) AS DT_Container
OUTER APPLY
(
  SELECT
    ISNULL(CASE WHEN SUM(D1.Unit_Price) = 0 THEN SUM(D1.Quantity) ELSE SUM(D1.Currency_Amount) / SUM(D1.Unit_Price) END, AID.Quantity) AS Quantity
  FROM dbo.AR_Invoice_Dist AS D1 WITH (INDEX(IX_Part_Key_Shipper_Line_Key))
  WHERE D1.Plexus_Customer_No = I.Plexus_Customer_No
    AND D1.Invoice_Link = I.Invoice_Link
    AND D1.Shipper_Line_Key = AID.Shipper_Line_Key
    AND D1.Part_Key = AID.Part_Key
) AS Q

WHERE I.Plexus_Customer_No = @Plexus_Customer_No
  AND (@Period_Start = 0 OR I.Period >= @Period_Start)
  AND (@Period_End = 0 OR I.Period <= @Period_End)
  AND (@Date_Start IS NULL OR I.Invoice_Date >= @Date_Start)
  AND (@Date_End IS NULL OR I.Invoice_Date <= @Date_End)
  AND I.Void = 0
  AND (@Customer_No = -1 OR I.Customer_No = @Customer_No)
  AND (@Exclude_No_Part = 0 OR P.Part_No IS NOT NULL)
  AND (@Part_Key = -1 OR AID.Part_Key = @Part_Key)
GROUP BY
  I.Invoice_Link,
  AID.Shipper_Line_Key,
  I.Customer_No,
  P.Part_No,
  P.Part_Key,
  DT_Container.Part_Operation_Key,
  P.Name,
  PPT.Product_Type
OPTION (RECOMPILE);

SELECT
  @Grand_Total = SUM(Part_Total_Revenue)
FROM dbo.#ctePart
WHERE (@Exclude_No_Part = 0 OR Part_No IS NOT NULL);

SELECT
  F.Customer,
  F.Customer_Code,
  F.Part_No,
  SUM(F.Quantity) AS Quantity,
  SUM(F.Total_Revenue) AS Total_Revenue,
  @Grand_Total AS Grand_Total,
  CASE ISNULL(@Grand_Total,0)
    WHEN 0 THEN 0
    ELSE (ISNULL( ROUND(CONVERT(DECIMAL(9,2),(SUM(F.Total_Revenue) / @Grand_Total) * 100),2,1) ,0 ) )
  END AS Revenue_Percent,

  @Cost_Type_Valuation_Columns AS Cost_Type_Valuation_Columns,
  F.Cost_Type_Valuation_Columns_Breakdown_List,
  F.Part_Name,
  F.Product_Type
FROM
(
SELECT
  C.[Name] AS Customer,
  C.Customer_Code,
  ISNULL(
    CASE WHEN ctePart.Part_No IS NULL THEN NULL ELSE ctePart.Part_No END,
    'No Part Number'
  ) AS Part_No,
  
  CASE WHEN ctePart.Part_No IS NOT NULL THEN SUM(ctePart.Quantity) ELSE 0 END AS Quantity,
  SUM(ctePart.Part_Total_Revenue) AS Total_Revenue,
  CASE
    WHEN @Cost_Type_Valuation_Columns > '' THEN
      (
        SELECT
          LEFT(F.OrdIDList, LEN(F.OrdIDList) - 1)
        FROM (
          SELECT
            T.[Value] + ','
          FROM
          (
            SELECT
              CT.Sort_Order,
              ISNULL(NULLIF(CONVERT(VARCHAR(50), CT.Abbreviated_Cost_Type), ''), CT.Cost_Type) AS Cost_Type,
              CAST(ISNULL(SUM(ISNULL(B.Cost,0)),0) AS VARCHAR(250)) AS VALUE
            FROM Common.dbo.Cost_Type AS  CT
            LEFT OUTER JOIN Common.dbo.Cost_Sub_Type AS S
              ON S.PCN = CT.PCN
              AND S.Cost_Type_Key = CT.Cost_Type_Key
            LEFT OUTER JOIN Part.dbo.Cost_Sub_Type_Breakdown_History AS B
              ON B.PCN = S.PCN
              AND B.Change_Key =
              (
                SELECT
                  MAX(B2.Change_Key) AS Change_Key
                FROM Part.dbo.Cost_Sub_Type_Breakdown_History AS B2
                WHERE B2.PCN = S.PCN
                  AND B2.Cost_Sub_Type_Key = S.Cost_Sub_Type_Key
                  AND B2.Cost_Model_Key = @Cost_Model_Key
                  AND B2.Part_Key = ctePart.Part_Key
                  AND B2.Part_Operation_Key = ctePart.Part_Operation_Key
                  AND B2.Change_Date <= @Today
                )
            WHERE CT.PCN = ctePart.PCN
              AND CT.Valuation_Column = 1
            GROUP BY
              CT.Sort_Order,
              ISNULL(NULLIF(CONVERT(VARCHAR(50), CT.Abbreviated_Cost_Type), ''), CT.Cost_Type)
          ) AS T
          ORDER BY
            T.Sort_Order,
            T.Cost_Type
          FOR XML PATH('')
        ) AS F(OrdIdList)
      )
    ELSE NULL
  END AS Cost_Type_Valuation_Columns_Breakdown_List,
  ctePart.Part_Key,
  ctePart.Part_Operation_Key,
  ctePart.Part_Name,
  ctePart.Product_Type
FROM dbo.#ctePart AS ctePart
JOIN Common.dbo.Customer AS C
  ON C.Plexus_Customer_No = ctePart.PCN
  AND C.Customer_No = ctePart.Customer_No
GROUP BY
  ctePart.PCN,
  C.[Name] ,
  C.Customer_Code,
  ctePart.Part_No,
  ctePart.Part_Key,
  ctePart.Part_Operation_Key,
  ctePart.Part_Name,
  ctePart.Product_Type
) AS F
WHERE F.Total_Revenue != 0
  AND @Exclude_No_Part = 0 OR F.Part_No != 'No Part Number'
GROUP BY
  F.Customer,
  F.Customer_Code,
  F.Part_No,
  F.Cost_Type_Valuation_Columns_Breakdown_List,
  F.Part_Name,
  F.Product_Type
ORDER BY
  CASE WHEN @Display_by_Product_Type = 1 THEN F.Product_Type ELSE F.Customer END,
  F.Customer_Code,
  F.Part_No,
  Total_Revenue DESC;

DROP TABLE dbo.#ctePart;
  
RETURN;                      
                  