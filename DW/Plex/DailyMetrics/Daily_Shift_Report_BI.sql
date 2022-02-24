WITH Cost_Gross_Margin_Daily AS
(
    SELECT
        PCN,
        Cost_Model_Key,
        Part_No,
        Part_Revision,
        Report_Date,
        Unit_Price,
        SUM(Sales_Qty) AS Sales_Qty
    FROM Plex.Cost_Gross_Margin_Daily
    GROUP BY
        PCN,
        Cost_Model_Key,
        Part_No,
        Part_Revision,
        Report_Date,
        Unit_Price
)

SELECT
    dsr.plexus_customer_code AS 'Plexus Customer Code',
    dsr.part_no AS 'Part No',
    dsr.part_revision AS 'Part Revision',
    dsr.part_name AS 'Part Name',
    SUM(dsr.parts_produced) AS 'Gross Volume Produced',
    SUM(dsr.parts_scrapped) AS 'Parts Scrapped',
    SUM(dsr.earned_hours) AS 'Labor Hours Earned',
    SUM(dsr.actual_hours) AS 'Labor Hours Actual',
    Labor_Cost.Cost * dsr.Labor_rate AS 'Labor Rate',
    cgmd.Sales_Qty AS 'Volume Shipped',
    cgmd.Unit_Price AS 'Sell Price',
    Material_Cost.Cost AS 'Material Standard'
FROM Plex.Daily_Shift_Report AS dsr
INNER JOIN Cost_Gross_Margin_Daily AS cgmd
    ON dsr.pcn = cgmd.PCN
    AND dsr.part_no = cgmd.Part_No
    AND ISNULL(dsr.part_revision, '') = ISNULL(cgmd.Part_Revision,'')
    AND CONVERT(DATE, dsr.report_date) = CONVERT(DATE, cgmd.Report_Date) 
OUTER APPLY
(
    SELECT TOP 1
        Cost
    FROM Plex.Cost_Sub_Type_Breakdown_Matrix AS cstbm
    WHERE cstbm.Cost_Date <= cgmd.Report_Date
        AND cstbm.Cost_Model_Key = cgmd.Cost_Model_Key
        AND cstbm.Cost_Type = 'Material'
        AND cstbm.Part_Description = cgmd.Part_No
        AND ISNULL(cstbm.Revision, '') = ISNULL(cgmd.Part_Revision, '')
    ORDER BY cstbm.Cost_Date DESC 
) AS Material_Cost
OUTER APPLY
(
    SELECT TOP 1
        Cost
    FROM Plex.Cost_Sub_Type_Breakdown_Matrix AS cstbm
    WHERE cstbm.Cost_Date <= cgmd.Report_Date
        AND cstbm.Cost_Model_Key = cgmd.Cost_Model_Key
        AND cstbm.Cost_Type = 'Labor'
        AND cstbm.Part_Description = cgmd.Part_No
        AND ISNULL(cstbm.Revision, '') = ISNULL(cgmd.Part_Revision, '')
    ORDER BY cstbm.Cost_Date DESC 
) AS Labor_Cost
WHERE CONVERT(DATE, dsr.report_date) = DATEADD(DAY, -1, CONVERT(DATE, GETDATE()))
GROUP BY
    dsr.plexus_customer_code,
    dsr.part_no,
    dsr.part_revision,
    dsr.part_name,
    dsr.labor_rate,
    cgmd.Sales_Qty,
    cgmd.Unit_Price,
    Material_Cost.Cost,
    Labor_Cost.Cost