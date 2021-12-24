CREATE PROCEDURE [dbo].[Cost_Gross_Margin_Get]
(
  @PCN INT,
  @Cost_Model_Key INT = NULL,
  @Part_No VARCHAR(50) = NULL,
  @Customer_Code VARCHAR(50) = NULL,
  @Cost_Model_Date DATETIME = NULL,
  @Product_Type_Key VARCHAR(MAX) = '',
  @Salesperson INT = NULL,
  @Start_Period INT = NULL,
  @End_Period INT = NULL,
  @Report VARCHAR(20) = '',
  @Part_Types VARCHAR(MAX) = '',
  @Part_Group_Keys VARCHAR(MAX) = '',
  @PO_Type_Keys VARCHAR(MAX) = '',
  @Include_Derived_Columns BIT = 0,
  @Part_Product_Type_Key VARCHAR(MAX) = '',
  @Department_No VARCHAR(MAX) = NULL,
  @Include VARCHAR(50) = 'Sales,Returns',
  @Return_Type_Keys VARCHAR(MAX) = '',
  @Ship_To VARCHAR(50) = '',
  @Customer_Parent_Key INT = NULL,
  @PCNs VARCHAR(1000) = '',
  @PUN INT = 0,
  @Begin_Date DATETIME = NULL,
  @End_Date DATETIME = NULL,
  @Ship_From_Keys VARCHAR(MAX) = '',
  @Customer_Category_Keys VARCHAR(MAX) = '',
  @Customer_Type VARCHAR(60) = NULL,
  @Part_Source_Keys VARCHAR(MAX) = '',
  @Part_Status VARCHAR(MAX) = '',
  @Master_Keys VARCHAR(MAX) = '',
  @Pivot BIT = 1,
  @Snapshot_Is_Building BIT = 0 OUTPUT,
  @Customer_Parent_Code VARCHAR(50) = NULL,
  @AR_Invoice_Type_Keys VARCHAR(MAX) = ''
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 -- The @Customer_Parent_Key paramter is deprecated in favor of @Customer_Parent_Code for xPCN functionality.
 
-- Purpose: Customer Gross Margin Report
-- Used in these files: Cost/Gross_Margin.asp
 
-- 12/20/04 mhal 32266: Initial creation.
-- 12/21/04 mhal: Added Revenue column.
-- 12/28/04 bbie Changed ROUNDing #cgm..Ext_Cost per DGRE
-- 12/29/04 bbie: Forced ABS() values for #cgm..Quantity, #cgm..Cost and #cgm..Ext_Cost per DGRE
-- 12/29/04 mhal: Revamp of container quantity and cross tab.
-- 01/06/04 mhal: Added Customer_Code to the "manual" invoices.
-- 02/02/05 kcan: Added Part_Type and Salesperson filters and columns.
-- 02/14/05 kcan: Changed Part_Type to Product_Type, added between period params
-- 03/07/05 kcan: Added Part_Cost and Sales_Qty columns; changed part_cost to unit_price
-- 03/03/06 mhal: Revamp for SQL 2005 performance problem.
-- 09/30/06 mhal: Rewrite for US 82704.
-- 12/22/06 mhal: Part Types and Part Groups
-- 07/07/08 mhal 149474: Missing double invoice rows.
-- 08/26/08 mhal 135685: PO Type filter.
-- 09/10/09 econ: Added @Include_Derived_Columns to avoid extra work when not downloading
-- 09/10/09 econ: Pass @Include_Derived_Columns to Cost_Gross_Margin_SGA
-- 09/24/09 econ: added @Part_Product_Type_Key parameter for Part's Product Type filter and return Product Type
--                corresponding to the setting "Gross Margin Report","Product Type Filter Display"
-- 07/02/10 mhal 476123: Gross Margin column on download.
-- 07/06/10 mhal 469886: Negative revenue fix.
-- 07/14/10 mhal 456621: Cost Type columns
-- 08/31/10 mhal 482193: Part No and Product Type issues.
-- 09/13/10 mhal 456621: Intercompany invoices exclude.
-- 10/27/10 mhal 482867: Credit Memo qty and margin.
-- 12/15/10 gacheson 480631: Added filter by department
-- 12/15/10 gacheson 480631: Corrected a code issue
-- 02/09/11 rkeast: Added Quantity_Unit (Mfg Unit), Sales_Unit, and Net_Weight to recordset
-- 03/07/11 mhal 517763: Retro prices should not show qty.
-- 03/08/11 mhal 507998: Include sales/returns, and return types.
-- 03/16/11 mhal 461528: Ship_To filter.
-- 08/16/11 mhal 589656: Only count actual returns as returns.
-- 09/21/11 mhal 606895: Cost_Type.COGS_Column
-- 10/14/11 mhal 602768: Performance overhaul.
-- 10/21/11 mhal 613674: Part Op precedence
-- 11/07/11 mhal 614418:/617881 Consignment in different weight unit than part.
-- 12/01/11 mhal 626746: #Shipper_Line
-- 02/10/12 mhal 636405: Piece Wt use container not routing
-- 02/28/12 mhal 457461:/517351 xPCN (FML)
-- 03/14/12 mhal 635425: Include: Scrap filter
-- 03/31/12 mhal 662142: Unit Conversions
-- 05/04/12 msto 618567: Set quantity to negative *if* credit memo flag flipped not if revenue is negative.
-- 08/15/12 molson: Added begin_date and end_date parameters
-- 08/16/12 molson: Added part_revision
-- 08/22/12 molson: Added Ship From filter
-- 08/23/12 molson: Added Customer Part No column
-- 08/29/12 molson: Made Ship From filter a multiselect
-- 09/07/12 molson: Fix cost model selection bug related to xPCN functionality.
-- 10/03/12 molson: Fix xPCN bug related to the bug fix above to accommodate silly customers using same named cost models to achieve xPCN functionality.
-- 12/14/12 molson: Fix several bugs noticed with the Net Weight and Raw.  Mostly related to shipper lines that spanned multiple invoices and for the quanity/unit price of 
--                      line items that shared a shipper line in the Raw report.
-- 03/04/13 molson: Performance tuning
-- 04/22/13 molson: Added Department as multi-picker
-- 04/29/13 molson: Made salesperson filter xPCN.
-- 05/08/13 molson: Fix error with discounts not being detected as discounts and thus returning a zero quantity sometimes.
-- 05/08/13 molson: Fix error with net weight calculation when invoice units differ from inventory units
-- 07/23/13 anhall: Add Customer Category filter and column
-- 07/29/13 anhall: Add Part Source multipicker and column
-- 08/05/13 anhall: Adjust Part Group param to support PCN?Part_Group_Key instead of just Part_Group_Key.
-- 09/09/13 anhall: Added the ability to calculate scrap cost with shipped quantity instead of produced quantity and added "Shipped Quantity For Scrap Calculation Use" setting
-- 09/27/13 anhall: Change Product Type to multipicker
-- 10/04/13 anhall: Added "By Sequence No" view
-- 12/17/13 rhenri: Added @Master_Keys & @Part_Status filters
-- 12/30/13 rhenri: Changed @Part_Status to multipicker
-- 03/12/14 anhall: Return null Master_No when not using CustomerMfgMaster view to prevent duplicates
-- 04/08/14 anhall: Performance tweak for CC2 cross apply
-- 05/19/14 jstroven 893275: performance improvements
-- 05/27/14 jstroven 893275: new setting to use better query
-- 06/13/14 anhall: Adjust joins in "Expensive Query" section to avoid bad plan
-- 07/08/14 anhall: Fix join to #Master that used a tautology in the join predicate
-- 07/23/14 anhall: Added @Pivot parameter for F5
-- 03/11/15 anhall 984792: Add primary key to #Shipper_Line temp table
-- 04/01/15 anhall: Change Cost_Sub_Type_Order column for F5
-- 05/01/15 anhall 984792: Add primary keys to temp tables and join to #xPCN table throughout so queries can seek on the index
-- 05/05/15 anhall 1009812: Add snapshot check
-- 09/08/15 anhall 1028966: Add @Customer_Parent_Code param to make Customer Parent filter xPCN
-- 10/22/15 anhall 2001055: Add cost type and cost sub type columns to the Sequence No result
-- 10/22/15 anhall 1034082: Add 1 second to the period's End Date
-- 11/24/15 matthewwhite 2003684: Escape the customer code going into Email_Send to prevent customer names with apostrophes from causing errors
-- 02/25/16 anhall 2005777: Return Line_Item_No when @Include = 'Quantity_RAW'.
-- 05/26/16 anhall 2102877: Pick up Net_Weight from the PCN specified in the temp table instead of @PCN. Also replaced a few other instances of @PCN.
-- 06/22/16 anhall 2015201: Ignore invoices that have been voided in AR_Invoice_Applied.
-- 06/23/16 anhall 2115760: Force loop join to container on SL update.
-- 08/24/16 edoherty UX-579: Fix for UX crosstab Sequence report
-- 10/10/16 anhall 2600017: Performance improvements to the "expensive" section and the CSTB building sections.
-- 10/27/16 anhall 2503289: Another attempt at performance improvements for the "expensive" section.
-- 11/01/16 anhall AC-3561: Force loop join and FORCE ORDER in new Net_Weight section.
-- 02/22/17 cjersey HR-4040: Added PCN to joins to #ARID.
-- 07/20/17 bste CR-3208: Add FORCESEEK to multiple joins to improve performance
-- 12/21/17 molson TRIAGE-9815: Correct issue with historical costs being deleted if they weren't on current part operations
-- 02/28/18 mMei CR-6107: Corrected Net Weight Calculation, was performing a AVG when Total and other calcs are SUM across part groupings
-- 12/03/18 tborowsky SI-1053: Optimized for SQL 2017 performance tuning.
--                    Updated for standards.
-- 12/27/18 tborowsky CR-11019: Corrected issue with returning inconsistent results related to the scrap filter.
-- 02/13/19 molson CR-11859: performance tuning
-- 02/21/19 molson CR-12020, CR-12021, CR-12022: performance tuning
-- 03/01/19 molson CR-11933: more performance tuning
-- 06/18/19 molson CR-13802: performancing tuning for when Gross Margin Actual Labor is turned on
-- 06/27/19 molson CR-13969: Performance tuning.  Longer term refactoring not done yet.
-- 03/17/21 ccristea MHM-6660: Add @AR_Invoice_Type_Keys input parameter

--#region Temp tables
CREATE TABLE dbo.#ARID
(
  PCN INT NOT NULL,
  Invoice_Link INT NULL,
  Invoice_No VARCHAR(50) NULL,
  Line_Item_No INT NULL,
  Customer_No INT NULL,
  PO_Type_Key INT NULL,
  Shipper_Line_Key INT NULL,
  Part_Key INT NULL,
  Quantity DECIMAL(19,5) NULL,
  Revenue DECIMAL(19,5) NULL,
  Account_No VARCHAR(20) NULL,
  Discount BIT NULL,
  Credit_Memo SMALLINT NULL
);

CREATE TABLE dbo.#ARID_Quantity
(
  PCN INT NOT NULL,
  Invoice_Link INT NULL,
  Shipper_Line_Key INT NULL,
  Part_Key INT NULL,
  Account_No VARCHAR(20) NULL,
  Discount BIT NULL,
  Quantity DECIMAL(19,5) NULL,
  Line_Item_No INT NULL
);

CREATE TABLE dbo.#cgm_all
(
  PCN INT NOT NULL,
  Gross_Margin_Key INT IDENTITY(1,1) NOT NULL,
  Customer_Code VARCHAR(35) NULL,
  Customer_Category VARCHAR(100) NULL,
  Customer_Type VARCHAR(60) NULL,
  Salesperson VARCHAR(100) NULL,
  Order_No VARCHAR(50) NULL,
  PO_No VARCHAR(50) NULL,
  Invoice_No VARCHAR(50) NULL,
  Line_Item_No INT NULL,
  Part_Key INT NULL,
  Part_No VARCHAR(120) NULL,
  Product_Type VARCHAR(50) NULL,
  Part_Source VARCHAR(50) NULL,
  Part_Description VARCHAR(500) NULL,
  Quantity DECIMAL(18,3) NULL,
  Quantity_Unit VARCHAR(20) NULL,
  Sales_Qty DECIMAL(18,3) NULL,
  Sales_Unit VARCHAR(20) NULL,
  Unit_Price DECIMAL(18,6) NULL,
  Revenue DECIMAL(18,5) NULL,
  Shipper_Line_Key INT NULL,
  Part_Group VARCHAR(50) NULL,
  Part_Type VARCHAR(50) NULL,
  PO_Type VARCHAR(50) NULL,
  Net_Weight DECIMAL(18,8) NULL,
  Part_Revision VARCHAR(8) NULL,
  Customer_Part_No VARCHAR(50) NULL,
  Customer_Part_Revision VARCHAR(50) NULL,
  Sequence_No VARCHAR(50) NULL,
  Master_No VARCHAR(50) NULL
);

CREATE TABLE dbo.#cgm_qty
(
  PCN INT NOT NULL,
  Gross_Margin_Key INT IDENTITY(1,1) NOT NULL,
  Customer_Code VARCHAR(35) NULL,
  Customer_Category VARCHAR(100) NULL,
  Customer_Type VARCHAR(60) NULL,
  Salesperson VARCHAR(100) NULL,
  Order_No VARCHAR(50) NULL,
  PO_No VARCHAR(50) NULL,
  Invoice_No VARCHAR(50) NULL,
  Line_Item_No INT NULL,
  Part_Key INT NULL,
  Part_No VARCHAR(120) NULL,
  Product_Type VARCHAR(50) NULL,
  Part_Source VARCHAR(50) NULL,
  Part_Description VARCHAR(500) NULL,
  Quantity DECIMAL(18,3) NULL,
  Quantity_Unit VARCHAR(20) NULL,
  Sales_Qty DECIMAL(18,3) NULL,
  Sales_Unit VARCHAR(20) NULL,
  Unit_Price DECIMAL(18,6) NULL,
  Revenue DECIMAL(18,5) NULL,
  Shipper_Line_Key INT NULL,
  Part_Group VARCHAR(50) NULL,
  Part_Type VARCHAR(50) NULL,
  PO_Type VARCHAR(50) NULL,
  Net_Weight DECIMAL(18,8) NULL,
  Part_Revision VARCHAR(8) NULL,
  Customer_Part_No VARCHAR(50) NULL,
  Customer_Part_Revision VARCHAR(50) NULL,
  Sequence_No VARCHAR(50) NULL,
  Master_No VARCHAR(50) NULL
);

CREATE TABLE dbo.#cgm
(
  PCN INT NOT NULL,
  Gross_Margin_Key INT NULL,
  Customer_Code VARCHAR(35) NULL,
  Customer_Category VARCHAR(100) NULL,
  Customer_Type VARCHAR(60) NULL,
  Salesperson VARCHAR(100) NULL,
  Order_No VARCHAR(50) NULL,
  PO_No VARCHAR(50) NULL,
  Invoice_No VARCHAR(50) NULL,
  Line_Item_No INT NULL,
  Part_Key INT NULL,
  Part_No VARCHAR(120) NULL,
  Product_Type VARCHAR(50) NULL,
  Part_Source VARCHAR(50) NULL,
  Part_Description VARCHAR(500) NULL,
  Quantity DECIMAL(18,3) NULL,
  Quantity_Unit VARCHAR(20) NULL,
  Sales_Qty DECIMAL(18,3) NULL,
  Sales_Unit VARCHAR(20) NULL,
  Unit_Price DECIMAL(18,6) NULL,
  Revenue DECIMAL(18,5) NULL,
  Cost DECIMAL(18,6) NULL,        -- was 18,9
  Ext_Cost DECIMAL(18,6) NULL,    -- was 18,9
  Cost_Column VARCHAR(100) NULL,
  Cost_Type VARCHAR(50) NULL,
  Cost_Sub_Type VARCHAR(50) NULL,
  Cost_Type_Order INT NULL,
  Cost_Sub_Type_Order INT NULL,
  Shipper_Line_Key INT NULL,
  Part_Group VARCHAR(50) NULL,
  Part_Type VARCHAR(50) NULL,
  PO_Type VARCHAR(50) NULL,
  Net_Weight DECIMAL(18,8) NULL,
  Customer_Currency_Code CHAR(3) NULL,
  Customer_Abbreviated_Name VARCHAR(10) NULL,
  Production_Qty DECIMAL(19,5) NULL,
  Part_Revision VARCHAR(8) NULL,
  Customer_Part_No VARCHAR(50) NULL,
  Customer_Part_Revision VARCHAR(50) NULL,
  Sequence_No VARCHAR(50) NULL,
  Master_No VARCHAR(50) NULL,
  GM_Total DECIMAL(18,6) NULL
);

CREATE TABLE dbo.#cgm2
(
  PCN INT NOT NULL,
  Part_Key INT NULL,
  Part_No VARCHAR(120) NULL,
  Product_Type VARCHAR(50) NULL,
  Part_Source VARCHAR(50) NULL,
  Part_Description VARCHAR(500) NULL,
  Customer_Code VARCHAR(35) NULL,
  Customer_Category VARCHAR(100) NULL,
  Customer_Type VARCHAR(60) NULL,
  Salesperson VARCHAR(100) NULL,
  Order_No VARCHAR(50) NULL,
  PO_No VARCHAR(50) NULL,
  Shipper_Line_Key INT NULL,
  Quantity DECIMAL(18,3) NULL,    -- was 18,5
  Quantity_Unit VARCHAR(20) NULL,
  Sales_Qty DECIMAL(18,3) NULL,
  Cost DECIMAL(18,6) NULL,        -- was 18,9
  Ext_Cost DECIMAL(18,6) NULL,    -- was 18,9
  Cost_Column VARCHAR(100) NULL,
  Cost_Type_Order INT NULL,
  Cost_Sub_Type_Order INT NULL,
  AR_Unit_Price DECIMAL(18,6) NULL,
  Revenue DECIMAL(18,5) NULL,     -- was 18,9
  Invoice_No VARCHAR(50) NULL,
  Line_Item_No INT NULL,
  SGA_Percent DECIMAL(12,4) NULL,
  SGA_Cost DECIMAL(18,6) NULL,
  Scrap_Percent DECIMAL(12,4) NULL,
  Scrap_Cost DECIMAL(18,6) NULL,
  Total_Cost DECIMAL(18,6) NULL,
  Cost_Per_Sales DECIMAL(18,6) NULL,
  Unit_Price DECIMAL(18,6) NULL,
  Markup DECIMAL(12,4) NULL,
  Margin DECIMAL(12,4) NULL,
  Sales_Unit VARCHAR(20) NULL,
  Part_Type VARCHAR(50) NULL,
  Part_Group VARCHAR(50) NULL,
  PO_Type VARCHAR(50) NULL,
  Net_Weight DECIMAL(18,8) NULL,
  Part_Revision VARCHAR(8) NULL,
  Customer_Part_No VARCHAR(50) NULL,
  Customer_Part_Revision VARCHAR(50) NULL,
  Sequence_No VARCHAR(50) NULL,
  Master_No VARCHAR(50) NULL,
  GM_Total DECIMAL(18,6) NULL
);

CREATE TABLE dbo.#Shipper_Line
(
  PCN INT,
  Shipper_Line_Key INT,
  Part_Key INT NULL,
  Customer_Part_Key INT NULL,
  Order_No VARCHAR(50) NULL,
  PO_No VARCHAR(50) NULL,
  PO_Type_Key INT NULL,
  Unit VARCHAR(20) NULL,
  Customer_Address_Code VARCHAR(100) NULL,
  Net_Weight DECIMAL(19,5) NULL,
  Piece_Weight DECIMAL(19,5) NULL,
  Inv_Unit VARCHAR(20) NULL,
  Conversion DECIMAL(19,9) NULL,
  Quantity DECIMAL(19,9) NULL,
  Ship_From INT NULL
);

CREATE TABLE dbo.#Shipper_Container
(
  PCN INT NOT NULL,
  Shipper_Line_Key INT NULL,
  Operation_No INT NULL,
  Unit VARCHAR(20) NULL,
  Net_Weight DECIMAL(18,8) NULL
);

CREATE TABLE dbo.#Department
(
  PCN INT NOT NULL,
  Department_No INT NULL
);

CREATE TABLE dbo.#Part_Status
(
  PCN INT NOT NULL,
  Part_Status VARCHAR(50) NULL
);

CREATE TABLE dbo.#Master
(
  PCN INT NOT NULL,
  Master_Key INT NULL
);

CREATE TABLE dbo.#Part_Type
(
  Part_Type VARCHAR(50) NULL
);

CREATE TABLE dbo.#Part_Source
(
  PCN INT NOT NULL,
  Part_Source_Key INT NULL,
  Part_Source VARCHAR(50) NULL
);

CREATE TABLE dbo.#Part_Group
(
  PCN INT NOT NULL,
  Part_Group_Key INT NULL,
  Part_Group VARCHAR(50) NULL
);

CREATE TABLE dbo.#Part_Product_Type
(
  PCN INT NOT NULL,
  Product_Type_Key INT NULL
);

CREATE TABLE dbo.#Customer_Part_Product_Type
(
  PCN INT NOT NULL,
  Product_Type_Key INT NULL
);

CREATE TABLE dbo.#PO_Type
(
  PCN INT NOT NULL,
  PO_Type_Key INT NULL,
  PO_Type VARCHAR(50) NULL
);

CREATE TABLE dbo.#Customer_Category
(
  PCN INT NOT NULL,
  Customer_Category_Key INT NULL,
  Customer_Category VARCHAR(100) NULL
);

CREATE TABLE dbo.#Part_Group_Split
(
  PCN INT NOT NULL,
  Element VARCHAR(MAX) NULL
);

CREATE TABLE dbo.#CSTB
(
  PCN INT NOT NULL,
  Cost_Model_Key INT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Cost_Sub_Type_Key INT NULL,
  Cost DECIMAL(19,5) NULL,
  Cost_Type VARCHAR(50) NULL,
  Cost_Sub_Type VARCHAR(50) NULL,
  CT_Sort_Order INT NULL,
  CST_Sort_Order INT NULL,
  Part_Operation_History_Key INT NULL
);

CREATE TABLE dbo.#PCN
(
  PCN INT NOT NULL,
  Cost_Model_Key INT NULL,
  Snapshot_Key INT NULL,
  Currency_Key INT NULL,
  Customer_Currency_Key INT NULL,
  Customer_Exchange_Rate DECIMAL(22,15) NULL,
  Customer_Currency_Code CHAR(3) NULL,
  Customer_Currency_Symbol VARCHAR(10) NULL,
  Customer_Abbreviated_Name VARCHAR(10) NULL
);

CREATE TABLE dbo.#xPCN
(
  PCN INT NOT NULL
);

CREATE CLUSTERED INDEX IX_ARID
ON dbo.#ARID
(
  PCN,
  Invoice_Link,
  Shipper_Line_Key,
  Part_Key,
  Quantity
);

CREATE CLUSTERED INDEX IX_ARID_Q
ON dbo.#ARID_Quantity
(
  PCN,
  Invoice_Link,
  Shipper_Line_Key,
  Part_Key,
  Line_Item_No,
  Discount,
  Account_No
);

CREATE CLUSTERED INDEX GM_CGMQ_IX
ON dbo.#cgm_qty
(
  PCN,
  Part_Key
);

CREATE CLUSTERED INDEX IX_IV_SL
ON dbo.#Shipper_Line
(
  PCN,
  Shipper_Line_Key
);

CREATE CLUSTERED INDEX IX_IV_SC
ON dbo.#Shipper_Container
(
  PCN,
  Shipper_Line_Key,
  Operation_No
);

CREATE CLUSTERED INDEX IX_Department
ON dbo.#Department
(
  PCN,
  Department_No
);

CREATE CLUSTERED INDEX IX_Part_Status
ON dbo.#Part_Status
(
  PCN,
  Part_Status
);

CREATE CLUSTERED INDEX IX_Master
ON dbo.#Master
(
  PCN,
  Master_Key
);

CREATE CLUSTERED INDEX IX_PT
ON dbo.#Part_Type
(
  Part_Type
);

CREATE CLUSTERED INDEX IX_Part_Source
ON dbo.#Part_Source
(
  PCN,
  Part_Source_Key
);

CREATE CLUSTERED INDEX IX_Part_Group
ON dbo.#Part_Group
(
  PCN,
  Part_Group_Key
);

CREATE CLUSTERED INDEX IX_Part_Product_Type
ON dbo.#Part_Product_Type
(
  PCN,
  Product_Type_Key
);

CREATE CLUSTERED INDEX IX_CPPT
ON dbo.#Customer_Part_Product_Type
(
  PCN,
  Product_Type_Key
);

CREATE CLUSTERED INDEX IX_PO_Type
ON dbo.#PO_Type
(
  PCN,
  PO_Type_Key
);

CREATE CLUSTERED INDEX IX_CC
ON dbo.#Customer_Category
(
  PCN,
  Customer_Category_Key
);

CREATE CLUSTERED INDEX GM_CSTB_IX
ON dbo.#CSTB
(
  PCN,
  Part_Key,
  Part_Operation_Key,
  Cost_Sub_Type_Key,
  Cost,
  Cost_Type,
  Cost_Sub_Type,
  CT_Sort_Order,
  CST_Sort_Order,
  Part_Operation_History_Key
);

CREATE CLUSTERED INDEX IX_XPCN
ON dbo.#xPCN
(
  PCN
);
--#endregion

--#region Settings
DECLARE
  @Allow_Partial_Consignment_Usage INT,
  @Product_Type_Display TINYINT,
  @PO_Type_Column BIT,
  @Credit_Memo_Part_No BIT,
  @Surcharge_Part_No BIT,
  @Intercompany_Credit_Memos BIT,
  @Unit_Display BIT,
  @Net_Weight_Display BIT,
  @Non_Part_Invoices BIT,
  @Parent_Company BIT,
  @COGS_Column BIT,
  @Actual_Labor BIT,
  @Separator VARCHAR(8),
  @Use_Price_Unit_For_Release_Quantity BIT,
  @Manufacturing_Master_Display BIT,
  @Use_Shipper_Quantity BIT,
  @Part_Weight_Unit VARCHAR(20);
  
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Customer Inventory', 'Show Quantity', @Allow_Partial_Consignment_Usage OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Gross Margin Report', 'Product Type Filter Display', @Product_Type_Display OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin PO Type', @PO_Type_Column OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Credit Memo Part No', @Credit_Memo_Part_No OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Surcharge Part No', @Surcharge_Part_No OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Intercompany Credit Memos', @Intercompany_Credit_Memos OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Unit Display', @Unit_Display OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Net Weight Display', @Net_Weight_Display OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Non-Part Invoices', @Non_Part_Invoices OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Parent Company', @Parent_Company OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Standard Costing', 'Gross Margin Actual Labor', @Actual_Labor OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Gross Margin Report', 'Manufacturing Master Display', @Manufacturing_Master_Display OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Part', 'Part Rev Separator', @Separator OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN, 'Customer_PO', 'Use Price Unit For Release Quantity', @Use_Price_Unit_For_Release_Quantity OUTPUT;
EXEC Plexus_Control.dbo.Customer_Setting_Get2 @PCN,'Gross Margin Report', 'Shipper Quantity Use', @Use_Shipper_Quantity OUTPUT;
EXEC Common.dbo.Part_Weight_Unit_Get @PCN, @Part_Weight_Unit OUTPUT;
--#endregion

--#region xPCN initialization
IF ISNULL(@PCNs, '') = ''
BEGIN
  INSERT dbo.#xPCN
  (
    PCN
  )
  VALUES
  (
    @PCN
  );
END
ELSE
BEGIN
  INSERT dbo.#xPCN
  (
    PCN
  )
  EXEC Plexus_Control.dbo.xPCN_List_Get @PCN, @PUN, @PCNs;
END;

INSERT dbo.#PCN
(
  PCN,
  Customer_Abbreviated_Name,
  Currency_Key
)
SELECT DISTINCT
  PC.Plexus_Customer_No,
  PC.Abbreviated_Name,
  PC.Currency_Key
FROM Plexus_Control.dbo.Plexus_Customer AS PC
JOIN dbo.#xPCN AS PCN
  ON PCN.PCN = PC.Plexus_Customer_No;

SELECT TOP(1)
  @COGS_Column = ISNULL(CT.COGS_Column, 0)
FROM Common.dbo.Cost_Type AS CT
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = CT.PCN
ORDER BY
  ISNULL(CT.COGS_Column, 0) DESC;

SET @Report = ISNULL(@Report, '');

IF ISNULL(@Cost_Model_Key, 0) = 0
BEGIN
  UPDATE PC -- UPDATE dbo.#PCN 
  SET
    PC.Cost_Model_Key = CA.Cost_Model_Key
  FROM dbo.#PCN AS PC
  OUTER APPLY
  (
    SELECT TOP(1)
      C.Cost_Model_Key
    FROM dbo.Cost_Model AS C
    WHERE C.PCN = PC.PCN
      AND C.Primary_Model = 1
  ) AS CA;
END
ELSE
BEGIN
  UPDATE PC -- UPDATE dbo.#PCN
  SET
    PC.Cost_Model_Key = CA.Cost_Model_Key
  FROM dbo.#PCN AS PC
  JOIN dbo.Cost_Model AS CMP
    ON CMP.PCN = @PCN
    AND CMP.Cost_Model_Key = @Cost_Model_Key
  OUTER APPLY
  (
    SELECT TOP(1)
      C.Cost_Model_Key
    FROM dbo.Cost_Model AS C
    WHERE C.PCN = PC.PCN
      --AND C.Cost_Model LIKE CMP.Cost_Model + '%'
      AND NOT C.Deleted = 1
    ORDER BY
      C.Active DESC,
      CASE WHEN C.Cost_Model = CMP.Cost_Model THEN 0 ELSE 1 END, -- exact match
      C.Primary_Model DESC,
      CMP.Cost_Model
  ) AS CA;
END;

UPDATE P -- UPDATE dbo.#PCN
SET
  P.Customer_Currency_Key = C.Currency_Key,
  P.Customer_Exchange_Rate = C.Exchange_Rate,
  P.Customer_Currency_Code = C.Currency_Code,
  P.Customer_Currency_Symbol = ISNULL(CC.Currency_Symbol, C.Currency_Symbol)
FROM dbo.#PCN AS P
JOIN dbo.Cost_Model AS CM
  ON CM.PCN = P.PCN
  AND CM.Cost_Model_Key = P.Cost_Model_Key
JOIN Common.dbo.Currency AS C
  ON C.Currency_Key = ISNULL(CM.Currency_Key, P.Currency_Key)
LEFT OUTER JOIN Common.dbo.Currency_Customer AS CC
  ON CC.PCN = P.PCN
  AND CC.Currency_Key = ISNULL(CM.Currency_Key, P.Currency_Key)
  AND CC.Language_Key IS NULL;
--#endregion

--#region Get cost snapshots for all PCNs
SET @Snapshot_Is_Building = 0;

IF @Cost_Model_Date IS NULL
BEGIN
  SET @Cost_Model_Date = GETDATE();
END;

EXEC sp_AdjustDate  @PCN, @Cost_Model_Date, 1, NULL, @Cost_Model_Date OUTPUT;


IF @Cost_Model_Date IS NULL
BEGIN
  SET @Cost_Model_Date = GETDATE();
END
ELSE
BEGIN
  DECLARE
    @New_PE_Execution_Added BIT = 0,
    @Snapshot_Key INT,
    @Params VARCHAR(500),
    @Cursor_PCN INT,
    @Cursor_Cost_Model_Key INT,
    @Dialog UNIQUEIDENTIFIER,
    @Email_Address VARCHAR(100),
    @Plexus_Customer_Code VARCHAR(100),
    @Already_Enqueued BIT = 0;
      
  DECLARE curPCN CURSOR LOCAL FAST_FORWARD FOR
  SELECT
    PCN.PCN,
    PCN.Cost_Model_Key
  FROM dbo.#PCN AS PCN
  WHERE PCN.Cost_Model_Key > 0;

  OPEN curPCN;
  FETCH NEXT FROM curPCN INTO @Cursor_PCN, @Cursor_Cost_Model_Key;

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    -- Get cost snapshot for each PCN. If not available, queue up
    -- Procedure Execute to build snapshots.
    
    SET @Snapshot_Key = NULL;

    EXEC dbo.Snapshot_Get 
      @PCN = @Cursor_PCN,
      @Snapshot_Date = @Cost_Model_Date,
      @Cost_Model_Key = @Cursor_Cost_Model_Key,
      @Snapshot_Key = @Snapshot_Key OUTPUT,
      @Auto_Add = 0;
    
    IF @Snapshot_Key > 0
    BEGIN
      UPDATE dbo.#PCN
      SET 
        Snapshot_Key = @Snapshot_Key
      WHERE PCN = @Cursor_PCN;
    END
    ELSE IF @Snapshot_Key = -1 -- @Snapshot_Key is -1 if a snapshot needs to be built or NULL if live tables should be used
    BEGIN      
      SET @Snapshot_Is_Building = 1;
      
      SET @Params =
        '@PCN = ' + CONVERT(VARCHAR(20), @Cursor_PCN)
        + ', @Snapshot_Date = ''' + CONVERT(VARCHAR(100), @Cost_Model_Date) + ''''
        + ', @Cost_Model_Key = ' + CONVERT(VARCHAR(20), @Cursor_Cost_Model_Key)
        + ', @Snapshot_Key = NULL';
  
      -- Don't queue up duplicates
      EXEC Plexus_Control.dbo.Procedure_Execute_Enqueued_Check
        @Procedure_Key = 92326, -- Part.dbo.Snapshot_Get
        @Execution_Parameters = @Params,
        @Enqueued = @Already_Enqueued OUTPUT;

      IF @Already_Enqueued = 0
      BEGIN
        SET @New_PE_Execution_Added = 1;
        EXEC Plexus_Control.dbo.Procedure_Execute_Enqueue
          @Procedure_Key = 92326, -- Part.dbo.Snapshot_Get
          @Execution_Parameters = @Params,
          @Dialog = @Dialog OUTPUT,
          @Keep_Open = 1;
      END;
    END;

    FETCH NEXT FROM curPCN INTO @Cursor_PCN, @Cursor_Cost_Model_Key;
  END; --(@@FETCH_STATUS = 0)

  CLOSE curPCN;
  DEALLOCATE curPCN;
  
  -- If anything was added to PE, queue up an email and short-circuit this sproc.
  IF @Snapshot_Is_Building = 1
  BEGIN
    IF @New_PE_Execution_Added = 1
    BEGIN
      SELECT
        @Email_Address = PU.Email
      FROM Plexus_Control.dbo.Plexus_User AS PU
      WHERE PU.Plexus_User_No = @PUN;
      
      SELECT
        @Plexus_Customer_Code = REPLACE(PC.Plexus_Customer_Code, '''', '''''')
      FROM Plexus_Control.dbo.Plexus_Customer AS PC
      WHERE PC.Plexus_Customer_No = @PCN;
      
      SET @Params = 
        '@Plexus_Customer_No = ' + CONVERT(VARCHAR(20), @PCN)
         + ', @Email_Subject = ''' + @Plexus_Customer_Code + ': Gross Margin ready for ' + CONVERT(VARCHAR(100), @Cost_Model_Date) + ''''
         + ', @Email_Message = ''The Gross Margin report may now be run for the Cost Date of ' + CONVERT(VARCHAR(100), @Cost_Model_Date) + '.'''
         + ', @Email_Address = ''' + @Email_Address + ''''
         + ', @From_Address = ''noreply@plex.com''';
      
      EXEC Plexus_Control.dbo.Procedure_Execute_Enqueue
        @Procedure_Key = 173, -- Plexus_Control.dbo.Email_Send
        @Execution_Parameters = @Params,
        @Dialog = @Dialog,
        @Keep_Open = 0,
        @Priority = 1;
    END;
    
    -- Make an empty recordset so ASP doesn't complain about rs being empty
    SELECT NULL WHERE 1 = 0;
    
    DROP TABLE dbo.#ARID;
    DROP TABLE dbo.#cgm;
    DROP TABLE dbo.#cgm2;
    DROP TABLE dbo.#cgm_all;
    DROP TABLE dbo.#cgm_qty;
    DROP TABLE dbo.#Part_Type;
    DROP TABLE dbo.#Part_Group;
    DROP TABLE dbo.#Part_Source;
    DROP TABLE dbo.#Customer_Category;
    DROP TABLE dbo.#PO_Type;
    DROP TABLE dbo.#CSTB;
    DROP TABLE dbo.#Shipper_Line;
    DROP TABLE dbo.#PCN;
    DROP TABLE dbo.#xPCN;
    DROP TABLE dbo.#ARID_Quantity;
    DROP TABLE dbo.#Part_Group_Split;
    DROP TABLE dbo.#Part_Product_Type;
    DROP TABLE dbo.#Customer_Part_Product_Type;
    DROP TABLE dbo.#Master;
    DROP TABLE dbo.#Part_Status;
    DROP TABLE dbo.#Department;
    RETURN;
  END;
END;
--#endregion

--#region Populate temp tables for multiselect pickers
INSERT dbo.#Department
(
  PCN,
  Department_No
)
SELECT
  D.Plexus_Customer_No,
  D.Department_No
FROM Common.dbo.Department AS D
JOIN dbo.#PCN AS P
  ON P.PCN = D.Plexus_Customer_No
WHERE (ISNULL(@Department_No, '') = '' 
  OR CHARINDEX(',' + CAST(D.Department_No AS VARCHAR(15)) + ',', ',' + @Department_No + ',', 0) > 0);

SET @Part_Types = REPLACE(@Part_Types, ', ', ',');
INSERT dbo.#Part_Type
(
  Part_Type
)
SELECT
  PT.Part_Type
FROM dbo.Part_Type AS PT
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = PT.Plexus_Customer_No
WHERE (ISNULL(@Part_Types, '') = '' OR CHARINDEX(',' + CAST(PT.Part_Type AS VARCHAR(50)) + ',', ',' + @Part_Types + ',', 0) > 0);

SET @Part_Group_Keys = REPLACE(@Part_Group_Keys, ', ', ',');
IF @Part_Group_Keys LIKE '%?%'
BEGIN
  INSERT dbo.#Part_Group_Split
  EXEC Common.dbo.List_Of_Strings_Split_With_PCN_Get @PCN, @Part_Group_Keys;

  INSERT dbo.#Part_Group
  SELECT
    PG.Plexus_Customer_No,
    PG.Part_Group_Key,
    PG.Part_Group
  FROM dbo.Part_Group AS PG
  JOIN dbo.#PCN AS PCN
    ON PCN.PCN = PG.Plexus_Customer_No
  WHERE
  (
    EXISTS
    (
      SELECT
        *
      FROM dbo.#Part_Group_Split AS PGS
      WHERE CAST(SUBSTRING(PGS.Element, 0, CHARINDEX('?', PGS.Element)) AS INT) = PG.Plexus_Customer_No
        AND CAST(SUBSTRING(PGS.Element, CHARINDEX('?', PGS.Element) + 1, LEN(PGS.Element)) AS INT) = PG.Part_Group_Key
    )
    OR NOT EXISTS (SELECT * FROM dbo.#Part_Group_Split)
  );
END
ELSE
BEGIN
  INSERT dbo.#Part_Group
  (
    PCN,
    Part_Group_Key,
    Part_Group
  )
  SELECT
    PG.Plexus_Customer_No,
    PG.Part_Group_Key,
    PG.Part_Group
  FROM dbo.Part_Group AS PG
  JOIN dbo.#PCN AS PCN
    ON PCN.PCN = PG.Plexus_Customer_No
  WHERE (ISNULL(@Part_Group_Keys, '') = '' 
    OR CHARINDEX(',' + CAST(PG.Part_Group_Key AS VARCHAR(15)) + ',', ',' + @Part_Group_Keys + ',', 0) > 0);
END;

SET @PO_Type_Keys = REPLACE(@PO_Type_Keys, ', ', ',');
INSERT dbo.#PO_Type
(
  PCN,
  PO_Type_Key,
  PO_Type
)
SELECT
  PT.PCN,
  PT.PO_Type_Key,
  PT.PO_Type
FROM Sales.dbo.PO_Type AS PT
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = PT.PCN
WHERE (ISNULL(@PO_Type_Keys, '') = '' 
  OR CHARINDEX(',' + CAST(PT.PO_Type_Key AS VARCHAR(15)) + ',', ',' + @PO_Type_Keys + ',', 0) > 0);

SET @Customer_Category_Keys = REPLACE(@Customer_Category_Keys, ', ', ',');
INSERT dbo.#Customer_Category
(
  PCN,
  Customer_Category_Key,
  Customer_Category
)
SELECT
  CC.PCN,
  CC.Customer_Category_Key,
  CC.Customer_Category
FROM Common.dbo.Customer_Category AS CC
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = CC.PCN
WHERE (ISNULL(@Customer_Category_Keys, '') = '' 
  OR CHARINDEX(',' + CAST(CC.Customer_Category_Key AS VARCHAR(15)) + ',', ',' + @Customer_Category_Keys + ',', 0) > 0);

SET @Part_Source_Keys = REPLACE(@Part_Source_Keys,', ',',');
INSERT dbo.#Part_Source
(
  PCN,
  Part_Source_Key,
  Part_Source
)
SELECT
  PS.PCN,
  PS.Part_Source_Key,
  PS.Part_Source
FROM dbo.Part_Source AS PS
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = PS.PCN
WHERE (ISNULL(@Part_Source_Keys, '') = '' 
  OR CHARINDEX(',' + CAST(PS.Part_Source_Key AS VARCHAR(15)) + ',', ',' + @Part_Source_Keys + ',', 0) > 0);

SET @Part_Product_Type_Key = REPLACE(@Part_Product_Type_Key, ', ', ',');
INSERT dbo.#Part_Product_Type
(
  PCN,
  Product_Type_Key
)
SELECT
  PPT.PCN,
  PPT.Product_Type_Key
FROM dbo.Part_Product_Type AS PPT
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = PPT.PCN
WHERE (CHARINDEX(',' + CAST(PPT.Product_Type_Key AS VARCHAR(15)) + ',', ',' + @Part_Product_Type_Key + ',', 0) > 0);

SET @Product_Type_Key = REPLACE(@Product_Type_Key, ', ', ',');
INSERT dbo.#Customer_Part_Product_Type
(
  PCN,
  Product_Type_Key
)
SELECT
  CPPT.PCN,
  CPPT.Product_Type_Key
FROM dbo.Customer_Part_Product_Type AS CPPT
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = CPPT.PCN
WHERE (CHARINDEX(',' + CAST(CPPT.Product_Type_Key AS VARCHAR(15)) + ',', ',' + @Product_Type_Key + ',', 0) > 0);

SET @Master_Keys =  REPLACE(@Master_Keys, ', ', ',');
INSERT dbo.#Master
(
  PCN,
  Master_Key
)
SELECT
  M.PCN,
  M.Master_Key
FROM dbo.[Master] AS M
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = M.PCN
WHERE (CHARINDEX(',' + CAST(M.Master_Key AS VARCHAR(15)) + ',', ',' + @Master_Keys + ',', 0) > 0);

SET @Part_Status =  REPLACE(@Part_Status, ', ', ',');
INSERT dbo.#Part_Status
(
  PCN,
  Part_Status
)
SELECT
  PS.Plexus_Customer_No,
  PS.Part_Status
FROM dbo.Part_Status AS PS
JOIN dbo.#PCN AS PCN
  ON PCN.PCN = PS.Plexus_Customer_No
WHERE (CHARINDEX(',' + PS.Part_Status + ',', ',' + @Part_Status + ',', 0) > 0);
--#endregion

--#region Period defaults

IF @Start_Period IS NULL AND @Begin_Date IS NULL
BEGIN
  SELECT
    @Start_Period = MAX(P.[Period])
  FROM Accounting.dbo.[Period] AS P
  WHERE P.Plexus_Customer_No = @PCN
    AND P.End_Date < GETDATE();

  SELECT
    @End_Period = ISNULL(NULLIF(@End_Period, 0), @Start_Period);
END;

IF @Start_Period IS NULL AND @End_Period IS NULL
BEGIN
  IF @Begin_Date IS NULL
  BEGIN
    SET @Begin_Date = CONVERT(DATETIME, '1/1/1980');
  END;
  IF @End_Date IS NULL
  BEGIN
    SET @End_Date = GETDATE();
  END;
END
ELSE
BEGIN
  IF @Begin_Date IS NULL
  BEGIN
    IF @Start_Period IS NOT NULL
    BEGIN
      SELECT
        @Begin_Date = P.Begin_Date
      FROM Accounting.dbo.[Period] AS P
      WHERE P.[Period] = @Start_Period
        AND P.Plexus_Customer_No = @PCN;
    END
    ELSE
    BEGIN
      SELECT
        @Begin_Date = P.Begin_Date
      FROM Accounting.dbo.[Period] AS P
      WHERE P.[Period] = @End_Period
        AND P.Plexus_Customer_No = @PCN;
    END;
  END;
  IF @End_Date IS NULL
  BEGIN
    IF @End_Period IS NOT NULL
    BEGIN
      SELECT
        @End_Date = DATEADD(S, 1, P.End_Date)
      FROM Accounting.dbo.[Period] AS P
      WHERE P.[Period] = @End_Period
        AND P.Plexus_Customer_No = @PCN;
    END
    ELSE
    BEGIN
      SELECT
        @End_Date = DATEADD(S, 1, P.End_Date)
      FROM Accounting.dbo.[Period] AS P
      WHERE P.[Period] = @Start_Period
        AND P.Plexus_Customer_No = @PCN;
    END;
  END;
END;
--#endregion

--#region Get AR_Invoice_Dist rows

INSERT dbo.#ARID
(
  PCN,
  Invoice_Link,
  Invoice_No,
  Customer_No,
  PO_Type_Key,
  Line_Item_No,
  Shipper_Line_Key,
  Part_Key,
  Quantity,
  Revenue,
  Account_No,
  Discount,
  Credit_Memo
)
SELECT
  PCN.PCN,
  ARID.Invoice_Link,
  I.Invoice_No,
  I.Customer_No,
  POT.PO_Type_Key,
  ARID.Line_Item_No,
  ARID.Shipper_Line_Key,
  CASE
    WHEN ARID.Shipper_Line_Key IS NULL AND @Credit_Memo_Part_No = 0 THEN NULL
    ELSE ARID.Part_Key
  END AS Part_Key,
  ARID.Quantity,
  ARID.Credit - ARID.Debit,
  ARID.Account_No,
  CASE
    WHEN (ARID.[Description] LIKE '%discount%' OR ARIDS.Price_Adjustment_Key IS NOT NULL OR ARIDS.Shipper_Line_Price_Adjustment_Key IS NOT NULL)
    THEN 1
    ELSE 0
  END,
  I.Credit_Memo
FROM dbo.#PCN AS PCN
JOIN Accounting.dbo.AR_Invoice AS I
  ON I.Plexus_Customer_No = PCN.PCN
JOIN Accounting.dbo.AR_Invoice_Type AS ARIT
  ON ARIT.PCN = I.Plexus_Customer_No
  AND ARIT.Invoice_Type_Key = I.Invoice_Type_Key
JOIN Accounting.dbo.AR_Invoice_Dist AS ARID
  ON ARID.Plexus_Customer_No = I.Plexus_Customer_No
  AND ARID.Invoice_Link = I.Invoice_Link
INNER LOOP JOIN Accounting.dbo.Account AS A
  ON A.Plexus_Customer_No = ARID.Plexus_Customer_No
  AND A.Account_No = ARID.Account_No
  AND A.Category_Type = 'Revenue' 
LEFT OUTER JOIN Accounting.dbo.AR_Invoice_Dist_Shipping AS ARIDS WITH(INDEX=IX_FK_UNIQUE_AR_Invoice_Dist_Shipping_AR_Invoice_Dist)
  ON ARIDS.PCN = ARID.Plexus_Customer_No
  AND ARIDS.Invoice_Link = ARID.Invoice_Link
  AND ARIDS.Line_Item_No = ARID.Line_Item_No
OUTER APPLY
(
  SELECT TOP(1)
    PO2.PO_Type_Key
  FROM Sales.dbo.PO AS PO2 WITH (FORCESEEK (Customer_PO (PCN, Customer_No,PO_No)))
  WHERE PO2.PCN = I.Plexus_Customer_No
    AND PO2.Customer_No = I.Customer_No
    AND PO2.PO_No = I.Customer_PO_No
) AS POT
LEFT OUTER MERGE JOIN 
(
  SELECT DISTINCT
    Unpvt.PCN,
    Unpvt.Invoice_Link,
    Unpvt.Void
  FROM 
  (
    SELECT
      AAD.Plexus_Customer_No AS PCN, 
      ARIA.Invoice_Link ARIA_Invoice_Link,
      AAD.Invoice_Link AS AAD_Invoice_Link,
      ARIA.Void
    FROM Accounting.dbo.AR_Invoice_Applied AS ARIA
    INNER LOOP JOIN Accounting.dbo.AR_Invoice_Applied_Dist AS AAD
      ON AAD.Plexus_Customer_No = ARIA.Plexus_Customer_No
      AND AAD.Applied_Link = ARIA.Applied_Link
    WHERE ARIA.Plexus_Customer_No = @PCN
      AND ARIA.Void = 1        
  ) AS ONE
  UNPIVOT(Invoice_Link FOR Source_Name IN (ARIA_Invoice_Link, AAD_Invoice_Link)) AS Unpvt
) AS VI
  ON VI.PCN = I.Plexus_Customer_No
  AND VI.Invoice_Link = I.Invoice_Link    
WHERE ISNULL(VI.Void, I.Void) = 0
  AND I.[Period] >= ISNULL(@Start_Period, I.[Period])
  AND I.[Period] <= ISNULL(@End_Period, I.[Period])
  AND I.Invoice_Date >= @Begin_Date
  AND I.Invoice_Date < @End_Date
  AND ARID.Offset = 0
  AND 
  (
    ISNULL(@AR_Invoice_Type_Keys, '') = ''
    OR ARIT.Invoice_Type_Key IN
    (
      SELECT
        SS.[value]
      FROM STRING_SPLIT(@AR_Invoice_Type_Keys, ',') AS SS
    )
  )
OPTION (FORCE ORDER);


IF (ISNULL(@Return_Type_Keys, '') != '' OR @Include NOT LIKE '%Sales%')
BEGIN
  DELETE ARID -- DELETE dbo.#ARID 
  FROM dbo.#ARID AS ARID
  WHERE NOT EXISTS
  (
    SELECT
      *
    FROM Sales.dbo.[Return] AS R
    JOIN Sales.dbo.Return_Reason AS RR
      ON RR.PCN = R.PCN
      AND RR.Return_Reason_Key = R.Return_Reason_Key
    JOIN Sales.dbo.Return_Type AS RT
      ON RT.PCN = RR.PCN
      AND RT.Return_Type_Key = RR.Return_Type_Key
    LEFT OUTER JOIN Sales.dbo.Return_Line AS RL
      ON RL.PCN = R.PCN
      AND RL.Return_Key = R.Return_Key
    WHERE R.PCN = ARID.PCN
      AND ARID.Invoice_Link = ISNULL(RL.Invoice_Link, R.Invoice_Link)
      AND (ISNULL(@Return_Type_Keys, '') = '' OR CHARINDEX(',' + CAST(RT.Return_Type_Key AS VARCHAR(15)) + ',', ',' + @Return_Type_Keys + ',', 0) > 0)
  );
END;

IF @Include NOT LIKE '%Return%'
BEGIN
  DELETE ARID -- DELETE dbo.#ARID 
  FROM dbo.#ARID AS ARID
  WHERE EXISTS
  (
    SELECT
      *
    FROM Sales.dbo.[Return] AS R
    JOIN Sales.dbo.Return_Reason AS RR
      ON RR.PCN = R.PCN
      AND RR.Return_Reason_Key = R.Return_Reason_Key
    JOIN Sales.dbo.Return_Type AS RT
      ON RT.PCN = RR.PCN
      AND RT.Return_Type_Key = RR.Return_Type_Key
    LEFT OUTER JOIN Sales.dbo.Return_Line AS RL
      ON RL.PCN = R.PCN
      AND RL.Return_Key = R.Return_Key
    WHERE R.PCN = ARID.PCN
      AND ARID.Invoice_Link = ISNULL(RL.Invoice_Link, R.Invoice_Link)
  );
END;

UPDATE ARID -- UPDATE dbo.#ARID 
SET
  ARID.Quantity = NULL
FROM dbo.#ARID AS ARID
WHERE EXISTS
(
  SELECT
    *
  FROM Accounting.dbo.AR_Invoice_Dist_Shipping AS ARIDS
  WHERE ARIDS.PCN = ARID.PCN
    AND ARIDS.Invoice_Link = ARID.Invoice_Link
    AND ARIDS.Line_Item_No = ISNULL(ARID.Line_Item_No, ARIDS.Line_Item_No)
);

UPDATE ARID -- UPDATE dbo.#ARID 
SET
  ARID.Quantity = NULL
FROM dbo.#ARID AS ARID
WHERE EXISTS
(
  SELECT
    *
  FROM Accounting.dbo.AR_Invoice_Dist_Retroactive AS ARIDR
  WHERE ARIDR.PCN = ARID.PCN
    AND ARIDR.Retroactive_Invoice_Link = ARID.Invoice_Link
    AND ARIDR.Retroactive_Line_Item_No = ISNULL(ARID.Line_Item_No, ARIDR.Retroactive_Line_Item_No)
);

INSERT dbo.#ARID_Quantity
(
  PCN,
  Invoice_Link,
  Shipper_Line_Key,
  Part_Key,
  Account_No,
  Discount,
  Quantity,
  Line_Item_No
)
SELECT
  ARID.PCN,
  ARID.Invoice_Link,
  ISNULL(ARID.Shipper_Line_Key, 0),
  ARID.Part_Key,
  ARID.Account_No,
  ARID.Discount,
  SUM(ARID.Quantity) AS [Quantity],
  CASE WHEN @Report LIKE '%Raw' THEN ARID.Line_Item_No ELSE -1 END
FROM dbo.#ARID AS ARID
WHERE ARID.Part_Key > 0
GROUP BY
  ARID.PCN,
  ARID.Invoice_Link,
  ARID.Shipper_Line_Key,
  ARID.Part_Key,
  ARID.Account_No, -- US 478220 need to group repeated qty by account no
  ARID.Discount,
  CASE WHEN @Report LIKE '%Raw' THEN ARID.Line_Item_No ELSE -1 END;
--#endregion

--#region Shipper lines
INSERT dbo.#Shipper_Line
(
  PCN,
  Shipper_Line_Key,
  Part_Key,
  Customer_Part_Key,
  Order_No,
  PO_No,
  PO_Type_Key,
  Unit,
  Customer_Address_Code,
  Conversion,
  Ship_From
)
SELECT
  ARID.PCN,
  SL.Shipper_Line_Key,
  SL.Part_Key,
  SL.Customer_Part_Key,
  PO.Order_No,
  PO.PO_No,
  PO.PO_Type_Key,
  --PR1.Unit,
  PR2.Unit,
  CA.Customer_Address_Code,
  SL.Conversion,
  S.Ship_From
FROM
(
  SELECT DISTINCT
    ARID1.PCN,
    ARID1.Shipper_Line_Key
  FROM dbo.#ARID AS ARID1
) AS ARID
 JOIN Sales.dbo.Shipper_Line AS SL
  ON SL.PCN = ARID.PCN
  AND SL.Shipper_Line_Key = ARID.Shipper_Line_Key
 JOIN Sales.dbo.Shipper AS S
  ON S.PCN = SL.PCN
  AND S.Shipper_Key = SL.Shipper_Key
 JOIN Sales.dbo.Release AS R WITH (INDEX (PK_Release))
  ON R.PCN = SL.PCN
  AND R.Release_Key = SL.Release_Key
 JOIN Sales.dbo.PO_Line AS POL WITH (INDEX (PK_PO_Line))
  ON POL.PCN = R.PCN
  AND POL.PO_Line_Key = R.PO_Line_Key
 JOIN Sales.dbo.PO AS PO
  ON PO.PCN = POL.PCN
  AND PO.PO_Key = POL.PO_Key
LEFT OUTER JOIN Common.dbo.Customer_Address AS CA
  ON CA.Plexus_Customer_No = R.PCN
  AND CA.Customer_Address_No = R.Ship_To
  AND CA.Customer_No = PO.Customer_No
  AND CA.Active = 1
  AND CA.Ship_To = 1
OUTER APPLY
(
  SELECT TOP(1)
    PR.PCN,
    PR.Price_Key
  FROM Sales.dbo.Price AS PR
  WHERE PR.PCN = R.PCN
    AND PR.PO_Line_Key = R.PO_Line_Key
  ORDER BY PR.Active DESC
) AS PR1
LEFT OUTER JOIN Sales.dbo.Price AS PR2
  ON PR2.PCN = PR1.PCN
  AND PR2.Price_Key = PR1.Price_Key
OPTION (FORCE ORDER);

INSERT dbo.#Shipper_Container
(
  PCN,
  Shipper_Line_Key,
  Operation_No,
  Unit,
  Net_Weight
)
SELECT DISTINCT
  SL.PCN,
  SL.Shipper_Line_Key,
  PO.Operation_No,
  O.Unit,
  PO.Net_Weight
FROM dbo.#Shipper_Line AS SL
INNER LOOP JOIN Sales.dbo.Shipper_Container AS SC
  ON SC.PCN = SL.PCN
  AND SC.Shipper_Line_Key = SL.Shipper_Line_Key
INNER LOOP JOIN dbo.Container AS C
  ON C.Plexus_Customer_No = SC.PCN
  AND C.Serial_No = SC.Serial_No
JOIN dbo.Part_Operation AS PO WITH (FORCESEEK (PK_Job_Operation (Plexus_Customer_No, Part_Key, Part_Operation_Key)))
  ON PO.Plexus_Customer_No = C.Plexus_Customer_No
  AND PO.Part_Key = C.Part_Key
  AND PO.Part_Operation_Key = C.Part_Operation_Key
JOIN dbo.Operation AS O WITH (FORCESEEK (IX_Operation_Operation_Key (Plexus_Customer_No, Operation_Key))) 
  ON O.Plexus_Customer_No = PO.Plexus_Customer_No
  AND O.Operation_Key = PO.Operation_Key
OPTION 
(
  FORCE ORDER, 
  MAXDOP 4
);

UPDATE SL -- UPDATE dbo.#Shipper_Line
SET
  SL.Inv_Unit = CA.Inv_Unit,
  SL.Piece_Weight = CA.Net_Weight
FROM dbo.#Shipper_Line AS SL
CROSS APPLY
(
  SELECT TOP(1)
    SC.Unit AS Inv_Unit,
    SC.Net_Weight
  FROM dbo.#Shipper_Container AS SC
  WHERE SC.PCN = SL.PCN
    AND SC.Shipper_Line_Key = SL.Shipper_Line_Key
  ORDER BY
    SC.Operation_No DESC
) AS CA;

WITH NW AS
(
  SELECT
    SL.PCN,
    SL.Shipper_Line_Key,
    SUM(ISNULL(C.Net_Weight, 0)) AS Net_Weight
  FROM dbo.#Shipper_Line AS SL WITH (FORCESEEK (IX_IV_SL (PCN, Shipper_Line_Key))) 
  JOIN
  (
    SELECT DISTINCT
      SC.PCN,
      SC.Shipper_Line_Key,
      SC.Serial_No
    FROM Sales.dbo.Shipper_Container AS SC WITH (FORCESEEK (IX_Shipper_Line_Key (PCN, Shipper_Line_Key))) 
  ) AS SCC
    ON SCC.PCN = SL.PCN
    AND SCC.Shipper_Line_Key = SL.Shipper_Line_Key
  INNER LOOP JOIN dbo.Container AS C
    ON C.Plexus_Customer_No = SCC.PCN
    AND C.Serial_No = SCC.Serial_No
  GROUP BY
    SL.PCN,
    SL.Shipper_Line_Key
)
UPDATE SL -- UPDATE dbo.#Shipper_Line
SET
  SL.Net_Weight = NW.Net_Weight
FROM dbo.#Shipper_Line AS SL
JOIN NW AS NW
  ON NW.PCN = SL.PCN
  AND NW.Shipper_Line_Key = SL.Shipper_Line_Key
OPTION(FORCE ORDER);

--Expensive Query Needed in certain complicated unit interactions
IF @Use_Price_Unit_For_Release_Quantity = 1 AND @Use_Shipper_Quantity = 0
BEGIN
  UPDATE SL  -- UPDATE dbo.#Shipper_Line expensive
  SET
    SL.Piece_Weight = SL.Net_Weight / J.Quantity,
    SL.Quantity = J.Quantity
  FROM dbo.#Shipper_Line AS SL
  JOIN
  (
    SELECT
      SC.PCN,
      SC.Shipper_Line_Key,
      SUM(ISNULL(OA1.Quantity, 0)) AS Quantity
    FROM
    (
      SELECT DISTINCT -- must do distinct because sometimes the same serial_no shows up twice
        SC2.PCN,
        SC2.Shipper_Line_Key,
        SC2.Serial_No
      FROM dbo.#Shipper_Line AS SL2
      JOIN Sales.dbo.Shipper_Container AS SC2 WITH (INDEX (PK_Shipper_Container))
        ON SC2.PCN = SL2.PCN
        AND SC2.Shipper_Line_Key = SL2.Shipper_Line_Key
    ) AS SC
    -- US 700808: must look at CC2 to determine the piece wt based on qty at ship time
    OUTER APPLY
    (
      SELECT TOP(1)
        CC2.Quantity
      FROM dbo.Container_Change2 AS CC2 WITH (INDEX (IX_History1))
      WHERE CC2.Plexus_Customer_No = SC.PCN
        AND CC2.Serial_No = SC.Serial_No
        AND CC2.Last_Action LIKE 'Shipped%'
      ORDER BY
        CC2.Change_Date DESC
    ) AS OA1
    GROUP BY
      SC.PCN,
      SC.Shipper_Line_Key
  ) AS J
    ON J.PCN = SL.PCN
    AND J.Shipper_Line_Key = SL.Shipper_Line_Key
  WHERE J.Quantity > 0
  OPTION 
  (
    FORCE ORDER,
    RECOMPILE
  );
END
ELSE --less expensive query
BEGIN
  UPDATE SL -- UPDATE dbo.#Shipper_Line less expensive
  SET 
    SL.Piece_Weight = J.Net_Weight / J.Quantity,
    SL.Net_Weight = J.Net_Weight,
    SL.Quantity = J.Quantity
  FROM dbo.#Shipper_Line AS SL
  JOIN
  (
    SELECT
      SC.PCN,
      SC.Shipper_Line_Key,
      SUM(ISNULL(C.Net_Weight, 0)) AS Net_Weight,
      SUM(ISNULL(SC.Quantity, 0)) AS Quantity
    FROM
    (
      SELECT -- must do distinct because sometimes the same serial_no shows up twice
        SC2.PCN,
        SC2.Shipper_Line_Key,
        SC2.Serial_No,
        SUM(SC2.Quantity) / (SL2.Conversion) AS Quantity
      FROM dbo.#Shipper_Line AS SL2
      JOIN Sales.dbo.Shipper_Container AS SC2
        ON SC2.PCN = SL2.PCN
        AND SC2.Shipper_Line_Key = SL2.Shipper_Line_Key
      GROUP BY
        SC2.PCN,
        SC2.Shipper_Line_Key,
        SC2.Serial_No,
        SL2.Conversion
    ) AS SC
    INNER LOOP JOIN dbo.Container AS C
      ON C.Plexus_Customer_No = SC.PCN
      AND C.Serial_No = SC.Serial_No
    GROUP BY
      SC.PCN,
      SC.Shipper_Line_Key
  ) AS J
    ON J.PCN = SL.PCN
    AND J.Shipper_Line_Key = SL.Shipper_Line_Key
  WHERE J.Quantity > 0
  OPTION 
  (
    FORCE ORDER,
    RECOMPILE
  );
END;

-- US 662142: don't use piece weight because it will double convert if both units are already weight

UPDATE SL -- UPDATE dbo.#Shipper_Line
SET 
  SL.Piece_Weight = NULL
FROM dbo.#Shipper_Line AS SL
JOIN Common.dbo.Unit AS U1
  ON U1.Plexus_Customer_No = SL.PCN
  AND U1.Unit = SL.Unit
JOIN Common.dbo.Unit AS U2
  ON U2.Plexus_Customer_No = SL.PCN
  AND U2.Unit = SL.Inv_Unit
WHERE U1.Weight_Unit = 1
  AND U2.Weight_Unit = 1;
--#endregion

--#region Collect data (main query)
-- All Data
INSERT dbo.#cgm_all
(
  PCN,
  Customer_Code,
  Customer_Category,
  Customer_Type,
  Salesperson,
  Order_No,
  PO_No,
  Invoice_No,
  Line_Item_No,
  Part_Key,
  Part_No,
  Part_Description,
  Product_Type,
  Part_Source,
  Quantity,
  Quantity_Unit,
  Sales_Qty,
  Sales_Unit,
  Unit_Price,
  Revenue,
  Shipper_Line_Key,
  Part_Group,
  Part_Type,
  PO_Type,
  Net_Weight,
  Part_Revision,
  Customer_Part_No,
  Customer_Part_Revision,
  Sequence_No,
  Master_No
)
SELECT
  T.PCN,
  T.Customer_Code,
  T.Customer_Category,
  T.Customer_Type,
  T.Salesperson,
  T.Order_No,
  T.PO_No,
  T.Invoice_No,
  T.Line_Item_No,
  T.Part_Key,
  T.Part_No,
  T.Part_Description,
  T.Product_Type,
  T.Part_Source,
  CASE
    WHEN @Report LIKE 'Sequence%' AND PBD.Production_Batch_Detail_Key IS NOT NULL THEN SUM(PBD.Delivery_Quantity)
    ELSE SUM(T.Quantity)
  END AS Quantity,
  T.Quantity_Unit,
  CASE
    WHEN @Report LIKE 'Sequence%' AND PBD.Production_Batch_Detail_Key IS NOT NULL THEN SUM(PBD.Delivery_Quantity)
    ELSE SUM(T.Sales_Qty)
  END AS Sales_Qty,
  T.Sales_Unit,
  SUM(T.Revenue) / NULLIF(SUM(T.Sales_Qty), 0.0),
  CASE 
    WHEN @Report LIKE 'Sequence%' AND PBD.Production_Batch_Detail_Key IS NOT NULL 
      THEN PBD.Delivery_Quantity * (SUM(T.Revenue) / NULLIF(SUM(T.Sales_Qty), 0.0))
    ELSE SUM(T.Revenue)
  END AS Revenue,
  NULL, --T.Shipper_Line_Key,
  T.Part_Group,
  T.Part_Type,
  CASE
    WHEN @PO_Type_Column = 1 THEN T.PO_Type 
    ELSE '' 
  END,
  SUM(T.Net_Weight),
  T.Revision,
  T.Customer_Part_No,
  T.Customer_Part_Revision,
  ISNULL(PBD.Sequence_No, ''),
  T.Master_No
FROM
(
  SELECT
    AR.PCN,
    AR.Customer_Code,
    AR.Customer_Category,
    AR.Customer_Type,
    AR.Salesperson,
    AR.Order_No,
    AR.PO_No,
    AR.Invoice_No,
    AR.Line_Item_No,
    AR.Part_Key,
    AR.Part_No,
    AR.Part_Description,
    CASE 
      WHEN @Product_Type_Display = 2 THEN AR.Product_Type 
      ELSE CPPT.Product_Type 
    END AS Product_Type,
    AR.Part_Source,
    SUM
    (
      -- tborowsky: CASE statements left formatted this way for readability
      CASE
        WHEN ISNULL(AR.Invoice_Part_Key, 0) = 0 THEN 0.0
        ELSE
          AR.Sales_Qty
          /
          ABS(ISNULL(NULLIF(AR.Conversion, 0.0), 1.0))
          /
          CASE
            WHEN AR.Piece_Weight > 0 AND AR.Conversion = -1.0 THEN AR.Piece_Weight
            WHEN AR.Piece_Weight > 0 AND AR.Conversion < 0 AND @Part_Weight_Unit NOT LIKE AR.Sales_Unit THEN AR.Piece_Weight
            ELSE 1
          END
      END
      *
      CASE WHEN AR.Credit_Memo = 1 OR AR.Revenue < 0 THEN -1 ELSE 1 END
    ) AS Quantity,
    AR.Inv_Unit AS Quantity_Unit,
    SUM
    (
      CASE
        WHEN AR.Conversion = -1.0 THEN AR.Net_Weight
        ELSE AR.Sales_Qty
      END
      *
      CASE
        WHEN (AR.Credit_Memo = 1 OR AR.Revenue < 0) THEN -1
        ELSE 1
      END
    ) AS Sales_Qty,
    AR.Sales_Unit,
    SUM(AR.Revenue) AS Revenue,
    AR.Shipper_Line_Key,
    AR.Part_Group,
    AR.Part_Type,
    AR.PO_Type,
    AR.Net_Weight,
    AR.Revision,
    CP.Customer_Part_No,
    CP.Customer_Part_Revision,
    AR.Master_No
  FROM
  (
    SELECT DISTINCT
      ID.PCN,
      CASE
        WHEN @Parent_Company = 1 AND (ISNULL(@Customer_Parent_Key, 0) = 0 AND NULLIF(@Customer_Parent_Code, '') IS NULL) AND CP.Customer_Parent_Key > 0
          THEN CP.Customer_Parent_Code
        ELSE C.Customer_Code
      END AS Customer_Code,
      CC.Customer_Category,
      C.Customer_Type,
      PU.Last_Name + ', ' + PU.First_Name AS Salesperson,
      CASE
        WHEN @Parent_Company = 1 AND (ISNULL(@Customer_Parent_Key, 0) = 0 AND NULLIF(@Customer_Parent_Code, '') IS NULL) AND CP.Customer_Parent_Key > 0
          THEN NULL
        ELSE SL1.Order_No
      END AS Order_No,
      CASE
        WHEN @Parent_Company = 1 AND (ISNULL(@Customer_Parent_Key, 0) = 0 AND NULLIF(@Customer_Parent_Code, '') IS NULL) AND CP.Customer_Parent_Key > 0
          THEN NULL
        ELSE SL1.PO_No
      END AS PO_No,
      CASE
        WHEN @Parent_Company = 1 AND (ISNULL(@Customer_Parent_Key, 0) = 0 AND NULLIF(@Customer_Parent_Code, '') IS NULL) AND CP.Customer_Parent_Key > 0
          THEN NULL
        ELSE ID.Invoice_No
      END AS Invoice_No,
      P.Part_Key,
      P.Part_No,
      P.[Name] AS Part_Description,
      PPT.Product_Type,
      PS.Part_Source,
      CASE WHEN ID.Part_Key > 0 THEN Q.Quantity ELSE 0 END AS Sales_Qty,
      SL1.Unit AS Sales_Unit,
      ID.Revenue AS Revenue,
      ID.Invoice_Link,
      ID.Shipper_Line_Key, --ELSE NULL END AS Shipper_Line_Key,
      ISNULL(SL1.Customer_Part_Key, P1.Customer_Part_Key) AS Customer_Part_Key,
      PG.Part_Group,
      PAT.Part_Type,
      POT3.PO_Type,
      ID.Part_Key AS Invoice_Part_Key,
      SL1.Inv_Unit,
      SL1.Piece_Weight,
      SL1.Net_Weight *
      -- tborowsky: CASE statements left formatted this way for readability
      CASE          
        WHEN ISNULL(ID.Part_Key, 0) = 0 THEN 0.0
        ELSE
          CASE WHEN ID.Part_Key > 0 THEN Q.Quantity ELSE 0 END
          /
          ABS(ISNULL(NULLIF(SL1.Conversion, 0.0), 1.0))
          /
          CASE
            WHEN SL1.Piece_Weight > 0 AND SL1.Conversion = -1.0 THEN SL1.Piece_Weight
            WHEN SL1.Piece_Weight > 0 AND SL1.Conversion < 0 AND @Part_Weight_Unit NOT LIKE SL1.Unit THEN SL1.Piece_Weight
            ELSE 1
          END
        END         
        *
        CASE WHEN ID.Credit_Memo = 1 OR ID.Revenue < 0 THEN -1 ELSE 1 END
        / SL1.Quantity
      AS Net_Weight,
      SL1.Conversion,
      ID.Line_Item_No,
      ID.Credit_Memo,
      P.Revision,
      CASE WHEN @Manufacturing_Master_Display = 1 THEN M.Master_No ELSE NULL END AS Master_No
    FROM
    (
      SELECT
        ARID.PCN,
        ARID.Invoice_Link,
        ARID.Invoice_No,
        CASE WHEN @Report LIKE '%Raw' THEN ARID.Line_Item_No ELSE NULL END AS Line_Item_No,
        ARID.Customer_No,
        ARID.PO_Type_Key,
        ARID.Shipper_Line_Key,
        CASE
          WHEN ARID.Shipper_Line_Key IS NULL AND @Credit_Memo_Part_No = 0 THEN NULL
          ELSE ARID.Part_Key
        END AS Part_Key,
        SUM(ARID.Revenue) AS Revenue,
        ARID.Credit_Memo
      FROM dbo.#ARID AS ARID
      GROUP BY
        ARID.PCN,
        ARID.Invoice_Link,
        ARID.Invoice_No,
        CASE WHEN @Report LIKE '%Raw' THEN ARID.Line_Item_No ELSE NULL END,
        ARID.Customer_No,
        ARID.PO_Type_Key,
        ARID.Shipper_Line_Key,
        ARID.Part_Key,
        ARID.Credit_Memo
    ) AS ID
    JOIN Common.dbo.Customer AS C WITH (FORCESEEK (PK_Customer (Plexus_Customer_No, Customer_No)))
      ON C.Plexus_Customer_No = ID.PCN
      AND C.Customer_No = ID.Customer_No
    LEFT OUTER JOIN Common.dbo.Customer_Parent AS CP WITH (FORCESEEK (PK_Customer_Parent (Plexus_Customer_No, Customer_Parent_Key)))
      ON CP.Plexus_Customer_No = C.Plexus_Customer_No
      AND CP.Customer_Parent_Key = C.Customer_Parent_Key
    LEFT OUTER JOIN Plexus_Control.dbo.Plexus_User AS PU
      ON PU.Plexus_User_No = C.Assigned_To
    OUTER APPLY
    (
      SELECT TOP(1)
        ARIDQ.Quantity
      FROM dbo.#xPCN AS PCN
      JOIN dbo.#ARID_Quantity AS ARIDQ
        ON ARIDQ.PCN = ID.PCN
        AND ARIDQ.Invoice_Link = ID.Invoice_Link
        AND ARIDQ.Shipper_Line_Key = ISNULL(ID.Shipper_Line_Key, 0)
        AND ARIDQ.Part_Key = ID.Part_Key
        AND (@Report NOT LIKE '%Raw' OR ARIDQ.Line_Item_No = ID.Line_Item_No) 
      ORDER BY
        ARIDQ.Discount,
        ARIDQ.Account_No
    ) AS Q
    OUTER APPLY
    (
      -- for anything without part/SL, see if there is precisely 1 invoice dist that does have this info
      SELECT TOP(1)
        CASE WHEN PC.Part_Count = 0 AND @Surcharge_Part_No = 1 THEN AID1.Part_Key ELSE NULL END AS [Part_Key],
        CASE WHEN PC.Part_Count = 0 AND @Surcharge_Part_No = 1 THEN AID1.Shipper_Line_Key ELSE NULL END AS [Shipper_Line_Key],
        CPAID.Customer_Part_Key
      FROM dbo.#ARID AS AID1
      JOIN dbo.Customer_Part AS CPAID
        ON CPAID.Plexus_Customer_No = ID.PCN
        AND CPAID.Customer_No = ID.Customer_No
        AND CPAID.Part_Key = AID1.Part_Key
      CROSS APPLY
      (
        SELECT
          COUNT(*) AS Part_Count
        FROM dbo.#ARID AS AID2
        WHERE AID2.PCN = AID1.PCN
          AND AID2.Invoice_Link = AID1.Invoice_Link
          AND AID2.Part_Key > 0
          AND AID2.Part_Key != AID1.Part_Key
      ) AS PC
      WHERE AID1.PCN = ID.PCN
        AND ID.Part_Key IS NULL
        AND AID1.Part_Key > 0
        AND AID1.Invoice_Link = ID.Invoice_Link
    ) AS P1
    OUTER APPLY
    (
      SELECT TOP(1)
        SL.Shipper_Line_Key,
        CASE WHEN @Surcharge_Part_No = 1 THEN SL.Part_Key ELSE NULL END AS Part_Key,
        SL.Customer_Part_Key,
        SL.Order_No,
        SL.PO_No,
        SL.PO_Type_Key,
        SL.Unit,
        SL.Customer_Address_Code,
        SL.Piece_Weight,
        SL.Inv_Unit,
        SL.Net_Weight,
        SL.Conversion,
        SL.Ship_From,
        SL.Quantity
      FROM dbo.#xPCN AS PCN
      JOIN dbo.#Shipper_Line AS SL
        ON SL.PCN = PCN.PCN
        AND SL.Shipper_Line_Key = ISNULL(ID.Shipper_Line_Key, P1.Shipper_Line_Key)
    ) AS SL1
    LEFT OUTER JOIN dbo.Part AS P
      ON P.Plexus_Customer_No = ID.PCN
      AND P.Part_Key = COALESCE(ID.Part_Key, SL1.Part_Key, P1.Part_Key)
    LEFT OUTER JOIN dbo.Part_Attributes AS PTA
      ON PTA.PCN = P.Plexus_Customer_No
      AND PTA.Part_Key = P.Part_Key
    LEFT OUTER JOIN dbo.#Department AS D
      ON D.PCN = PTA.PCN
      AND D.Department_No = PTA.Department_No
    LEFT OUTER JOIN dbo.#Part_Type AS PAT
      ON PAT.Part_Type = P.Part_Type
    LEFT OUTER JOIN dbo.#Part_Group AS PG
      ON PG.PCN = P.Plexus_Customer_No
      AND PG.Part_Group_Key = P.Part_Group_Key
    LEFT OUTER JOIN dbo.#Customer_Category AS CC
      ON CC.PCN = C.Plexus_Customer_No
      AND CC.Customer_Category_Key = C.Customer_Category_Key
    LEFT OUTER JOIN dbo.#Part_Source AS PS
      ON PS.PCN = P.Plexus_Customer_No
      AND PS.Part_Source_Key = P.Part_Source_Key
    LEFT OUTER JOIN dbo.Part_Product_Type AS PPT
      ON PPT.PCN = P.Plexus_Customer_No
      AND PPT.Product_Type_Key = P.Product_Type_Key
    LEFT OUTER JOIN dbo.#Part_Product_Type AS PPT2
      ON PPT2.PCN = PPT.PCN
      AND PPT2.Product_Type_Key = PPT.Product_Type_Key
    LEFT OUTER JOIN dbo.Master_Part AS MP
      ON MP.PCN = P.Plexus_Customer_No
      AND MP.Part_Key = P.Part_Key
    LEFT OUTER JOIN dbo.[Master] AS M
      ON M.PCN = MP.PCN
      AND M.Master_Key = MP.Master_Key
    LEFT OUTER JOIN dbo.#Master AS M2
      ON M2.PCN = M.PCN
      AND M2.Master_Key = M.Master_Key
    LEFT OUTER JOIN dbo.#Part_Status AS PS2
      ON PS2.PCN = P.Plexus_Customer_No
      AND PS2.Part_Status = P.Part_Status
    OUTER APPLY
    (
      SELECT TOP(1)
        POT2.PO_Type
      FROM dbo.#xPCN AS PCN
      JOIN dbo.#PO_Type AS POT2
        ON POT2.PCN = PCN.PCN
        AND (POT2.PO_Type_Key = SL1.PO_Type_Key OR POT2.PO_Type_Key = ID.PO_Type_Key)
      ORDER BY
        CASE WHEN POT2.PO_Type_Key = SL1.PO_Type_Key THEN 0 ELSE 1 END
    ) AS POT3
    WHERE (@Customer_Code IS NULL OR C.Customer_Code LIKE @Customer_Code)
      AND C.Customer_Type = ISNULL(@Customer_Type, C.Customer_Type)
      AND (@Salesperson IS NULL OR PU.Plexus_User_No = @Salesperson)
      AND (ISNULL(@Department_No, '') = '' OR D.Department_No IS NOT NULL)
      AND (@Part_No IS NULL OR P.Part_No LIKE @Part_No + '%'
        OR 
        CASE
          WHEN P.Revision = '' THEN P.Part_No
          ELSE P.Part_No + @Separator + P.Revision
        END LIKE @Part_No + '%')
      AND (ISNULL(@Part_Types, '') = '' OR PAT.Part_Type IS NOT NULL)
      AND (ISNULL(@Part_Group_Keys, '') = '' OR PG.Part_Group IS NOT NULL)
      AND (ISNULL(@PO_Type_Keys, '') = '' OR POT3.PO_Type IS NOT NULL)
      AND (ISNULL(@Customer_Category_Keys, '') = '' OR CC.Customer_Category IS NOT NULL)
      AND (ISNULL(@Part_Source_Keys, '') = '' OR PS.Part_Source_Key IS NOT NULL)
      AND (@Part_Product_Type_Key = '' OR PPT2.Product_Type_Key IS NOT NULL)
      AND (ISNULL(@Ship_To, '') = '' OR SL1.Customer_Address_Code LIKE @Ship_To + '%')
      AND (@Ship_From_Keys = '' OR CHARINDEX (',' + CAST(SL1.Ship_From AS VARCHAR(10)) + ',', ',' + @Ship_From_Keys + ',') > 0)
      --AND (@Ship_From IS NULL OR SL1.Ship_From = @Ship_From)
      AND (@Non_Part_Invoices = 1 OR P.Part_Key > 0)
      AND (ISNULL(@Customer_Parent_Key, 0) = 0 OR CP.Customer_Parent_Key = @Customer_Parent_Key)
      AND ((NULLIF(@Customer_Parent_Code, '') IS NULL) OR CP.Customer_Parent_Code = @Customer_Parent_Code)
      AND (ISNULL(@Part_Status, '') = '' OR PS2.Part_Status IS NOT NULL)
      AND (ISNULL(@Master_Keys, '') = '' OR M2.Master_Key IS NOT NULL)
      AND NOT EXISTS
      (
        SELECT
          *
        FROM Common.dbo.Customer_Link AS CL  WITH (FORCESEEK (PK_Customer_Link (PCN, Customer_No)))
        WHERE @Intercompany_Credit_Memos = 0
          AND CL.PCN = ID.PCN
          AND CL.Customer_No = ID.Customer_No
          AND CL.Inter_Company = 1
          AND ID.Shipper_Line_Key IS NULL
      )
  ) AS AR
  LEFT OUTER JOIN dbo.Customer_Part AS CP
    ON CP.Plexus_Customer_No = AR.PCN
    AND CP.Customer_Part_Key = AR.Customer_Part_Key
  LEFT OUTER JOIN dbo.Customer_Part_Product_Type AS CPPT
    ON CPPT.PCN = CP.Plexus_Customer_No
    AND CPPT.Product_Type_Key = CP.Product_Type_Key
  LEFT OUTER JOIN dbo.#Customer_Part_Product_Type AS CPPT2
    ON CPPT2.PCN = CPPT.PCN
    AND CPPT2.Product_Type_Key = CPPT.Product_Type_Key
  WHERE (@Product_Type_Key = '' OR CPPT2.Product_Type_Key IS NOT NULL)
  GROUP BY
    AR.PCN,
    AR.Customer_Code,
    AR.Customer_Category,
    AR.Customer_Type,
    AR.Salesperson,
    AR.Order_No,
    AR.PO_No,
    AR.Invoice_No,
    AR.Part_Key,
    AR.Part_No,
    AR.Part_Description,
    CPPT.Product_Type,
    AR.Product_Type,
    AR.Part_Source,
    AR.Sales_Qty,
    AR.Sales_Unit,
    AR.Revenue,
    AR.Part_Group,
    AR.Part_Type,
    AR.Conversion,
    AR.Shipper_Line_Key,
    --AR.Quantity, -- US 110444: don't repeat quantities
    AR.Inv_Unit,
    AR.Net_Weight,
    AR.PO_Type,
    AR.Invoice_Part_Key,
    AR.Piece_Weight,
    AR.Line_Item_No,
    AR.Revision,
    CP.Customer_Part_No,
    CP.Customer_Part_Revision,
    AR.Master_No
) AS T
LEFT OUTER JOIN Sales.dbo.Shipper_Line AS SL
  ON @Report LIKE 'Sequence%'
  AND SL.PCN = T.PCN
  AND SL.Shipper_Line_Key = T.Shipper_Line_Key
LEFT OUTER JOIN dbo.Production_Batch AS PB
  ON PB.PCN = SL.PCN
  AND PB.Production_Batch_Key = SL.Production_Batch_Key
LEFT OUTER JOIN dbo.Production_Batch_Detail AS PBD WITH (INDEX (IX_FK_Production_Batch_Detail_Production_Batch))
  ON PBD.PCN = PB.PCN
  AND PBD.Production_Batch_Key = PB.Production_Batch_Key
GROUP BY
  T.PCN,
  T.Customer_Code,
  T.Customer_Category,
  T.Customer_Type,
  T.Salesperson,
  T.Order_No,
  T.PO_No,
  T.Invoice_No,
  T.Part_Key,
  T.Part_No,
  T.Part_Description,
  T.Product_Type,
  T.Part_Source,
  T.Part_Group,
  T.Part_Type,
  CASE WHEN @PO_Type_Column = 1 THEN T.PO_Type ELSE '' END,
  T.Quantity_Unit,
  T.Sales_Unit,
  --T.Net_Weight,
  T.Line_Item_No,
  T.Revision,
  T.Customer_Part_No,
  T.Customer_Part_Revision,
  PBD.Production_Batch_Detail_Key,
  PBD.Sequence_No,
  PBD.Delivery_Quantity,
  T.Master_No
 OPTION(FORCE ORDER, RECOMPILE);

IF @Report LIKE 'Part%'
BEGIN
  INSERT dbo.#cgm_qty
  (
    PCN,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Part_Key,
    Part_No,
    Part_Description,
    Product_Type,
    Part_Source,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    T.PCN,
    NULL AS Customer_Code,
    NULL AS Customer_Category,
    NULL AS Customer_Type,
    NULL AS Salesperson,
    NULL AS Order_No,
    NULL AS PO_No,
    NULL Invoice_No,
    T.Part_Key,
    T.Part_No,
    T.Part_Description,
    T.Product_Type,
    T.Part_Source,
    SUM(T.Quantity),
    T.Quantity_Unit,
    SUM(T.Sales_Qty) AS Sales_Qty,
    T.Sales_Unit,
    SUM(T.Revenue) / NULLIF(SUM(T.Sales_Qty), 0.0) AS Unit_Price,
    SUM(T.Revenue) AS Revenue,
    NULL AS Shipper_Line_Key,
    T.Part_Group,
    T.Part_Type,
    T.PO_Type,
    SUM(T.Net_Weight),
    T.Part_Revision,
    T.Customer_Part_No,
    T.Customer_Part_Revision,
    T.Sequence_No,
    T.Master_No
  FROM dbo.#cgm_all AS T
  WHERE T.Part_Key > 0
  GROUP BY
    T.PCN,
    T.Part_Key,
    T.Part_No,
    T.Part_Description,
    T.Product_Type,
    T.Part_Source,
    T.Part_Group,
    T.Part_Type,
    T.PO_Type,
    T.Quantity_Unit,
    T.Sales_Unit,
    T.Part_Revision,
    T.Customer_Part_No,
    T.Customer_Part_Revision,
    T.Sequence_No,
    T.Master_No;
END
ELSE IF @Report LIKE 'Customer%'
BEGIN
  INSERT dbo.#cgm_qty
  (
    PCN,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Part_Key,
    Part_No,
    Part_Description,
    Product_Type,
    Part_Source,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    T.PCN,
    T.Customer_Code,
    T.Customer_Category,
    T.Customer_Type,
    NULL AS Salesperson,
    NULL AS Order_No,
    NULL AS PO_No,
    NULL Invoice_No,
    T.Part_Key,
    T.Part_No,
    T.Part_Description,
    T.Product_Type,
    T.Part_Source,
    SUM(T.Quantity),
    T.Quantity_Unit,
    SUM(T.Sales_Qty) AS Sales_Qty,
    T.Sales_Unit,
    SUM(T.Revenue) / NULLIF(SUM(T.Sales_Qty), 0.0) AS Unit_Price,
    SUM(T.Revenue) AS Revenue,
    NULL AS Shipper_Line_Key,
    T.Part_Group,
    T.Part_Type,
    T.PO_Type,
    SUM(T.Net_Weight),
    T.Part_Revision,
    T.Customer_Part_No,
    T.Customer_Part_Revision,
    T.Sequence_No,
    T.Master_No
  FROM dbo.#cgm_all AS T
  WHERE T.Part_Key > 0
    OR  T.Customer_Code IS NOT NULL
  GROUP BY
    T.PCN,
    T.Customer_Code,
    T.Customer_Category,
    T.Customer_Type,
    T.Part_Key,
    T.Part_No,
    T.Part_Description,
    T.Product_Type,
    T.Part_Source,
    T.Part_Group,
    T.Part_Type,
    T.PO_Type,
    T.Quantity_Unit,
    T.Sales_Unit,
    T.Part_Revision,
    T.Customer_Part_No,
    T.Customer_Part_Revision,
    T.Sequence_No,
    T.Master_No;
END
ELSE IF @Report LIKE 'Sequence%'
BEGIN
  INSERT dbo.#cgm_qty
  (
    PCN,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Part_Key,
    Part_No,
    Part_Description,
    Product_Type,
    Part_Source,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    T.PCN,
    NULL AS Customer_Code,
    NULL AS Customer_Category,
    NULL AS Customer_Type,
    NULL AS Salesperson,
    NULL AS Order_No,
    NULL AS PO_No,
    NULL AS Invoice_No,
    T.Part_Key AS Part_Key,
    NULL AS Part_No,
    NULL AS Part_Description,
    NULL AS Product_Type,
    NULL AS Part_Source,
    SUM(T.Quantity),
    NULL AS Quantity_Unit,
    SUM(T.Sales_Qty) AS Sales_Qty,
    NULL AS Sales_Unit,
    SUM(T.Revenue) / NULLIF(SUM(T.Sales_Qty), 0.0) AS Unit_Price,
    SUM(T.Revenue) AS Revenue,
    NULL AS Shipper_Line_Key,
    NULL AS Part_Group,
    NULL AS Part_Type,
    NULL AS PO_Type,
    SUM(T.Net_Weight),
    NULL AS Part_Revision,
    NULL AS Customer_Part_No,
    NULL AS Customer_Part_Revision,
    T.Sequence_No,
    NULL AS Master_No
  FROM dbo.#cgm_all AS T
  WHERE T.Part_Key > 0
  GROUP BY
    T.PCN,
    T.Part_Key,
    T.Sequence_No;
END
ELSE
BEGIN
  INSERT dbo.#cgm_qty
  (
    PCN,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Line_Item_No,
    Part_Key,
    Part_No,
    Part_Description,
    Product_Type,
    Part_Source,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    CGM.PCN,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Part_Description,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Quantity,
    CGM.Quantity_Unit,
    CGM.Sales_Qty,
    CGM.Sales_Unit,
    CGM.Unit_Price,
    CGM.Revenue,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No
  FROM dbo.#cgm_all AS CGM;
END;

-- percent report
IF @Report LIKE 'Quantity_RAW'
BEGIN
  SELECT
    CGM.Customer_Code,
    CGM.Part_Key,
    CGM.Invoice_No,
    CGM.Quantity,
    CGM.Revenue AS Price,
    CGM.Line_Item_No
  FROM dbo.#cgm_qty AS CGM;
  
  DROP TABLE dbo.#ARID;
  DROP TABLE dbo.#cgm;
  DROP TABLE dbo.#cgm2;
  DROP TABLE dbo.#cgm_all;
  DROP TABLE dbo.#cgm_qty;
  DROP TABLE dbo.#Part_Type;
  DROP TABLE dbo.#Part_Group;
  DROP TABLE dbo.#Part_Source;
  DROP TABLE dbo.#Customer_Category;
  DROP TABLE dbo.#PO_Type;
  DROP TABLE dbo.#CSTB;
  DROP TABLE dbo.#Shipper_Line;
  DROP TABLE dbo.#PCN;
  DROP TABLE dbo.#xPCN;
  DROP TABLE dbo.#ARID_Quantity;
  DROP TABLE dbo.#Part_Group_Split;
  DROP TABLE dbo.#Part_Product_Type;
  DROP TABLE dbo.#Customer_Part_Product_Type;
  DROP TABLE dbo.#Master;
  DROP TABLE dbo.#Part_Status;
  DROP TABLE dbo.#Department;
  RETURN;
END;
--#endregion

--#region Standard costing
-- Build a CSTB temp table.
INSERT dbo.#CSTB
(
  PCN,
  Cost_Model_Key,
  Part_Key,
  Part_Operation_Key,
  Cost_Sub_Type_Key,
  Cost,
  Cost_Type,
  Cost_Sub_Type,
  CT_Sort_Order,
  CST_Sort_Order
)
SELECT
  PCN.PCN,
  PCN.Cost_Model_Key,
  CSTBH2.Part_Key,
  CSTBH2.Part_Operation_Key,
  CSTBH2.Cost_Sub_Type_Key,
  CSTBH2.Cost,
  CT.Cost_Type,
  CST.Cost_Sub_Type,
  CT.Sort_Order AS CT_Sort_Order,
  CST.Sort_Order AS CST_Sort_Order
FROM dbo.#PCN AS PCN
JOIN dbo.Snapshot_Cost_Sub_Type_Breakdown AS SCSTB
  ON SCSTB.PCN = PCN.PCN
  AND SCSTB.Snapshot_Key = PCN.Snapshot_Key
JOIN dbo.Cost_Sub_Type_Breakdown_History AS CSTBH2
  ON CSTBH2.PCN = PCN.PCN
  AND CSTBH2.Cost_Model_Key = PCN.Cost_Model_Key
  AND CSTBH2.Change_Key = SCSTB.Change_Key
JOIN Common.dbo.Cost_Sub_Type AS CST
  ON CST.PCN = CSTBH2.PCN
  AND CST.Cost_Sub_Type_Key = CSTBH2.Cost_Sub_Type_Key
JOIN Common.dbo.Cost_Type AS CT
  ON CT.PCN = CST.PCN
  AND CT.Cost_Type_Key = CST.Cost_Type_Key
WHERE PCN.Snapshot_Key > 0
  AND NOT CSTBH2.Cost = 0.0
  AND (ISNULL(CT.Valuation_Column, 1) = 1)
  AND (ISNULL(CT.COGS_Column, 0) = @COGS_Column)
  AND CST.Cost_Of_Goods_Sold = 1
OPTION (FORCE ORDER);

UPDATE U -- UPDATE dbo.#CSTB
SET
  U.Part_Operation_History_Key = CA.Part_Operation_History_Key
FROM dbo.#CSTB AS U
CROSS APPLY
(
  SELECT TOP(1)
    PO.Part_Operation_History_Key
  FROM dbo.Part_Operation_History AS PO
  WHERE PO.PCN = U.PCN
    AND PO.Part_Key = U.Part_Key
    AND PO.Part_Operation_Key = U.Part_Operation_Key
    AND PO.Change_Date <= @Cost_Model_Date
  ORDER BY
    PO.Change_Date DESC
) AS CA;

DELETE D -- DELETE dbo.#CSTB
FROM dbo.#CSTB AS D
WHERE Part_Operation_History_Key IS NULL;

INSERT dbo.#CSTB
(
  PCN,
  Cost_Model_Key,
  Part_Key,
  Part_Operation_Key,
  Cost_Sub_Type_Key,
  Cost,
  Cost_Type,
  Cost_Sub_Type,
  CT_Sort_Order,
  CST_Sort_Order
)
SELECT
  CSTBH2.PCN,
  CSTBH2.Cost_Model_Key,
  CSTBH2.Part_Key,
  CSTBH2.Part_Operation_Key,
  CSTBH2.Cost_Sub_Type_Key,
  CSTBH2.Cost,
  CT.Cost_Type,
  CST.Cost_Sub_Type,
  CT.Sort_Order AS CT_Sort_Order,
  CST.Sort_Order AS CST_Sort_Order
FROM dbo.#PCN AS PCN
JOIN dbo.Cost_Sub_Type_Breakdown AS CSTBH2
  ON CSTBH2.PCN = PCN.PCN
  AND CSTBH2.Cost_Model_Key = PCN.Cost_Model_Key
JOIN Common.dbo.Cost_Sub_Type AS CST
  ON CST.PCN = CSTBH2.PCN
  AND CST.Cost_Sub_Type_Key = CSTBH2.Cost_Sub_Type_Key
JOIN Common.dbo.Cost_Type AS CT
  ON CT.PCN = CST.PCN
  AND CT.Cost_Type_Key = CST.Cost_Type_Key
WHERE PCN.Snapshot_Key IS NULL
  AND NOT CSTBH2.Cost = 0.0
  AND (ISNULL(CT.Valuation_Column, 1) = 1)
  AND (ISNULL(CT.COGS_Column, 0) = @COGS_Column)
  AND CST.Cost_Of_Goods_Sold = 1;

IF @Include LIKE '%Scrap%'
BEGIN
  DECLARE
    @Shipped_Status INT,
    @Use_Shipped_Quantity BIT;

  SELECT
    @Shipped_Status = SS.Shipper_Status_Key
  FROM Sales.dbo.Shipper_Status AS SS
  WHERE SS.PCN = @PCN
    AND SS.Shipper_Status = 'Shipped';

  EXEC Plexus_Control.dbo.Customer_Setting_Get2
    @PCN,
    'Gross Margin Report',
    'Shipped Quantity For Scrap Calculation Use',
    @Use_Shipped_Quantity OUTPUT;

  INSERT dbo.#cgm
  (
    PCN,
    Gross_Margin_Key,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Line_Item_No,
    Part_Key,
    Part_No,
    Product_Type,
    Part_Source,
    Part_Description,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Cost,
    Ext_Cost,
    Cost_Column,
    Cost_Type,
    Cost_Sub_Type,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Production_Qty,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT DISTINCT
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    SUM(CGM.Quantity),
    CGM.Quantity_Unit,
    SUM(CGM.Sales_Qty),
    CGM.Sales_Unit,
    CGM.Unit_Price,
    SUM(CGM.Revenue),
    (CAS.Scrap_Cost / NULLIF(CASE WHEN @Use_Shipped_Quantity = 1 THEN CASH.Quantity ELSE CAP.Quantity END, 0)) as Cost,
    (SUM(CGM.Quantity) * ROUND(CAS.Scrap_Cost / NULLIF(CASE WHEN @Use_Shipped_Quantity = 1 THEN CASH.Quantity ELSE CAP.Quantity END, 0), 5)) AS Ext_Cost,
    'Scrap / ',
    'Scrap',
    '',
    999 AS Cost_Type_Order,
    0 AS Cost_Sub_Type_Order,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    SUM(CGM.Net_Weight) AS Net_Weight,
    CAP.Quantity,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No
  FROM dbo.#cgm_qty AS CGM
  CROSS APPLY
  (
    SELECT
      SUM(S.Quantity * CSTBH.Cost) AS Scrap_Cost
    FROM dbo.Scrap AS S
    OUTER APPLY
    (
      SELECT
        SUM(CSTBH1.Cost) AS Cost
      FROM dbo.#CSTB AS CSTBH1
      WHERE CSTBH1.Part_Key = S.Part_Key
        AND CSTBH1.Part_Operation_Key = S.Part_Operation_Key
    ) AS CSTBH
    WHERE S.Plexus_Customer_No = CGM.PCN
      AND S.Part_Key = CGM.Part_Key
      -- tborowsky: Changed the date range filter formatting to better match standards. Left the @End_Date as inclusive to maintain functionality.
      AND S.Scrap_Date >= @Begin_Date
      AND S.Scrap_Date <= @End_Date
  ) AS CAS
  CROSS APPLY
  (
    SELECT
      SUM(S.Quantity) AS Quantity
    FROM dbo.Production AS S
    WHERE S.Plexus_Customer_No = CGM.PCN
      AND S.Part_Key = CGM.Part_Key
      -- tborowsky: Changed the date range filter formatting to better match standards. Left the @End_Date as inclusive to maintain functionality.
      AND S.Record_Date >= @Begin_Date
      AND S.Record_Date <= @End_Date
  ) AS CAP
  CROSS APPLY
  (
    SELECT
      SUM(SC.Quantity) AS Quantity
    FROM
    (
      SELECT
        SL.Shipper_Line_Key
      FROM Sales.dbo.Shipper AS S
      JOIN Sales.dbo.Shipper_Line AS SL
        ON SL.PCN = S.PCN
        AND SL.Shipper_Key = S.Shipper_Key
        AND SL.Part_Key = CGM.Part_Key
      JOIN Part.dbo.Part AS P
        ON P.Plexus_Customer_No = SL.PCN
        AND P.Part_Key = SL.Part_Key
      WHERE S.PCN = CGM.PCN
        AND S.Shipper_Status_Key = @Shipped_Status
        --tborowsky: Removed equality checks on dates for being equal to ''. Left the @End_Date as inclusive to maintain functionality. 
        AND S.Ship_Date >= @Begin_Date
        AND S.Ship_Date <= @End_Date
    ) AS SL
    JOIN Sales.dbo.Shipper_Container AS SC
      ON SC.PCN = CGM.PCN
      AND SC.Shipper_Line_Key = SL.Shipper_Line_Key
  ) AS CASH
  LEFT OUTER JOIN
  (
    SELECT
      CSTBH1.Part_Key,
      SUM(CSTBH1.Cost) AS Cost
    FROM dbo.#CSTB AS CSTBH1
    GROUP BY
      CSTBH1.Part_Key
  ) AS CSTBH
    ON CSTBH.Part_Key = CGM.Part_Key
  GROUP BY
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Unit_Price,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Quantity_Unit,
    CGM.Sales_Unit,
    CAS.Scrap_Cost,
    CAP.Quantity,
    CASH.Quantity,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No;
END;

DELETE D -- DELETE dbo.#CSTB
FROM dbo.#CSTB AS D
JOIN dbo.Part_Operation_History AS POH
  ON POH.PCN = D.PCN
  AND POH.Part_Operation_History_Key = D.Part_Operation_History_Key
JOIN dbo.Part_Op_Type AS POT
  ON POT.PCN = POH.PCN
  AND POT.Part_Op_Type_Key = POH.Part_Op_Type_Key
WHERE NOT
(
  POH.Active = 1
  AND POH.Suboperation = 0
  AND POT.[Standard] = 1
  AND POT.Rework = 0
);

DELETE D -- DELETE dbo.#CSTB
FROM dbo.#CSTB AS D
CROSS APPLY
(
  SELECT TOP(1)
    C.Part_Operation_Key
  FROM dbo.#CSTB AS C
  JOIN dbo.Part_Operation_History AS POH
    ON POH.PCN = C.PCN
    AND POH.Part_Operation_History_Key = C.Part_Operation_History_Key
  WHERE C.Part_Key = D.Part_Key
  ORDER BY
    POH.Operation_No DESC
) AS CA1
WHERE D.Part_Operation_Key != CA1.Part_Operation_Key
OPTION (MAXDOP 4);
  
DELETE CSTB -- DELETE dbo.#CSTB
FROM 
(
  SELECT DISTINCT
    C.PCN,
    C.Part_Key
  FROM dbo.#CSTB AS C
) AS C2
OUTER APPLY
(
  SELECT TOP(1)
    PO.Plexus_Customer_No AS PCN,
    PO.Part_Key,
    PO.Part_Operation_Key
  FROM dbo.Part_Operation AS PO
  JOIN dbo.Part_Op_Type AS POT
    ON POT.PCN = PO.Plexus_Customer_No
    AND POT.Part_Op_Type_Key = PO.Part_Op_Type_Key
  WHERE PO.Plexus_Customer_No = C2.PCN
    AND PO.Part_Key = C2.Part_Key
    AND PO.Active = 1
    AND PO.Suboperation = 0
    AND POT.[Standard] = 1
    AND POT.Rework = 0
  ORDER BY
    PO.Operation_No DESC
) AS CA
JOIN dbo.#CSTB AS CSTB
  ON CSTB.PCN = C2.PCN
  AND CSTB.Part_Key = C2.Part_Key
  AND (CSTB.Part_Operation_Key != CA.Part_Operation_Key OR CA.PCN IS NULL)
  AND CSTB.Part_Operation_History_Key IS NULL
OPTION(FORCE ORDER);

IF @Actual_Labor = 1
BEGIN
  DECLARE
    @Labor_Cost_Sub_Type_Key INT;

  SELECT TOP(1)
    @Labor_Cost_Sub_Type_Key = CST.Cost_Sub_Type_Key
  FROM Common.dbo.Cost_Sub_Type AS CST
  WHERE CST.PCN = @PCN
    AND CST.Direct_Labor = 1
    AND CST.Indirect_Labor = 0
  ORDER BY
    CST.Production_Cost DESC,
    CST.Setup_Cost; -- ASC
     
  UPDATE CSTB -- UPDATE dbo.#CSTB
  SET 
    CSTB.Cost = CGM2.Cost
  FROM
  (
    SELECT
      CGM.Part_Key,
      CGM.Part_Operation_Key,
      SUM(CA.Ext_Cost) / SUM(CGM.Quantity) AS Cost
    FROM
    (
      SELECT DISTINCT
        SL.PCN,
        C.Serial_No,
        C.Part_Key,
        C.Part_Operation_Key,
        C.Quantity
      FROM dbo.#Shipper_Line AS SL
      JOIN Sales.dbo.Shipper_Container AS SC
        ON SC.PCN = SL.PCN
        AND SC.Shipper_Line_Key = SL.Shipper_Line_Key
      JOIN dbo.Container AS C
        ON C.Plexus_Customer_No = SC.PCN
        AND C.Serial_No = SC.Serial_No
      JOIN dbo.Part AS P WITH (INDEX (IX_Key_Type_Group_Grade))
        ON P.Plexus_Customer_No = C.Plexus_Customer_No
        AND P.Part_Key = C.Part_Key
      WHERE (ISNULL(@Part_No, '') = '' OR P.Part_No LIKE @Part_No + '%'
        OR CASE
          WHEN P.Revision = '' THEN P.Part_No
          ELSE P.Part_No + @Separator + P.Revision
        END LIKE @Part_No + '%')
    ) AS CGM
    JOIN
    (
      SELECT
        CC.PCN,
        CC.Serial_No,
        SUM(CC.Extended_Cost) AS Ext_Cost
      FROM Common.dbo.Cost AS CC
      JOIN Common.dbo.System_Cost_Point AS SCP
        ON SCP.Cost_Point_Key = CC.Cost_Point_Key
        AND SCP.Value_Add = 1
      WHERE CC.Cost_Sub_Type_Key = @Labor_Cost_Sub_Type_Key
      GROUP BY
        CC.PCN,
        CC.Serial_No
    ) AS CA
      ON CA.PCN = CGM.PCN
      AND CA.Serial_No = CGM.Serial_No
    GROUP BY
      CGM.Part_Key,
      CGM.Part_Operation_Key
  ) AS CGM2
  JOIN dbo.#CSTB AS CSTB
    ON CSTB.Part_Key = CGM2.Part_Key
    AND CSTB.Part_Operation_Key = CGM2.Part_Operation_Key
  WHERE CSTB.Cost_Sub_Type_Key = @Labor_Cost_Sub_Type_Key
  OPTION(FORCE ORDER);
END;
--#endregion

--#region Compile final result
IF @Report LIKE 'Sequence%'
BEGIN
  INSERT dbo.#cgm
  (
    PCN,
    Gross_Margin_Key,
    Unit_Price,
    Revenue,
    Cost,
    Ext_Cost,
    Cost_Column,
    Sequence_No,
    Quantity,
    Sales_Qty,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    Cost_Type,
    Cost_Sub_Type
  )
  SELECT
    CGM.PCN,
    0,
    0 AS Unit_Price,
    ST.Revenue,
    SUM(ISNULL(CSTBH.Cost, 0)) AS Cost,
    SUM(CGM.Quantity) * ROUND(ISNULL(CSTBH.Cost, 0), 5) AS Ext_Cost,
    ISNULL(CSTBH.Cost_Type + ' / ' + CSTBH.Cost_Sub_Type, ' ') AS Cost_Column,
    CGM.Sequence_No,
    ST.Quantity,
    0 AS Sales_Qty,
    ISNULL(CSTBH.CT_Sort_Order, 0) AS Cost_Type_Order,
    ISNULL(CSTBH.CST_Sort_Order, 0) AS Cost_Sub_Type_Order,
    CSTBH.Cost_Type AS Cost_Type,
    CSTBH.Cost_Sub_Type AS Cost_Sub_Type
  FROM dbo.#cgm_qty AS CGM
  LEFT OUTER JOIN dbo.#CSTB AS CSTBH
    ON CSTBH.Part_Key = CGM.Part_Key
  JOIN
  (
    SELECT
      CGM.PCN,
      CGM.Sequence_No,
      SUM(CGM.Quantity) AS Quantity,
      SUM(CGM.Revenue) AS Revenue
    FROM dbo.#cgm_qty AS CGM
    GROUP BY
      CGM.PCN,
      CGM.Sequence_No
  ) AS ST
    ON ST.PCN = CGM.PCN
    AND ST.Sequence_No = CGM.Sequence_No
  GROUP BY
    CGM.PCN,
    CGM.Sequence_No,
    CSTBH.Cost_Type,
    CSTBH.Cost_Sub_Type,
    ST.Revenue,
    ST.Quantity,
    CSTBH.Cost,
    CSTBH.CT_Sort_Order,
    CSTBH.CST_Sort_Order;
END
ELSE
BEGIN
  INSERT dbo.#cgm
  (
    PCN,
    Gross_Margin_Key,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Line_Item_No,
    Part_Key,
    Part_No,
    Product_Type,
    Part_Source,
    Part_Description,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Cost,
    Ext_Cost,
    Cost_Column,
    Cost_Type,
    Cost_Sub_Type,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT DISTINCT
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    SUM(CGM.Quantity),
    CGM.Quantity_Unit,
    SUM(CGM.Sales_Qty),
    CGM.Sales_Unit,
    CGM.Unit_Price,
    SUM(CGM.Revenue),
    (ISNULL(CSTBH.Cost, 0)) as Cost,
    (SUM(CGM.Quantity) * ROUND(ISNULL(CSTBH.Cost, 0), 5)) AS Ext_Cost,
    ISNULL(CSTBH.Cost_Type + ' / ' + CASE WHEN @Report LIKE 'Customer%' THEN '' ELSE CSTBH.Cost_Sub_Type END,' '),
    CSTBH.Cost_Type,
    CSTBH.Cost_Sub_Type,
    ISNULL(CSTBH.CT_Sort_Order, 0) AS Cost_Type_Order,
    ISNULL(CASE WHEN @Report LIKE 'Customer%' THEN 0 ELSE CSTBH.CST_Sort_Order END, 0) AS Cost_Sub_Type_Order,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    SUM(CGM.Net_Weight) AS Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No
  FROM dbo.#cgm_qty AS CGM
  LEFT OUTER JOIN dbo.#CSTB AS CSTBH
    ON CSTBH.Part_Key = CGM.Part_Key
  GROUP BY
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Unit_Price,
    CSTBH.Cost,
    CSTBH.Cost_Type,
    CSTBH.Cost_Sub_Type,
    CSTBH.CT_Sort_Order,
    CSTBH.CST_Sort_Order,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Quantity_Unit,
    CGM.Sales_Unit,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No;
END;

IF @Report NOT LIKE '%_Raw%'
BEGIN
  -- insert the totals for each shipper line
  INSERT dbo.#cgm
  (
    PCN,
    Gross_Margin_Key,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Line_Item_No,
    Part_Key,
    Part_No,
    Product_Type,
    Part_Source,
    Part_Description,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Cost,
    Ext_Cost,
    Cost_Column,
    Cost_Type,
    Cost_Sub_Type,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Quantity_Unit,
    CGM.Sales_Qty,
    CGM.Sales_Unit,
    CGM.Unit_Price,
    CGM.Revenue,
    SUM(CGM.Cost),
    --CGM.Revenue - SUM(CGM.Ext_Cost),
    SUM(CGM.Ext_Cost),
    'TOTAL',
    'TOTAL',
    '',
    999 AS Cost_Type_Order,
    999 AS Cost_Sub_Type_Order,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No
  FROM dbo.#cgm AS CGM
  GROUP BY
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Sales_Qty,
    CGM.Unit_Price,
    CGM.Revenue,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Quantity_Unit,
    CGM.Sales_Unit,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No;
    
  IF @Report LIKE 'Sequence%'
  BEGIN
    UPDATE CGM -- UPDATE dbo.#CGM
    SET
      CGM.GM_Total = A.Ext_Cost
    FROM dbo.#cgm AS CGM
    JOIN
    (
      SELECT
        CGM2.PCN,
        CGM2.Sequence_No,
        CGM2.Ext_Cost
      FROM dbo.#cgm AS CGM2
      WHERE CGM2.Cost_Type = 'TOTAL'
    ) AS A
      ON A.PCN = CGM.PCN
      AND A.Sequence_No = CGM.Sequence_No;
  END
  ELSE
  BEGIN
    UPDATE CGM -- UPDATE dbo.#CGM
    SET
      CGM.GM_Total = A.Ext_Cost
    FROM dbo.#cgm AS CGM
    JOIN
    (
      SELECT
        CGM2.PCN,
        CGM2.Gross_Margin_Key,
        CGM2.Ext_Cost
      FROM dbo.#cgm AS CGM2
      WHERE CGM2.Cost_Type = 'TOTAL'
    ) AS A
      ON A.PCN = CGM.PCN
      AND A.Gross_Margin_Key = CGM.Gross_Margin_Key;
  END;
END;
  
IF @Include_Derived_Columns = 1 AND @Report NOT LIKE '%_Raw'
BEGIN
  INSERT dbo.#cgm
  (
    PCN,
    Gross_Margin_Key,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Line_Item_No,
    Part_Key,
    Part_No,
    Product_Type,
    Part_Source,
    Part_Description,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Cost,
    Ext_Cost,
    Cost_Column,
    Cost_Type,
    Cost_Sub_Type,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Quantity_Unit,
    CGM.Sales_Qty,
    CGM.Sales_Unit,
    CGM.Unit_Price,
    CGM.Revenue,
    SUM(CGM.Cost),
    ROUND(CGM.Revenue - SUM(ISNULL(CGM.Ext_Cost, 0)), 2),
    --SUM(CGM.Ext_Cost),
    'Gross Margin',
    'Gross Margin',
    '',
    997 AS Cost_Type_Order,
    997 AS Cost_Sub_Type_Order,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No
  FROM dbo.#cgm AS CGM
  WHERE CGM.Cost_Column = 'TOTAL'
  GROUP BY
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Sales_Qty,
    CGM.Unit_Price,
    CGM.Revenue,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Quantity_Unit,
    CGM.Sales_Unit,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No;
    
  INSERT dbo.#cgm
  (
    PCN,
    Gross_Margin_Key,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Invoice_No,
    Line_Item_No,
    Part_Key,
    Part_No,
    Product_Type,
    Part_Source,
    Part_Description,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Unit_Price,
    Revenue,
    Cost,
    Ext_Cost,
    Cost_Column,
    Cost_Type,
    Cost_Sub_Type,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    Shipper_Line_Key,
    Part_Group,
    Part_Type,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No
  )
  SELECT
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Quantity_Unit,
    CGM.Sales_Qty,
    CGM.Sales_Unit,
    CGM.Unit_Price,
    CGM.Revenue,
    SUM(CGM.Cost),
    ROUND(100 * (CGM.Revenue - SUM(CGM.Ext_Cost)) / ISNULL(NULLIF(CGM.Revenue, 0), 1), 2),
    --SUM(CGM.Ext_Cost),
    'Percent of Revenue',
    'Percent of Revenue',
    '',
    998 AS Cost_Type_Order,
    998 AS Cost_Sub_Type_Order,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No
  FROM dbo.#cgm AS CGM
  WHERE CGM.Cost_Column = 'Total'
  GROUP BY
    CGM.PCN,
    CGM.Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    CGM.Line_Item_No,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Sales_Qty,
    CGM.Unit_Price,
    CGM.Revenue,
    CGM.Shipper_Line_Key,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Quantity_Unit,
    CGM.Sales_Unit,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No;
END;

IF @Report LIKE '%_Raw'
BEGIN
  IF @Report LIKE 'Customer%'
  BEGIN
    UPDATE dbo.#cgm 
    SET 
      Cost_Column = REPLACE(Cost_Column, ' / ', '');
  END
  ELSE
  BEGIN
    UPDATE dbo.#cgm 
    SET 
      Cost_Column = REPLACE(Cost_Column, ' / ', '<BR>');
  END;
END;

IF @Report LIKE 'SGA%'
BEGIN
  DECLARE
    @PercMult SMALLINT;
  SET
    @PercMult = 1;
  IF @Include_Derived_Columns = 1
  BEGIN
    SET
      @PercMult = 100;
  END;

  INSERT dbo.#cgm2
  (
    PCN,
    Part_Key,
    Part_No,
    Product_Type,
    Part_Source,
    Part_Description,
    Customer_Code,
    Customer_Category,
    Customer_Type,
    Salesperson,
    Order_No,
    PO_No,
    Shipper_Line_Key,
    Quantity,
    Quantity_Unit,
    Sales_Qty,
    Sales_Unit,
    Cost,
    Ext_Cost,
    Cost_Column,
    Cost_Type_Order,
    Cost_Sub_Type_Order,
    AR_Unit_Price,
    Revenue,
    Invoice_No,
    Part_Type,
    Part_Group,
    PO_Type,
    Net_Weight,
    Part_Revision,
    Customer_Part_No,
    Customer_Part_Revision,
    Sequence_No,
    Master_No,
    GM_Total
  )
  SELECT
    CGM.PCN,
    CGM.Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Shipper_Line_Key,
    CGM.Quantity,
    CGM.Quantity_Unit,
    CGM.Sales_Qty,
    CGM.Sales_Unit,
    CGM.Cost,
    CGM.Ext_Cost,
    CGM.Cost_Column,
    CGM.Cost_Type_Order,
    CGM.Cost_Sub_Type_Order,
    CGM.Unit_Price,
    CGM.Revenue,
    CGM.Invoice_No,
    CGM.Part_Type,
    CGM.Part_Group,
    CGM.PO_Type,
    CGM.Net_Weight,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No,
    CGM.GM_Total
  FROM dbo.#cgm AS CGM
  WHERE (CGM.Cost_Type_Order = 999 AND CGM.Cost_Sub_Type_Order = 999);

  UPDATE CGM -- UPDATE dbo.#cgm2
  SET
    CGM.Unit_Price = PR.Price,
    CGM.Sales_Unit = PR.Unit
  FROM dbo.#cgm2 AS CGM
  JOIN Sales.dbo.Shipper_Line AS SL
    ON SL.PCN = CGM.PCN
    AND SL.Shipper_Line_Key = CGM.Shipper_Line_Key
  JOIN Sales.dbo.Release AS R
    ON R.PCN = SL.PCN
    AND R.Release_Key = SL.Release_Key
  JOIN Sales.dbo.PO_Line AS POL
    ON POL.PCN = R.PCN
    AND POL.PO_Line_Key = R.PO_Line_Key
  CROSS APPLY
  (
    SELECT TOP(1)
      P.Price,
      P.Unit
    FROM Sales.dbo.Price AS P
    WHERE P.PCN = POL.PCN
      AND P.PO_Line_Key = POL.PO_Line_Key
      AND P.Active = 1
    ORDER BY
      P.Effective_Date DESC
  ) AS PR;

  UPDATE CGM -- UPDATE dbo.#cgm2
  SET 
    CGM.SGA_Percent =
    (
      SELECT
        QCS.Current_SG_AND_A_Percentage
      FROM Sales.dbo.Quote_Cost_Summary AS QCS
      WHERE QCS.PCN = CGM.PCN
        AND QCS.Current_SG_AND_A_Effective_Date =
        (
          SELECT 
            MAX(QCS2.Current_SG_AND_A_Effective_Date)
          FROM Sales.dbo.Quote_Cost_Summary AS QCS2
          WHERE QCS2.PCN = CGM.PCN
            AND QCS2.Current_SG_AND_A_Effective_Date < @End_Date
        )
    ),
    CGM.Scrap_Percent =
    (
      SELECT
        QCS.Current_Scrap_Percentage
      FROM Sales.dbo.Quote_Cost_Summary AS QCS
      WHERE QCS.PCN = CGM.PCN
        AND QCS.Current_Scrap_Effective_Date =
        (
          SELECT 
            MAX(QCS2.Current_Scrap_Effective_Date)
          FROM Sales.dbo.Quote_Cost_Summary AS QCS2
          WHERE QCS2.PCN = CGM.PCN
            AND QCS2.Current_Scrap_Effective_Date < @End_Date
        )
    )
  FROM dbo.#cgm2 AS CGM;

  UPDATE dbo.#cgm2 
  SET
    SGA_Cost = CAST(Ext_Cost * SGA_Percent / 100 AS DECIMAL(18, 6)),
    Scrap_Cost = CAST(Ext_Cost * Scrap_Percent / 100 AS DECIMAL(18, 6));

  UPDATE dbo.#cgm2 
  SET
    Total_Cost = Ext_Cost + SGA_Cost + Scrap_Cost;

  UPDATE dbo.#cgm2 
  SET
    Cost_Per_Sales = CASE WHEN Sales_Qty = 0 THEN 0 ELSE CAST((Ext_Cost + SGA_Cost + Scrap_Cost) / Sales_Qty AS DECIMAL(18, 6)) END;

  UPDATE dbo.#cgm2 
  SET
    Markup = CASE WHEN Cost_Per_Sales = 0 THEN 0 ELSE @PercMult * (((Unit_Price - Cost_Per_Sales) / Cost_Per_Sales) * 1) END,
    Margin = CASE WHEN Revenue = 0 THEN 0 ELSE @PercMult * (Revenue - Total_Cost) / Revenue END;

  SELECT
    CGM.PCN,
    NULL AS Gross_Margin_Key,
    CGM.Customer_Code,
    CGM.Customer_Category,
    CGM.Customer_Type,
    CGM.Salesperson,
    CGM.Order_No,
    CGM.PO_No,
    CGM.Invoice_No,
    NULL AS Line_Item_No,
    NULL AS Part_Key,
    CGM.Part_No,
    CGM.Product_Type,
    CGM.Part_Source,
    CGM.Part_Description,
    CGM.Quantity,
    CGM.Quantity_Unit,
    CGM.Sales_Qty,
    CGM.Sales_Unit,
    CGM.Unit_Price,
    CGM.Revenue,
    NULL AS Cost,
    NULL AS Ext_Cost,
    NULL AS Cost_Column,
    NULL AS Cost_Type,
    NULL AS Cost_Sub_Type,
    NULL AS Cost_Type_Order,
    NULL AS Cost_Sub_Type_Order,
    CGM.Shipper_Line_Key,
    CGM.Ext_Cost AS Total,
    CGM.SGA_Percent,
    CGM.SGA_Cost,
    CGM.Scrap_Percent,
    CGM.Scrap_Cost,
    CGM.Total_Cost,
    CGM.Cost_Per_Sales,
    CGM.Markup,
    CGM.Margin,
    CGM.Part_Group,
    CGM.Part_Type,
    CGM.PO_Type,
    CGM.Net_Weight,
    PCN.Customer_Currency_Code AS Customer_Currency_Code,
    PCN.Customer_Abbreviated_Name AS Customer_Abbreviated_Name,
    NULL AS Production_Qty,
    CGM.Part_Revision,
    CGM.Customer_Part_No,
    CGM.Customer_Part_Revision,
    CGM.Sequence_No,
    CGM.Master_No,
    CGM.GM_Total
  FROM dbo.#cgm2 AS CGM
  JOIN dbo.#PCN AS PCN
    ON PCN.PCN = CGM.PCN
  ORDER BY
    CGM.Customer_Code,
    CGM.PO_No,
    CGM.Order_No,
    CGM.Invoice_No,
    CGM.Part_No,
    CGM.Part_Revision;
END
ELSE
BEGIN
  IF @Report LIKE '%Raw'
  BEGIN 
    SELECT
      CGM.PCN,
      NULL AS Gross_Margin_Key,
      CGM.Customer_Code,
      CGM.Customer_Category,
      CGM.Customer_Type,
      CGM.Salesperson,
      CGM.Order_No,
      CGM.PO_No,
      CGM.Invoice_No,
      CGM.Line_Item_No,
      CGM.Part_Key,
      CGM.Part_No,
      CGM.Product_Type,
      CGM.Part_Source,
      CGM.Part_Description,
      CGM.Quantity,
      CGM.Quantity_Unit,
      CGM.Sales_Qty,
      CGM.Sales_Unit,
      CGM.Unit_Price,
      CGM.Revenue,
      NULL AS Cost,
      NULL AS Ext_Cost,
      CGM.Cost_Column,
      NULL AS Cost_Type,
      NULL AS Cost_Sub_Type,
      NULL AS Cost_Type_Order,
      NULL AS Cost_Sub_Type_Order,
      NULL AS Shipper_Line_Key,
      SUM(CGM.Ext_Cost) AS Total,
      NULL AS SGA_Percent,
      NULL AS SGA_Cost,
      NULL AS Scrap_Percent,
      NULL AS Scrap_Cost,
      NULL AS Total_Cost,
      NULL AS Cost_Per_Sales,
      NULL AS Markup,
      NULL AS Margin,
      CGM.Part_Group,
      CGM.Part_Type,
      CGM.PO_Type,
      CGM.Net_Weight,
      PCN.Customer_Currency_Code AS Customer_Currency_Code,
      PCN.Customer_Abbreviated_Name AS Customer_Abbreviated_Name,
      NULL AS Production_Qty,
      CGM.Part_Revision,
      CGM.Customer_Part_No,
      CGM.Customer_Part_Revision,
      CGM.Sequence_No,
      CGM.Master_No,
      CGM.GM_Total
    FROM dbo.#cgm AS CGM
    JOIN dbo.#PCN AS PCN
      ON PCN.PCN = CGM.PCN
    GROUP BY
      CGM.PCN,
      CGM.Customer_Code,
      CGM.Customer_Category,
      CGM.Customer_Type,
      CGM.Salesperson,
      CGM.Order_No,
      CGM.PO_No,
      CGM.Part_Key,
      CGM.Part_No,
      CGM.Product_Type,
      CGM.Part_Source,
      CGM.Part_Description,
      CGM.Sales_Qty,
      CGM.Sales_Unit,
      CGM.Quantity,
      CGM.Quantity_Unit,
      CGM.Unit_Price,
      CGM.Revenue,
      CGM.Invoice_No,
      CGM.Line_Item_No,
      CGM.Cost_Column,
      CGM.Part_Type,
      CGM.Part_Group,
      CGM.PO_Type,
      CGM.Net_Weight,
      CGM.Cost_Type_Order,
      PCN.Customer_Abbreviated_Name,
      PCN.Customer_Currency_Code,
      CGM.Part_Revision,
      CGM.Customer_Part_No,
      CGM.Customer_Part_Revision,
      CGM.Sequence_No,
      CGM.Master_No,
      CGM.GM_Total
    ORDER BY
      PCN.Customer_Abbreviated_Name,
      CGM.Customer_Code,
      CGM.Customer_Category,
      CGM.Customer_Type,
      CGM.PO_No,
      CGM.Order_No,
      CGM.Invoice_No,
      CGM.Part_No,
      CGM.Part_Revision,
      CGM.Cost_Type_Order;      
  END
  ELSE
  BEGIN  
    IF @Report NOT LIKE 'Sequence%'
    BEGIN
      UPDATE CGM
      SET
        CGM.Customer_Currency_Code = PCN.Customer_Currency_Code,
        CGM.Customer_Abbreviated_Name = PCN.Customer_Abbreviated_Name,
        CGM.Production_Qty = OA.Production_Qty
      FROM dbo.#cgm AS CGM
      JOIN dbo.#PCN AS PCN
        ON PCN.PCN = CGM.PCN
      OUTER APPLY
      (
        SELECT TOP(1)
          CGM1.Production_Qty
        FROM dbo.#cgm AS CGM1
        WHERE @Include LIKE '%Scrap%'
          AND CGM1.Part_Key = CGM.Part_Key
          AND CGM1.Cost_Type = 'Scrap'
      ) AS OA;
    END;
  
    IF @Pivot = 1
    BEGIN
      -- run the temp table through sp_Cross_Tab
      DECLARE @insert_code VARCHAR(1000);
      SET @insert_code = 
      '
      INSERT dbo.#crosscol 
      SELECT 
        CGM.Cost_Column, 
        (1000 * MIN(CGM.Cost_Type_Order)) + MIN(CGM.Cost_Sub_Type_Order) AS Sort_Order 
      FROM dbo.#cgm AS CGM
      WHERE ISNULL(CGM.Cost_Column, '''') != '''' 
      GROUP BY CGM.Cost_Column 
      ORDER BY 
        MIN(CGM.Cost_Type_Order), 
        MIN(CGM.Cost_Sub_Type_Order), 
        CGM.Cost_Column
      ';
      EXEC master.dbo.sp_Cross_Tab
        '#cgm',
        'Cost_Column',
        'Gross_Margin_Key, Customer_Code, Salesperson, Order_No, PO_No, Invoice_No, Part_No, Customer_Category, Customer_Type, Product_Type,
          Part_Source, Part_Description, Quantity, Quantity_Unit, Sales_Qty, Sales_Unit, Production_Qty, Unit_Price, Revenue, Part_Group,
          Part_Type, PO_Type, Net_Weight, Customer_Abbreviated_Name, Customer_Currency_Code, Part_Revision, Customer_Part_No,
          Customer_Part_Revision, Sequence_No, Master_No',
        'Ext_Cost',
        'Customer_Code, Customer_Abbreviated_Name, PO_No, Order_No, Invoice_No, Part_No, Part_Revision, Sequence_No', 
        0,
        @insert_code;
    END
    ELSE
    BEGIN
      IF @Report LIKE 'Customer%'
      BEGIN
        SELECT
          CGM.PCN,
          CGM.Gross_Margin_Key,
          CGM.Customer_Code,
          CGM.Customer_Category,
          CGM.Customer_Type,
          CGM.Salesperson,
          CGM.Order_No,
          CGM.PO_No,
          CGM.Invoice_No,
          CGM.Line_Item_No,
          CGM.Part_Key,
          CGM.Part_No,
          CGM.Product_Type,
          CGM.Part_Source,
          CGM.Part_Description,
          CGM.Quantity,
          CGM.Quantity_Unit,
          CGM.Sales_Qty,
          CGM.Sales_Unit,
          CGM.Unit_Price,
          CGM.Revenue,
          SUM(ISNULL(CGM.Cost, 0)) AS Cost,
          SUM(ISNULL(CGM.Ext_Cost, 0)) AS Ext_Cost,
          CGM.Cost_Column,
          CGM.Cost_Type,
          NULL AS Cost_Sub_Type,
          NULL AS Cost_Type_Order,
          CAST((CGM.Cost_Type_Order * 1000) AS VARCHAR(1000)) + CGM.Cost_Column AS Cost_Sub_Type_Order,
          CGM.Shipper_Line_Key,
          NULL AS Total,
          NULL AS SGA_Percent,
          NULL AS SGA_Cost,
          NULL AS Scrap_Percent,
          NULL AS Scrap_Cost,
          NULL AS Total_Cost,
          NULL AS Cost_Per_Sales,
          NULL AS Markup,
          NULL AS Margin,
          CGM.Part_Group,
          CGM.Part_Type,
          CGM.PO_Type,
          CGM.Net_Weight,
          CGM.Customer_Currency_Code,
          CGM.Customer_Abbreviated_Name,
          CGM.Production_Qty,
          CGM.Part_Revision,
          CGM.Customer_Part_No,
          CGM.Customer_Part_Revision,
          CGM.Sequence_No,
          CGM.Master_No,
          CGM.GM_Total
        FROM dbo.#cgm AS CGM
        JOIN dbo.#PCN AS PCN
          ON PCN.PCN = CGM.PCN
        WHERE CGM.Cost_Column != ''
        GROUP BY
          CGM.PCN,
          CGM.Gross_Margin_Key,
          CGM.Customer_Code,
          CGM.Customer_Category,
          CGM.Customer_Type,
          CGM.Salesperson,
          CGM.Order_No,
          CGM.PO_No,
          CGM.Invoice_No,
          CGM.Line_Item_No,
          CGM.Part_Key,
          CGM.Part_No,
          CGM.Product_Type,
          CGM.Part_Source,
          CGM.Part_Description,
          CGM.Quantity,
          CGM.Quantity_Unit,
          CGM.Sales_Qty,
          CGM.Sales_Unit,
          CGM.Unit_Price,
          CGM.Revenue,
          CGM.Cost_Column,
          CGM.Cost_Type,
          CGM.Cost_Type_Order,
          CGM.Cost_Sub_Type_Order,
          CGM.Shipper_Line_Key,
          CGM.Part_Group,
          CGM.Part_Type,
          CGM.PO_Type,
          CGM.Net_Weight,
          CGM.Customer_Currency_Code,
          CGM.Customer_Abbreviated_Name,
          CGM.Production_Qty,
          CGM.Part_Revision,
          CGM.Customer_Part_No,
          CGM.Customer_Part_Revision,
          CGM.Sequence_No,
          CGM.Master_No,
          CGM.GM_Total
        ORDER BY
          CGM.Customer_Code,
          CGM.Customer_Abbreviated_Name,
          CGM.PO_No,
          CGM.Order_No,
          CGM.Invoice_No,
          CGM.Part_No,
          CGM.Part_Revision,
          CGM.Sequence_No,
          CGM.Cost_Type_Order,
          CGM.Cost_Sub_Type_Order;
      END
      ELSE
      BEGIN
        SELECT
          CGM.PCN,
          CGM.Gross_Margin_Key,
          CGM.Customer_Code,
          CGM.Customer_Category,
          CGM.Customer_Type,
          CGM.Salesperson,
          CGM.Order_No,
          CGM.PO_No,
          CGM.Invoice_No,
          CGM.Line_Item_No,
          CGM.Part_Key,
          CGM.Part_No,
          CGM.Product_Type,
          CGM.Part_Source,
          CGM.Part_Description,
          CGM.Quantity,
          CGM.Quantity_Unit,
          CGM.Sales_Qty,
          CGM.Sales_Unit,
          CGM.Unit_Price,
          CGM.Revenue,
          SUM(CGM.Cost) AS Cost,
          SUM(CGM.Ext_Cost) AS Ext_Cost,
          CGM.Cost_Column,
          CGM.Cost_Type,
          CGM.Cost_Sub_Type,
          NULL AS Cost_Type_Order,
          CAST((CGM.Cost_Type_Order * 1000) + CGM.Cost_Sub_Type_Order AS VARCHAR(10)) + CGM.Cost_Type + CGM.Cost_Sub_Type AS Cost_Sub_Type_Order,
          CGM.Shipper_Line_Key,
          NULL AS Total,
          NULL AS SGA_Percent,
          NULL AS SGA_Cost,
          NULL AS Scrap_Percent,
          NULL AS Scrap_Cost,
          NULL AS Total_Cost,
          NULL AS Cost_Per_Sales,
          NULL AS Markup,
          NULL AS Margin,
          CGM.Part_Group,
          CGM.Part_Type,
          CGM.PO_Type,
          CGM.Net_Weight,
          CGM.Customer_Currency_Code,
          CGM.Customer_Abbreviated_Name,
          CGM.Production_Qty,
          CGM.Part_Revision,
          CGM.Customer_Part_No,
          CGM.Customer_Part_Revision,
          CGM.Sequence_No,
          CGM.Master_No,
          CGM.GM_Total
        FROM dbo.#cgm AS CGM
        JOIN dbo.#PCN AS PCN
          ON PCN.PCN = CGM.PCN
        WHERE CGM.Cost_Column != ''
        GROUP BY
          CGM.PCN,
          CGM.Gross_Margin_Key,
          CGM.Customer_Code,
          CGM.Salesperson,
          CGM.Order_No,
          CGM.PO_No,
          CGM.Invoice_No,
          CGM.Customer_Category,
          CGM.Customer_Type,
          CGM.Product_Type,
          CGM.Part_Source,
          CGM.Part_Description,
          CGM.Quantity,
          CGM.Quantity_Unit,
          CGM.Sales_Qty,
          CGM.Sales_Unit,
          CGM.Production_Qty,
          CGM.Unit_Price,
          CGM.Revenue,
          CGM.Part_Group,
          CGM.Part_Type,
          CGM.PO_Type,
          CGM.Net_Weight,
          CGM.Customer_Abbreviated_Name,
          CGM.Customer_Currency_Code,
          CGM.Part_Revision,
          CGM.Customer_Part_No,
          CGM.Customer_Part_Revision,
          CGM.Sequence_No,
          CGM.Master_No,
          CGM.Line_Item_No,
          CGM.Part_Key,
          CGM.Part_No,
          Cost_Type_Order,
          Cost_Sub_Type_Order,
          CGM.Shipper_Line_Key,
          CGM.Cost_Column,
          CGM.Cost_Type,
          CGM.Cost_Sub_Type,
          CGM.GM_Total
        ORDER BY
          CGM.Customer_Abbreviated_Name,
          CGM.Customer_Code,
          CGM.PO_No,
          CGM.Order_No,
          CGM.Invoice_No,
          CGM.Part_No,
          CGM.Part_Revision,
          CGM.Sequence_No,
          CGM.Cost_Type_Order,
          CGM.Cost_Sub_Type_Order;
      END;
    END;
  END;
END;
--#endregion

--#region Clean up
DROP TABLE dbo.#ARID;
DROP TABLE dbo.#cgm;
DROP TABLE dbo.#cgm2;
DROP TABLE dbo.#cgm_all;
DROP TABLE dbo.#cgm_qty;
DROP TABLE dbo.#Part_Type;
DROP TABLE dbo.#Part_Group;
DROP TABLE dbo.#Part_Source;
DROP TABLE dbo.#Customer_Category;
DROP TABLE dbo.#PO_Type;
DROP TABLE dbo.#CSTB;
DROP TABLE dbo.#Shipper_Line;
DROP TABLE dbo.#PCN;
DROP TABLE dbo.#xPCN;
DROP TABLE dbo.#ARID_Quantity;
DROP TABLE dbo.#Part_Group_Split;
DROP TABLE dbo.#Part_Product_Type;
DROP TABLE dbo.#Customer_Part_Product_Type;
DROP TABLE dbo.#Master;
DROP TABLE dbo.#Part_Status;
DROP TABLE dbo.#Department;
DROP TABLE dbo.#Shipper_Container;
--#endregion

RETURN;