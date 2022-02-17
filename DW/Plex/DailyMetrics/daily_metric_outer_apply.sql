/*
Microsoft SQL Server 2005 introduced the APPLY operator, which is like a join clause and it allows joining between two table expressions 
i.e. joining a left/outer table expression with a right/inner table expression. The difference between the join and APPLY operator becomes 
evident when you have a table-valued expression on the right side and you want this table-valued expression to be evaluated for each row 
from the left table expression. 
In this tip I am going to demonstrate the APPLY operator, how it differs from regular JOINs and some uses.
 */
SELECT
  --  dsrg.plexus_customer_code AS 'Plexus Customer Code',
	dsrg.pcn,
	dsrg.part_no AS 'Part No',
    dsrg.part_name AS 'Part Name',
    SUM(dsrg.parts_produced) AS 'Gross Volume Produced',
    SUM(dsrg.parts_scrapped) AS 'Parts Scrapped',
    SUM(dsrg.quantity_produced) AS 'Volume Produced',
    SUM(dsrg.earned_hours) AS 'Labor Hours Earned',
    SUM(dsrg.actual_hours) AS 'Labor Hours Actual',
    dsrg.labor_rate AS 'Labor Rate',
    cgmg.Sales_Qty AS 'Volume Shipped',
    cgmg.Unit_Price AS 'Sell Price',
    cstbm.Cost AS 'Material Cost'
FROM Plex.daily_shift_report_get AS dsrg
INNER JOIN Plex.Cost_Gross_Margin_Get AS cgmg
    ON dsrg.pcn = cgmg.PCN
    AND dsrg.part_no = cgmg.Part_No
    AND CONVERT(DATE, dsrg.report_date) = CONVERT(DATE, cgmg.Report_Date) 
cross APPLY
(
    SELECT TOP 1
        Cost
    FROM Plex.Cost_Sub_Type_Breakdown_Matrix AS cstbm
    WHERE cstbm.Cost_Date <= cgmg.Report_Date
        AND cstbm.Cost_Model_Key = cgmg.Cost_Model_Key
        AND cstbm.Cost_Type = 'Material'
        AND cstbm.Part_Description = cgmg.Part_No
    ORDER BY cstbm.Cost_Date DESC 
) AS cstbm
WHERE CONVERT(DATE, dsrg.report_date) = DATEADD(DAY, -1, CONVERT(DATE, GETDATE()))
GROUP BY
    dsrg.pcn,
--    dsrg.plexus_customer_code,
    dsrg.part_no,
    dsrg.part_name,
    dsrg.labor_rate,
    cgmg.Sales_Qty,
    cgmg.Unit_Price,
    cstbm.Cost
ORDER BY
	pcn,
--    [Plexus Customer Code],
    [Part No]