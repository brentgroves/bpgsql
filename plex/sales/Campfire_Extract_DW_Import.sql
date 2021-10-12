/*
 * Params
@PCNList varchar(max) = '123681,300758,300757,310507,306766,295932',
@Start_Date DATETIME = '10/1/2021'
 */
/*
create PCN table from param
*/
create table #list
(
 tuple int
)
declare @delimiter varchar(1)
set @delimiter = ','
declare @in_string varchar(max)
set @in_string = @PCNList
WHILE LEN(@in_string) > 0
BEGIN
    INSERT INTO #list
    SELECT cast(left(@in_string, charindex(@delimiter, @in_string+',') -1) as int) as tuple

    SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
end
-- select tuple from #list

--SET @PCN = (SELECT TOP 1 P.Plexus_Customer_No FROM Part_v_Part AS P);

SET @Start_Date = ISNULL(@Start_Date, GETDATE());
--select @Start_Date 

Declare @Current_Month_Begin datetime
declare @Month_1_Begin datetime
declare @Month_2_Begin datetime
declare @Month_3_Begin datetime
declare @Month_4_Begin datetime
declare @Month_5_Begin datetime
declare @Month_6_Begin datetime
declare @Month_7_Begin datetime

SET @Current_Month_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, -1, @Start_Date)));
SET @Month_1_Begin = DATEADD(d, 1, EOMONTH(@Start_Date));
SET @Month_2_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 1, @Start_Date)));
SET @Month_3_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 2, @Start_Date)));
SET @Month_4_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 3, @Start_Date)));
SET @Month_5_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 4, @Start_Date)));
SET @Month_6_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 5, @Start_Date)));
SET @Month_7_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 6, @Start_Date)));

--SELECT @Current_Month_Begin;
--SELECT @Month_1_Begin;
--SELECT @Month_2_Begin;
--SELECT @Month_3_Begin;
--SELECT @Month_4_Begin;
--SELECT @Month_5_Begin;
--SELECT @Month_6_Begin;

CREATE TABLE #Exchange_Rates
(
  Currency_Key INT,
  Exchange_Rate FLOAT,
  Exchange_Rate_Date DATETIME
)
INSERT INTO #Exchange_Rates
SELECT DISTINCT
  C.Currency_Key,
  C.Exchange_Rate,
  C.Exchange_Rate_Date
FROM Common_v_Currency_h AS C
WHERE C.Exchange_Rate_Date > DATEADD(MM, -6, @Start_Date);

CREATE NONCLUSTERED INDEX IX_Exchange_Rates ON #Exchange_Rates(Currency_Key, Exchange_Rate_Date);

--select * from #Exchange_Rates

CREATE TABLE #Invoices
(
  Plexus_Customer_No INT,
  Invoice_Link INT,
  Base_Currency_Key INT,
  Invoice_No VARCHAR(500),
  Invoice_Description VARCHAR(MAX),
  Part_Key INT,
  Invoice_Date DATETIME,
  Timezone_Offset FLOAT,
  Price_Date DATE,
  Price FLOAT,
  Invoiced_Quantity FLOAT,
  Taxable_Amount FLOAT,
  Inv_Exchange_Rate FLOAT,
  Inv_Currency_Key INT,
  Inv_Currency_Code VARCHAR(5),
  Ship_To_Address INT
)
INSERT INTO #Invoices
SELECT DISTINCT
       AI.Plexus_Customer_No,
       AI.Invoice_Link,
       CG.Currency_Key,
       AI.Invoice_No,
       ID.Description,
       ID.Part_Key,
       AI.Invoice_Date,
       LT.Timezone_Offset,
       DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date), 
       ID.Unit_Price,
       ID.Quantity,
       ID.Taxable_Amount,
       AI.Exchange_Rate,
       C.Currency_Key,
       AI.Currency_Code,
       AI.Ship_To_Address
FROM Accounting_v_AR_Invoice_e AS AI
JOIN Accounting_v_AR_Invoice_Dist_e AS ID
  ON ID.Plexus_Customer_No = AI.Plexus_Customer_No
  AND ID.Invoice_Link = AI.Invoice_Link
JOIN Plexus_Control_v_Customer_Group_Member AS CG
  ON CG.Plexus_Customer_No = AI.Plexus_Customer_No
JOIN Plexus_Control_v_Logical_Timezone AS LT
  ON LT.Timezone_Key = CG.Timezone_Key
JOIN Common_v_Currency AS C
  ON C.Currency_Code = AI.Currency_Code
WHERE (DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) >= @Current_Month_Begin 
  AND DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) < @Month_1_Begin);

CREATE NONCLUSTERED INDEX IX_Invoices ON #Invoices (Plexus_Customer_No, Part_Key, Ship_To_Address);
--SELECT * FROM #Invoices AS I;


CREATE TABLE #Summarized_Invoices
(
  Plexus_Customer_No INT,
  Base_Currency_Key INT,
  Part_Key INT,
  Ship_To_Address INT,
  Price FLOAT,
  Invoiced_Quantity FLOAT,
  Local_Extended_Price FLOAT,
  Local_Taxable_Amount FLOAT,
  Local_Price_Plus_Tax FLOAT,
  Inv_Exchange_Rate FLOAT,
  Foreign_Extended_Price FLOAT,
  Foreign_Taxable_Amount FLOAT,
  Foreign_Price_Plus_Tax FLOAT,
  Inv_Currency_Key INT,
  Inv_Currency_Code VARCHAR(5)
)
INSERT INTO #Summarized_Invoices
SELECT 
  I.Plexus_Customer_No,
  I.Base_Currency_Key,
  I.Part_Key,
  I.Ship_To_Address,
  I.Price,
  SUM(I.Invoiced_Quantity) AS Invoiced_Quantity,
  I.Price * SUM(I.Invoiced_Quantity) AS Local_Extended_Price,
  I.Taxable_Amount AS Local_Taxable_Amount,
  ((I.Price * SUM(I.Invoiced_Quantity)) + I.Taxable_Amount) AS Local_Price_Plus_Tax,

  I.Inv_Exchange_Rate,
  (SUM(I.Invoiced_Quantity)*(I.Price * I.Inv_Exchange_Rate)) AS Foreign_Extended_Price,
  (I.Taxable_Amount * I.Inv_Exchange_Rate) AS Foreign_Taxable_Amount,
  ((SUM(I.Invoiced_Quantity)*(I.Price * I.Inv_Exchange_Rate)) + (I.Taxable_Amount * I.Inv_Exchange_Rate)) AS Foreign_Price_Plus_Tax,
  I.Inv_Currency_Key,
  I.Inv_Currency_Code
FROM #Invoices AS I
GROUP BY
  I.Plexus_Customer_No,
  I.Base_Currency_Key,
  I.Part_Key,
  I.Ship_To_Address,
  I.Price,
  I.Taxable_Amount,
  I.Inv_Exchange_Rate,
  I.Inv_Currency_Key,
  I.Inv_Currency_Code;

CREATE NONCLUSTERED INDEX IX_Summarized_Invoices ON #Summarized_Invoices (Plexus_Customer_No, Part_Key, Ship_To_Address);
--SELECT * FROM #Summarized_Invoices AS SI; 


CREATE TABLE #Releases
(
  PCN INT,
  PO_No VARCHAR(100),
  PO_Line_Key INT,
  Part_Key INT,
  Ship_To INT,
  Month_Sequence INT,
  Ship_Date DATETIME,
  Quantity FLOAT,
  Effective_Price FLOAT,
  Currency_Key INT
)
INSERT INTO #Releases
SELECT
  R.PCN,
  PO.PO_No,
  POL.PO_Line_Key,
  POL.Part_Key,
  R.Ship_To,
  CASE
    WHEN R.Ship_Date < @Month_1_Begin THEN 0
    WHEN R.Ship_Date >= @Month_1_Begin AND R.Ship_Date < @Month_2_Begin THEN 1
    WHEN R.Ship_Date >= @Month_2_Begin AND R.Ship_Date < @Month_3_Begin THEN 2
    WHEN R.Ship_Date >= @Month_3_Begin AND R.Ship_Date < @Month_4_Begin THEN 3
    WHEN R.Ship_Date >= @Month_4_Begin AND R.Ship_Date < @Month_5_Begin THEN 4
    WHEN R.Ship_Date >= @Month_5_Begin AND R.Ship_Date < @Month_6_Begin THEN 5
    WHEN R.Ship_Date >= @Month_6_Begin AND R.Ship_Date < @Month_7_Begin THEN 6
  ELSE 999
  END AS Month_Sequence,
  R.Ship_Date,
  R.Quantity,
  P.Price AS Effective_Price,
  P.Currency_Key
FROM Sales_v_Release_e AS R
JOIN Sales_v_Release_Status_e AS RS
  ON RS.PCN = R.PCN
  AND RS.Release_Status_Key = R.Release_Status_Key
JOIN Sales_v_PO_Line_e AS POL
  ON POL.PCN = R.PCN
  AND POL.PO_Line_Key = R.PO_Line_Key
JOIN Sales_v_PO_e AS PO
  ON PO.PCN = POL.PCN
  AND PO.PO_Key = POL.PO_Key
LEFT OUTER JOIN Sales_v_Price_e AS P
  ON P.PCN = POL.PCN
  AND P.PO_Line_Key = POL.PO_Line_Key
  AND P.Effective_Date <= R.Ship_Date
  AND (P.Expiration_Date IS NULL OR P.Expiration_Date > R.Ship_Date)
-- WHERE (@PCN = '' OR R.PCN = @PCN) -- BUG
where R.PCN in
(
 select tuple from #list
)
  AND RS.Active = 1
  AND P.Active = 1
  AND R.Ship_Date < @Month_7_Begin;

CREATE NONCLUSTERED INDEX IX_Releases ON #Releases (PCN, Part_Key, Ship_To, Month_Sequence);
-- SELECT * FROM #Releases AS R;


CREATE TABLE #Releases_With_Cost
(
  PCN INT,
  PO_No VARCHAR(50),
  PO_Line_Key INT,--
  Part_Key INT,
  Ship_To INT,
  Month_Sequence INT,
  Ship_Date DATETIME,
  Quantity FLOAT,
  Effective_Price FLOAT,
  Currency_Key INT,
  Exchange_Rate FLOAT,
  Material_Cost FLOAT,
  Direct_Labor_Cost FLOAT,
  Variable_Overhead_Cost FLOAT,
  Fixed_Overhead_Cost FLOAT
)
INSERT INTO #Releases_With_Cost
SELECT 
  R.PCN,
  R.PO_No,
  R.PO_Line_Key,
  R.Part_Key,
  R.Ship_To,
  R.Month_Sequence,
  R.Ship_Date,
  R.Quantity,
  R.Effective_Price,
  R.Currency_Key,
  ISNULL((SELECT TOP 1 ER.Exchange_Rate FROM #Exchange_Rates AS ER WHERE ER.Currency_Key = R.Currency_Key AND ER.Exchange_Rate_Date < R.Ship_Date ORDER BY ER.Exchange_Rate_Date DESC),1) AS Exchange_Rate,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Material') AS Material_Cost,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor') AS Direct_Labor_Cost,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Variable', 'Variable Overhead')) AS Variable_Overhead_Cost,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Fixed', 'Fixed Overhead')) AS Fixed_Overhead_Cost
FROM #Releases AS R;

CREATE NONCLUSTERED INDEX IX_Releases_With_Cost ON #Releases_With_Cost(PCN, Part_Key, Ship_To, Month_Sequence);
--SELECT * FROM #Releases_With_Cost AS RWC;

CREATE TABLE #Summarized_Releases_With_Cost
(
  PCN INT,
  PO_No VARCHAR(50),
  Part_Key INT,
  Ship_To INT,
  Month_Sequence INT,
  Extended_Quantity FLOAT,
  Effective_Price FLOAT,
  Extended_Price FLOAT,
  Currency_Key INT,
  Exchange_Rate FLOAT,
  Local_Material_Cost FLOAT,
  Foreign_Material_Cost FLOAT,
  Local_Direct_Labor_Cost FLOAT,
  Foreign_Direct_Labor_Cost FLOAT,
  Local_Variable_Overhead_Cost FLOAT,
  Foreign_Variable_Overhead_Cost FLOAT,
  Local_Fixed_Overhead_Cost FLOAT,
  Foreign_Fixed_Overhead_Cost FLOAT
)
INSERT INTO #Summarized_Releases_With_Cost
SELECT
  RWC.PCN,
  RWC.PO_No,
  RWC.Part_Key,
  RWC.Ship_To,
  RWC.Month_Sequence,
  SUM(RWC.Quantity) AS Extended_Quantity,
  RWC.Effective_Price,
  SUM(RWC.Quantity) * RWC.Effective_Price AS Extended_Price,
  RWC.Currency_Key,
  RWC.Exchange_Rate,
  (SUM(RWC.Quantity) * RWC.Material_Cost) AS Local_Material_Cost,
  (SUM(RWC.Quantity) * RWC.Material_Cost) * RWC.Exchange_Rate AS Foreign_Material_Cost,
  (SUM(RWC.Quantity) * RWC.Direct_Labor_Cost) AS Local_Direct_Labor_Cost,
  (SUM(RWC.Quantity) * RWC.Direct_Labor_Cost) * RWC.Exchange_Rate AS Foreign_Material_Cost,  -- bug should be Foreign_Direct_Labor_Cost
  (SUM(RWC.Quantity) * RWC.Variable_Overhead_Cost) AS Local_Variable_Overhead_Cost,
  (SUM(RWC.Quantity) * RWC.Variable_Overhead_Cost) * RWC.Exchange_Rate AS Foreign_Variable_Overhead_Cost,
  (SUM(RWC.Quantity) * RWC.Fixed_Overhead_Cost) AS Local_Fixed_Overhead_Cost,
  (SUM(RWC.Quantity) * RWC.Fixed_Overhead_Cost) * RWC.Exchange_Rate AS Foreign_Fixed_Overhead_Cost
FROM #Releases_With_Cost AS RWC
GROUP BY
  RWC.PCN,
  RWC.PO_No,
  RWC.Part_Key,
  RWC.Ship_To,
  RWC.Month_Sequence,
  RWC.Effective_Price,
  RWC.Currency_Key,
  RWC.Exchange_Rate,
  RWC.Material_Cost,
  RWC.Direct_Labor_Cost,
  RWC.Variable_Overhead_Cost,
  RWC.Fixed_Overhead_Cost;

CREATE NONCLUSTERED INDEX IX_Summarized_Releases_With_Cost ON #Summarized_Releases_With_Cost(PCN, Part_Key, Ship_To, Month_Sequence);
--SELECT * FROM #Summarized_Releases_With_Cost AS SRWC;


WITH CTE_Distinct_Line_Items AS
(
  SELECT DISTINCT
    R.PCN,
    R.Part_Key,
    R.Ship_To
  FROM #Summarized_Releases_With_Cost AS R
),

CTE_Summarized_Releases_By_Month AS
(
  SELECT DISTINCT
    R.PCN,
    R.Part_Key,
    R.Ship_To,
    R.Month_Sequence,
    SUM(R.Extended_Quantity) AS Pieces_Quantity,
    SUM(R.Extended_Price) AS Revenue,
    SUM(R.Local_Material_Cost) AS Local_Material_Cost,
    SUM(R.Foreign_Material_Cost) AS Foreign_Material_Cost,
    SUM(R.Local_Direct_Labor_Cost) AS Local_Direct_Labor_Cost,
    SUM(R.Foreign_Direct_Labor_Cost) AS Foreign_Direct_Labor_Cost,
    SUM(R.Local_Variable_Overhead_Cost) AS Local_Variable_Overhead_Cost,
    SUM(R.Foreign_Variable_Overhead_Cost) AS Foreign_Variable_Overhead_Cost,
    SUM(R.Local_Fixed_Overhead_Cost) AS Local_Fixed_Overhead_Cost,
    SUM(R.Foreign_Fixed_Overhead_Cost) AS Foreign_Fixed_Overhead_Cost
  FROM #Summarized_Releases_With_Cost AS R
  GROUP BY
    R.PCN,
    R.Part_Key,
    R.Ship_To,
    R.Month_Sequence
),

CTE_Summarized_Invoices AS
(
  SELECT 
    SI.Plexus_Customer_No,
    SI.Base_Currency_Key,
    SI.Part_Key,
    SI.Ship_To_Address,
    SI.Inv_Currency_Key,
    SI.Inv_Currency_Code,
    SUM(SI.Invoiced_Quantity) AS Invoiced_Quantity,
    SUM(SI.Local_Extended_Price) AS Local_Extended_Price,
    SUM(SI.Local_Taxable_Amount) AS Local_Taxable_Amount,
    SUM(SI.Local_Price_Plus_Tax) AS Local_Price_Plus_Tax,
    SUM(SI.Foreign_Extended_Price) AS Foreign_Extended_Price,
    SUM(SI.Foreign_Taxable_Amount) AS Foreign_Taxable_Amount,
    SUM(SI.Foreign_Price_Plus_Tax) AS Foreign_Price_Plus_Tax
  FROM #Summarized_Invoices AS SI
  GROUP BY
    SI.Plexus_Customer_No,
    SI.Base_Currency_Key,
    SI.Part_Key,
    SI.Ship_To_Address,
    SI.Inv_Currency_Key,
    SI.Inv_Currency_Code
),

CTE_Final_Summary AS
(
  SELECT DISTINCT
    CDLI.PCN,
    CGM.AD_Company_Code,
    CGM.Plexus_Customer_Code,    
    CDLI.Part_Key,
    P.Part_No + ' - ' + P.Revision AS Part_Number,
    CDLI.Ship_To,
    SI.Base_Currency_Key,
    C.Currency_HTML,
    (SELECT TOP 1 AP.Period FROM Accounting_v_Period_e AS AP WHERE AP.Plexus_Customer_No = CDLI.PCN AND  AP.Begin_Date <= @Start_Date AND AP.End_Date >= @Start_Date) AS Period,
    SI.Invoiced_Quantity AS Actual_Units,
    SI.Local_Extended_Price,
    SI.Local_Taxable_Amount,
    SI.Local_Price_Plus_Tax,
    SI.Inv_Currency_Code,
    SI.Foreign_Extended_Price,
    SI.Foreign_Taxable_Amount,
    SI.Foreign_Price_Plus_Tax,
    ISNULL(CSRBM.Local_Material_Cost,0) AS Local_Material_Cost,
    ISNULL(CSRBM.Foreign_Material_Cost,0) AS Foreign_Material_Cost,
    ISNULL(CSRBM.Local_Direct_Labor_Cost,0) AS Local_Direct_Labor_Cost,
    ISNULL(CSRBM.Foreign_Direct_Labor_Cost,0) AS Foreign_Direct_Labor_Cost,
    ISNULL(CSRBM.Local_Variable_Overhead_Cost,0) AS Local_Variable_Overhead_Cost,
    ISNULL(CSRBM.Foreign_Variable_Overhead_Cost,0) AS Foreign_Variable_Overhead_Cost,
    ISNULL(CSRBM.Local_Fixed_Overhead_Cost,0) AS Local_Fixed_Overhead_Cost,
    ISNULL(CSRBM.Foreign_Fixed_Overhead_Cost,0) AS Foreign_Fixed_Overhead_Cost,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 0 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
--    CASE
--      WHEN CSRBM.Month_Sequence = 0 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS CurrBackLogUnits,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 1 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS BacklogUnits1,
--    CASE
--     WHEN CSRBM.Month_Sequence = 1 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS BackLogUnits1,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 2 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS BacklogUnits2,
--    CASE
--      WHEN CSRBM.Month_Sequence = 2 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS BackLogUnits2,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 3 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS BacklogUnits3,
--    CASE
--      WHEN CSRBM.Month_Sequence = 3 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS BackLogUnits3,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 4 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS BacklogUnits4,
--    CASE
--      WHEN CSRBM.Month_Sequence = 4 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS BackLogUnits4,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 5 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS BacklogUnits5,
--    CASE
--      WHEN CSRBM.Month_Sequence = 5 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS BackLogUnits5,
    ISNULL((SELECT CSRBM.Pieces_Quantity FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 6 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS BacklogUnits6
--    CASE
--      WHEN CSRBM.Month_Sequence = 6 THEN CSRBM.Pieces_Quantity
--      ELSE 0
--    END AS BackLogUnits6
  FROM CTE_Distinct_Line_Items AS CDLI
  JOIN Part_v_Part_e AS P
    ON P.Plexus_Customer_No = CDLI.PCN
    AND P.Part_Key = CDLI.Part_Key
  LEFT OUTER JOIN CTE_Summarized_Invoices AS SI
    ON SI.Plexus_Customer_No = CDLI.PCN
    AND SI.Part_Key = CDLI.Part_Key
    AND SI.Ship_To_Address = CDLI.Ship_To
  JOIN Plexus_Control_v_Customer_Group_Member AS CGM
    ON CGM.Plexus_Customer_No = CDLI.PCN
  LEFT OUTER JOIN CTE_Summarized_Releases_By_Month AS CSRBM
    ON CSRBM.PCN = CDLI.PCN
    AND CSRBM.Part_Key = CDLI.Part_Key
    AND CSRBM.Ship_To = CDLI.Ship_To
  JOIN Common_v_Currency AS C
    ON C.Currency_Key = SI.Base_Currency_Key
  WHERE CSRBM.Month_Sequence = 0
--  GROUP BY 
--    CDLI.PCN,
--    CDLI.Part_Key,
--    P.Part_No + ' - ' + P.Revision,
--    CDLI.Ship_To,
--    SI.Base_Currency_Key,
--    SI.Invoiced_Quantity,
--    SI.Local_Extended_Price,
--    SI.Local_Taxable_Amount,
--    SI.Local_Price_Plus_Tax,
--    SI.Inv_Currency_Code,
--    SI.Foreign_Extended_Price,
--    SI.Foreign_Taxable_Amount,
--    SI.Foreign_Price_Plus_Tax;
)

--SELECT * FROM #Exchange_Rates AS ER;
--SELECT * FROM #Invoices AS I;
--SELECT * FROM #Summarized_Invoices AS SI;
--SELECT * FROM #Releases AS R;
--SELECT * FROM #Releases_with_Cost AS RWC;
--SELECT * FROM #Summarized_Releases_With_Cost AS SRWC;
--SELECT * FROM CTE_Releases_By_Month AS CRBM ORDER BY CRBM.PCN, CRBM.Part_Key, CRBM.Ship_To;
--SELECT * FROM CTE_Summarized_Invoices AS SI ORDER BY SI.Plexus_Customer_No, SI.Part_Key, SI.Ship_To_Address;
--SELECT * FROM CTE_Final_Summary AS CFS;

SELECT
row_number() over( order by pcn,part_key,ship_to) id,
CFS.pcn, 
CFS.Plexus_Customer_Code,
CFS.AD_Company_Code AS Company,
CFS.part_key,
CFS.Part_Number,
CFS.Ship_To AS Destination_Code,
CFS.Inv_Currency_Code AS Currency,
CFS.Period,
CFS.Actual_Units,
CFS.Foreign_Price_Plus_Tax AS Actual_Local_Rev,
CFS.Local_Price_Plus_Tax AS Actual_USD_Rev,
CFS.Local_Material_Cost AS Actual_Local_Material_Cost,
CFS.Local_Direct_Labor_Cost AS Actual_Local_Direct_Labor_Cost,
CFS.Local_Variable_Overhead_Cost AS Actual_Variable_Local_Overhead_Cost,
CFS.Local_Fixed_Overhead_Cost AS Actuals_Local_Fixed_Cost,
CFS.Foreign_Material_Cost AS Actual_USD_Material_Cost,
CFS.Foreign_Direct_Labor_Cost AS Actual_USD_Direct_Labor_Cost,
CFS.Foreign_Variable_Overhead_Cost AS Actual_Variable_USD_Overhead_Cost,
CFS.Foreign_Fixed_Overhead_Cost AS Actuals_USD_Fixed_Cost,
CFS.CurrBacklogUnits,
CFS.BacklogUnits1,
CFS.BacklogUnits2,
CFS.BacklogUnits3,
CFS.BacklogUnits4,
CFS.BacklogUnits5,
CFS.BacklogUnits6
FROM CTE_Final_Summary AS CFS
/*
create table #campfire_extract
(
id int, -- row_number() over( order by pcn,part_key,ship_to) id,
pcn int,
plexus_customer_code varchar(50), -- Plexus_Control_v_Customer_Group_Member.plexus_customer_code 
company varchar(50),  -- Plexus_Control_v_Customer_Group_Member.AD_Company_Code
part_key int,  -- added this for joins
part_number varchar(50), -- part_v_part.part_no
Destination_Code int, -- release.ship_to
Currency varchar(5),  -- Accounting_v_AR_Invoice_e.currency_code
Period int, -- Accounting_v_Period_e.Period  
Actual_Units float, -- --   SUM(Accounting_v_AR_Invoice_Dist_e.Quantity),
Actual_Local_Rev float, --SUM((SUM(Accounting_v_AR_Invoice_Dist_e.Quantity)*(Accounting_v_AR_Invoice_Dist_e.unit_price * Accounting_v_AR_Invoice_e.exchange_rate)) + (Accounting_v_AR_Invoice_Dist_e.taxable_amount * Accounting_v_AR_Invoice_e.exchange_rate))) AS Foreign_Price_Plus_Tax
Actual_USD_Rev float, --SUM(((Accounting_v_AR_Invoice_Dist_e.Unit_Price * SUM(Accounting_v_AR_Invoice_Dist_e.Quantity)) + Accounting_v_AR_Invoice_Dist_e.Taxable_Amount)) 
Actual_Local_Material_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) *  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Material') )),0) AS Local_Material_Cost,
Actual_Local_Direct_Labor_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor'))),0)
Actual_Variable_Local_Overhead_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Variable', 'Variable Overhead')))),0) AS Local_Variable_Overhead_Cost,
Actuals_Local_Fixed_Cost float,--ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Fixed', 'Fixed Overhead')))),0) AS Local_Fixed_Overhead_Cost,
Actual_USD_Material_Cost float,-- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor'))),0) AS Foreign_Material_Cost,
Actual_USD_Direct_Labor_Cost float, --ISNULL(SUM((SUM(Sales_v_Release_e) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor')) * RWC.Exchange_Rate),0) AS Foreign_Direct_Labor_Cost,
Actual_Variable_USD_Overhead_Cost float,-- ISNULL(SUM((SUM(Sales_v_Release_e) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Variable', 'Variable Overhead'))) * RWC.Exchange_Rate),0) AS Foreign_Variable_Overhead_Cost,
Actuals_USD_Fixed_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Fixed', 'Fixed Overhead'))) * RWC.Exchange_Rate),0) AS Foreign_Fixed_Overhead_Cost,
CurrBacklogUnits int, -- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 0 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits1 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 1 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits2 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 2 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits3 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 3 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits4 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 4 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits5 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 5 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits6 int -- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 6 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
)
*/

/*

SELECT
  CFS.AD_Company_Code AS Company,
  CFS.Part_Number, 
  CFS.Ship_To AS Destination_Code,
--  CFS.Currency_HTML AS Currency,
  CFS.Inv_Currency_Code AS Currency,
  CFS.Period,
  CFS.Actual_Units AS 'Actual (Units)',
  CFS.Foreign_Price_Plus_Tax AS Actual_Local_Rev,
  CFS.Local_Price_Plus_Tax AS Actual_USD_Rev,
  CFS.Local_Material_Cost AS Actual_Local_Material_Cost,
  CFS.Local_Direct_Labor_Cost AS Actual_Local_Direct_Labor_Cost,
  CFS.Local_Variable_Overhead_Cost AS Actual_Variable_Local_Overhead_Cost,
  CFS.Local_Fixed_Overhead_Cost AS Actuals_Local_Fixed_Cost,
  CFS.Foreign_Material_Cost AS Actual_USD_Material_Cost,
  CFS.Foreign_Direct_Labor_Cost AS Actual_USD_Direct_Labor_Cost,
  CFS.Foreign_Variable_Overhead_Cost AS Actual_Variable_USD_Overhead_Cost,
  CFS.Foreign_Fixed_Overhead_Cost AS Actuals_USD_Fixed_Cost,
  CFS.CurrBacklogUnits,
  CFS.BacklogUnits1,
  CFS.BacklogUnits2,
  CFS.BacklogUnits3,
  CFS.BacklogUnits4,
  CFS.BacklogUnits5,
  CFS.BacklogUnits6
FROM CTE_Final_Summary AS CFS
*/

DROP TABLE #Exchange_Rates;
DROP TABLE #Invoices;
DROP TABLE #Summarized_Invoices;
DROP TABLE #Releases;
DROP TABLE #Releases_With_Cost;
DROP TABLE #Summarized_Releases_With_Cost;