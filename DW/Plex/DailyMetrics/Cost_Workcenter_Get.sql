CREATE PROCEDURE [dbo].[Cost_Workcenter_Get]
(
  @PCN INT,
  @Workcenter_Key INT,
  @Cost_Model_Key INT = NULL,
  @Part_Key INT = NULL,
  @Part_No VARCHAR(100) = NULL,
  @Operation_Key INT = NULL,
  @Part_Status_Keys VARCHAR(1000) = NULL
)
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

----------------------------------------------------------------
-- Generated with ASP_Template.asp on 7/18/2005 2:58:29 PM by mhal
-- Purpose: Stored proc to take filter vars and return rs for grid
-- Used in: Cost_Workcenter.asp

-- 04/17/08 mhal US 108499 Workcenter_Group
-- 10/03/08 mhal US 160183 Do not show all parts for the workcenter, just approved.
-- 01/05/12 gsingh: Added @Part_Status_Keys parameter. Changed left outer join on 
--                    Part_Operation to simple join to improve performance.
-- 08/27/12 molson - Added part op level workcenter override columns.
-- 10/17/14 igedeon 877089: Add new Setup_Cost column to the Cost_Workcenter table and Workcenter Cost Override page

IF LEN(ISNULL(@Part_Status_Keys,'')) > 0
BEGIN
  SET @Part_Status_Keys = ',' + @Part_Status_Keys;
END;

IF @Cost_Model_Key IS NULL
BEGIN
  SELECT TOP(1)
    @Cost_Model_Key = CM.Cost_Model_Key
  FROM dbo.Cost_Model AS CM
  WHERE CM.PCN = @PCN
    AND CM.Estimating_Model = 1;
END;

SELECT 
  CM.Cost_Model,
  WC.Workcenter_Key,
  WC.Workcenter_Code,
  WC.Name AS Workcenter_Name,
  PO.Part_Key,
  PO.Part_Operation_Key,
  PO.Operation_Key,
  PO.Part_No,
  PO.Revision,
  PO.Operation_No,
  PO.Operation_Code,
  WC.Direct_Labor_Cost,
  CW.Direct_Labor_Cost AS Direct_Labor_Cost_Override,
  WC.Variable_Cost,
  CW.Variable_Cost AS Variable_Cost_Override,
  WC.Overhead_Cost,
  CW.Overhead_Cost AS Overhead_Cost_Override,
  W.Setup_Time,
  CW2.Setup_Time AS Setup_Time_Override,
  W.Standard_Production_Rate,
  CW2.Standard_Production_Rate AS Standard_Production_Rate_Override,
  W.Crew_Size,
  CW2.Crew_Size AS Crew_Size_Override,
  WC.Workcenter_Group,
  CWG.Direct_Labor_Cost AS WC_Group_Direct_Labor_Cost_Override,
  CWG.Variable_Cost AS WC_Group_Variable_Cost_Override,
  CWG.Overhead_Cost AS WC_Group_Overhead_Cost_Override,
  CW2.Variable_Cost AS Part_Op_Variable_Cost_Override,
  CW2.Overhead_Cost AS Part_Op_Overhead_Cost_Override,
  CW2.Direct_Labor_Cost AS Part_Op_Direct_Labor_Cost_Override,
  WC.Setup_Cost,
  CW.Setup_Cost AS Setup_Cost_Override,
  CWG.Setup_Cost AS WC_Group_Setup_Cost_Override
FROM dbo.Workcenter AS WC
JOIN 
  (
  SELECT
    PO.Plexus_Customer_No AS PCN,
    PO.Part_Key,
    PO.Part_Operation_Key,
    P.Part_No,
    P.Revision,
    PO.Operation_No,
    PO.Operation_Key,
    O.Operation_Code
  FROM dbo.Part_Operation AS PO
  JOIN dbo.Part AS P
    ON  P.Plexus_Customer_No = PO.Plexus_Customer_No
    AND P.Part_Key = PO.Part_Key
  JOIN dbo.Part_Status AS PS
    ON PS.Plexus_Customer_No = PO.Plexus_Customer_No
    AND PS.Part_Status = P.Part_Status
  JOIN dbo.Operation AS O
    ON  O.Plexus_Customer_No = PO.Plexus_Customer_No
    AND O.Operation_Key = PO.Operation_Key  
  JOIN dbo.Part_Op_Type AS POT 
    ON  POT.PCN = PO.Plexus_Customer_No
    AND POT.Part_Op_Type_Key = PO.Part_Op_Type_Key
    AND POT.[Standard] = 1
    AND POT.Rework = 0
    AND POT.Test = 0
    AND PO.Active = 1
  WHERE PO.Plexus_Customer_No = @PCN
    AND (@Part_Key IS NULL OR PO.Part_Key = @Part_Key)
    AND (@Part_No IS NULL OR P.Part_No LIKE @Part_No + '%')
    AND (@Operation_Key IS NULL OR PO.Operation_Key = @Operation_Key)
    AND RTRIM(P.Part_No) != ''
    AND (ISNULL(@Part_Status_Keys,'') = '' OR CHARINDEX (',' + CAST(PS.Part_Status_Key AS VARCHAR(20)), @Part_Status_Keys) > 0)
  ) AS PO
  ON PO.PCN = WC.Plexus_Customer_No
JOIN dbo.Preferred_Approved_Source_v AS W 
  ON  W.Plexus_Customer_No = PO.PCN
  AND W.Part_Key = PO.Part_Key
  AND W.Part_Operation_Key = PO.Part_Operation_Key
  AND W.Workcenter_Key = WC.Workcenter_Key
JOIN dbo.Cost_Model AS CM
  ON  CM.PCN = @PCN
  AND CM.Cost_Model_Key = @Cost_Model_Key
  AND CM.Estimating_Model = 1
LEFT OUTER JOIN dbo.Cost_Workcenter AS CW -- values specific to this w/c and part op
  ON  CW.PCN = WC.Plexus_Customer_No
  AND CW.Cost_Model_Key = @Cost_Model_Key
  AND CW.Part_Key IS NULL
  AND CW.Part_Operation_Key IS NULL
  AND CW.Workcenter_Key = WC.Workcenter_Key
LEFT OUTER JOIN dbo.Cost_Workcenter AS CW2 -- for part ops
  ON  CW2.PCN = WC.Plexus_Customer_No
  AND CW2.Cost_Model_Key = @Cost_Model_Key
  AND CW2.Part_Key = PO.Part_Key
  AND CW2.Part_Operation_Key = PO.Part_Operation_Key
  AND CW2.Workcenter_Key = WC.Workcenter_Key
LEFT OUTER JOIN dbo.Cost_Workcenter AS CWG
  ON  CWG.PCN = WC.Plexus_Customer_No
  AND CWG.Cost_Model_Key = @Cost_Model_Key
  AND CWG.Workcenter_Key IS NULL
  AND CWG.Part_Key IS NULL
  AND CWG.Part_Operation_Key IS NULL
  AND CWG.Workcenter_Group = WC.Workcenter_Group
WHERE WC.Plexus_Customer_No = @PCN
  AND WC.Workcenter_Key = @Workcenter_Key
ORDER BY 
  WC.Workcenter_Code, 
  PO.Part_No, 
  PO.Operation_No, 
  PO.Operation_Code;

RETURN;