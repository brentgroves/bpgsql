CREATE PROCEDURE [dbo].[Report_Shipping_History_Container_Detail_Get]
(
  @PCN INT,
  @Customer_Code VARCHAR(25) = '',
  @Part_No VARCHAR(25) = '',
  @Begin_Date SMALLDATETIME = NULL,
  @End_Date SMALLDATETIME = NULL,
  @Container_Tracking_No VARCHAR(25) = '',
  @Part_Group_Key INT = 0,
  @PO_Type_Key INT = NULL,
  @Customer_Address_No INT = 0,
  @Shipper_No VARCHAR(50) = '',
  @AR_Invoice_No VARCHAR(50) = '',
  @Customer_Part_No VARCHAR(50) = ''
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Created: 01/11/07 jhap
-- Purpose: Shipping History with Container Attributes for Customer Audit
-- Used in: Quick Report

-- 01/11/07 jhap: Added Quantity
-- 02/06/08 jhap: Added @Container_Tracking_No parameter
-- 06/29/10 jhap: Added EDI_Line_11
-- 06/29/10 jhap: Added Product_Type
-- 08/05/10 jhap: Added @Part_Group_Key parameter
-- 08/20/10 jhap: Added Release_Ship_Date
-- 02/09/11 gacheson: Added Customer_Address_Code to rs
-- 05/27/11 gmacmaster: Added @PO_Type_Key parameter
-- 03/27/12 cschwartz: Added Customer_Part_No and Container_Type
-- 03/30/12 cschwartz: Added @Customer_Address_No parameter
-- 04/30/12 cschwartz: Added Cross Apply for performance
-- 09/05/12 jhap: Updated to use CTE, removed OPTION
-- 01/29/13 jrobert: Updated to handle PO_Type_Key null table values
-- 10/18/13 rbedard: Updated to use @Shipper_No, @AR_Invoice_No, @Customer_Part_No and AR_Invoice_No column.
-- 07/11/14 gjeler: [929124] Added OPTION (FORCE ORDER)
-- 02/08/17 cjersey DR-88: Added recompile option to address issues with the optimize for unknown trace flag.

DECLARE
  @Shipper_Status_Key INT;

EXEC dbo.Shipper_Status_Shipped_Get @PCN, @Shipper_Status_Key OUTPUT;

WITH Filtered_Data AS
(
  SELECT
    S.PCN,
    CU.Customer_Code,
    S.Ship_Date,
    S.Shipper_No,
    P.Part_No,
    R.EDI_Line_11,
    R.Ship_Date AS Release_Ship_Date,
    CA.Customer_Address_Code,
    P.Product_Type_Key,
    SL.Customer_Part_Key,
    SL.Shipper_Line_Key,
    ARI.Invoice_No
  FROM dbo.Shipper AS S 
  JOIN Common.dbo.Customer AS CU
    ON CU.Plexus_Customer_No = S.PCN
    AND CU.Customer_No = S.Customer_No
  JOIN Common.dbo.Customer_Address AS CA 
    ON CA.Plexus_Customer_No = S.PCN
    AND CA.Customer_No = S.Customer_No 
    AND CA.Customer_Address_No = S.Customer_Address_No
  JOIN dbo.Shipper_Line AS SL
    ON SL.PCN = S.PCN
    AND SL.Shipper_Key = S.Shipper_Key
  JOIN Part.dbo.Part AS P
    ON P.Plexus_Customer_No = SL.PCN
    AND P.Part_Key = SL.Part_Key
  JOIN dbo.Release AS R
    ON R.PCN = SL.PCN
    AND R.Release_Key = SL.Release_Key 
  JOIN dbo.PO_Line AS PL
    ON PL.PCN = R.PCN
    AND PL.PO_Line_Key = R.PO_Line_Key
  JOIN dbo.PO AS PO
    ON PO.PCN = PL.PCN
    AND PO.PO_Key = PL.PO_Key
  OUTER APPLY
  (
    SELECT TOP(1)
      ARI.Invoice_No
    FROM dbo.Shipper_AR_Invoice AS SARI
    JOIN Accounting.dbo.AR_Invoice_Dist AS ARID
      ON ARID.Plexus_Customer_No = SARI.PCN
      AND ARID.Invoice_Link = SARI.Invoice_Link
      AND ARID.Line_Item_No = SARI.Invoice_Line_Item_No
    JOIN Accounting.dbo.AR_Invoice AS ARI
      ON ARI.Plexus_Customer_No = ARID.Plexus_Customer_No
      AND ARI.Invoice_Link = ARID.Invoice_Link
      AND ARI.Void = 0
    WHERE SARI.PCN = SL.PCN
      AND SARI.Shipper_Key = SL.Shipper_Key
      AND SARI.Shipper_Line_Key = SL.Shipper_Line_Key
  ) AS ARI
  WHERE S.PCN = @PCN
    AND S.Shipper_Status_Key = @Shipper_Status_Key
    AND S.Ship_Date >= @Begin_Date
    AND S.Ship_Date < DATEADD(DAY, 1, @End_Date)
    AND CU.Customer_Code LIKE @Customer_Code + '%'
    AND P.Part_No LIKE @Part_No + '%'
    AND (@Part_Group_Key = 0 OR P.Part_Group_Key = @Part_Group_Key)
    AND (@PO_Type_Key IS NULL OR PO.PO_Type_Key = @PO_Type_Key)
    AND S.Customer_Address_No = ISNULL(NULLIF(@Customer_Address_No, 0), S.Customer_Address_No)
    AND S.Shipper_No LIKE @Shipper_No + '%'
    AND (@AR_Invoice_No = '' OR ARI.Invoice_No LIKE @AR_Invoice_No + '%')
)
SELECT
  F.Customer_Code,
  F.Ship_Date,
  F.Shipper_No,
  F.Part_No,
  C.Serial_No,
  C.Tracking_No,
  X.Quantity,
  F.EDI_Line_11,
  PPT.Product_Type,
  F.Release_Ship_Date,
  F.Customer_Address_Code,
  CP.Customer_Part_No,
  C.Container_Type,
  F.Invoice_No
FROM Filtered_Data AS F
CROSS APPLY
(
	SELECT
		SC.PCN, 
		SC.Serial_No,
		SUM(SC.Quantity) AS Quantity
	FROM dbo.Shipper_Container AS SC 
	WHERE SC.PCN = F.PCN
	  AND SC.Shipper_Line_Key = F.Shipper_Line_Key
	GROUP BY
		SC.PCN,
		SC.Serial_No
) AS X
JOIN Part.dbo.Container AS C  
  ON C.Plexus_Customer_No = X.PCN
  AND C.Serial_No = X.Serial_No
LEFT OUTER JOIN Part.dbo.Customer_Part AS CP
  ON CP.Plexus_Customer_No = F.PCN
  AND CP.Customer_Part_Key = F.Customer_Part_Key
LEFT OUTER JOIN Part.dbo.Part_Product_Type AS PPT
  ON PPT.PCN = F.PCN
  AND PPT.Product_Type_Key = F.Product_Type_Key
WHERE C.Tracking_No LIKE @Container_Tracking_No + '%'
  AND (@Customer_Part_No = '' OR CP.Customer_Part_No LIKE @Customer_Part_No + '%')
ORDER BY
  F.Customer_Code,
  F.Ship_Date,
  F.Shipper_No,
  F.Part_No
OPTION (FORCE ORDER, RECOMPILE);

RETURN;