CREATE PROCEDURE [dbo].[Daily_Shift_Report_Get]
(
  @PCN INT,
  @Start_Date DATETIME,
  @End_Date DATETIME = NULL,
  @Department_Nos VARCHAR(1000) = '',
  @Workcenter_Keys VARCHAR(8000) = '',
  @Shift_Group VARCHAR(50) = '',
  @Manager_PUN INT = 0,
  @Workcenter_Rate SMALLINT = 1,  -- 1 = ideal_rate, 2 = target_rate, 0 = standard_production_rate
  @Labor_Rate SMALLINT = 2,       -- 1 = ideal_rate, 2 = target_rate, 0 = standard_production_rate
  @Part_Key INT = -1,
  @Job_Key INT = -1,
  @Workcenter_Type_Key INT = -1,
  @Operation_Key INT = -1,
  @Include_Rework SMALLINT = -1,  -- 1 = only, 0 = none, -1 = all
  @Include_Unassigned_Labor BIT = 0,
  @Workcenter_Efficiency_Max DECIMAL(9,5) = NULL,
  @Labor_Efficiency_Max DECIMAL(9,5) = NULL,
  @Use_Current_Rates BIT = 0,
  @Include_Operators BIT = 0,
  @Workcenter_Group VARCHAR(50) = '',
  @Include_Accounting_Jobs BIT = 0
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Created: 01/19/11  JSEARLES
-- Purpose: Retrieves production & scrap information and calculates efficiency & utilization
-- Used in: VP Daily Shift Report, Common.dbo.Measurable_OEE

------------------------------------------------------------------------------------------ 
-- NOTE: Be sure to update Common.dbo.Measurable_OEE with any changes to the RESULT SET --
------------------------------------------------------------------------------------------

-- 02/08/11: JSEARLES Added Weighting_Factor to allow report to weight utilization/efficiency totals.
-- 02/09/11: JSEARLES Added parameters for Workcenter_Rate & Labor_Rate
-- 02/10/11: TSCH Log_Date for W/C Logs (compare User Support #268205 and KPIs Fill procedure [Warehouse].[dbo].[Department_KPI_Utilization_By_Part_Fill])
-- 02/15/11: JSEARLES Changed back to Report_Date for date selection per customer request. Customer knows this will not match KPI
--                Record_Date for Production records (compare KPIs Fill procedure [Warehouse].[dbo].[Department_KPIs_Production_Fill])
/*             This example has one with scrap only, one with production only, one with both - good example! Also, 3rd Shift seems to reveal date issues better!
              EXEC Warehouse.dbo.Department_KPIs_Utilization_And_Efficiency_Detail_Get @PCN=79870, 
              @Start='2/7/2011 12:00:00 AM', @End='2/7/2011 12:00:00 AM', 
              @Department_Code='CHR Cell - 1302', @Workcenter_Code='ROLL066', 
              @Shift_Group='3rd'

              EXEC Part.dbo.Daily_Shift_Report_Get @PCN=79870, @Start_Date='2/7/2011 12:00:00 AM', @End_Date='2/7/2011 12:00:00 AM', @Department_Nos='11689', @Workcenter_Keys='11877', @Shift_Group='3rd',
                @Workcenter_Rate =1 */
-- 02/21/11: JSEARLES Updated to divide labor actual hours among multiout parts by quantity produced.
-- 03/23/11: JSEARLES Added Earned_Machine_Hours & Actual_Machine_Hours
-- 03/28/11: JSEARLES Changed efficiency to be calculated as earned machine hours / actual machine hours
-- 05/16/11: JSEARLES Changed crew_size to be calculated by summing crew size for part operation for cell production records
-- 05/26/11: JSEARLES Joined prorate on parent part too, in case child part is a part of multi multiouts
-- 06/03/11: JSEARLES Added Workcenter to prorate partitioning to fix prorate amounts fluctatuating when parts are run through multiple workcenters
-- 06/06/11: JSEARLES Performance
-- 06/13/11: JSEARLES Fix for multiout parents in production record. Sometimes the child record is written to the workcenter log.
-- 07/08/11: JSEARLES Added additional filtering for Part, Job, Workcenter_Type, Operation, and Rework
-- 08/03/11: JSEARLES Added unassigned labor for department
-- 08/08/11: JSEARLES Removed part filtering from production & labor queries and moved it down to end results. We need to
--                    do this so we capture all the associated multi-out parts and labor is divided up appropriately.
-- 08/08/11: JSEARLES Exclude deleted clockin records
-- 08/16/11: JSEARLES Convert date_time to Plex time for clockin record lookup, limit clockin records to Work_Day = 1 for unassigned hours
-- 08/24/11: JSEARLES Added @Use_Current_Rates parameter to retrieve current workcenter rates as opposed to historical rates
--                    Added @Labor_Efficiency_Max & @Workcenter_Efficiency_Max to filter for lower efficiencies
-- 08/25/11: JSEARLES Added @Weight_Efficiency_By_Multiout_Count for efficiency weighting
-- 09/08/11: JSEARLES Performance - switched most CTEs to use temp tables
-- 09/14/11: JSEARLES Exclude scrap from Earned labor calculations per parameter @Include_Scrap_In_Earned_Labor
-- 09/29/11: JSEARLES Use actual shift times for checking clockin records.
-- 10/05/11: JSEARLES Changed labor select to use union for performance
-- 10/06/11: JSEARLES Fixed child count for multiouts
-- 10/10/11: CJERSEY Performance adjustments.  Added an overall daterange for the Shift times.  (Based on Max Duration of Clockin records and start/end time.)
--                   This date range seemed to help SQL Server narrow down the data it needed to bring back.
-- 10/17/11: JSEARLES Prorated Machine efficiency per child parts, just as Labor efficiency is prorated
-- 10/31/11: JSEARLES Fixed issue with unassigned labor query
-- 11/01/11: JSEARLES Changed machine calculations to prorate by child part count
-- 11/10/11: JSEARLES Remove report date adjustment from shift time
-- 11/18/11: BVEENSTRA Adding note to Measurable dependency
-- 11/23/11: JSEARLES Performance
-- 11/30/11: JSEARLES Performance
-- 01/23/12: JSEARLES Added Cell_Production records per parameter @Include_Cell_Production, and rewrote Production & Labor queries and added index hints
-- 02/06/12: JSEARLES Changed to use settings instead of hard-coded parameters for @Weight_Efficiency_By_Multiout_Count, @Include_Scrap_In_Earned_Labor, @Include_Cell_Production
-- 02/16/12: JSEARLES Issue with labor issues being picked up for European timezones. Redid shift times to be more accurate.
-- 02/24/12: JSEARLES Added Operators, Job Op Note, added support for "Manufactured Part Scrap Only" to allow scrap without Part_Source.
-- 03/22/12: JSEARLES Performance on Unassigned Labor query
-- 04/09/12: JSEARLES Use Department from Plexus_User record instead of Workcenter for unassigned labor.
-- 04/11/12: JSEARLES Increased MAXRECURSION on CTE populating shift days
-- 05/25/12: JSEARLES Added Workcenter_Group filter
-- 08/27/12: PHStockton Added setting to not use the clockin table for cost records
-- 11/12/12: GSINGH Performance changes
-- 11/01/13 phstockton: tweaked joins to improve performance and added an index hint
-- 12/20/13 phstockton: Copied from Daily_Shift_Report_Get and standards updates
-- 01/27/14: GTIL - use the report date only for scrap to match Daily_Shift_By_Job_Report_Get
-- 02/07/14 anhall: Add Accounting_Job_Nos and @Include_Accounting_Jobs
-- 06/18/14 phstockton: added labor status to unassigned labor 
-- 06/02/15 cjersey 989099: Added MAXDOP 4 to several statements. 
--                          Added Parallel_Execution_Plan_Encourage() to the insert into #Production_Records.
-- 03/16/16 cjersey 2012507: Removed routing.
--                           Specified NULL/NOT NULL on temp table columns.
--                           Added Recompile to several statements to get better optimizations for any parameter set.
--                           Applied additional filter values to the set of workcenter keys to allow better filtering on the Production and Workcenter log tables.
--                           Increased @Workcenter_Key parameter to 8000 characters in length.
-- 07/19/16 cjersey 2012507: Converted most of the @Include_Rework predicates into CHARINDEX filters.  This eliminated the need to join to Part_Op_Type.
--                           Converted the Cost_Sub_Type.Production_Cost = 1 predicates to CHARINDEX filters.
--                           Increased the MAXDOP for the insert into #Production to 8.
-- 08/09/16 GTIL 1029637: correct look-up of cell op crew size. <= was causing it to find the production operation again.
-- 01/25/18 mmei CR-5881: cell op crew size was not considering multiple Cell operations.  
--                        Later operations were summing crew size across ALL previous cell ops, rather than cell ops in support of just that operation.
-- 07/11/19 cjersey MP-99: Added FORCESEEK hint to Job_Op reference.
-- 07/17/19 cjersey MP-99: Added FORCESEEK hint to Clockin table for insert into #Labor_Records.
--                         Increased MAXDOP to 8 on statements using MAXDOP hint.
-- 7/22/20 spenyaz MO-1679: Fixed "Operator" empty field for scrap records
-- 10/21/21 sbokil MO-3923: Fixed Actual Hours When Shift_Key was 0. Considered including the Shift_Key along. Also a 'WHERE' condition didn't make sense (like C.Cost_Date < Begin_Date AND C.Cost_Date < End_Date) - so removed it. Also some standard fixes 

/* Example
compare against 
exec [Part].dbo.[Daily_Shift_Report_Get] @PCN=79870,@Start_Date='2011-02-07 00:00:00',@End_Date='2011-02-07 00:00:00',@Department_Nos='11755',@Workcenter_Keys='12488',@Shift_Group='2nd'
exec [Warehouse].dbo.[Department_KPIs_Utilization_And_Efficiency_Detail_Get] @PCN=79870,@Start='2011-02-07 00:00:00',@End='2011-02-07 00:00:00',@Department_Code='STP Cell - 1601',@Area='Stampings',@Workcenter_Code='PRESS185',@Shift_Group='2nd'
*/

/* Multiout Example
EXEC Part.dbo.Daily_Shift_Report_Get @PCN=79306, @Start_Date='5/27/2011 12:00:00 AM', @End_Date='5/27/2011 12:00:00 AM', @Department_Nos='21912', @Workcenter_Keys='34838'
*/

/* Cell production Example
EXEC Part.dbo.Daily_Shift_Report_Get @PCN = 95506, @Start_Date = '2016-2-11', @End_Date = ''
*/

/* Part that is child of multi multiouts
EXEC Part.dbo.Daily_Shift_Report_Get @PCN = 95506, @Start_Date = '2011-05-25', @End_Date = '2011-05-25', @Workcenter_Keys = '31533', @Workcenter_Rate = 0, @Labor_Rate = 0
*/

/* Including Unassigned Labor
EXEC Part.dbo.Daily_Shift_Report_Get @PCN=79870,@Start_Date='8/3/2011 12:00:00 AM',@End_Date='8/3/2011 12:00:00 AM',@Department_Nos='11690',@Include_Unassigned_Labor=1
*/

/* Include Operators
EXEC Part.dbo.Daily_Shift_Report_Get @PCN = 95506, @Start_Date = '2011-05-25', @End_Date = '2011-05-25', @Workcenter_Keys = '31533', @Workcenter_Rate = 0, @Labor_Rate = 0, @Include_Operators = 1
*/

CREATE TABLE dbo.#Unassigned_Labor
(
  PCN INT NOT NULL,
  Department_No INT NOT NULL,
  Unassigned_Hours DECIMAL(19,5) NULL
);

CREATE TABLE dbo.#Shift_Times
(
  PCN INT NOT NULL,
  Shift_Key INT NOT NULL,
  Begin_Date DATETIME NULL,
  End_Date DATETIME NULL
);

CREATE CLUSTERED INDEX IDX_Shift_Times 
ON dbo.#Shift_Times
(
  PCN,
  Shift_Key
);

CREATE TABLE dbo.#Workcenter_Log_Records
(
  PCN INT NOT NULL,
  Workcenter_Key INT NOT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Downtime_Hours DECIMAL(19,5) ,
  Log_Hours DECIMAL(19,5) NOT NULL,
  Is_MultiOut BIT NOT NULL,
  Parent_Part_Key INT NULL,
  Parent_Part_Operation_Key INT NULL,
  Note VARCHAR(200) NULL
);

CREATE TABLE dbo.#Production_Records
(
  PCN INT NOT NULL,
  Production_No INT NOT NULL,
  Workcenter_Key INT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Quantity_Produced DECIMAL(19,5) NOT NULL,
  Parent_Part_Key INT NULL,
  Parent_Part_Operation_Key INT NULL,
  Crew_Size DECIMAL(9,2) NULL,
  Labor_Rate DECIMAL(18,5) NULL,
  Workcenter_Rate DECIMAL(18,5) NULL,
  Accounting_Job_Key INT NULL
);
  
CREATE TABLE dbo.#Scrap_Records
(
  PCN INT NOT NULL,
  Production_No INT NULL,
  Workcenter_Key INT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Quantity_Scrapped DECIMAL(19,5) NOT NULL,
  Control_Panel_Scrap DECIMAL(19,5) NOT NULL
);

CREATE TABLE dbo.#Labor_Records
(
  PCN INT NOT NULL,
  Workcenter_Key INT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Actual_Hours DECIMAL(19,5) NOT NULL
);

CREATE TABLE dbo.#Prorate
(
  PCN INT NOT NULL,
  Workcenter_Key INT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Parent_Part_Key INT NULL,
  Parent_Part_Operation_Key INT NULL,
  Prorate_Rate DECIMAL(19,5) NOT NULL
);

CREATE TABLE dbo.#Operators
(
  PCN INT NOT NULL,
  Workcenter_Key INT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Operator_PUN INT NOT NULL
);

DECLARE 
  @Cell_Production_Depletion_Use BIT,
  @Workcenter_Type VARCHAR(50) = '',
  @Clockin_Begin_Date DATETIME,
  @Clockin_End_Date DATETIME,
  @Include_Cell_Production BIT,
  @Include_Scrap_In_Earned_Labor BIT,
  @Weight_Efficiency_By_Multiout_Count BIT,
  @Scrap_Manufactured_Part_Only BIT,
  @Days INT,
  @Clockin_Records_Use BIT,
  @Rework_Filtered_Part_Op_Type_Keys VARCHAR(8000),
  @Production_Cost_Sub_Type_Keys VARCHAR(8000);

EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Production Add', 'Cell Production Depletion Use', @Cell_Production_Depletion_Use OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Daily Shift Report', 'Cell Production Include', @Include_Cell_Production OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Daily Shift Report', 'Scrap In Earned Labor Include', @Include_Scrap_In_Earned_Labor OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Daily Shift Report', 'Weight Efficiency By Multiout Count', @Weight_Efficiency_By_Multiout_Count OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Daily Shift Report', 'Manufactured Part Scrap Only', @Scrap_Manufactured_Part_Only OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Daily Shift Report', 'Clockin Records Use', @Clockin_Records_Use OUTPUT;


-- normalize the parameters
SELECT
  @End_Date = DATEADD(DAY,1,ISNULL(@End_Date, @Start_Date)),
  @Workcenter_Keys = CASE WHEN NULLIF(@Workcenter_Keys, '') IS NULL THEN '' ELSE ',' + @Workcenter_Keys + ',' END,
  @Department_Nos = CASE WHEN NULLIF(@Department_Nos, '') IS NULL THEN '' ELSE ',' + @Department_Nos + ',' END,
  @Shift_Group = ISNULL(@Shift_Group, ''),
  @Manager_PUN = ISNULL(@Manager_PUN, 0),
  @Part_Key = ISNULL(@Part_Key, -1),
  @Job_Key = ISNULL(@Job_Key, -1),
  @Operation_Key = ISNULL(@Operation_Key, -1),
  @Include_Rework = ISNULL(@Include_Rework, -1),
  @Labor_Efficiency_Max = @Labor_Efficiency_Max / 100.0,
  @Workcenter_Efficiency_Max = @Workcenter_Efficiency_Max / 100.0,
  @Days = DATEDIFF(DAY, @Start_Date, @End_Date),
  @Workcenter_Group = ISNULL(@Workcenter_Group, '');

IF @Include_Rework != -1
BEGIN
  SELECT
    @Rework_Filtered_Part_Op_Type_Keys = 
    (
      SELECT
        ',' + CAST(POT.Part_Op_Type_Key AS VARCHAR(20))
      FROM dbo.Part_Op_Type AS POT
      WHERE POT.PCN = @PCN
        AND POT.Rework = @Include_Rework
      FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(8000)') + ',';
END;

SELECT
  @Production_Cost_Sub_Type_Keys =
  (
    SELECT
      ',' + CAST(C.Cost_Sub_Type_Key AS VARCHAR(20))
    FROM Common.dbo.Cost_Sub_Type AS C
    WHERE C.PCN = @PCN
      AND C.Production_Cost = 1
    FOR XML PATH(''), TYPE
  ).value('.', 'VARCHAR(8000)') + ',';

IF @Workcenter_Type_Key > 0
BEGIN
  -- retrieving this value will avoid a join
  -- since the FK on workcenter is not the PK
  SELECT
    @Workcenter_Type = WT.Workcenter_Type
  FROM dbo.Workcenter_Type AS WT
  WHERE WT.Plexus_Customer_No = @PCN
    AND WT.Workcenter_Type_Key = @Workcenter_Type_Key;
END;

-- *** Further filter Workcenter_Keys. ***
-- Since workcenter_Keys are one of the most useful ways to directly filter
-- Production and Workcenter_Log records, apply other filters (like department No)
-- to the list of workcetner keys.  This will help cut down on reads to the bigger tables.
IF @Workcenter_Keys = ''
BEGIN
  SELECT
    @Workcenter_Keys = 
    (
      SELECT
        ',' + CAST(W.Workcenter_Key AS VARCHAR(100))
      FROM dbo.Workcenter AS W
      WHERE W.Plexus_Customer_No = @PCN
        AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
        AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
        AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
      FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(8000)') + ',';

  -- No workcenter keys were passed in.  This means that we can't assume that all the desired keys will
  -- fit in the string variable.  If we hit the 8000 character limit, we have to skip this optimization.
  IF LEN(@Workcenter_Keys) = 8000
  BEGIN
    SET @Workcenter_Keys = '';
  END;
END
ELSE
BEGIN
  -- Since we started with workcenter keys that fit into the variable, we know that we will only end up with a sub set from that.
  -- We can safely keep what gets assigned here.
  SELECT
    @Workcenter_Keys = 
    (
      SELECT
        ',' + CAST(W.Workcenter_Key AS VARCHAR(100))
      FROM dbo.Workcenter AS W
      WHERE W.Plexus_Customer_No = @PCN
        AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(W.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
        AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
        AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
        AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
      FOR XML PATH(''), TYPE
    ).value('.', 'VARCHAR(8000)') + ',';
END;

-- labor records do not corrolate directly with the "report date" as used
-- elsewhere, so we need to get the corresponding shift date and use that
-- IMPORTANT: This block of code is identical to Daily_Shift_Report_Shift_Times_Populate
-- however had to be removed to support the OEE calculation in the metrics system.
-- This should be kept in sync with that sproc
WITH Shifts_CTE AS
(
  SELECT
    S.Plexus_Customer_No AS PCN,
    S.Shift_Key,
    -- converts shift times to equal start_date/end_date
    DATEADD(DAY, DATEDIFF(DAY, S.Start_Time, @Start_Date) - DO.Date_Offset, S.Start_Time) AS Begin_Date,
    DATEADD(DAY, DATEDIFF(DAY, S.Start_Time, @Start_Date) - DO.Date_Offset, S.Stop_Time) AS End_Date,
    1 AS [Day]
  FROM Common.dbo.[Shift] AS S
  CROSS APPLY
  (
    SELECT
      CASE S.Report_Date_Adjustment
        WHEN 1 THEN 1
        ELSE 0
      END AS Date_Offset
  ) AS DO
  WHERE S.Plexus_Customer_No = @PCN
    AND (@Shift_Group = '' OR S.Shift_Group = @Shift_Group)
    
  UNION ALL
  
  -- use a recursive CTE to advance subsequence date/times
  SELECT 
    SH.PCN,
    SH.Shift_Key,
    DATEADD(DAY, 1, SH.Begin_Date),
    DATEADD(DAY, 1, SH.End_Date),
    SH.[Day] + 1
  FROM Shifts_CTE AS SH
  WHERE SH.PCN = @PCN
    AND SH.[Day] < @Days
)
INSERT dbo.#Shift_Times
(
  PCN,
  Shift_Key,
  Begin_Date,
  End_Date
)
SELECT 
  SH.PCN,
  SH.Shift_Key,
  SH.Begin_Date,
  SH.End_Date
FROM Shifts_CTE AS SH
WHERE SH.PCN = @PCN
OPTION (MAXRECURSION 1000);

-- set a limit to cover clock ins that span over an entire shift
-- arbitrarily add +/- 4 hours to catch any stragglers
SELECT
  @Clockin_Begin_Date = DATEADD(HOUR, -4, MIN(ST.Begin_Date)),
  @Clockin_End_Date = DATEADD(HOUR, 4, MAX(ST.End_Date))
FROM dbo.#Shift_Times AS ST;
      
IF @Include_Unassigned_Labor = 1
BEGIN
  -- IMPORTANT: This block of code is identical to Daily_Shift_Report_Unassigned_Labor_Populate
  -- It was pulled out due to an issue with the OEE metric system and EXEC inserts
  -- but should be kept in sync 
  INSERT dbo.#Unassigned_Labor
  (
    PCN,
    Department_No,
    Unassigned_Hours
  )
  SELECT
    X.PCN,
    X.Department_No,
    SUM(X.Clockin_Hours - X.Assigned_Hours) AS Unassigned_Hours
  FROM
  (
    SELECT 
      CL.Plexus_Customer_No AS PCN,
      PU.Department_No,
      CL.Regular_Hours + CL.Overtime_Hours + CL.Doubletime_Hours AS Clockin_Hours,
      0 AS Assigned_Hours
    FROM Personnel.dbo.Clockin AS CL
    JOIN Personnel.dbo.Clockin_Type AS CT
      ON CT.Plexus_Customer_No = CL.Plexus_Customer_No
      AND CT.Clockin_Type_Key = CL.Clockin_Type_Key
    JOIN Plexus_Control.dbo.Plexus_User AS PU
      ON PU.Plexus_Customer_No = CL.Plexus_Customer_No
      AND PU.Plexus_User_No = CL.Plexus_User_No
    JOIN Common.dbo.Department AS D
      ON D.Plexus_Customer_No = PU.Plexus_Customer_No
      AND D.Department_No = PU.Department_No
    JOIN Common.dbo.Position AS P
      ON P.Plexus_Customer_No = PU.Plexus_Customer_No
      AND P.Position_Key = PU.Position_Key
    JOIN Common.dbo.Labor_Status AS LS
      ON LS.PCN = P.Plexus_Customer_No
      AND LS.Labor_Status_Key = P.Labor_Status_Key
    WHERE CL.Plexus_Customer_No = @PCN
      AND CL.Clockin_Time BETWEEN @Clockin_Begin_Date AND @Clockin_End_Date
      AND CT.Work_Day = 1
      AND LS.Direct = 1
      AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(PU.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
      AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
      AND EXISTS
      (
        -- we will not join on shift times - instead we will look for the existence
        -- this is to account for shift mismatches where an operator is assigned
        -- one shift but ends up working a different shift.
        -- if a Shift_Group is passed in, we need to limit to those times.
        SELECT * 
        FROM dbo.#Shift_Times AS ST
        WHERE ST.PCN = CL.Plexus_Customer_No
          AND ST.Shift_Key = CL.Shift_Key
          AND 
          (
            CL.Clockin_Time BETWEEN ST.Begin_Date AND ST.End_Date
            OR
            CL.Clockout_Time BETWEEN ST.Begin_Date AND ST.End_Date
            OR
            (CL.Clockin_Time < ST.Begin_Date AND CL.Clockout_Time > ST.End_Date)
          ) 
      )
      
    UNION ALL
    
    SELECT
      C.PCN,
      PU.Department_No,
      0 AS Clockin_Hours,
      C.Quantity AS Assigned_Hours
    FROM Personnel.dbo.Clockin AS CL
    JOIN Common.dbo.Cost AS C
      ON C.PCN = CL.Plexus_Customer_No
      AND C.Clockin_Key = CL.Clockin_Key
    JOIN Common.dbo.Cost_Sub_Type AS CST
      ON CST.PCN = C.PCN
      AND CST.Cost_Sub_Type_Key = C.Cost_Sub_Type_Key
    JOIN Plexus_Control.dbo.Plexus_User AS PU
      ON PU.Plexus_Customer_No = CL.Plexus_Customer_No
      AND PU.Plexus_User_No = CL.Plexus_User_No
    LEFT OUTER JOIN Common.dbo.Department AS D
      ON D.Plexus_Customer_No = PU.Plexus_Customer_No
      AND D.Department_No = PU.Department_No
    JOIN Common.dbo.Position AS P
      ON P.Plexus_Customer_No = PU.Plexus_Customer_No
      AND P.Position_Key = PU.Position_Key
    JOIN Common.dbo.Labor_Status AS LS
      ON LS.PCN = P.Plexus_Customer_No
      AND LS.Labor_Status_Key = P.Labor_Status_Key
    WHERE CL.Plexus_Customer_No = @PCN
      AND CST.Direct_Labor = 1
      AND CL.Clockin_Time >= @Clockin_Begin_Date
      AND CL.Clockout_Time <= @Clockin_End_Date
      AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
      AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(PU.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
      AND LS.Direct = 1
      AND EXISTS
      (
        -- we will not join on shift times - instead we will look for the existence
        -- this is to account for shift mismatches where an operator is assigned
        -- one shift but ends up working a different shift.
        -- if a Shift_Group is passed in, we need to limit to those times.
        SELECT * 
        FROM dbo.#Shift_Times AS ST
        WHERE ST.PCN = CL.Plexus_Customer_No
          AND ST.Shift_Key = CL.Shift_Key
          AND 
          (
            CL.Clockin_Time BETWEEN ST.Begin_Date AND ST.End_Date
            OR
            CL.Clockout_Time BETWEEN ST.Begin_Date AND ST.End_Date
            OR
            (CL.Clockin_Time < ST.Begin_Date AND CL.Clockout_Time > ST.End_Date)
          ) 
      )
  ) AS X
  GROUP BY
    X.PCN,
    X.Department_No
  OPTION 
  (
    FORCE ORDER,
    MAXDOP 8
  );
END;

INSERT dbo.#Workcenter_Log_Records
(
  PCN,
  Workcenter_Key,
  Part_Key,
  Part_Operation_Key,
  Downtime_Hours,
  Log_Hours,
  Is_MultiOut,
  Parent_Part_Key,
  Parent_Part_Operation_Key,
  Note
)
SELECT
  WLR.PCN,
  WLR.Workcenter_Key,
  ISNULL(MO.Out_Part_Key, WLR.Part_Key) AS Part_Key,
  ISNULL(MO.Out_Part_Operation_Key, WLR.Part_Operation_Key) AS Part_Operation_Key,
  WLR.Downtime_Hours,
  WLR.Log_Hours,
  CASE 
    WHEN MO.Out_Part_Key IS NOT NULL THEN CAST(1 AS BIT)
    ELSE CAST(0 AS BIT)
  END AS Is_MultiOut,
  WLR.Parent_Part_Key,
  WLR.Parent_Part_Operation_Key,
  WLR.Note
FROM
(
  SELECT
    WL.Plexus_Customer_No AS PCN,
    WL.Workcenter_Key,
    WL.Part_Key,
    WL.Part_Operation_Key,
    SUM
    (
      -- Replaced (WL.Log_Hours * WS.Downtime_Status) with a case statement
      -- to eliminate implicit type conversion and possible loss of precision.
      -- Also, Downtime_Status is a smallint which would lead to issues if a non 1 or 0
      -- value slipped into the table.
      CASE
        WHEN WS.Downtime_Status != 0 THEN WL.Log_Hours
        ELSE 0
      END
    ) AS Downtime_Hours,
    SUM(WL.Log_Hours) AS Log_Hours,
    WL.Part_Key AS Parent_Part_Key,
    WL.Part_Operation_Key AS Parent_Part_Operation_Key,
    MAX(JO.Note) AS Note
  FROM dbo.Workcenter_Log AS WL WITH (INDEX = IX_PCN_Report_Date)
  JOIN dbo.Workcenter_Status AS WS
    ON WS.Plexus_Customer_No = WL.Plexus_Customer_No
    AND WS.Workcenter_Status_Key = WL.Workcenter_Status_Key
  LEFT OUTER JOIN Common.dbo.[Shift] AS SH
    ON SH.Plexus_Customer_No = WL.Plexus_Customer_No
    AND SH.Shift_Key = WL.Shift_Key
  LEFT OUTER JOIN dbo.Job_Op AS JO WITH (FORCESEEK (PK_Job_Op (PCN, Job_Op_Key)))
    ON JO.PCN = WL.Plexus_Customer_No
    AND JO.Job_Op_Key = WL.Job_Op_Key
  WHERE WL.Plexus_Customer_No = @PCN
    AND WL.Log_Key = WL.Log_Key
    AND WL.Report_Date >= @Start_Date 
    AND WL.Report_Date < @End_Date
    AND WS.Planned_Production_Time = 1
    AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(WL.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
    AND (@Job_Key = -1 OR JO.Job_Key = @Job_Key)
    AND (@Shift_Group = '' OR SH.Shift_Group = @Shift_Group)
  GROUP BY 
    WL.Plexus_Customer_No,
    WL.Workcenter_Key, 
    WL.Part_Key,
    WL.Part_Operation_Key
) AS WLR
JOIN dbo.Workcenter AS W
  ON W.Plexus_Customer_No = WLR.PCN
  AND W.Workcenter_Key = WLR.Workcenter_Key
LEFT OUTER JOIN Common.dbo.Department AS D
  ON D.Plexus_Customer_No = W.Plexus_Customer_No
  AND D.Department_No = W.Department_No
LEFT OUTER JOIN dbo.Multi_Out AS MO
  ON MO.PCN = WLR.PCN
  AND MO.Part_Key = WLR.Part_Key
  AND MO.Part_Operation_Key = WLR.Part_Operation_Key
JOIN dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = WLR.PCN
  AND PO.Part_Operation_Key = ISNULL(MO.Out_Part_Operation_Key,WLR.Part_Operation_Key)
WHERE WLR.PCN = @PCN
  AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
  AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
  AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
  AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
  AND (@Part_Key = -1 OR ISNULL(MO.Out_Part_Key, WLR.Part_Key) = @Part_Key)
  AND (@Operation_Key = -1 OR PO.Operation_Key = @Operation_Key)
  AND (@Include_Rework = -1 OR CHARINDEX(',' + CAST(PO.Part_Op_Type_Key AS VARCHAR(20)) + ',', @Rework_Filtered_Part_Op_Type_Keys, 0) > 0)
OPTION 
(
  -- Since the only index on Workcenter_Log with Report_Date is indexed on PCN and Report_Date, 
  -- starting from that table is very helpful to prevent multiple inefficient passes against it.
  -- This is the number one bottle neck of the query.
  FORCE ORDER,

  RECOMPILE,
  MAXDOP 8
);


INSERT dbo.#Production_Records
(
  PCN,
  Production_No,
  Workcenter_Key,
  Part_Key,
  Part_Operation_Key,
  Quantity_Produced,
  Parent_Part_Key,
  Parent_Part_Operation_Key,
  Crew_Size,
  Labor_Rate,
  Workcenter_Rate,
  Accounting_Job_Key
)    
SELECT
  PR.Plexus_Customer_No,
  PR.Production_No,
  PR.Workcenter_Key,
  PR.Part_Key,
  PR.Part_Operation_Key,
  PR.Quantity AS Quantity_Produced,
  ISNULL(PP.Part_Key, WL.Part_Key) AS Parent_Part_Key,
  ISNULL(PP.Part_Operation_Key, WL.Part_Operation_Key) AS Parent_Part_Operation_Key,
  CASE
    WHEN @Cell_Production_Depletion_Use = 1 AND ISNULL(CP.Cell_Crew_Size, 0) != 0 THEN 
      CP.Cell_Crew_Size
    ELSE 
      AW.Crew_Size
  END AS Crew_Size,
  AW.Labor_Rate AS Labor_Rate,
  AW.Workcenter_Rate AS Workcenter_Rate,
  C.Accounting_Job_Key
  
-- This statement benifits from parallelism a lot but still compiles
-- as a single threaded plan for some parameter sets.  
-- For instance: exec [Part].dbo.[Daily_Shift_Report_Get] @PCN=170888,@Start_Date='2015-06-02 00:00:00',@End_Date='2015-06-02 00:00:00',@Workcenter_Keys='47932,47924'
-- Thus, this has been added to help ensure that parallel plans get created.
FROM Plexus_System.dbo.Parallel_Execution_Plan_Encourage() AS PEPE
CROSS JOIN dbo.Production AS PR WITH (INDEX = Report_Date)

JOIN dbo.Workcenter AS W
  ON W.Plexus_Customer_No = PR.Plexus_Customer_No
  AND W.Workcenter_Key = PR.Workcenter_Key
JOIN dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = PR.Plexus_Customer_No
  AND PO.Part_Key = PR.Part_Key
  AND PO.Part_Operation_Key = PR.Part_Operation_Key
JOIN dbo.Part_Op_Type AS POT
  ON POT.PCN = PO.Plexus_Customer_No
  AND POT.Part_Op_Type_Key = PO.Part_Op_Type_Key
LEFT OUTER JOIN Common.dbo.Department AS D
  ON D.Plexus_Customer_No = W.Plexus_Customer_No
  AND D.Department_No = W.Department_No
LEFT OUTER JOIN dbo.Workcenter_Log AS WL
  ON WL.Plexus_Customer_No = PR.Plexus_Customer_No
  AND WL.Log_Key = PR.Log_Key
LEFT OUTER JOIN Common.dbo.[Shift] AS SH
  ON SH.Plexus_Customer_No = PR.Plexus_Customer_No
  AND SH.Shift_Key = PR.Report_Shift
LEFT OUTER JOIN dbo.Job_Op AS JO
  ON JO.PCN = PR.Plexus_Customer_No
  AND JO.Job_Op_Key = PR.Job_Op_Key
LEFT OUTER JOIN dbo.Container AS C
  ON C.Plexus_Customer_No = PR.Plexus_Customer_No
  AND C.Serial_No = PR.Serial_No
  AND @Include_Accounting_Jobs = 1
OUTER APPLY
(
  -- historal workcenter rates
  SELECT
    H1.Crew_Size,
    ISNULL(CASE @Workcenter_Rate
      WHEN 1 THEN H1.Ideal_Rate
      WHEN 2 THEN H1.Target_Rate
      ELSE H1.Standard_Production_Rate
    END, 0) AS Workcenter_Rate,
    ISNULL(CASE @Labor_Rate
      WHEN 1 THEN H1.Ideal_Rate
      WHEN 2 THEN H1.Target_Rate
      ELSE H1.Standard_Production_Rate
    END, 0) AS Labor_Rate
  FROM 
  (
    SELECT TOP(1)
      H.PCN,
      H.Approved_Workcenter_History_Key
    FROM dbo.Approved_Workcenter_History AS H
    WHERE H.PCN = PR.Plexus_Customer_No
      AND H.Part_Key = PR.Part_Key
      AND H.Part_Operation_Key = PR.Part_Operation_Key
      AND H.Change_Date <= PR.Record_Date
      AND @Use_Current_Rates = 0
      AND 
      (
        H.Workcenter_Key = PR.Workcenter_Key 
        OR 
        (@Include_Cell_Production = 1 AND POT.Cell = 1)
      )
    ORDER BY 
      H.Change_Date DESC
  ) AS H
  JOIN dbo.Approved_Workcenter_History AS H1
    ON H1.PCN = H.PCN
    AND H1.Approved_Workcenter_History_Key = H.Approved_Workcenter_History_Key
  
  UNION ALL
  
  -- current workcenter rate
  SELECT TOP (1)
    C1.Crew_Size,
    ISNULL(CASE @Workcenter_Rate
      WHEN 1 THEN C1.Ideal_Rate
      WHEN 2 THEN C1.Target_Rate
      ELSE C1.Standard_Production_Rate
    END, 0) AS Workcenter_Rate,
    ISNULL(CASE @Labor_Rate
      WHEN 1 THEN C1.Ideal_Rate
      WHEN 2 THEN C1.Target_Rate
      ELSE C1.Standard_Production_Rate
    END, 0) AS Labor_Rate
  FROM dbo.Approved_Workcenter AS C1
  WHERE C1.Plexus_Customer_No = PR.Plexus_Customer_No
    AND C1.Part_Key = PR.Part_Key
    AND C1.Part_Operation_Key = PR.Part_Operation_Key
    AND 
    (
      C1.Workcenter_Key = PR.Workcenter_Key 
      OR 
      (@Include_Cell_Production = 1 AND POT.Cell = 1)
    )
    AND @Use_Current_Rates = 1
  ORDER BY
    C1.Sort_Order
) AS AW
OUTER APPLY
(
  -- for cell production, get crew size from entire
  -- part routing and add together
  SELECT
    SUM(ISNULL(AW1.Crew_Size, 0)) AS Cell_Crew_Size
  FROM dbo.Part_Operation AS PO1
  JOIN dbo.Part_Op_Type AS POT1
    ON POT1.PCN = PO1.Plexus_Customer_No
    AND POT1.Part_Op_Type_Key = PO1.Part_Op_Type_Key
  OUTER APPLY
  (
    SELECT TOP(1)
      PO2.Operation_No
    FROM dbo.Part_Operation AS PO2
    JOIN dbo.Part_Op_Type AS POT2
      ON POT2.PCN = PO2.Plexus_Customer_No
      AND POT2.Part_Op_Type_Key = PO2.Part_Op_Type_Key
    WHERE PO2.Plexus_Customer_No = PR.Plexus_Customer_No
      AND PO2.Part_Key = PR.Part_Key
      AND PO2.Operation_No < PO.Operation_No
      AND PO2.Active = 1
      AND POT2.Cell = 0
    ORDER BY
      PO2.Operation_No DESC
  ) AS DT_PriorProdOp(Operation_No)
  OUTER APPLY
  (
    -- history crew size
    SELECT TOP (1)
      H1.Crew_Size
    FROM dbo.Approved_Workcenter_History AS H1
    WHERE H1.PCN = PO1.Plexus_Customer_No 
      AND H1.Part_Key = PO1.Part_Key 
      AND H1.Part_Operation_Key = PO1.Part_Operation_Key
      AND H1.Workcenter_Key = PR.Workcenter_Key
      AND H1.Change_Date <= PR.Record_Date
      AND @Use_Current_Rates = 0
      AND EXISTS(SELECT * FROM dbo.Approved_Workcenter AS AA WHERE AA.Plexus_Customer_No = PO1.Plexus_Customer_No AND AA.Part_Key = PO1.Part_Key AND AA.Part_Operation_Key = PO1.Part_Operation_Key AND AA.Workcenter_Key = PR.Workcenter_Key) -- if there are no approved workcenters anymore, skip this history lookup
    ORDER BY H1.Change_Date DESC
    
    UNION ALL
    
    -- current crew size
    SELECT TOP (1)
      C1.Crew_Size
    FROM dbo.Approved_Workcenter AS C1
    WHERE C1.Plexus_Customer_No = PO1.Plexus_Customer_No
      AND C1.Part_Key = PO1.Part_Key
      AND C1.Part_Operation_Key = PO1.Part_Operation_Key
      AND C1.Workcenter_Key = PR.Workcenter_Key
      AND @Use_Current_Rates = 1
  ) AS AW1
  WHERE PO1.Plexus_Customer_No = PR.Plexus_Customer_No
    AND PO1.Part_Key = PR.Part_Key
    AND PO1.Operation_No <= PO.Operation_No
    AND (POT1.Cell = 1 OR PO1.Part_Operation_Key = PR.Part_Operation_Key) -- cell production or operation under which production was recorded
    AND (DT_PriorProdOp.Operation_No IS NULL OR PO1.Operation_No > DT_PriorProdOp.Operation_No)
    AND @Cell_Production_Depletion_Use = 1
    AND POT.Cell = 0
) AS CP
OUTER APPLY
(
  SELECT TOP (1)
    MO1.Part_Key,
    MO1.Part_Operation_Key
  FROM dbo.Multi_Out AS MO1
  WHERE MO1.PCN = PR.Plexus_Customer_No
    AND MO1.Out_Part_Key = PR.Part_Key
    AND MO1.Out_Part_Operation_Key = PR.Part_Operation_Key
    AND WL.Part_Key = PR.Part_Key -- only retrieve when the parent part is not contained within 
  ORDER BY 
    MO1.Sort_Order
) AS PP
WHERE PR.Plexus_Customer_No = @PCN
  AND PR.Report_Date >= @Start_Date
  AND PR.Report_Date < @End_Date
  AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(PR.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
  AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
  AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
  AND (@Job_Key = -1 OR JO.Job_Key = @Job_Key)
  AND (@Operation_Key = -1 OR PO.Operation_Key = @Operation_Key)
  AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
  AND (@Shift_Group = '' OR SH.Shift_Group = @Shift_Group)
  AND (@Include_Rework = -1 OR CHARINDEX(',' + CAST(PO.Part_Op_Type_Key AS VARCHAR(20)) + ',', @Rework_Filtered_Part_Op_Type_Keys, 0) > 0)
  AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
  AND NOT EXISTS
  (
    SELECT *
    FROM dbo.Multi_Out AS MO
    WHERE MO.PCN = PR.Plexus_Customer_No
      AND MO.Part_Key = PR.Part_Key
      AND MO.Part_Operation_Key = PR.Part_Operation_Key
  )
  AND NOT EXISTS
  (
    SELECT *
    FROM dbo.Scrap AS S0
    WHERE S0.Plexus_Customer_No = PR.Plexus_Customer_No
      AND S0.Production_No = PR.Production_No
  )
OPTION
( 
  FORCE ORDER,
  RECOMPILE,

  -- This report needs to be accessed using the data warehouse due to the amount of data.
  -- Until that is possible, increasing the MAXDOP will help distribute reads over additional 
  -- threads and improve duration some.
  MAXDOP 8
);

WITH Total_Production_CTE AS
(
  SELECT 
    PR.PCN,
    PR.Workcenter_Key,
    PR.Part_Key,
    PR.Part_Operation_Key,
    PR.Parent_Part_Key,
    PR.Parent_Part_Operation_Key,
    SUM(PR.Quantity_Produced) AS Quantity_Produced
  FROM dbo.#Production_Records AS PR
  WHERE PR.PCN = @PCN
    AND ISNULL(PR.Parent_Part_Key, PR.Part_Key) != PR.Part_Key
    AND ISNULL(PR.Parent_Part_Operation_Key, PR.Part_Operation_Key) != PR.Part_Operation_Key
  GROUP BY
    PR.PCN,
    PR.Workcenter_Key,
    PR.Part_Key,
    PR.Part_Operation_Key,
    PR.Parent_Part_Key,
    PR.Parent_Part_Operation_Key
)
INSERT dbo.#Prorate
(
  PCN,
  Workcenter_Key,
  Part_Key,
  Part_Operation_Key,
  Parent_Part_Key,
  Parent_Part_Operation_Key,
  Prorate_Rate
)
SELECT 
  PR.PCN,
  PR.Workcenter_Key,
  PR.Part_Key,
  PR.Part_Operation_Key,
  PR.Parent_Part_Key,
  PR.Parent_Part_Operation_Key,
  CASE
    WHEN SUM(PR.Quantity_Produced) OVER (PARTITION BY PR.Workcenter_Key, PR.Parent_Part_Key, PR.Parent_Part_Operation_Key) = 0 THEN 0
    ELSE PR.Quantity_Produced / (SUM(PR.Quantity_Produced) OVER (PARTITION BY PR.Workcenter_Key, PR.Parent_Part_Key, PR.Parent_Part_Operation_Key))
  END AS Prorate_Rate
FROM Total_Production_CTE AS PR
WHERE PR.PCN = @PCN
GROUP BY
  PR.PCN,
  PR.Workcenter_Key,
  PR.Part_Key,
  PR.Part_Operation_Key,
  PR.Parent_Part_Key,
  PR.Parent_Part_Operation_Key,
  PR.Quantity_Produced;

IF @Include_Operators = 1
BEGIN
  INSERT dbo.#Operators
  (
    PCN,
    Workcenter_Key,
    Part_Key,
    Part_Operation_Key,
    Operator_PUN
  )
  SELECT DISTINCT
    P.PCN,
    P.Workcenter_Key,
    P.Part_Key,
    P.Part_Operation_Key,
    O.Operator
  FROM dbo.#Production_Records AS P
  JOIN dbo.Operator AS O
    ON O.Plexus_Customer_No = P.PCN
    AND O.Production_No = P.Production_No
  WHERE P.PCN = @PCN;
END;
  
IF @Include_Cell_Production = 1
BEGIN
  WITH Production_CTE AS
  (
    SELECT
      PR.Plexus_Customer_No AS PCN,
      PR.Production_No,
      PR.Serial_No
    FROM dbo.Production AS PR WITH (INDEX = Report_Date)
    JOIN dbo.Workcenter AS W
      ON W.Plexus_Customer_No = PR.Plexus_Customer_No
      AND W.Workcenter_Key = PR.Workcenter_Key
    WHERE PR.Plexus_Customer_No = @PCN
      AND PR.Report_Date >= @Start_Date
      AND PR.Report_Date < @End_Date
  )
  INSERT dbo.#Production_Records
  (
    PCN,
    Production_No,
    Workcenter_Key,
    Part_Key,
    Part_Operation_Key,
    Quantity_Produced,
    Parent_Part_Key,
    Parent_Part_Operation_Key,
    Crew_Size,
    Labor_Rate,
    Workcenter_Rate,
    Accounting_Job_Key
  )
  SELECT
    PR.PCN,
    PR.Production_No,
    AW.Workcenter_Key,
    CP.Part_Key,
    CP.Part_Operation_Key,
    CP.Quantity,
    CP.Part_Key,
    CP.Part_Operation_Key,
    AW.Crew_Size,
    AW.Labor_Rate,
    AW.Workcenter_Rate,
    C.Accounting_Job_Key
  FROM Production_CTE AS PR
  JOIN dbo.Cell_Production AS CP
    ON CP.PCN = PR.PCN
    AND CP.Serial_No = PR.Serial_No
  JOIN dbo.Part_Operation AS PO                              
    ON PO.Plexus_Customer_No = CP.PCN
    AND PO.Part_Key = CP.Part_Key
    AND PO.Part_Operation_Key = CP.Part_Operation_Key
  LEFT OUTER JOIN dbo.Container AS C
    ON C.Plexus_Customer_No = PR.PCN
    AND C.Serial_No = PR.Serial_No
    AND @Include_Accounting_Jobs = 1
  OUTER APPLY
  (
    -- historal workcenter rates
    -- TODO: this may need to be tweaked to make sure to pull the first workcenter
    -- from the routing at the TIME of the production
    SELECT TOP (1)
      H1.PCN,
      H1.Workcenter_Key,
      H1.Crew_Size,
      ISNULL(CASE @Workcenter_Rate
        WHEN 1 THEN H1.Ideal_Rate
        WHEN 2 THEN H1.Target_Rate
        ELSE H1.Standard_Production_Rate
      END, 0) AS Workcenter_Rate,
      ISNULL(CASE @Labor_Rate
        WHEN 1 THEN H1.Ideal_Rate
        WHEN 2 THEN H1.Target_Rate
        ELSE H1.Standard_Production_Rate
      END, 0) AS Labor_Rate
    FROM dbo.Approved_Workcenter_History AS H1
    WHERE H1.PCN = CP.PCN
      AND H1.Part_Key = CP.Part_Key
      AND H1.Part_Operation_Key = CP.Part_Operation_Key
      AND H1.Change_Date <= CP.Production_Date
      AND @Use_Current_Rates = 0
    ORDER BY 
      H1.Change_Date DESC
    
    UNION ALL
    
    -- current workcenter rate
    SELECT TOP (1)
      C1.Plexus_Customer_No,
      C1.Workcenter_Key,
      C1.Crew_Size,
      ISNULL(CASE @Workcenter_Rate
        WHEN 1 THEN C1.Ideal_Rate
        WHEN 2 THEN C1.Target_Rate
        ELSE C1.Standard_Production_Rate
      END, 0) AS Workcenter_Rate,
      ISNULL(CASE @Labor_Rate
        WHEN 1 THEN C1.Ideal_Rate
        WHEN 2 THEN C1.Target_Rate
        ELSE C1.Standard_Production_Rate
      END, 0) AS Labor_Rate
    FROM dbo.Approved_Workcenter AS C1
    WHERE C1.Plexus_Customer_No = CP.PCN
      AND C1.Part_Key = CP.Part_Key
      AND C1.Part_Operation_Key = CP.Part_Operation_Key
      AND @Use_Current_Rates = 1
    ORDER BY
      C1.Sort_Order
  ) AS AW
  JOIN dbo.Workcenter AS W
    ON W.Plexus_Customer_No = AW.PCN
    AND W.Workcenter_Key = AW.Workcenter_Key
  LEFT OUTER JOIN Common.dbo.Department AS D
    ON D.Plexus_Customer_No = W.Plexus_Customer_No
    AND D.Department_No = W.Department_No
  WHERE PR.PCN = @PCN
    AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(AW.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
    AND (@Department_Nos = '' OR  CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
    AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
    AND (@Operation_Key = -1 OR PO.Operation_Key = @Operation_Key)
    AND (@Include_Rework = -1 OR CHARINDEX(',' + CAST(PO.Part_Op_Type_Key AS VARCHAR(20)) + ',', @Rework_Filtered_Part_Op_Type_Keys, 0) > 0)
    AND (@Part_Key = -1 OR CP.Part_Key = @Part_Key)
    AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
    AND NOT EXISTS
    (
      SELECT *
      FROM dbo.Multi_Out AS MO
      WHERE MO.PCN = CP.PCN
        AND MO.Part_Key = CP.Part_Key
        AND MO.Part_Operation_Key = CP.Part_Operation_Key
    )
  OPTION
  ( 
    FORCE ORDER,
    OPTIMIZE FOR (@Include_Accounting_Jobs = 1),
    MAXDOP 8
  );
END;

INSERT dbo.#Scrap_Records
(
  PCN,
  Production_No,
  Workcenter_Key,
  Part_Key,
  Part_Operation_Key,
  Quantity_Scrapped,
  Control_Panel_Scrap
)
SELECT
  S.Plexus_Customer_No AS PCN,
  S.Production_No,
  S.Workcenter_Key,
  S.Part_Key,
  S.Part_Operation_Key,
  SUM(S.Quantity) AS Quantity_Scrapped,
  SUM
  (
    -- Replaced (S.Quantity * S.Control_Panel_Scrap) with case statement to avoid implicit conversion and 
    -- possible precision loss.
    CASE 
      WHEN S.Control_Panel_Scrap != 0 THEN S.Quantity
      ELSE 0
    END
  ) AS Control_Panel_Scrap

-- cjersey - Removing index hint.  With the recompile option specified, we want
-- to give it the ability to optimize for cases where just the dates are present as
-- well as when part or Job filters are present.
FROM dbo.Scrap AS S
JOIN dbo.Scrap_Reason AS SR
  ON SR.Plexus_Customer_No = S.Plexus_Customer_No
  AND SR.Scrap_Reason = S.Scrap_Reason
JOIN dbo.Part AS P
  ON P.Plexus_Customer_No = S.Plexus_Customer_No
  AND P.Part_Key = S.Part_Key
LEFT OUTER JOIN dbo.Workcenter AS W WITH(INDEX(PK_Workcenter))
  ON W.Plexus_Customer_No = S.Plexus_Customer_No
  AND W.Workcenter_Key = S.Workcenter_Key
LEFT OUTER JOIN dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = S.Plexus_Customer_No
  AND PO.Part_Operation_Key = S.Part_Operation_Key
  AND PO.Part_Key = S.Part_Key
LEFT OUTER JOIN Common.dbo.Department AS D
  ON D.Plexus_Customer_No = W.Plexus_Customer_No
  AND D.Department_No = W.Department_No
LEFT OUTER JOIN dbo.Part_Source AS PS
  ON PS.PCN = P.Plexus_Customer_No
  AND PS.Part_Source_Key = P.Part_Source_Key
LEFT OUTER JOIN Common.dbo.[Shift] AS SH
  ON SH.Plexus_Customer_No = S.Plexus_Customer_No
  AND SH.Shift_Key = S.[Shift]
WHERE S.Plexus_Customer_No = @PCN
  AND S.Report_Date >= @Start_Date
  AND S.Report_Date < @End_Date
  AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(S.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
  AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
  AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
  AND (@Part_Key = -1 OR S.Part_Key = @Part_Key)
  AND (@Operation_Key = -1 OR PO.Operation_Key = @Operation_Key)
  AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
  AND (@Include_Rework = -1 OR CHARINDEX(',' + CAST(PO.Part_Op_Type_Key AS VARCHAR(20)) + ',', @Rework_Filtered_Part_Op_Type_Keys, 0) > 0)
  AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
  AND SR.Include_In_PPM = 1
  AND (@Scrap_Manufactured_Part_Only = 0 OR PS.Manufactured_Part = 1)
  AND (@Job_Key = -1 OR S.Job_Key = @Job_Key)
  AND (@Shift_Group = '' OR SH.Shift_Group = @Shift_Group)
GROUP BY
  S.Plexus_Customer_No,
  S.Production_No,
  S.Workcenter_Key,
  S.Part_Key,
  S.Part_Operation_Key
OPTION
( 
  FORCE ORDER,
  RECOMPILE,
  MAXDOP 8
);

IF @Include_Operators = 1
BEGIN
  INSERT dbo.#Operators
  (
    PCN,
    Workcenter_Key,
    Part_Key,
    Part_Operation_Key,
    Operator_PUN
  )
  SELECT DISTINCT
    SR.PCN,
    SR.Workcenter_Key,
    SR.Part_Key,
    SR.Part_Operation_Key,
    O.Operator
  FROM dbo.#Scrap_Records AS SR
  JOIN dbo.Operator AS O
    ON O.Plexus_Customer_No = SR.PCN
    AND O.Production_No = SR.Production_No
  WHERE SR.PCN = @PCN
END;

IF @Clockin_Records_Use = 1 -- Use the clockin table to filter cost records
BEGIN
  INSERT dbo.#Labor_Records -- w/ Clockin table.
  (
    PCN,
    Workcenter_Key,
    Part_Key,
    Part_Operation_Key,
    Actual_Hours
  )
  SELECT
    C.PCN,
    C.Workcenter_Key,
    C.Part_Key,
    C.Orig_Part_Op_Key,
    SUM(C.Quantity) AS Actual_Hours
  FROM Personnel.dbo.Clockin AS CL
  JOIN Common.dbo.Cost AS C WITH (FORCESEEK (IX_PCN_Clockin (PCN, Clockin_Key)))
    ON C.PCN = CL.Plexus_Customer_No
    AND C.Clockin_Key = CL.Clockin_Key
  JOIN dbo.Workcenter AS W
    ON W.Plexus_Customer_No = C.PCN
    AND W.Workcenter_Key = C.Workcenter_Key
  LEFT OUTER JOIN Common.dbo.Department AS D
    ON D.Plexus_Customer_No = W.Plexus_Customer_No
    AND D.Department_No = W.Department_No
  JOIN dbo.Part_Operation AS PO
    ON PO.Plexus_Customer_No = C.PCN
    AND PO.Part_Operation_Key = C.Orig_Part_Op_Key
  WHERE CL.Plexus_Customer_No = @PCN
    AND CHARINDEX(',' + CAST(C.Cost_Sub_Type_Key AS VARCHAR(20)) + ',', @Production_Cost_Sub_Type_Keys, 0) > 0
    AND CL.Clockin_Time >= @Clockin_Begin_Date
    AND CL.Clockout_Time <= @Clockin_End_Date
    AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(C.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
    AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
    AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
    AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
    AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
    AND EXISTS
    (
      -- we will not join on shift times - instead we will look for the existence
      -- this is to account for shift mismatches where an operator is assigned
      -- one shift but ends up working a different shift.
      -- if a Shift_Group is passed in, we need to limit to those times.
      SELECT * 
      FROM dbo.#Shift_Times AS ST
      WHERE ST.PCN = CL.Plexus_Customer_No
        AND ST.Shift_Key = CL.Shift_Key
        AND 
        (
          CL.Clockin_Time BETWEEN ST.Begin_Date AND ST.End_Date
          OR
          CL.Clockout_Time BETWEEN ST.Begin_Date AND ST.End_Date
          OR
          (CL.Clockin_Time < ST.Begin_Date AND CL.Clockout_Time > ST.End_Date)
        ) 
    )
    AND (@Operation_Key = -1 OR PO.Operation_Key = @Operation_Key)
    AND (@Include_Rework = -1 OR CHARINDEX(',' + CAST(PO.Part_Op_Type_Key AS VARCHAR(20)) + ',', @Rework_Filtered_Part_Op_Type_Keys, 0) > 0)
    AND (@Job_Key = -1 OR C.Job_Key = @Job_Key)
  GROUP BY
    C.PCN,
    C.Workcenter_Key,
    C.Part_Key,
    C.Orig_Part_Op_Key
  OPTION 
  (
    FORCE ORDER,
    RECOMPILE,
    MAXDOP 8
  );
END;
ELSE
BEGIN -- Get labor directly from the cost table
  WITH Labor_CTE AS
  (
    SELECT
      C.PCN,
      C.Cost_Key
    FROM Common.dbo.Cost AS C WITH (INDEX = IX_Cost_Date)
    JOIN dbo.Workcenter AS W
      ON W.Plexus_Customer_No = C.PCN
      AND W.Workcenter_Key = C.Workcenter_Key
    LEFT OUTER JOIN Common.dbo.Department AS D
      ON D.Plexus_Customer_No = W.Plexus_Customer_No
      AND D.Department_No = W.Department_No
    WHERE C.PCN = @PCN
      AND CHARINDEX(',' + CAST(C.Cost_Sub_Type_Key AS VARCHAR(20)) + ',', @Production_Cost_Sub_Type_Keys, 0) > 0
      AND C.Cost_Date >= @Clockin_Begin_Date
      AND C.Cost_Date <= @Clockin_End_Date
      AND C.Cost_Point_Key = 48
      AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(C.Workcenter_Key AS VARCHAR(20)) + ',', ',' + @Workcenter_Keys + ',', 0) > 0)
      AND (@Workcenter_Type = '' OR W.Workcenter_Type = @Workcenter_Type)
      AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
      AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
      AND (@Workcenter_Group = '' OR W.Workcenter_Group = @Workcenter_Group)
      AND (C.Part_Key = @Part_Key OR @Part_Key = -1)
  )
  INSERT dbo.#Labor_Records -- w/o Clockin table.
  (
    PCN,
    Workcenter_Key,
    Part_Key,
    Part_Operation_Key,
    Actual_Hours
  )
  SELECT
    L.PCN,
    C.Workcenter_Key,
    C.Part_Key,
    C.Orig_Part_Op_Key,
    SUM(C.Quantity) AS Actual_Hours
  FROM Labor_CTE AS L
  JOIN Common.dbo.Cost AS C
    ON C.PCN = L.PCN
    AND C.Cost_Key = L.Cost_Key
  JOIN dbo.Part_Operation AS PO
    ON PO.Plexus_Customer_No = C.PCN
    AND PO.Part_Operation_Key = C.Orig_Part_Op_Key
  WHERE C.PCN = @PCN
    AND (ISNULL(C.Shift_Key, 0) = 0 
      OR EXISTS
      (
        -- we will not join on shift times - instead we will look for the existence
        -- this is to account for shift mismatches where an operator is assigned
        -- one shift but ends up working a different shift.
        -- if a Shift_Group is passed in, we need to limit to those times.
        SELECT * 
        FROM dbo.#Shift_Times AS ST
        WHERE ST.PCN = C.PCN
          AND ST.Shift_Key = C.Shift_Key
          AND (C.Cost_Date BETWEEN ST.Begin_Date AND ST.End_Date)
      )
    )
    AND (@Operation_Key = -1 OR PO.Operation_Key = @Operation_Key)
    AND (@Include_Rework = -1 OR CHARINDEX(',' + CAST(PO.Part_Op_Type_Key AS VARCHAR(20)) + ',', @Rework_Filtered_Part_Op_Type_Keys, 0) > 0)
    AND (@Job_Key = -1 OR C.Job_Key = @Job_Key)
  GROUP BY
    L.PCN,
    C.Workcenter_Key,
    C.Part_Key,
    C.Orig_Part_Op_Key
  OPTION 
  (
    FORCE ORDER,
    MAXDOP 8
  );
END;

WITH Combined_CTE AS
(
  SELECT
    X.PCN,
    X.Workcenter_Key,
    X.Part_Key,
    X.Part_Operation_Key,
    SUM(X.Actual_Hours) AS Actual_Hours,
    SUM(X.Quantity_Produced) AS Quantity_Produced,
    SUM(X.Quantity_Scrapped) AS Quantity_Scrapped,
    SUM(X.Control_Panel_Scrap) AS Control_Panel_Scrap,
    SUM(X.Log_Hours) AS Log_Hours,
    SUM(X.Downtime_Hours) AS Downtime_Hours,
    MAX(X.Workcenter_Rate) AS Workcenter_Rate,
    MAX(X.Labor_Rate) AS Labor_Rate,
    MAX(ISNULL(X.Crew_Size, 1)) AS Crew_Size, -- crew size should never be 0.
    MAX(ISNULL(NULLIF(X.Child_Part_Count, 0), 1)) AS Child_Part_Count,
    MAX(X.Note) AS Note,
    RIGHT(CA.Accounting_Job_Nos, LEN(CA.Accounting_Job_Nos) - 2) AS Accounting_Job_Nos
  FROM
  (
    SELECT 
      WL.PCN,
      WL.Workcenter_Key,
      WL.Part_Key,
      WL.Part_Operation_Key,
      CASE 
        WHEN WL.Is_MultiOut = 1 THEN WL.Log_Hours * ISNULL(RT.Prorate_Rate, 0) 
        ELSE WL.Log_Hours
      END AS Log_Hours,
      CASE
        WHEN WL.Is_MultiOut = 1 THEN WL.Downtime_Hours * ISNULL(RT.Prorate_Rate, 0)
        ELSE WL.Downtime_Hours
      END AS Downtime_Hours,
      0 AS Quantity_Scrapped,
      0 AS Control_Panel_Scrap,
      0 AS Quantity_Produced,
      0 AS Actual_Hours,
      0 AS Workcenter_Rate,
      0 AS Labor_Rate,
      0 AS Crew_Size,
      0 AS Child_Part_Count,
      WL.Note,
      -1 AS Accounting_Job_Key
    FROM dbo.#Workcenter_Log_Records AS WL
    LEFT OUTER JOIN dbo.#Prorate AS RT
      ON WL.PCN = RT.PCN
      AND WL.Workcenter_Key = RT.Workcenter_Key
      AND WL.Part_Key = RT.Part_Key
      AND WL.Part_Operation_Key = RT.Part_Operation_Key
      AND WL.Parent_Part_Key = RT.Parent_Part_Key
      AND WL.Parent_Part_Operation_Key = RT.Parent_Part_Operation_Key
      
    UNION ALL
    
    SELECT
      S.PCN,
      S.Workcenter_Key,
      S.Part_Key,
      S.Part_Operation_Key,
      0 AS Log_Hours,
      0 AS Downtime_Hours,
      S.Quantity_Scrapped,
      S.Control_Panel_Scrap,
      0 AS Quantity_Produced,
      0 AS Actual_Hours,
      0 AS Workcenter_Rate,
      0 AS Labor_Rate,
      0 AS Crew_Size,
      0 AS Child_Part_Count,
      '' AS Note,
      -1 AS Accounting_Job_Key
    FROM dbo.#Scrap_Records AS S
    
    UNION ALL
    
    SELECT
      P.PCN,
      P.Workcenter_Key,
      P.Part_Key,
      P.Part_Operation_Key,
      0 AS Log_Hours,
      0 AS Downtime_Hours,
      0 AS Quantity_Scrapped,
      0 AS Control_Panel_Scrap,
      SUM(P.Quantity_Produced) AS Quantity_Produced,
      0 AS Actual_Hours,
      MAX(P.Workcenter_Rate) AS Workcenter_Rate,
      MAX(P.Labor_Rate) AS Labor_Rate,
      MAX(P.Crew_Size) AS Crew_Size,
      ISNULL(CC.Child_Part_Count, 0) AS Child_Part_Count,
      '' AS Note,
      P.Accounting_Job_Key
    FROM #Production_Records AS P
    OUTER APPLY
    (
      -- the part count is used for weighting efficiency
      -- if @Weight_Efficiency_By_Multiout_Count is not enabled
      -- then we do not need to know the count
      SELECT 
        COUNT(*) AS Child_Part_Count
      FROM dbo.Multi_Out AS MO
      JOIN dbo.Part AS CP
        ON CP.Plexus_Customer_No = MO.PCN
        AND CP.Part_Key = MO.Out_Part_Key
      JOIN dbo.Part_Status AS PS
        ON PS.Plexus_Customer_No = CP.Plexus_Customer_No
        AND PS.Part_Status = CP.Part_Status
      WHERE MO.PCN = P.PCN
        AND MO.Part_Key = P.Parent_Part_Key
        AND PS.Active = 1
        AND @Weight_Efficiency_By_Multiout_Count = 1
    ) AS CC
    GROUP BY
      P.PCN,
      P.Workcenter_Key,
      P.Part_Key,
      P.Part_Operation_Key,
      ISNULL(CC.Child_Part_Count, 0),
      P.Accounting_Job_Key
      
    UNION ALL
    
    SELECT
      L.PCN,
      L.Workcenter_Key,
      ISNULL(RT.Part_Key, L.Part_Key) AS Part_Key,
      ISNULL(RT.Part_Operation_Key, L.Part_Operation_Key) AS Part_Operation_Key,
      0 AS Log_Hours,
      0 AS Downtime_Hours,
      0 AS Quantity_Scrapped,
      0 AS Control_Panel_Scrap,
      0 AS Quantity_Produced,
      L.Actual_Hours * ISNULL(RT.Prorate_Rate, 1) AS Actual_Hours,  -- Prorate labor by quantity produced of multiout
      0 AS Workcenter_Rate,
      0 AS Labor_Rate,
      0 AS Crew_Size,
      0 AS Child_Part_Count,
      '' AS Note,
      -1 AS Accounting_Job_Key
    FROM dbo.#Labor_Records AS L
    LEFT OUTER JOIN dbo.#Prorate AS RT
      ON RT.PCN = L.PCN
      AND RT.Workcenter_Key = L.Workcenter_Key
      AND RT.Parent_Part_Key = L.Part_Key
      AND RT.Parent_Part_Operation_Key = L.Part_Operation_Key
  ) AS X
  OUTER APPLY
  (
    SELECT
      ', ' + AJ.Accounting_Job_No
    FROM Accounting.dbo.Accounting_Job AS AJ
    WHERE AJ.PCN = X.PCN
      AND AJ.Accounting_Job_Key IN
      (
        SELECT
          PR.Accounting_Job_Key
        FROM dbo.#Production_Records AS PR
        WHERE PR.PCN = X.PCN
          AND PR.Workcenter_Key = X.Workcenter_Key
          AND PR.Part_Key = X.Part_Key
          AND PR.Part_Operation_Key = X.Part_Operation_Key
      )
    FOR XML PATH('')
  ) AS CA(Accounting_Job_Nos)
  GROUP BY
    X.PCN,
    X.Workcenter_Key,
    X.Part_Key,
    X.Part_Operation_Key,
    CA.Accounting_Job_Nos
)
SELECT 
  D.Department_No, 
  D.Department_Code, 
  M.First_Name AS Manager_First_Name,
  M.Middle_Name AS Manager_Middle_Name,
  M.Last_Name AS Manager_Last_Name,
  W.Workcenter_Key, 
  W.Workcenter_Code,
  P.Part_Key,
  CMB.Part_Operation_Key,
  P.Part_No,
  P.Revision AS Part_Revision,
  P.[Name] AS Part_Name,
  PO.Operation_No,
  O.Operation_Code,
  CMB.Downtime_Hours,
  CMB.Log_Hours AS Planned_Production_Hours,
  CMB.Quantity_Produced + CMB.Control_Panel_Scrap AS Parts_Produced,
  CMB.Quantity_Scrapped AS Parts_Scrapped,
  CASE 
    WHEN CMB.Quantity_Produced + CMB.Control_Panel_Scrap = 0 THEN 0
    ELSE CMB.Quantity_Scrapped / (CMB.Quantity_Produced + CMB.Control_Panel_Scrap)
  END AS Scrap_Rate,  -- parts scrapped / parts produced
  CASE 
    WHEN CMB.Log_Hours = 0 THEN 0
    ELSE (CMB.Log_Hours - CMB.Downtime_Hours) / CMB.Log_Hours
  END AS Utilization, 
  CASE
    WHEN CMB.Workcenter_Rate = 0 OR CMB.Log_Hours - CMB.Downtime_Hours = 0 THEN 0
    ELSE ((CMB.Quantity_Produced + CMB.Control_Panel_Scrap) / CMB.Workcenter_Rate) / (CMB.Log_Hours - CMB.Downtime_Hours) / CMB.Child_Part_Count
  END AS Efficiency,
  CASE
    WHEN CMB.Log_Hours = 0 OR CMB.Log_Hours - CMB.Downtime_Hours = 0 OR CMB.Workcenter_Rate = 0 THEN 0
    ELSE 
      ((CMB.Quantity_Produced + CMB.Control_Panel_Scrap) / CMB.Workcenter_Rate) / (CMB.Log_Hours - CMB.Downtime_Hours) / CMB.Child_Part_Count *
      ((CMB.Log_Hours - CMB.Downtime_Hours) / CMB.Log_Hours) *
      CASE 
        WHEN CMB.Quantity_Produced + CMB.Control_Panel_Scrap = 0 THEN 1
        ELSE (1 - (CMB.Quantity_Scrapped / (CMB.Quantity_Produced + CMB.Control_Panel_Scrap)))
      END
  END AS OEE, -- (1 - Scrap Rate) * Efficiency * Utilization
  CASE
    WHEN CMB.Labor_Rate = 0 THEN 0
    -- only include scrap in calculation if @Exclude_Scrap_From_Earned_Labor = 0
    ELSE (CMB.Quantity_Produced + (CMB.Control_Panel_Scrap * @Include_Scrap_In_Earned_Labor)) * (CMB.Crew_Size / CMB.Labor_Rate)
  END AS Earned_Hours,
  CASE
    WHEN CMB.Workcenter_Rate = 0 THEN 0
    ELSE (CMB.Quantity_Produced + CMB.Control_Panel_Scrap) / CMB.Workcenter_Rate / CMB.Child_Part_Count
  END AS Earned_Machine_Hours,
  CMB.Log_Hours - CMB.Downtime_Hours AS Actual_Machine_Hours,
  CMB.Actual_Hours AS Actual_Hours,
  CASE
    WHEN CMB.Actual_Hours = 0 OR CMB.Labor_Rate = 0 THEN 0
    ELSE ((CMB.Quantity_Produced + (CMB.Control_Panel_Scrap * @Include_Scrap_In_Earned_Labor)) * (CMB.Crew_Size / CMB.Labor_Rate) / CMB.Actual_Hours)
  END AS Labor_Efficiency, -- Earned Hours / Actual Hours
  CMB.Quantity_Produced,
  CMB.Workcenter_Rate,
  CMB.Labor_Rate,
  CMB.Crew_Size,
  UL.Unassigned_Hours AS Department_Unassigned_Hours,
  ISNULL(NULLIF(CMB.Child_Part_Count,0),1) AS Child_Part_Count,
  (
    SELECT
      PU0.First_Name,
      PU0.Last_Name
    FROM dbo.#Operators AS O0
    JOIN Plexus_Control.dbo.Plexus_User AS PU0
      ON PU0.Plexus_User_No = O0.Operator_PUN 
    WHERE O0.PCN = CMB.PCN
      AND O0.Workcenter_Key = CMB.Workcenter_Key
      AND O0.Part_Key = CMB.Part_Key
      AND O0.Part_Operation_Key = CMB.Part_Operation_Key
      AND @Include_Operators = 1
    FOR XML PATH
  ) AS Operators,
  CMB.Note,
  CMB.Accounting_Job_Nos
FROM dbo.Workcenter AS W
JOIN Combined_CTE AS CMB
  ON CMB.PCN = W.Plexus_Customer_No
  AND CMB.Workcenter_Key = W.Workcenter_Key
JOIN dbo.Part AS P
  ON P.Plexus_Customer_No = CMB.PCN
  AND P.Part_Key = CMB.Part_Key
JOIN dbo.Part_Operation AS PO
  ON PO.Plexus_Customer_No = CMB.PCN
  AND PO.Part_Operation_Key = CMB.Part_Operation_Key
JOIN dbo.Operation AS O
  ON O.Plexus_Customer_No = PO.Plexus_Customer_No
  AND O.Operation_Key = PO.Operation_Key
LEFT OUTER JOIN Common.dbo.Department AS D
  ON D.Plexus_Customer_No = W.Plexus_Customer_No
  AND D.Department_No = W.Department_No
LEFT OUTER JOIN Plexus_Control.dbo.Plexus_User AS M
  ON M.Plexus_Customer_No = D.Plexus_Customer_No
  AND M.Plexus_User_No = D.Manager
LEFT OUTER JOIN dbo.#Unassigned_Labor AS UL
  ON UL.PCN = D.Plexus_Customer_No
  AND UL.Department_No = D.Department_No
WHERE W.Plexus_Customer_No = @PCN
  AND W.Active = 1
  AND (@Workcenter_Keys = '' OR CHARINDEX(',' + CAST(W.Workcenter_Key AS VARCHAR(20)) + ',', @Workcenter_Keys,0) > 0)
  AND (@Department_Nos = '' OR CHARINDEX(',' + CAST(W.Department_No AS VARCHAR(20)) + ',', @Department_Nos,0) > 0)
  AND (@Manager_PUN = 0 OR D.Manager = @Manager_PUN)
  AND (@Part_Key = -1 OR CMB.Part_Key = @Part_Key)
  AND 
  (
    (@Labor_Efficiency_Max IS NULL) 
    OR   
    (
      -- labor efficiency calc
      CASE
        WHEN CMB.Actual_Hours = 0 OR CMB.Labor_Rate = 0 THEN 0
        ELSE (CMB.Quantity_Produced + CMB.Control_Panel_Scrap) * (CMB.Crew_Size / CMB.Labor_Rate) / CMB.Actual_Hours
      END <= @Labor_Efficiency_Max
    )
  )
  AND
  (
    (@Workcenter_Efficiency_Max IS NULL)
    OR
    (
      -- workcenter efficiency calc
      CASE
        WHEN CMB.Workcenter_Rate = 0 OR CMB.Log_Hours - CMB.Downtime_Hours = 0 THEN 0
        ELSE ((CMB.Quantity_Produced + CMB.Control_Panel_Scrap) / CMB.Workcenter_Rate) / (CMB.Log_Hours - CMB.Downtime_Hours)
      END <= @Workcenter_Efficiency_Max
    )
  )
OPTION (FORCE ORDER);

DROP TABLE dbo.#Unassigned_Labor;
DROP TABLE dbo.#Shift_Times;
DROP TABLE dbo.#Workcenter_Log_Records;
DROP TABLE dbo.#Production_Records;
DROP TABLE dbo.#Scrap_Records;
DROP TABLE dbo.#Labor_Records;
DROP TABLE dbo.#Prorate;
DROP TABLE dbo.#Operators;