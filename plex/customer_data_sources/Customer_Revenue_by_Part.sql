CREATE PROCEDURE [dbo].[Customer_Revenue_By_Part_Get]
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
  @Forecast_Version_Key INT = 0,
  @Display_by_Product_Type BIT = 0
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--------------------------------------------------------------------------------------------------------------------
-- 02/27/04 mMei
-- Return revenue information group by Part
-- Used in: Accounting/Report_Customer_Revenue_By_Part.asp
-- Based on dbo.Customer_Revenue_By_Part_Type_Get
-- Assumptions:
-- 1. This needs some adjustmens to be universal for all customers. 
--   It works for us because we don't normally have things like Discounts and Late Charges
--
-- 3/3/04 - mMei added condition on quantity check that we only sum quantity for selected release key
-- 6/30/04 - mMei changed table var to TABLE dbo.#Part
-- 12/29/05 MSTO sql2005 ORDER BY change.  T1.Customer should be [Customer].  All DECLARES and CREATE stuff moved to top.
-- 02/19/07 MYOU SR#99744 Add Identity col, PK to Temp table to attempt to improve performance.
-- 02/19/07 MYOU SR#99744 Move Part Revenue calculation to a derrived table.
-- 03/06/07 Mmei performance, addition of AND (@Customer_No = -1 OR I.Customer_No = @Customer_No)
-- 05/12/2009 MYOU US#375412 Replaced call to f_Cost_Type_Valuation_Columns_Breakdown_List with a subquery.
-- 05/05/2009 MYOU US#133334 Add functionality from @Exclude_No_Part param
-- 05/05/2009 MYOU US#133334 Change Temp Table to CTE, calculation for grand total needs to exclude 'No Part' when selected
-- 06/23/2009 MYOU US#133334 Remove function for cost cols, add reference to Abbreviated_Cost_Type and use if populated.
-- 07/06/2009 MYOU US#394716 CONVERT Abbreviated_Cost_Subtype to a longer VARCHAR() to prevent truncation.
-- 08/03/2009 MYOU US#427767 Add filtering by date.
-- 11/17/2009 JBLAC US#442611 Changed to router sproc to support Forecasting data
-- 03/05/2014 RGRI US#879077 Add Product_Type_Key param
--------------------------------------------------------------------------------------------------------------------

IF ISNULL(@Forecast_Version_Key, -1) > 0
BEGIN
  EXEC dbo.Customer_Revenue_By_Forecast_Part_Get
    @Plexus_Customer_No,
    @Part_Key,
    @Period_Start,
    @Period_End,
    @Cost_Model_Key,
    @Customer_No,
    @Exclude_No_Part,
    @Forecast_Version_Key,
    @Display_by_Product_Type;
END;
ELSE
BEGIN
  EXEC dbo.Customer_Revenue_By_Invoice_Part_Get
    @Plexus_Customer_No,
    @Part_Key,
    @Period_Start,
    @Period_End,
    @Date_Start,
    @Date_End,
    @Cost_Model_Key,
    @Customer_No,
    @Exclude_No_Part,
    @Display_by_Product_Type;
END;