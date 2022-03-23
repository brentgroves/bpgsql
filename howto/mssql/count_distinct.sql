--https://www.w3resource.com/sql/aggregate-functions/count-with-distinct.php
/*
 * 
*/

SELECT COUNT ( DISTINCT cust_code ) AS "Number of employees" 
FROM orders;

	select ap.pcn,ap.Plexus_Customer_Code,ap.report_date,ap.Part_No,ap.revision,
	count(distinct Unit_Price) price_count,
	count(*) po_count,
	min(Unit_Price) min_price,
	max(Unit_Price) max_price
	from all_po ap 
	group by ap.pcn,ap.Plexus_Customer_Code,ap.report_date,ap.Part_No,ap.revision