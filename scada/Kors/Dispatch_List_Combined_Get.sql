CREATE PROCEDURE [dbo].[sproc_Dispatch_List_Combined_Get]
(
  @PCN INT,
  @PLC_Name VARCHAR(50) = '',
  @Result_Error BIT = 0 OUTPUT,
  @Result_Code INT = 0 OUTPUT,
  @Result_Message VARCHAR(2000) = '' OUTPUT
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

---------------------------------------------------------------------------------------------------
-- Created: 12/27/16 cc.mmedwith
-- Purpose: Provide a list Jobs and Kanban tasks for a given workcenter
-- Used in: Cumulus Custom Integration with Ignition
--
-- 12/27/16 cc.mmedwith: Added
-- 04/17/17 itaylor PR-3666: Update temp table definition to be in line with modified Job_Dispatchs_Approved_Get
-- 12/18/17 cc.smorawski: Added Part_Op_Type data to SELECT lists
-- 06/04/20 skrishnaswamy : PX-44, 45 Add Multi out Set to be in line with Job Dispatch screens
-- 09/23/20 cc.mmedwith Adding a comment to track that we sold this to KORS, they will deploy their own version
---------------------------------------------------------------------------------------------------

-- Default values since Web Serivce calls overwrite the defaults
SELECT
  @Result_Message = 'Incomplete Transaction',
  @Result_Error = 1,
  @Result_Code = 100;

DECLARE
  @Workcenter_Type VARCHAR(50),
  @Only_Disply_Confirmed_Jobs SMALLINT,
  @Workcenter_Key INT;

-- Lookup the workcenter
SELECT 
  @Workcenter_Key = Workcenter_Key 
FROM Part.dbo.Workcenter AS W
WHERE W.Plexus_Customer_No = @PCN
  AND W.PLC_Name = @PLC_Name;

IF @Workcenter_Key IS NULL
BEGIN
  SELECT
    @Result_Message = 'Unable to find Workcenter with PLC_Name of ' + @PLC_Name,
    @Result_Error = 1,
    @Result_Code = 10;
  RETURN;
END;

-- Load Settings for Part.dbo.Job_Dispatchs_Approved_Get
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Job Dispatch List', 'Only Display Confirmed Jobs', @Only_Disply_Confirmed_Jobs OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Job Dispatch List', 'Workcenter Type Use', @Workcenter_Type OUTPUT;

-- Table for Part.dbo.Job_Dispatchs_Approved_Get
CREATE TABLE dbo.#Job_List
(
  -- Table is populated from another SPROC that doesn't return PCN
  Job_Key INT NULL,
  Job_Op_Key INT NULL,
  Job_No VARCHAR(100) NULL,
  Job_Status_Color VARCHAR(100) NULL,
  Job_Status VARCHAR(100) NULL,
  Issued_Status VARCHAR(100) NULL,
  Part_Key INT NULL,
  Part_No VARCHAR(100) NULL,
  Part_Status_Color VARCHAR(100) NULL,
  Part_No_Revision VARCHAR(100) NULL,
  Grade VARCHAR(100) NULL,
  Op_No VARCHAR(100) NULL,
  Operation_Key INT NULL,
  Operation_Code VARCHAR(100) NULL,
  Quantity INT NULL,
  Setup_Time DECIMAL(19,2) NULL,
  Run_Time DECIMAL(19,2) NULL,
  Due_Date DATETIME NULL,
  Job_Op_Status VARCHAR(100) NULL,
  Job_Op_Status_Color VARCHAR(100) NULL,
  Scheduled_Start VARCHAR(100) NULL,
  Temper VARCHAR(100) NULL,
  Priority INT NULL,
  Priority_Description VARCHAR(100),
  Priority_Color VARCHAR(100),
  Part_Operation_Key INT NULL,
  Work_Center VARCHAR(100),
  Workcenter_Key INT NULL,
  Standard_Hours_Remaining DECIMAL(19,2) NULL,
  Produced DECIMAL(19,2) NULL, 
  Job_Inventory DECIMAL(19,2) NULL,
  Job_Op_Due_Date DATETIME NULL,
  Setup_Job INT NULL,
  Sort INT NULL,
  Workcenter_Status VARCHAR(100) NULL,
  Workcenter_Status_Color VARCHAR(100) NULL,
  Run_Key INT NULL,
  Previous_Op_No INT NULL,
  Part_Group VARCHAR(100) NULL,
  Part_Group_Color VARCHAR(100) NULL,
  Part_Name VARCHAR(100) NULL,
  Job_Type VARCHAR(100) NULL,
  Job_Type_Color VARCHAR(100) NULL,
  Job_Due_Date DATETIME NULL,
  Workcenter_Group VARCHAR(100) NULL,
  Part_Net_Weight DECIMAL(19,2) NULL,
  Job_Op_Bulletin VARCHAR(100) NULL,
  Batch_Criteria VARCHAR(100) NULL,
  Batch_Workcenter INT NULL,
  Run_Locked BIT NULL,
  APS_Sequence_Key INT NULL,
  APS_Sequence_Sort_Order INT NULL,
  Multi_Out_Set_Key INT NULL
);

-- Call Part.dbo.Job_Dispatchs_Approved_Get
INSERT dbo.#Job_List
EXEC Part.dbo.Job_Dispatchs_Approved_Get
  @PCN = @PCN,
  @Workcenter_Key = @Workcenter_Key,
  @Job_No = '',
  @Part_Key = -1,
  @Operation_Key = '-1',
  @Job_Op_Status_Key = -1,
  @Outlook = 365,
  @Sort_Order = '',  -- Not yet used in this sproc
  @Workcenter_Type = '',
  @Only_Disply_Confirmed_Jobs = NULL,
  @Workcenter_Order = NULL,
  @Part_Group_Key = 0;

-- Table for Part.dbo.Kanban_Racks_Exclude_Job_Containers_Get
-- Table for Part.dbo.Kanban_Racks_by_Building_Get
CREATE TABLE dbo.#Kanban_Racks
(
  -- Table is populated from another SPROC that doesn't return PCN
  Max_Kanban_Cards INT NULL,
  URL VARCHAR(200) NULL,
  Red_Level INT NULL,
  Kanban_Cards INT NULL,
  Build_Cards INT NULL,
  Yellow_Level INT NULL, 
  Priority VARCHAR(100) NULL,
  Kanban_Rack_Key INT NULL,
  Part_Key INT NULL,
  --Kanban_Rack_Part_Operation_Key INT NULL, --Column is commented out in SPROC, guess this keeps things interesting
  Part_Operation_Key INT NULL,
  Quantity_Per_Card INT NULL,
  Cards_In_Use DECIMAL(19,2) NULL,
  Cards_In_Heijunka DECIMAL(19,2) NULL,
  [Level] INT NULL,
  Cards_Required DECIMAL(19,2) NULL,
  Part_No_Revision VARCHAR(100) NULL,
  Setup1 INT NULL,
  Setup INT NULL,
  Multi_Out_Part_Key INT NULL,
  Multi_Out_Part_Operation_Key INT NULL, 
  Workcenter_Key INT NULL,
  Workcenter_Code VARCHAR(100) NULL,
  Workcenter_Type VARCHAR(100) NULL,
  Pieces_By_Material DECIMAL(19,2) NULL,
  Operation_Code VARCHAR(100) NULL,
  Operation_Key INT NULL,
  Material_Code VARCHAR(100) NULL,
  Building_Code VARCHAR(100) NULL,
  Building_Key INT NULL,
  --Accounting_Job_Key INT NULL,  -- Not there, why we need two kanban tables
  --Accounting_Job_No VARCHAR(100) NULL, -- Also not there
  Part_Name VARCHAR(100) NULL,
  Approved_WC_Sort_Order INT NULL
);

-- Table for Part.dbo.Kanban_Racks_Get2
CREATE TABLE dbo.#Kanban_Racks_Get2
(
  -- Table is populated from another SPROC that doesn't return PCN
  Max_Kanban_Cards INT NULL,
  URL VARCHAR(200) NULL,
  Red_Level INT NULL,
  Kanban_Cards INT NULL,
  Build_Cards INT NULL,
  Yellow_Level INT NULL, 
  Priority VARCHAR(100) NULL,
  Kanban_Rack_Key INT NULL,
  Part_Key INT NULL,
  Kanban_Rack_Part_Operation_Key INT NULL,
  Part_Operation_Key INT NULL,
  Quantity_Per_Card INT NULL,
  Cards_In_Use DECIMAL(19,2) NULL,
  Cards_In_Heijunka DECIMAL(19,2) NULL,
  [Level] INT NULL,
  Cards_Required DECIMAL(19,2) NULL,
  Part_No_Revision VARCHAR(100) NULL,
  Setup1 INT NULL,
  Setup INT NULL,
  Multi_Out_Part_Key INT NULL,
  Multi_Out_Part_Operation_Key INT NULL, 
  Workcenter_Key INT NULL,
  Workcenter_Code VARCHAR(100) NULL,
  Workcenter_Type VARCHAR(100) NULL,
  Pieces_By_Material DECIMAL(19,2) NULL,
  Operation_Code VARCHAR(100) NULL,
  Operation_Key INT NULL,
  Material_Code VARCHAR(100) NULL,
  Building_Code VARCHAR(100) NULL,
  Building_Key INT NULL,
  Accounting_Job_Key INT NULL,
  Accounting_Job_No VARCHAR(100) NULL,
  Part_Name VARCHAR(100) NULL,
  Approved_WC_Sort_Order INT NULL
);

DECLARE
  @Exclude_Job_Containers BIT,
  @Same_Kanban_Rack_Different_Building_Allow BIT,
  @Kanban_Rack_To_Accounting_Job_Link BIT,
  @Workcenter_Status_Key INT;

EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Kanban','Job Associated Containers Exclude',@Exclude_Job_Containers OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Kanban','Same Kanban Rack Different Building Allow',@Same_Kanban_Rack_Different_Building_Allow OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Kanban','Kanban Rack to Accounting Job Link',@Kanban_Rack_To_Accounting_Job_Link OUTPUT;

EXEC @Workcenter_Status_Key = Part.dbo.Workcenter_Current_Status_Key_Get @PCN, @Workcenter_Key, 1;

-- Kanban results are defined by settings, similar behavior on Kanban_Racks.asp
IF @Exclude_Job_Containers = 1
BEGIN
  -- Call Part.dbo.Kanban_Racks_Exclude_Job_Containers_Get
  INSERT dbo.#Kanban_Racks
  EXEC Part.dbo.Kanban_Racks_Exclude_Job_Containers_Get
    @PCN = @PCN,
    @Workcenter_Key = @Workcenter_Key;

END
ELSE IF @Same_Kanban_Rack_Different_Building_Allow = 1 OR @Kanban_Rack_To_Accounting_Job_Link = 1
BEGIN
  -- Call Part.dbo.Kanban_Racks_by_Building_Get
  INSERT dbo.#Kanban_Racks
  EXEC Part.dbo.Kanban_Racks_by_Building_Get
    @PCN = @PCN,
    @Workcenter_Key = @Workcenter_Key;
END
ELSE
BEGIN
  -- Call Part.dbo.Kanban_Racks_Get2
  INSERT dbo.#Kanban_Racks_Get2
  EXEC Part.dbo.Kanban_Racks_Get2
    @PCN = @PCN,
    @Workcenter_Key = @Workcenter_Key;
END;

SELECT
  1 AS Dispatch_Type_Key,
  'Job' AS Dispatch_Type,
  JL.Part_Key,
  JL.Part_No_Revision,
  JL.Part_Operation_Key,
  JL.Part_Group,
  JL.Part_Name,
  JL.Part_Net_Weight,
  JL.Op_No,
  JL.Operation_Key,
  JL.Operation_Code,
  JL.Work_Center AS Workcenter_Code,
  JL.Workcenter_Key,
  W.Workcenter_Type,
  JL.Workcenter_Group,
  WS.Workcenter_Status_Key,
  WS.Description AS Workcenter_Status,
  WS.Color AS Workcenter_Status_Color,
  -- Job Stuff
  JL.Job_Key,
  JL.Job_Op_Key,
  JL.Job_No,
  JL.Job_Status,
  JL.Job_Op_Due_Date,
  JL.Job_Type,
  JL.Job_Op_Bulletin,
  JL.Quantity AS Job_Quantity,
  JL.Due_Date AS Job_Due_Date,
  JL.Priority AS Job_Priority,
  JL.Produced AS Job_Produced,
  -- Kanban stuff
  NULL AS Red_Level,
  NULL AS Kanban_Cards,
  NULL AS Build_Cards,
  NULL AS Yellow_Level, 
  NULL AS Quantity_Per_Card,
  NULL AS Cards_In_Use,
  NULL AS Cards_In_Heijunka,
  NULL AS [Level],
  NULL AS Cards_Required,
  -- Part_Op_Type stuff
  POT.Part_Op_Type_Key,
  POT.Description AS Part_Op_Type_Description,
  POT.Standard,
  POT.Color AS Part_Op_Type_Color,
  POT.Default_Part_Op_Type,
  POT.Sort_Order,
  POT.Copy_To_Job,
  POT.Test,
  POT.Qualification,
  POT.Rework,
  POT.Zero_Standard_Cost,
  POT.Include_In_MRP,
  POT.Job_Op_Status_Key,
  POT.Cell,
  POT.Custom_Order_BOM,
  POT.Include_In_MRP_Inventory,
  POT.Packaging,
  POT.Accept_Job_Allocations,
  POT.Key_Count_Operation,
  POT.Paint_Document,
  POT.Emissions_Label,
  POT.Emissions_Verify,
  POT.Reclassification_Allow,
  POT.Scaling
FROM dbo.#Job_List AS JL
JOIN Part.dbo.Workcenter AS W
  ON W.Plexus_Customer_No = @PCN
  AND W.Workcenter_Key = JL.Workcenter_Key
LEFT OUTER JOIN Part.dbo.Workcenter_Status AS WS
  ON WS.Plexus_Customer_No = W.Plexus_Customer_No
  AND WS.Workcenter_Status_Key = @Workcenter_Status_Key
LEFT OUTER JOIN Part.dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = W.Plexus_Customer_No
  AND PO.Part_Operation_Key = JL.Part_Operation_Key
LEFT OUTER JOIN Part.dbo.Part_Op_Type AS POT
  ON POT.PCN = PO.Plexus_Customer_No
  AND POT.Part_Op_Type_Key = PO.Part_Op_Type_Key
UNION ALL
SELECT
  2 AS Dispatch_Type_Key,
  'Kanban' AS Dispatch_Type,
  K1.Part_Key,
  K1.Part_No_Revision,
  K1.Part_Operation_Key,
  PG.Part_Group,
  K1.Part_Name,
  PO.Net_Weight AS Part_Net_Weight,
  PO.Operation_No AS Op_No,
  K1.Operation_Key,
  K1.Operation_Code,
  K1.Workcenter_Code,
  K1.Workcenter_Key,
  K1.Workcenter_Type,
  W.Workcenter_Group,
  WS.Workcenter_Status_Key,
  WS.Description AS Workcenter_Status,
  WS.Color AS Workcenter_Status_Color,
  -- Job Stuff
  NULL AS Job_Key,
  NULL AS Job_Op_Key,
  NULL AS Job_No,
  NULL AS Job_Status,
  NULL AS Job_Op_Due_Date,
  NULL AS Job_Type,
  NULL AS Job_Op_Bulletin,
  NULL AS Job_Quantity,
  NULL AS Job_Due_Date,
  NULL AS Job_Priority,
  NULL AS Job_Produced,
  -- Kanban stuff
  K1.Red_Level,
  K1.Kanban_Cards,
  K1.Build_Cards,
  K1.Yellow_Level, 
  K1.Quantity_Per_Card,
  K1.Cards_In_Use,
  K1.Cards_In_Heijunka,
  K1.[Level],
  K1.Cards_Required,
  -- Part_Op_Type stuff
  POT.Part_Op_Type_Key,
  POT.Description AS Part_Op_Type_Description,
  POT.Standard,
  POT.Color AS Part_Op_Type_Color,
  POT.Default_Part_Op_Type,
  POT.Sort_Order,
  POT.Copy_To_Job,
  POT.Test,
  POT.Qualification,
  POT.Rework,
  POT.Zero_Standard_Cost,
  POT.Include_In_MRP,
  POT.Job_Op_Status_Key,
  POT.Cell,
  POT.Custom_Order_BOM,
  POT.Include_In_MRP_Inventory,
  POT.Packaging,
  POT.Accept_Job_Allocations,
  POT.Key_Count_Operation,
  POT.Paint_Document,
  POT.Emissions_Label,
  POT.Emissions_Verify,
  POT.Reclassification_Allow,
  POT.Scaling
FROM dbo.#Kanban_Racks AS K1
JOIN Part.dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = @PCN
  AND PO.Part_Key = K1.Part_Key
  AND PO.Part_Operation_Key = K1.Part_Operation_Key
JOIN Part.dbo.Workcenter AS W
  ON W.Plexus_Customer_No = @PCN
  AND W.Workcenter_Key = K1.Workcenter_Key
LEFT OUTER JOIN Part.dbo.Workcenter_Status AS WS
  ON WS.Plexus_Customer_No = W.Plexus_Customer_No
  AND WS.Workcenter_Status_Key = @Workcenter_Status_Key
JOIN Part.dbo.Part AS P
  ON P.Plexus_Customer_No = @PCN
  AND P.Part_Key = K1.Part_Key
LEFT OUTER JOIN Part.dbo.Part_Group AS PG
  ON PG.Plexus_Customer_No = P.Plexus_Customer_No
  AND PG.Part_Group_Key = P.Part_Group_Key
LEFT OUTER JOIN Part.dbo.Part_Op_Type AS POT
  ON POT.PCN = PO.Plexus_Customer_No
  AND POT.Part_Op_Type_Key = PO.Part_Op_Type_Key
UNION ALL
SELECT
  2 AS Dispatch_Type_Key,
  'Kanban' AS Dispatch_Type,
  K2.Part_Key,
  K2.Part_No_Revision,
  K2.Part_Operation_Key,
  PG.Part_Group,
  K2.Part_Name,
  PO.Net_Weight AS Part_Net_Weight,
  PO.Operation_No AS Op_No,
  K2.Operation_Key,
  K2.Operation_Code,
  K2.Workcenter_Code,
  K2.Workcenter_Key,
  K2.Workcenter_Type,
  W.Workcenter_Group,
  WS.Workcenter_Status_Key,
  WS.Description AS Workcenter_Status,
  WS.Color AS Workcenter_Status_Color,
  -- Job Stuff
  NULL AS Job_Key,
  NULL AS Job_Op_Key,
  NULL AS Job_No,
  NULL AS Job_Status,
  NULL AS Job_Op_Due_Date,
  NULL AS Job_Type,
  NULL AS Job_Op_Bulletin,
  NULL AS Job_Quantity,
  NULL AS Job_Due_Date,
  NULL AS Job_Priority,
  NULL AS Job_Produced,
  -- Kanban stuff
  K2.Red_Level,
  K2.Kanban_Cards,
  K2.Build_Cards,
  K2.Yellow_Level, 
  K2.Quantity_Per_Card,
  K2.Cards_In_Use,
  K2.Cards_In_Heijunka,
  K2.[Level],
  K2.Cards_Required,
  -- Part_Op_Type stuff
  POT.Part_Op_Type_Key,
  POT.Description AS Part_Op_Type_Description,
  POT.Standard,
  POT.Color AS Part_Op_Type_Color,
  POT.Default_Part_Op_Type,
  POT.Sort_Order,
  POT.Copy_To_Job,
  POT.Test,
  POT.Qualification,
  POT.Rework,
  POT.Zero_Standard_Cost,
  POT.Include_In_MRP,
  POT.Job_Op_Status_Key,
  POT.Cell,
  POT.Custom_Order_BOM,
  POT.Include_In_MRP_Inventory,
  POT.Packaging,
  POT.Accept_Job_Allocations,
  POT.Key_Count_Operation,
  POT.Paint_Document,
  POT.Emissions_Label,
  POT.Emissions_Verify,
  POT.Reclassification_Allow,
  POT.Scaling
FROM dbo.#Kanban_Racks_Get2 AS K2
JOIN Part.dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = @PCN
  AND PO.Part_Key = K2.Part_Key
  AND PO.Part_Operation_Key = K2.Part_Operation_Key
JOIN Part.dbo.Workcenter AS W
  ON W.Plexus_Customer_No = @PCN
  AND W.Workcenter_Key = K2.Workcenter_Key
LEFT OUTER JOIN Part.dbo.Workcenter_Status AS WS
  ON WS.Plexus_Customer_No = W.Plexus_Customer_No
  AND WS.Workcenter_Status_Key = @Workcenter_Status_Key
JOIN Part.dbo.Part AS P
  ON P.Plexus_Customer_No = @PCN
  AND P.Part_Key = K2.Part_Key
LEFT OUTER JOIN Part.dbo.Part_Group AS PG
  ON PG.Plexus_Customer_No = P.Plexus_Customer_No
  AND PG.Part_Group_Key = P.Part_Group_Key
LEFT OUTER JOIN Part.dbo.Part_Op_Type AS POT
  ON POT.PCN = PO.Plexus_Customer_No
  AND POT.Part_Op_Type_Key = PO.Part_Op_Type_Key;

DROP TABLE dbo.#Job_List;
DROP TABLE dbo.#Kanban_Racks;
DROP TABLE dbo.#Kanban_Racks_Get2;

SELECT
  @Result_Message = 'Success',
  @Result_Error = 0,
  @Result_Code = 0;

RETURN;