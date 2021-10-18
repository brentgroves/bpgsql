CREATE PROCEDURE [dbo].[Account_Balances_by_Periods_Get]  
(
  @PCN INT,
  @Period_Range VARCHAR(20),
  @Type VARCHAR(7) = '',
  @Accounts VARCHAR(2000) = '',
  @Exclude_Period_13 SMALLINT = 0,
  @Summarize_By VARCHAR(30) = 'Account',
  @Format_Type_No INT = 0,
  @Account_No_Exclude VARCHAR(2000) = '',
  @Cost_Center_No VARCHAR(8000) = '',
  @Base_No VARCHAR(8000) = '',
  @Location_No VARCHAR(8000) = '',
  @Budget_Version_Key INT = 0,
  @Category_Types VARCHAR(100) = '',
  @Period_End INT = 0,
  @Periods_Compare SMALLINT = 0,
  @Report_Type VARCHAR(10) = '',
  @Exclude_Period_Adjustments BIT = 0
)

AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Created: msto 09/24/03
-- Purpose: Returns the balances or accounts by period
-- Used in: Accounting/Report_Income_Statement_v2.asp
-- 09/26/03 MSTO @Cost_Center_No now can pass in a string of ',' separated values.
-- 09/26/03 KDAL Added @Fiscal_Year parameter so can use in Accounting/Report_Balance_Sheet_by_Period.asp
--      NOTE: Balance Sheet by Period relies on order and number of records returned so don't change to return more lines for given params without checking effect on that page
-- 10/09/03 KDAL Changed @Fiscal_Year parameter to @End_Period due to change in search block for Report_Balance_Sheet_by_Period.asp
-- 11/18/03 KDAL Changed Location_No to VARCHAR(5) to match table changes
-- 11/24/03 KDAL Changed @Budget to @Budget_Version_Key due to table changes.
-- 01/14/04 MSTO Removed  [Table_Key] from final SELECT.
-- 01/15/04 MSTO Added @Periods_Compare param.  Removed [Table_Key] andf [Order] columns from table variable.  Now joining to Category table on final select to get the correct sort order for values returned.
-- 02/09/04 MSTO Changes to incorporate graphing ability.
-- 02/10/04 MSTO Based on todays web meeting moving all DECLAREs and CREATEs to top of sproc and DROPs to end to avoid recompilations.  However, since temp table is used in cursor this may be futile.
-- 02/25/04 MSTO Replaced PB.* with actually naming each available column in table variable.  Added PB.[No] to final SELECT for graphing or data to ensure proper displaying of resutls.
-- 03/08/04 JFOS Added Sub_Category L.O.JOIN and Sub_Category.Sort_Order to ORDER BY - it was no properly sorting subcategories when
--               viewing the graph by Account.
-- 06/08/04 MSTO Remove split, Fiscal_Year_from_Period_Get and Fiscal_Year_First_Period UDFs.
-- 10/31/04 MSTO Replace EXEC Periods_from_Period_Range_Get with direct table query.
-- 11/01/04 MSTO Drop table var for selectively populated cursor.
-- 05/11/05 MSTO Rewrite to take advantage of performance enhancments in Account_Balances.  Remove cursor.
-- 06/22/06 KDAL Populate #Periods_Open with all possible periods needed, not just ones in range requested
-- 01/03/07 MSTO Add PCN column to each temp table to take advantage of table indexes. 
-- 01/05/07 MSTO US#94960 This US open after last changes adding PCN to temp table.  Dropping PRIMARY KEY from temp tables makes much faster, less reads.
-- 04/17/07 KDAL Removed old commented code, allow for @Exclude_Period_13 = -1
-- 06/06/07 MYOU SR# 110321 Removing any cross-sproc temp table use to improve Plan Cache size and performance.
-- 08/02/07 MSTO Performance problems with PCN=82392.  Add PCN to #Period_Balance.  Add OPTION(FORCE ORDER) to final SELECTS.
-- 02/03/09 RGRI US#207472/207977 Increase Base_No to 10 characters
-- 02/20/09 KDAL US#269914 Better handling of Format_Type_No = 0
-- 03/01/2010 MSTO USR#459241 Change msto @plex.com to POLAccountingErrorChecks @plex.com.
-- 06/25/2010 MSTO USR#469589 Suspect missing account for IMS Gear from report is caused by record deletion against work table before report grabs that data for presentation.
-- 07/31/12 CJANELLO USR 689060 Added logic to check for the length of the period to see if it is 6 or 8 digit
-- 08/17/12 SOSTROWSKI USR#689060 Add @Exclude_Period_Adjustments parameter 
-- 08/24/12 SRAMESWARAN USR#663982 Increase data type length for Base, Cost center & Location.
-- 12/27/12 MCSMITH USR#754820 Added "IF @Report_Type = 'VP_Nulls'" to return Expenses and Revenue as an agregate total. Used in VP Report.
-- 01/14/14 MMEDWITH USR#853223 Changed email to FinancialsTeam3@plex.com
-- 05/02/14 matthewwhite: Replaced Procedure Execute call; standards
-- 06/15/16 cherberg: JIRA AR-767: Updated select statements to have consistent returned param lists

CREATE TABLE dbo.#Period_Balance
(
 PCN INT,
 Period INT,
 Period_Display VARCHAR(10),
 Category_Type VARCHAR(10),
 Category_No INT ,
 Category_Name VARCHAR(50),
 [No] VARCHAR(20),
 [Name] VARCHAR(110),
 Ytd_Debit DECIMAL(18,2),
 Ytd_Credit DECIMAL(18,2),
 Current_Debit DECIMAL(18,2),
 Current_Credit DECIMAL(18,2),
 Sub_Category_No INT ,
 Sub_Category_Name VARCHAR(50) ,
 Subtotal_After INT, -- Unused
 Subtotal_Name VARCHAR(50) -- Unused
);

DECLARE @Periods_All TABLE
(
  Table_Key INT PRIMARY KEY IDENTITY(1,1) ,
  Period INT ,
  Period_Display VARCHAR(10) ,
  [Open] BIT
);

DECLARE 
  @Fiscal_Year INT,
  @Period INT,
  @Period_Display VARCHAR(10),
  @Period_Min INT,
  @Period_Max INT,
  @Retained_Earnings_Account_No VARCHAR(20),
  @Balance_Period_Start INT,
  @Table_Key INT,
  @Record_Count INT,
  @GUID UNIQUEIDENTIFIER,
  @Parameter_Values VARCHAR(100),
  @Execute_Date DATETIME;  

SELECT
  @GUID = NEWID(),
  @Fiscal_Year = 0,
  @Execute_Date = DATEADD(MINUTE,5,GETDATE());
  
SET
  @Parameter_Values = '@PCN = ' + CAST( @PCN AS VARCHAR(10) ) + ',@GUID = ''' + CAST( @GUID AS VARCHAR(50) )+ '''';

EXEC Plexus_Control.dbo.Procedure_Execute_Delayed_Enqueue
  @Procedure_Key = 7,--Accounting.dbo.Category_Accounts_Delete
  @Execution_Parameters = @Parameter_Values,
  @Execution_Time = @Execute_Date,
  @Conversation_Priority = 1;

IF @Period_End > 0 
BEGIN
  SELECT
    @Fiscal_Year = YC.Fiscal_Year
  FROM dbo.Year_Close AS YC  
  WHERE YC.Plexus_Customer_No = @PCN
    AND YC.Period_Start <= @Period_End
    AND YC.Period_End  >= @Period_End;
END;

IF @Fiscal_Year > 0  
BEGIN
  SET
    @Period_Range = 
  CAST
  ( 
    (
      SELECT
        YC.Period_Start
      FROM dbo.Year_Close AS YC  
      WHERE YC.Plexus_Customer_No = @PCN
        AND YC.Fiscal_Year = @Fiscal_Year
    ) AS VARCHAR(30)) + '|' + CAST(@Period_End AS VARCHAR(30)
  ); 
END;

IF CHARINDEX('|',@Period_Range) < 8
BEGIN 
  SET
    @Period_Min = CAST( LEFT ( @Period_Range, 6 ) AS INT );
  SET
    @Period_Max = CAST( RIGHT( @Period_Range, 6 ) AS INT );
END 
ELSE
BEGIN
  SET
    @Period_Min = CAST( LEFT ( @Period_Range, 8 ) AS INT );
  SET
    @Period_Max = CAST( RIGHT( @Period_Range, 8 ) AS INT );
END;
 
IF @Format_Type_No = 0
BEGIN
  SELECT
    @Format_Type_No = MIN(FT.Format_Type_No)
  FROM dbo.Format_Type AS FT
  WHERE FT.Plexus_Customer_No = @PCN;
END;

IF @Periods_Compare = 1 
BEGIN
  INSERT @Periods_All 
  SELECT
    P.Period,
    P.Period_Display,
    P.Period_Status
  FROM dbo.Period AS P
  WHERE P.Plexus_Customer_No = @PCN
    AND
    (
      P.Period = @Period_Min OR P.Period = @Period_Max
    )
  ORDER BY
    P.Period;
END
ELSE
BEGIN 
  INSERT @Periods_All 
  SELECT
    P.Period,
    P.Period_Display,
    P.Period_Status
  FROM dbo.Period AS P
  WHERE P.Plexus_Customer_No = @PCN
    AND P.Period BETWEEN @Period_Min AND @Period_Max
  ORDER BY
    P.Period;
END;

SET
  @Record_Count = @@ROWCOUNT; -- dont' move
SET
  @Table_Key = 1;

IF @Exclude_Period_13 = -1
BEGIN
  INSERT @Periods_All 
  SELECT
    P.Period,
    '13',
    P.Period_Status
  FROM dbo.Period AS P
  WHERE P.Plexus_Customer_No = @PCN
    AND P.Period = @Period_Max;

 SET @Record_Count = @Record_Count + 1;
END;

SELECT
  @Balance_Period_Start = MIN( YC.Period_Start )
FROM dbo.Year_Close AS YC 
WHERE YC.Plexus_Customer_No = @PCN;


EXEC dbo.Standards_Account_Get
  @PCN,
   'RE',
  @Retained_Earnings_Account_No OUTPUT;

EXEC dbo.Account_Balances_Category_Accounts_Fill
  @PCN,
  @GUID,
  @Type,
  @Accounts,
  @Format_Type_No,
  @Account_No_Exclude,
  @Cost_Center_No,
  @Base_No,
  @Location_No,
  @Category_Types; 

IF @Exclude_Period_13 = -1 
BEGIN
  SET
    @Exclude_Period_13 = 1;
END;

WHILE @Table_Key <= @Record_Count
BEGIN
  SELECT 
    @Period = PA.Period, 
    @Period_Display = PA.Period_Display  
  FROM @Periods_All AS PA
  WHERE PA.Table_Key = @Table_Key;
  
  IF @Period_Display = '13'
  BEGIN
     EXEC dbo.Account_Balances_Aggregate_Period_13    
       @PCN = @PCN,
       @GUID = @GUID,
       @Period_End = @Period,
       @Retained_Earnings_Account_No = @Retained_Earnings_Account_No,
       @Balance_Period_Start = @Balance_Period_Start,
       @Exclude_Period_Adjustments = @Exclude_Period_Adjustments;
  END
  ELSE 
  BEGIN
    IF @Budget_Version_Key = 0 
    BEGIN
      EXEC dbo.Account_Balances_Aggregate
        @PCN = @PCN,
        @GUID = @GUID,
        @Period_End = @Period,
        @Exclude_Period_13 = @Exclude_Period_13,
        @Retained_Earnings_Account_No = @Retained_Earnings_Account_No,
        @Balance_Period_Start = @Balance_Period_Start,
        @Exclude_Period_Adjustments = @Exclude_Period_Adjustments;   
    END
    ELSE
    BEGIN
      EXEC dbo.Account_Balances_Aggregate_Budget
        @PCN,
        @GUID,
        @Period,     
        @Budget_Version_Key,
        @Balance_Period_Start;
    END;
  END;

  INSERT dbo.#Period_Balance
  EXEC dbo.Account_Balances_Summarize_with_Period
    @PCN,
    @GUID,
    @Summarize_By,
    @Period,    
    @Period_Display;

  UPDATE dbo.Category_Accounts
  SET  
    YTD_Debit = 0,
    YTD_Credit = 0,
    Current_Debit = 0,
    Current_Credit = 0
  WHERE PCN = @PCN
    AND [GUID] = @GUID;

  SET
    @Table_Key = @Table_Key + 1;
END; 


IF @Periods_Compare != -1
BEGIN
  IF @Periods_Compare = 1
  BEGIN

  INSERT dbo.#Period_Balance
    SELECT 
      @PCN,
      999999,
      'Difference',
      PB1.Category_Type ,
      PB1.Category_No ,
      PB1.Category_Name ,
      PB1.[No]  ,
      PB1.[Name] ,
      0 ,
      0 ,
      (
        SELECT
          SUM( PB2.Current_Debit ) 
        FROM dbo.#Period_Balance AS PB2 
        WHERE PB2.Period = @Period_Max
          AND PB2.Category_Type = PB1.Category_Type
          AND PB2.Category_No = PB1.Category_No 
          AND PB2.Sub_Category_No =  PB1.Sub_Category_No 
          AND PB2.[No] = PB1.[No] 
      )-
      ( 
        SELECT
         SUM( PB2.Current_Debit ) 
        FROM dbo.#Period_Balance AS PB2 
        WHERE PB2.Period = @Period_Min
          AND PB2.Category_Type = PB1.Category_Type
          AND PB2.Category_No = PB1.Category_No 
          AND PB2.Sub_Category_No =  PB1.Sub_Category_No 
          AND PB2.[No] = PB1.[No] 
      ),
      (
        SELECT
          SUM( PB2.Current_Credit ) 
        FROM dbo.#Period_Balance AS PB2 
        WHERE PB2.Period = @Period_Max
          AND PB2.Category_Type = PB1.Category_Type
          AND PB2.Category_No = PB1.Category_No 
          AND PB2.Sub_Category_No =  PB1.Sub_Category_No 
          AND PB2.[No] = PB1.[No] 
      )-
      ( 
        SELECT
          SUM( PB2.Current_Credit ) 
        FROM dbo.#Period_Balance AS PB2 
        WHERE PB2.Period = @Period_Min
          AND PB2.Category_Type = PB1.Category_Type
          AND PB2.Category_No = PB1.Category_No 
          AND PB2.Sub_Category_No =  PB1.Sub_Category_No 
          AND PB2.[No] = PB1.[No] 
     ),
     PB1.Sub_Category_No ,
     PB1.Sub_Category_Name ,
     PB1.Subtotal_After ,
     PB1.Subtotal_Name
    FROM dbo.#Period_Balance AS PB1
    GROUP BY 
      PB1.Category_Type ,
      PB1.Category_No  ,
      PB1.Category_Name ,
      PB1.Sub_Category_No ,
      PB1.Sub_Category_Name ,
      PB1.[No] ,
      PB1.[Name] ,
      PB1.Subtotal_After ,
      PB1.Subtotal_Name;
  END -- = 0
  ELSE
  BEGIN
  INSERT dbo.#Period_Balance
    SELECT 
      @PCN,
      999999,
      'Total',
      Category_Type ,
      Category_No ,
      Category_Name ,
      [No]  ,
      [Name] ,
      0 ,
      0 ,
      SUM( Current_Debit ) ,
      SUM( Current_Credit ) ,
     Sub_Category_No ,
     Sub_Category_Name ,
     Subtotal_After ,
     Subtotal_Name
    FROM dbo.#Period_Balance
    GROUP BY 
      Category_Type ,
      Category_No  ,
      Category_Name ,
      Sub_Category_No ,
      Sub_Category_Name ,
      [No] ,
      [Name] ,
      Subtotal_After ,
      Subtotal_Name;
  END; -- = 0
END; -- !=-1

IF @Report_Type = 'Graph'
BEGIN 
  SELECT 
    NULL AS Revenue,
    NULL AS Expense,
    (
      CASE PB.Category_Type
      WHEN 'Revenue' THEN PB.Current_Credit - PB.Current_Debit
      ELSE PB.Current_Debit - PB.Current_Credit 
      END
    ) / 1000 AS Amount,
    NULL AS Period,
    PB.Period_Display,
    PB.Category_Type,
    NULL AS Category_No,
    NULL AS Category_Name,
    NULL AS [No],
    NULL AS [Name],
    NULL AS Ytd_Debit,
    NULL AS Ytd_Credit,
    NULL AS Current_Debit,
    NULL AS Current_Credit,
    NULL AS Sub_Category_No,
    NULL AS Sub_Category_Name,
    NULL AS Subtotal_After,
    NULL AS Subtotal_Name
  FROM dbo.#Period_Balance AS PB
  LEFT OUTER JOIN dbo.Category AS C 
    ON C.Plexus_Customer_No = PB.PCN
    AND C.Category_No = PB.Category_No
  LEFT OUTER JOIN dbo.Sub_Category AS S 
    ON S.Plexus_Customer_No = PB.PCN
    AND S.Sub_Category_No = PB.Sub_Category_No
  ORDER BY 
    PB.Period,
    C.Sort_Order,
    S.Sort_Order,
    PB.[No]
  OPTION (FORCE ORDER);
END
ELSE IF @Report_Type = 'VP_Nulls'
BEGIN
  SELECT
    SUM((
        CASE PB.Category_Type
        WHEN 'Revenue' THEN PB.Current_Credit - PB.Current_Debit
        END 
        )/1000) AS Revenue,
    SUM((
        CASE PB.Category_Type
        WHEN 'Expense' THEN PB.Current_Debit - PB.Current_Credit
        END
        )/1000) AS Expense,
    NULL AS Amount,
    PB.Period,
    PB.Period_Display,
    NULL AS Category_Type,
    NULL AS Category_No,
    NULL AS Category_Name,
    NULL AS [No],
    NULL AS [Name],
    NULL AS Ytd_Debit,
    NULL AS Ytd_Credit,
    NULL AS Current_Debit,
    NULL AS Current_Credit,
    NULL AS Sub_Category_No,
    NULL AS Sub_Category_Name,
    NULL AS Subtotal_After,
    NULL AS Subtotal_Name 
  FROM dbo.#Period_Balance AS PB
  GROUP BY
    PB.Period,
    PB.Period_Display
  ORDER BY
    PB.Period,
    PB.Period_Display;
END
ELSE
BEGIN
  SELECT 
    NULL AS Revenue,
    NULL AS Expense,
    NULL AS Amount,
    PB.Period,
    PB.Period_Display,
    PB.Category_Type,
    PB.Category_No,
    PB.Category_Name,
    PB.[No],
    PB.[Name],
    PB.Ytd_Debit,
    PB.Ytd_Credit,
    PB.Current_Debit,
    PB.Current_Credit,
    PB.Sub_Category_No,
    PB.Sub_Category_Name,
    PB.Subtotal_After,
    PB.Subtotal_Name 
  FROM dbo.#Period_Balance AS PB
  LEFT OUTER JOIN dbo.Category AS C 
    ON C.Plexus_Customer_No = PB.PCN
    AND C.Category_No = PB.Category_No
  LEFT OUTER JOIN dbo.Sub_Category AS S 
    ON S.Plexus_Customer_No = PB.PCN
    AND S.Sub_Category_No = PB.Sub_Category_No
  ORDER BY 
    PB.Period,
    PB.Period_Display,
    C.Sort_Order,
    S.Sort_Order,
    PB.[No]
  OPTION (FORCE ORDER);
END;

DROP TABLE dbo.#Period_Balance;

RETURN;