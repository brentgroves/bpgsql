

-- Plex.Daily_Metrics_Report_View source

CREATE view [Plex].[Daily_Metrics_Report_View]
as
/*
*  Sum the quanity and price by part number and date.
*/
WITH Gross_Margin_Daily AS
(
    SELECT
        gmd.PCN,
        CONVERT(DATE, gmd.Report_Date) AS Report_Date,
        gmd.Part_No,
        SUM(gmd.Quantity) AS Quantity,
        SUM(gmd.Unit_Price * gmd.Quantity) AS Extended_Price
    FROM Plex.Cost_Gross_Margin_Daily AS gmd
    GROUP BY
        gmd.PCN,
        CONVERT(DATE, gmd.Report_Date),
        gmd.Part_No
),
/*
*  Sum the quantites and hours by part no and date.
*/
Daily_Shift_Report AS
(
    SELECT
        CONVERT(DATE, dsr.report_date) AS Report_Date,
        dsr.Plexus_Customer_Code,
        dsr.Part_Key,
        dsr.PCN,
        dsr.Part_No,
        dsr.Part_Revision,
        dsr.Part_Name,
        SUM(dsr.Parts_Produced) - SUM(dsr.Parts_Scrapped) AS Quantity_Produced,
        SUM(dsr.Parts_Produced) AS Parts_Produced,
        SUM(dsr.Parts_Scrapped) AS Parts_Scrapped,
        SUM(dsr.Earned_Hours) AS Earned_Hours,
        SUM(dsr.Actual_Hours) AS Actual_Hours,
        SUM(lc.Cost * dsr.Labor_Rate * dsr.Actual_Hours) AS Direct_Labor
    FROM Plex.Daily_Shift_Report AS dsr
    -- We only want the last op.
    INNER JOIN Plex.Part_Operation AS po
        ON dsr.PCN = po.PCN
        AND dsr.Part_Key = po.Part_Key
        AND dsr.Part_Operation_Key = po.Part_Operation_Key
        AND po.Shippable = 1
        AND po.Part_Op_Type IN ('Production','Checksheet','Kanban','External/Outside')
    -- With the cost of labor from the sub type breakdown.
    OUTER APPLY
    (
        SELECT TOP 1
            Cost
        FROM Plex.Cost_Sub_Type_Breakdown_Matrix AS cstbm
        WHERE cstbm.Cost_Date <= DATEADD(DAY, 0, CONVERT(DATE, GETDATE()))
            AND cstbm.Cost_Type = 'Labor'
            AND cstbm.Part_Description = dsr.Part_No
            AND cstbm.Revision = dsr.Part_Revision
        ORDER BY cstbm.Cost_Date DESC 
    ) AS lc
    WHERE EXISTS
    (
        SELECT 
            *
        FROM Plex.Customer_Orders_Active AS coa
        WHERE coa.PCN = dsr.PCN
            AND coa.Part_No = dsr.Part_No
    )
    GROUP BY
        CONVERT(DATE, dsr.report_date),
        dsr.Plexus_Customer_Code,
        dsr.Part_Key,
        dsr.PCN,
        dsr.Part_No,
        dsr.Part_Revision,
        dsr.Part_Name
)
/*
*  Join both togater by part and date.  No need to sum here.
*/
SELECT
    dsr.Report_Date AS Report_Date,
    dsr.Plexus_Customer_Code AS Plexus_Customer_Code,
    dsr.Part_No AS Part_No,
    dsr.Part_Name AS Part_Name,
    dsr.Parts_Produced AS Gross_Volume_Produced,
    dsr.Quantity_Produced AS Volume_Produced,
    dsr.Parts_Scrapped AS Parts_Scrapped,
    ISNULL(dsr.Earned_Hours, 0) AS Labor_Hours_Earned,
    ISNULL(dsr.Actual_Hours, 0) AS Labor_Hours_Actual,
    ISNULL(dsr.Direct_Labor, 0) AS Direct_Labor,
    CASE
        WHEN ISNULL(dsr.Actual_Hours, 0) = 0 THEN 0
        WHEN ISNULL(dsr.Direct_Labor, 0) = 0 THEN 0
        ELSE dsr.Direct_Labor / dsr.Actual_Hours
    END AS Labor_Rate,
    ISNULL(gmd.Quantity, 0) AS Volume_Shipped,
    ISNULL(gmd.Extended_Price, 0) AS Sales,
    CASE
        WHEN ISNULL(gmd.Quantity, 0) = 0 THEN coa.Unit_Price
        WHEN ISNULL(gmd.Extended_Price, 0) = 0 THEN coa.Unit_Price
        ELSE gmd.Extended_Price / gmd.Quantity
    END AS Sell_Price,
    ISNULL(mc.Cost, 0) AS Material_Standard
FROM Daily_Shift_Report AS dsr
-- incase none have shipped use the last purchase order price.
OUTER APPLY
(
    SELECT TOP 1
        Unit_Price
    FROM Plex.Customer_Orders_Active AS coa
        WHERE dsr.PCN = coa.PCN
        AND dsr.Part_Key = coa.Part_Key
    ORDER BY coa.PO_Date DESC
) AS coa
LEFT JOIN Gross_Margin_Daily AS gmd
    ON gmd.PCN = dsr.PCN
    AND dsr.Report_Date = gmd.Report_Date
    AND dsr.Part_No = gmd.Part_No
-- Get the cost of materials from the sub type breakdown.
OUTER APPLY
(
    SELECT TOP 1
       Cost
    FROM Plex.Cost_Sub_Type_Breakdown_Matrix AS cstbm
    WHERE cstbm.Cost_Date <= DATEADD(DAY, 0, CONVERT(DATE, GETDATE()))
        AND cstbm.Cost_Type = 'Material'
        AND cstbm.Part_Description = dsr.Part_No
        AND cstbm.Revision = dsr.Part_Revision
    ORDER BY cstbm.Cost_Date DESC 
) AS mc;