CREATE PROCEDURE [dbo].[Customer_Revenue_By_Forecast_Part_Get]
(
  @PCN INT,
  @Part_Key INT,
  @Period_Start INT,
  @Period_End INT,
  @Cost_Model_Key INT,
  @Customer_No INT,
  @Exclude_No_Part BIT,
  @Forecast_Version_Key INT,
  @Display_by_Product_Type BIT = 0
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Created: 11/13/09 JBlac
--Purpose: Retrieve data for contribution analysis from a given forecast
--Used In: Accounting/Report_Customer_Revenue_By_Part.asp

-- 12/02/2009 JBLAC Updated the order of price selection from master price file, forecast to forcast, master price file
-- 12/03/2009 JBLAC Moved PS.Active from ORDER BY to WHERE for performance
-- 07/15/2010 MSTO USR#479560 Increase table var column width.
-- 05/29/2012 CJANELLO USR#653958 Add part name for enhancement. 
-- 03/10/2014 RGRI USR#879077 Add Product_Type breakdown Sort option
-- 12/12/17 bste CR-5181: Performance updates: use temp table to prevent double running main CTE, improve join order and force it for the temp table
-- 12/13/17 bste CR-5181: Correct column mismatch between Cost_Type_Valuation_Columns and Cost_Type_Valuation_Columns_Breakdown_List when a valuation cost type does not have a matching sub type

CREATE TABLE dbo.#Part_Temp
(
  PCN INT NOT NULL,
  Customer_No INT NOT NULL,
  Part_Key INT NOT NULL,
  Part_Operation_Key INT,
  Quantity DECIMAL(19,5),
  Price DECIMAL(18,6)
);

DECLARE @CostTypeCols TABLE
(
  Cost_Type_Valuation_Columns VARCHAR(800)
);

INSERT @CostTypeCols
(
  Cost_Type_Valuation_Columns
)
  SELECT
    LEFT(F.OrdIDList, LEN(F.OrdIDList) - 1)
  FROM
  (
    SELECT
      T.Cost_Type + ','
    FROM
    (
      SELECT
        Sort_Order,
        ISNULL(NULLIF(CONVERT(VARCHAR(50), CT.Abbreviated_Cost_Type), ''), CT.Cost_Type) AS Cost_Type
      FROM Common.dbo.Cost_Type AS CT
      WHERE CT.PCN = @PCN
        AND CT.Valuation_Column = 1
    ) AS T
    ORDER BY
      T.Sort_Order,
      T.Cost_Type
    FOR XML PATH('')
  ) AS F(OrdIdList);

DECLARE
  @Today DATETIME,
  @Revenue_No_Part DECIMAL(9,2),
  @Start INT,
  @End INT;

SET @Today = GETDATE();

-- Safety net: This should only happen when the PIT screen accessed from Plexus when the user chooses the customer
IF @Cost_Model_Key = -1 BEGIN
  SELECT TOP 1
    @Cost_Model_Key = Cost_Model_Key
  FROM Part.dbo.Cost_Model
  WHERE PCN = @PCN
    AND Primary_Model = 1;
END;

--Get Defaults for the period filters
SELECT
  @Start = MIN(FP.Sort_Order),
  @End = MAX(FP.Sort_Order)
FROM Sales.dbo.Forecast_Version AS FV
JOIN Sales.dbo.Forecast_Period AS FP
  ON FP.PCN = FV.PCN
  AND FP.Forecast_Year_Key = FV.Forecast_Year_Key
WHERE FV.PCN = @PCN
  AND FV.Forecast_Version_Key = @Forecast_Version_Key;

--If a start period was supplied, replace the default
SELECT
  @Start = FP.Sort_Order
FROM Sales.dbo.Forecast_Version AS FV
JOIN Sales.dbo.Forecast_Period AS FP
  ON FP.PCN = FV.PCN
  AND FP.Forecast_Year_Key = FV.Forecast_Year_Key
  AND FP.Forecast_Period_Key = @Period_Start
WHERE FV.PCN = @PCN
  AND FV.Forecast_Version_Key = @Forecast_Version_Key;

--If an end period was supplied, replace the default
SELECT
  @End = FP.Sort_Order
FROM Sales.dbo.Forecast_Version AS FV
JOIN Sales.dbo.Forecast_Period AS FP
  ON FP.PCN = FV.PCN
  AND FP.Forecast_Year_Key = FV.Forecast_Year_Key
  AND FP.Forecast_Period_Key = @Period_End
WHERE FV.PCN = @PCN
  AND FV.Forecast_Version_Key = @Forecast_Version_Key;

INSERT dbo.#Part_Temp
(
  PCN,
  Customer_No,
  Part_Key,
  Part_Operation_Key,
  Quantity,
  Price
)
SELECT
  P.Plexus_Customer_No,
  FR.Customer_No,
  P.Part_Key,
  PO.Part_Operation_Key,
  ISNULL(FV.Quantity, 0) AS Quantity,
  ISNULL(NULLIF(FV.Sales_Price, 0), PR1.Price) AS Price
FROM Sales.dbo.Forecast_Row AS FR
JOIN Part.dbo.Part AS P
  ON P.Plexus_Customer_No = FR.PCN
  AND P.Part_Key = FR.Part_Key
OUTER APPLY
(
  SELECT TOP (1)
    PO1.Part_Operation_Key
  FROM Part.dbo.Part_Operation AS PO1
  JOIN Part.dbo.Part_Op_Type AS POT1
    ON POT1.PCN = PO1.Plexus_Customer_No
    AND POT1.Part_Op_Type_Key = PO1.Part_Op_Type_Key
    AND POT1.Standard = 1
  WHERE PO1.Plexus_Customer_No = P.Plexus_Customer_No
    AND PO1.Part_Key = P.Part_Key
    AND PO1.Active = 1
    AND PO1.Suboperation = 0
  ORDER BY
    PO1.Operation_No DESC
) AS PO
LEFT OUTER JOIN Sales.dbo.Forecast_Value AS FV WITH (FORCESEEK(IX_Forecast_Value_Forecast_Row_Key(PCN, Forecast_Row_Key)))
  ON FV.PCN = FR.PCN
  AND FV.Forecast_Row_Key = FR.Forecast_Row_Key
LEFT OUTER JOIN Sales.dbo.Forecast_Period AS FP
  ON FP.PCN = FV.PCN
  AND FP.Forecast_Period_Key = FV.Forecast_Period_Key
OUTER APPLY
(
  SELECT TOP(1)
    PR.Price
  FROM Sales.dbo.PO_Line AS POL
  JOIN Sales.dbo.PO AS PO1
    ON PO1.PCN = POL.PCN
    AND PO1.PO_Key = POL.PO_Key
  JOIN Sales.dbo.PO_Status AS PS
    ON PS.PCN = PO1.PCN
    AND PS.PO_Status_Key = PO1.PO_Status_Key
  JOIN Sales.dbo.Price AS PR
    ON PR.PCN = POL.PCN
    AND PR.PO_Line_Key = POL.PO_Line_Key
  WHERE PO1.PCN = FR.PCN
    AND PO1.Customer_No = FR.Customer_No
    AND POL.Part_Key = FR.Part_Key
    AND PS.Active = 1
    AND PR.Active = 1
    AND (PR.Effective_Date IS NULL OR PR.Effective_Date <= FP.Begin_Date)
    AND PR.Breakpoint_Quantity <= FV.Quantity
  ORDER BY
    PO1.Master_Price DESC,
    CASE WHEN PR.Effective_Date IS NULL THEN 1 ELSE 0 END,
    PR.Effective_Date DESC,
    PR.Breakpoint_Quantity DESC,
    PR.Price DESC -- If all else fails, grab the highest price
) AS PR1
WHERE FR.PCN = @PCN
  AND FR.Forecast_Version_Key = @Forecast_Version_Key
  AND ISNULL(FP.Sort_Order, @Start) BETWEEN @Start AND @End
  AND (@Customer_No = -1 OR FR.Customer_No = @Customer_No)
OPTION 
(
  FORCE ORDER,
  RECOMPILE
);

WITH ctePart AS
(
  SELECT 
    PT.*,
    P.Part_No,
    P.Name AS Part_Name,
    PPT.Product_Type
  FROM dbo.#Part_Temp AS PT
  JOIN Part.dbo.Part AS P
    ON P.Plexus_Customer_No = PT.PCN
    AND P.Part_Key = PT.Part_Key
  LEFT OUTER JOIN Part.dbo.Part_Product_Type AS PPT
    ON PPT.PCN = P.Plexus_Customer_No
    AND PPT.Product_Type_Key = P.Product_Type_Key
), 
cteGrandTotal AS
(
  SELECT
    SUM(T.Price * T.Quantity) AS Grand_Total
  FROM ctePart AS T
)

SELECT
  C.[Name] AS Customer,
  C.Customer_Code,
  T.Product_Type,
  T.Part_No,
  T.Quantity,
  T.Part_Total_Revenue AS Total_Revenue,
  GT.Grand_Total AS Grand_Total,
  CASE ISNULL(GT.Grand_Total,0)
    WHEN 0 THEN
      0
    ELSE
      ISNULL( ROUND(CONVERT(DECIMAL(9,2),(T.Part_Total_Revenue / GT.Grand_Total) * 100),2,1) ,0 )
  END AS Revenue_Percent,
  CT.Cost_Type_Valuation_Columns,
  CASE
    WHEN CT.Cost_Type_Valuation_Columns > '' THEN
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
            CT.Cost_Type,
            CAST(ISNULL(SUM(ISNULL(B.Cost,0)),0) AS VARCHAR(250)) AS Value
          FROM Common.dbo.Cost_Type AS  CT
          LEFT OUTER JOIN Common.dbo.Cost_Sub_Type AS S  ON S.PCN = CT.PCN
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
                AND B2.Part_Key = T.Part_Key
                AND B2.Part_Operation_Key = T.Part_Operation_Key
                AND B2.Change_Date <= @Today
              )
          WHERE CT.PCN = @PCN
            AND CT.Valuation_Column = 1
          GROUP BY CT.Sort_Order, CT.Cost_Type
        ) AS T
        ORDER BY
          T.Sort_Order,
          T.Cost_Type
        FOR XML PATH('')
      ) AS F(OrdIdList)
    )
    ELSE NULL
  END AS Cost_Type_Valuation_Columns_Breakdown_List,
  T.Part_Name
FROM
(
  SELECT
    T1.Customer_No,
    ISNULL(T1.Part_No, 'No Part Number') AS Part_No,
    ISNULL(T1.Part_Key, -1) AS Part_Key,
    SUM(ISNULL(T1.Quantity, 0)) AS Quantity,
    ISNULL(T1.Part_Operation_Key, -1) AS Part_Operation_Key,
    SUM(ISNULL(T1.Price, 0) * T1.Quantity) AS Part_Total_Revenue,
    T1.Part_Name,
    T1.Product_Type
  FROM ctePart AS T1
  GROUP BY
    T1.Part_Key,
    T1.Part_No,
    T1.Part_Operation_Key,
    T1.Customer_No,
    T1.Product_Type,
    T1.Part_Name
) AS T
CROSS APPLY
(
  SELECT
    CGT.Grand_Total
  FROM cteGrandTotal AS CGT
) AS GT
CROSS APPLY
(
  SELECT
    CTC.Cost_Type_Valuation_Columns
  FROM @CostTypeCols AS CTC
) AS CT
JOIN Common.dbo.Customer AS C
  ON C.Plexus_Customer_No = @PCN
  AND C.Customer_No = T.Customer_No
WHERE T.Part_Total_Revenue != 0
ORDER BY
  CASE WHEN @Display_by_Product_Type = 1 THEN T.Product_Type ELSE C.[Name] END,
  C.Customer_Code,
  T.Part_No,
  T.Part_Total_Revenue DESC
OPTION(RECOMPILE);

DROP TABLE dbo.#Part_Temp;

RETURN;