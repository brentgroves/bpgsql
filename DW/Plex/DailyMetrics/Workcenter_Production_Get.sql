CREATE PROCEDURE [dbo].[Workcenter_Production_Get]
(
  @Plexus_Customer_No INTEGER,
  @Workcenter_Key INTEGER
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Revised by SSIG on 1/25/02
-- Purpose: Gets the workcenter info for recording production.
-- Used in: Record_Production_Form.asp

-- 07/10/02 DSHU: Added Processing_Capacity to the Select.
-- 08/09/02 BVIN: Return new Machine Integration fields in recordset.
-- 08/12/02 DSHU: Added Resource_Key and Resource_Available to the select
-- 10/14/02 gpra: Added Cost_Unit
-- 11/01/02 DSHU: Added W.Department_No to the select
-- 02/24/03 BVIN: Added PLC_Name and Server_Key to recordset.
-- 05/12/03 BVIN: Remove unused PLC fields.
-- 06/04/03 JFOS: Added @Saw_Dept_No
-- 03/19/04 GTIL: remove f_previous_part_op UDF
-- 06/28/04 JDAN: Added Direct_Labor_Cost, removed f_ Customer_Setting_Get UDF
-- 12/15/04 GTIL: removed UDFs, add Quantity, only return production within the last thirty minutes
-- 01/30/06 GTIL: add Fixed_Overhead_Cost_Table_Vlue
-- 04/06/06 TMCG: Added Workcenter.IPAddress to SELECT list
-- 07/21/06 MMCD: added Allow_Master_Unit_Build
-- 05/21/07 MYEA: Added Suppress_Label Auto_Unload_Source Password_Required_For_Production Square_Area
-- 09/26/07 CCAST: Added Setup_Check_Expiration_Days
-- 01/28/08 DRAYCHEV: Added 3 cols:Lifetime,Maintenance_Cost,Fair_Market_Value
-- 08/06/08 MREINELT: Added column Crop_Length
-- 09/12/08 DRAYCHEV: dbo.Workcenter_Rate.Periodic_Quantity
-- 11/25/08 RNG: Added setup cost
-- 12/17/08 MMCD added Global_Production_Rate
-- 06/12/09 MMCD added Target_Value_Add
-- 02/20/10 SSHERMAN added location group
-- 08/09/10 MREINELT: Added Key_Reporting to SELECT.
-- 02/08/11 RKEAST: Replaced Part.Image w/ Part_Image.Image_Path (USR 525131)
-- 02/28/11 TSCH: "PO.Net_Weight AS Part_Weight," was listed 2x in final select. Removed to prevent DS registration VP error: 
--          Exception: Plexus.Data.DuplicateColumnNameException: A duplicate column name (Part_Weight) was detected in the result set. Please verify all column names are unique by either removing the duplicate(s) or using an alias for identical column name(s) from multiple tables
-- 10/23/12 ITAYLOR: Removed Resource_Available
-- 03/03/16 itaylor 2001762: Eliminate Alt_Sh1ft_Cycle_Key
-- 03/03/16 itaylor 838699: Eliminate Queue_T1me

DECLARE 
  @Current_Op INT,
  @Next_Op_Key INT,
  @Last_Container VARCHAR(25),
  @Last_Weight DECIMAL(9,2),
  @Last_User VARCHAR(100),
  @Last_Time DATETIME,
  @Last_Location VARCHAR(50),
  @Part_Key INT,
  @Saw_Dept_No VARCHAR(50),
  @Setting_Saw_Department VARCHAR(100),
  @Supplier VARCHAR(500),
  @Last_Quantity INT,
  @LifetimeDaysInAYear DECIMAL(8,5),    -- conversion factor
  @MaintCostDaysInAYear DECIMAL(8,5),   -- conversion factor
  @LifeTimeYearsDisplay INT,            -- customer setting on/off
  @MaintenanceCostPerYearDisplay INT,   -- customer setting on/off
  @Days2YearsFactor DECIMAL(8,5),        -- get from customer setting and apply to Lifetime and MaintCost - if needed
  @Location_Group_Key INT,
  @Location_Group VARCHAR(50)

-- get the conversion factor for days to years
exec Plexus_Control.dbo.Customer_Setting_Get2 @Plexus_Customer_No,'Workcenter','Days to Years Conversion Factor', @Days2YearsFactor OUTPUT
IF ISNULL(@Days2YearsFactor,0) = 0 SET @Days2YearsFactor = 365

-- check if the customer wants the Lifetime in days (default) or years (enabled by a setting)
exec Plexus_Control.dbo.Customer_Setting_Get2 @Plexus_Customer_No,'Workcenter','Lifetime Years Display', @LifeTimeYearsDisplay OUTPUT
IF @LifeTimeYearsDisplay = 1
  SET @LifetimeDaysInAYear = @Days2YearsFactor
ELSE
  SET @LifetimeDaysInAYear = 1

-- check if the customer wants the Lifetime in days (default) or years (enabled by a setting)
exec Plexus_Control.dbo.Customer_Setting_Get2 @Plexus_Customer_No,'Workcenter','Maintenance Cost Per Year Display', @MaintenanceCostPerYearDisplay OUTPUT
IF @MaintenanceCostPerYearDisplay = 1
  SET @MaintCostDaysInAYear = @Days2YearsFactor
ELSE
  SET @MaintCostDaysInAYear = 1


EXEC Plexus_Control.dbo.Customer_Setting_Get2 @Plexus_Customer_No, 'Material Control Manager', 'Saw Department', @Setting_Saw_Department OUTPUT

-- The MCM section on the form if the workcenter is part of the department defined in the "Saw Department" customer setting.
SELECT 
@Saw_Dept_No = D.Department_No
FROM Common.dbo.Department AS D
WHERE D.Plexus_Customer_No = @Plexus_Customer_No
  AND D.Department_Code = @Setting_Saw_Department

SELECT TOP 1 
@Last_Container = P1.Serial_No,
@Last_Weight = P1.Net_Weight,
@Last_User = PU.First_Name + ' ' + PU.Last_Name,
@Last_Time = P1.Record_Date,
@Last_Location = C.Location,
@Last_Quantity = P1.Quantity

FROM dbo.Workcenter AS W 
JOIN dbo.Production AS P1
  ON P1.Plexus_Customer_No = W.Plexus_Customer_No -- added by dshu and draychev: Don't all indexes on the production table include PCN now?
  AND W.Part_Key = P1.Part_Key
  AND W.Part_Operation_Key = P1.Part_Operation_Key
  AND W.Workcenter_Key = P1.Workcenter_Key
JOIN dbo.Container AS C
  ON C.Plexus_Customer_No = P1.Plexus_Customer_No
  AND C.Serial_No = P1.Serial_no
LEFT OUTER JOIN Plexus_Control.dbo.Plexus_User AS PU 
  ON PU.Plexus_User_No = P1.Record_By
WHERE W.Plexus_Customer_No = @Plexus_Customer_No 
  AND W.Workcenter_Key = @Workcenter_Key
  AND P1.Record_Date > DATEADD(mi,-30, GETDATE())
ORDER BY P1.Record_Date DESC

SELECT TOP 1
  @Location_Group_Key = L.Location_Group_Key,
  @Location_Group = LG.Location_Group
FROM dbo.Workcenter AS W
JOIN Common.dbo.Location AS L
  ON L.Plexus_Customer_No = W.Plexus_Customer_No
  AND L.Location = W.Workcenter_Code
JOIN Common.dbo.Location_Group AS LG
  ON LG.PCN = L.Plexus_Customer_No
  AND LG.Location_Group_Key = L.Location_Group_Key
WHERE W.Plexus_Customer_No = @Plexus_Customer_No
  AND W.Workcenter_Key = @Workcenter_Key

SELECT 
@Current_Op = PO.Operation_No, 
@Part_Key = W.Part_Key
FROM dbo.Workcenter AS W 
JOIN dbo.Part_Operation AS PO
  ON PO.Part_Operation_Key = W.Part_Operation_Key
  AND PO.Part_Key = W.Part_Key
  AND PO.Plexus_Customer_No = W.Plexus_Customer_No
WHERE W.Plexus_Customer_No = @Plexus_Customer_No 
  AND W.Workcenter_Key = @Workcenter_Key

SELECT TOP 1 
  @Next_Op_Key = PO.Part_Operation_Key 
FROM dbo.Part_Operation AS PO 
WHERE PO.Plexus_Customer_No = @Plexus_Customer_No 
  AND PO.Part_Key = @Part_Key 
  AND PO.Operation_No > @Current_Op 
  AND PO.Active = 1 
  AND PO.Suboperation = 0 
ORDER BY PO.Operation_No ASC

SELECT @Supplier = ISNULL(@Supplier + ', ','') + CS.Supplier_Code
FROM dbo.Approved_Supplier AS S 
JOIN Common.dbo.Supplier AS CS 
  ON S.Plexus_Customer_No = CS.Plexus_Customer_No
  AND S.Supplier_No = CS.Supplier_No
WHERE S.Plexus_Customer_No = @Plexus_Customer_No
  AND S.Part_Key = @Part_Key
  AND S.Part_Operation_Key = @Next_Op_Key
  AND CS.Supplier_Status != 'Deleted'
ORDER BY S.Sort_Order, CS.Supplier_Code


SELECT  
  CASE W.Department_No
    WHEN @Saw_Dept_No THEN W.Kerf_Length
    ELSE -1
  END AS Default_Kerf_Length,
  W.Workcenter_Key, 
  W.Workcenter_Code, 
  W.[Name], 
  W.Workcenter_Type, 
  W.Workcenter_Group,
  W.Workcenter_Size,
  W.Part_Key, 
  W.Part_Operation_Key, 
  W.Heat_Key, 
  W.Building_Key, 
  W.Sort_Order,
  W.Note,
  W.Material_Key,
  W.Shift_Schedule_Key,
  W.Shift_Cycle_Key,
  W.Allow_Schedule,
  W.Variable_Cost,
  W.Setup_Cost,
  W.Overhead_Cost,
  W.Direct_Labor_Cost,
  W.Cost_Unit,
  W.Active,
  W.Default_Production_Location,
  W.Standard_Setup_Time,
  W.Goal_Setup_Time,
  W.Finite_Percent,
  W.Processing_Type_Key,
  W.Processing_Unit,  
  W.Account_No,
  W.Scheduling_Method_Key,
  W.Efficiency,
  W.Batching,
  W.Machine_Integration,
  W.PLC_Name,
  W.Server_Key,
  W.Suppress_Label,
  W.Auto_Unload_Source,
  W.Password_Required_For_Production,
  W.Square_Area,
  P.Part_No, 
  P.Revision, 
  P.[Name] AS Part_Name, 
  PIM.Image_Path AS [Image], 
  PO.Net_Weight AS Part_Weight,
  M.Material_Code,
  O.Operation_Code, 
  O.Operation_Key, 
  H.Heat_Code, 
  H.Heat_No, 
  B.Building_Code, 
  CSS.[Description],
  SC.Shift_Cycle,
  '0' AS Open_Work_Order,
  @Supplier AS Supplier,
  W.Operation_Key AS Setup_Operation_Key,
  (
    SELECT TOP 1 Production_Tool_Status_Key
    FROM dbo.Timeblock AS T1
    WHERE T1.Workcenter_Key = W.Workcenter_Key
      AND T1.[Open] = 1
    ORDER BY Schedule_Order
  ) AS Production_tool_Status_Key,
  W.Processing_Capacity,
  W.Resource_Key,
  @Last_Container AS Last_Container,
  @Last_Weight AS Last_Weight,
  @Last_User AS Last_User,
  @Last_Time AS Last_Time,
  @Last_Location AS Last_Location,
  @Last_Quantity AS Last_Quantity,
  (SELECT TOP 1 PO.Part_Operation_Key
  FROM dbo.Part_Operation AS PO
  JOIN dbo.Part_Op_Type AS POT
    ON PO.Plexus_Customer_No = POT.PCN
    AND PO.Part_Op_Type_Key = POT.Part_Op_Type_Key
  WHERE PO.Plexus_Customer_No = W.Plexus_Customer_No
    AND PO.Part_Key = W.Part_Key
    AND PO.Operation_No < (SELECT Operation_No FROM dbo.Part_Operation WHERE Plexus_Customer_No = W.Plexus_Customer_No AND Part_Key = W.Part_Key AND Part_Operation_Key = W.Part_Operation_Key)
    AND PO.Active = 1
    AND POT.Standard = 1
    AND PO.Suboperation = 0
    ORDER BY PO.Operation_No DESC
  )  AS Previous_Op,
  W.Department_No,
  (SELECT TOP 1 Timeblock_Key FROM dbo.Timeblock WHERE Plexus_Customer_No = W.Plexus_Customer_No AND Workcenter_Key = W.Workcenter_Key AND [Open] = 1 ORDER BY Schedule_Order) AS 'Current_Timeblock',
  (SELECT TOP 1 Timeblock_Key FROM dbo.Timeblock WHERE Plexus_Customer_No = W.Plexus_Customer_No AND Workcenter_Key = W.Workcenter_Key AND [Open] = 1 AND Schedule_Order > (SELECT TOP 1 Schedule_Order FROM Timeblock WHERE Plexus_Customer_No = W.Plexus_Customer_No AND Workcenter_Key = W.Workcenter_Key AND [Open] = 1 ORDER BY Schedule_Order) ORDER BY Schedule_Order) AS 'Next_Timeblock',
  @Next_Op_Key AS Next_Part_Op,
  (SELECT SUM(Fixed_Overhead_Cost) FROM dbo.Fixed_Overhead_Cost WHERE PCN = @Plexus_Customer_No AND Workcenter_Key = @Workcenter_Key) AS 'Fixed_Overhead_Cost_Table_Value',
  W.IPAddress,
  W.Allow_Master_Unit_Build,
  W.Setup_Check_Expiration_Days,
  CASE    -- if the customer desires to calculate the lifetime in years - setting
    WHEN @LifetimeDaysInAYear > 1 THEN ROUND(W.[Lifetime]/@LifetimeDaysInAYear,0)  --value is stored in days, if years - INTeger
    ELSE W.[Lifetime]
  END AS [Lifetime],
  CASE    -- if the customer desires to calculate the maint cost in currency per year - setting
    WHEN @MaintCostDaysInAYear > 1 THEN ROUND(W.Maintenance_Cost*@MaintCostDaysInAYear,1) -- value is stored in $ per day
    ELSE W.Maintenance_Cost
  END AS Maintenance_Cost,
  W.Fair_Market_Value,
  W.Crop_Length,
  WR.Periodic_Quantity,
  WR.Periodic_Quantity_Unit_Key,
  U.Unit AS Periodic_Quantity_Unit,
  W.Global_Production_Rate,
  W.Target_Value_Add,
  @Location_Group_Key AS Location_Group_Key,
  @Location_Group AS Location_Group,
  W.Key_Reporting
FROM dbo.Workcenter AS W
LEFT OUTER JOIN dbo.Part AS P
  ON W.Plexus_Customer_No = P.Plexus_Customer_No 
  AND W.Part_Key = P.Part_Key
LEFT OUTER JOIN Material.dbo.Heat AS H 
  ON H.Plexus_Customer_No = W.Plexus_Customer_No 
  AND H.Heat_Key = W.Heat_Key 
LEFT OUTER JOIN Material.dbo.Material AS M 
  ON M.Plexus_Customer_No = W.Plexus_Customer_No 
  AND M.Material_Key = W.Material_Key
LEFT OUTER JOIN dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = W.Plexus_Customer_No 
  AND PO.Part_Key = W.Part_Key
  AND PO.Part_Operation_Key = W.Part_Operation_Key
LEFT OUTER JOIN dbo.Operation AS O
  ON O.Plexus_Customer_No = PO.Plexus_Customer_No 
  AND O.Operation_Key = PO.Operation_Key
LEFT OUTER JOIN Common.dbo.Building AS B
  ON B.Plexus_Customer_No = W.Plexus_Customer_No 
  AND B.Building_Key = W.Building_Key
LEFT OUTER JOIN Common.dbo.Shift_Cycle AS SC 
  ON SC.PCN = W.Plexus_Customer_No 
  AND SC.Shift_Cycle_Key = W.Shift_Cycle_Key
LEFT OUTER JOIN Common.dbo.Shift_Schedule AS CSS
  ON CSS.Plexus_Customer_No = W.Plexus_Customer_No
  AND CSS.Shift_Schedule_Key = W.Shift_Schedule_Key
LEFT OUTER JOIN dbo.Workcenter_Rate AS WR
  ON WR.PCN = W.Plexus_Customer_No
  AND WR.Workcenter_Key = W.Workcenter_Key
LEFT OUTER JOIN Common.dbo.Unit AS U
  ON U.Plexus_Customer_No = W.Plexus_Customer_No
  AND U.Unit_Key = WR.Periodic_Quantity_Unit_Key
LEFT OUTER JOIN dbo.Part_Image AS PIM
  ON PIM.PCN = P.Plexus_Customer_No
  AND PIM.Part_Key = P.Part_Key
  AND PIM.Default_Image = 1
  AND PIM.Active = 1
WHERE W.Plexus_Customer_No = @Plexus_Customer_No
  AND W.Workcenter_Key = @Workcenter_Key


RETURN