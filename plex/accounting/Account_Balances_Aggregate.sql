CREATE PROCEDURE [dbo].[Account_Balances_Aggregate]
(
  @PCN INT ,
  @GUID UNIQUEIDENTIFIER,
  @Period_End INT ,
  @Exclude_Period_13 SMALLINT ,
  @Retained_Earnings_Account_No VARCHAR(20),
  @Balance_Period_Start INT,
  @Income_Period_Start INT = 0,
  @Called_From VARCHAR(30) = '',
  @Booked BIT = 1,
  @Exclude_Period_Adjustments BIT = 0
)

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 05/11/05 CREATE for performance.  Called by sproc Account_Balances
-- 02/01/06 MSTO US#51309 Added to WHERE clause for closed periods:   OR (B.Period_13 = 1 AND B.Period <> @Period_End)) 
-- 07/21/06 KDAL Add @Income_Period_Start parameter
-- 01/03/07 MSTO Use new column in place of @PCN in JOINs to take advantage of table indexes.
-- 01/04/07 MSTO Added OPTION (FORCE ORDER)
-- 06/06/07 MYOU SR# 110321 Removing any cross-sproc temp table use to improve Plan Cache size and performance.
-- 06/27/07 MSTO Performance problems, switched IX_Offset for IX_Financials on AP_Invoice table and added new index [IX_GUID_Category_Type_Account_No] to Category_Accounts.
-- 06/28/07 MSTO Performance problems switch back to IX_Offset.
-- 08/02/07 MSTO Call newly created Routing sprocs.
-- 09/05/07 KDAL US#118875 Switch sides when year end close for current period populated
-- 05/09/11 RGRI US#512224 Add param @Booked filtering
-- 05/13/11 RGRI US#512220 @Booked default changed from NULL to 1
-- 08/16/12 DJJOHNSTON Added @Exclude_Period_Adjustments to inputs and to Account_Balances_Aggregate_Closed_Periods_Get 
--                     and Account_Balances_Aggregate_GL_Journals_Get
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Year_Close_Debit DECIMAL(18,2) 
DECLARE @Year_Close_Credit DECIMAL(18,2) 

IF @Income_Period_Start = 0 BEGIN
  SELECT @Income_Period_Start = MAX ( YC.Period_Start )
  FROM dbo.Year_Close AS YC 
  WHERE YC.Plexus_Customer_No = @PCN
    AND YC.Period_Start <= @Period_End
END

IF @Income_Period_Start = @Period_End BEGIN
  SELECT 
    @Year_Close_Debit = ISNULL( Debit , 0 ) ,
    @Year_Close_Credit = ISNULL( Credit , 0 )
  FROM dbo.GL_Journal AS J 
  JOIN dbo.GL_Journal_Dist AS D 
    ON D.Plexus_Customer_No = J.Plexus_Customer_No
    AND D.Journal_Link = J.Journal_Link
  WHERE J.Plexus_Customer_No = @PCN
    AND J.Journal_Link < 0
    AND J.Period = @income_period_start 

  SELECT
    @Year_Close_Debit = ISNULL( @Year_Close_Debit , 0 )  ,
    @Year_Close_Credit = ISNULL( @Year_Close_Credit , 0 )  

  	UPDATE dbo.Category_Accounts 
    SET 
	  Current_Debit = @Year_Close_Credit,  
	  Current_Credit = @Year_Close_Debit 
	FROM dbo.Category_Accounts 
	WHERE PCN = @PCN
	  AND [GUID] = @GUID
	  AND Account_No = @Retained_Earnings_Account_No

 END


EXEC [dbo].[Account_Balances_Aggregate_Closed_Periods_Get]
  @PCN ,
  @GUID,
  @Period_End ,
  @Exclude_Period_13,
  @Balance_Period_Start,
  @Income_Period_Start,
  @Exclude_Period_Adjustments

EXEC [dbo].[Account_Balances_Aggregate_AP_Invoices_Get]
  @PCN ,
  @GUID,
  @Period_End,
  @Exclude_Period_13,
  @Balance_Period_Start,
  @Income_Period_Start,
  @Booked


EXEC [dbo].[Account_Balances_Aggregate_AR_Invoices_Get]
  @PCN ,
  @GUID,
  @Period_End ,
  @Exclude_Period_13 ,
  @Balance_Period_Start ,
  @Income_Period_Start,
  @Booked

EXEC [dbo].[Account_Balances_Aggregate_GL_Journals_Get]
  @PCN,
  @GUID,
  @Period_End,
  @Exclude_Period_13,
  @Balance_Period_Start,
  @Income_Period_Start,
  @Booked,
  @Exclude_Period_Adjustments
  
EXEC [dbo].[Account_Balances_Aggregate_AR_Applieds_Get]
  @PCN ,
  @GUID,
  @Period_End ,
  @Exclude_Period_13,
  @Balance_Period_Start,
  @Income_Period_Start,
  @Booked

EXEC [dbo].[Account_Balances_Aggregate_Checks_Get]
  @PCN ,
  @GUID,
  @Period_End,
  @Exclude_Period_13,
  @Balance_Period_Start,
  @Income_Period_Start,
  @Booked
  

EXEC [dbo].[Account_Balances_Aggregate_Deposits_Get]
  @PCN,
  @GUID,
  @Period_End,
  @Exclude_Period_13,
  @Balance_Period_Start,
  @Income_Period_Start, 
  @Booked

RETURN                      
                  