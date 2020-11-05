CREATE PROCEDURE dbo.sproc23551_Last_Loaded_Source_Inventory_Container_By_Part_Get
(
  @PCN INT = 23551,
  @Workcenter_Key INT = NULL,
  @Part_Key INT,
  @Row_Limit INT = 100,
  @Require_Part_Key BIT = 1,
  @Require_WcKey BIT = 1,
  @Result_Error BIT = 0 OUTPUT,
  @Result_Code INT = 0 OUTPUT,
  @Result_Message VARCHAR(150) = 'Success' OUTPUT
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Created: 9/29/2020 ke.kofflerj, Kors Engineering
-- Purpose: Get workcenter's most recently loaded source container for a given part key
-- Used in: Mach2

-- Set default row limit to 100 if null or to 1000 if over 1000...
SELECT
  @Row_Limit = ISNULL(IIF(@Row_Limit <= 0, NULL, IIF(@Row_Limit > 1000, 1000, @Row_Limit)), 100);

-- If @Workcenter_Key is provided verify it is valid regardless if @Require_WcKey is true or not...
IF ISNULL(@Workcenter_Key, 0) > 0
BEGIN
  IF NOT EXISTS
  (
    SELECT
    *
    FROM Part.dbo.Workcenter AS W
    WHERE W.Plexus_Customer_No = @PCN
    AND W.Workcenter_Key = @Workcenter_Key
  )
  BEGIN
    SELECT
      @Result_Code = 101,
      @Result_Error = 1,
      @Result_Message = 'Workcenter key ' + CONVERT(varchar(32), @Workcenter_Key) + ' does not exist.';
    RETURN;
  END
END
-- If @Workcenter_Key is null or zero and @Require_WcKey is true then display no wcKey error...
ELSE IF ISNULL(@Workcenter_Key, 0) = 0 AND ISNULL(@Require_WcKey, 1) = 1
BEGIN
  SELECT
    @Result_Code = 102,
    @Result_Error = 1,
    @Result_Message = 'No workcenter key provided';
  RETURN;
END;

-- Verify we have a part key if @Require_Part_Key is true...
IF ISNULL(@Part_Key, -1) < 0 AND ISNULL(@Require_Part_Key, 1) = 1
BEGIN
  SELECT
    @Result_Code = 103,
    @Result_Error = 1,
    @Result_Message = 'Part Key Not Provided';
  RETURN;
END
ELSE IF NOT EXISTS(SELECT * FROM Part.dbo.Part WHERE Part_Key = @Part_Key) AND @Part_Key IS NOT NULL
BEGIN
  SELECT
    @Result_Code = 104,
    @Result_Error = 1,
    @Result_Message = 'Invalid Part Key ' + CONVERT(varchar(32), @Part_Key);
  RETURN;
END;

SELECT TOP(@Row_Limit)
  WC.Workcenter_Code AS 'Workcenter_Code',
  WC.PLC_Name AS 'PLC_Name',
  WC.Workcenter_Key AS 'Workcenter_Key',
  WS.Part_Key AS 'Part_Key',
  P.Part_No AS 'Part_No',
  P.Revision AS 'Revision',
  P.[Name] AS 'Name',
  WS.Serial_No AS 'Serial_No',
  WS.Quantity AS 'Quantity',
  WS.Net_Weight AS 'Net Weight',
  WS.Deplete_Quantity AS 'Deplete_Quantity',
  WS.Container_Type AS 'Container_Type',
  WS.Part_Operation_Key AS 'Part_Operation_Key',
  WS.Shared AS 'Shared',
  WS.Sort_Order AS 'Sort_Order',
  WS.Tracking_No AS 'Tracking_No',
  WS.Workcenter_Source_Position_Key AS 'Workcenter_Source_Position_Key',
  WS.BOM_Key AS 'BOM_Key',
  P.Part_Type AS 'Part_Type',
  P.Serialize AS 'Serialize',
  P.Standard_Job_Quantity AS 'Standard_Job_Quantity',
  (
    SELECT TOP(1)
      CC2.Change_Date AS 'Change_Date'
    FROM Part.dbo.Container_Change2 AS CC2
    WHERE CC2.Serial_No = WS.Serial_No
      AND CC2.Last_Action LIKE '%Loaded to Workcenter%'
    ORDER BY
      CC2.Change_Date DESC
  ) AS 'Loaded_Date',
  (PU.First_Name + ' ' + PU.Last_Name) AS 'Loaded_By',
  PU.User_ID AS 'Loaded_By_User_ID'
FROM Part.dbo.Workcenter_Source_Inventory_D AS WS
JOIN Part.dbo.Workcenter AS WC
  ON WC.Plexus_Customer_No = @PCN
  AND WC.Workcenter_Key = WS.Workcenter_Key
JOIN Plexus_Control.dbo.Plexus_User AS PU
  ON PU.Plexus_Customer_No = @PCN
  AND PU.Plexus_User_No =
  (
    SELECT TOP(1)
      CC2.Change_By
    FROM Part.dbo.Container_Change2 AS CC2
    WHERE CC2.Serial_No = WS.Serial_No
      AND CC2.Last_Action LIKE '%Loaded to Workcenter%'
    ORDER BY
      CC2.Change_Date DESC
  )
JOIN Part.dbo.Part AS P
  ON P.Plexus_Customer_No = @PCN
  AND P.Part_Key = WS.Part_Key
WHERE WS.Workcenter_Key = ISNULL(@Workcenter_Key, WS.Workcenter_Key)
  AND WS.Part_Key = ISNULL(@Part_Key, WS.Part_Key)
ORDER BY
  Loaded_Date DESC