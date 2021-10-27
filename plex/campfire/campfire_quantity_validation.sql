/*
Parameters:
@PCN INT = '',
@Start_Date DATETIME,
@Current_Month_Begin DATETIME = '',
@Month_1_Begin DATETIME = '',
@Month_2_Begin DATETIME = '',
@Month_3_Begin DATETIME = '',
@Month_4_Begin DATETIME = '',
@Month_5_Begin DATETIME = '',
@Month_6_Begin DATETIME = '',
@Month_7_Begin DATETIME = ''
*/

--SET @PCN = (SELECT TOP 1 P.Plexus_Customer_No FROM Part_v_Part AS P);
/*
Taken from AR_Invoice_Dist_Get customer data source

*/

SET @Start_Date = ISNULL(@Start_Date, GETDATE());

/* 

All parameters except @Start_date and @PCN are set in SPROC overwriting parameter values.  

*/ 

SET @Current_Month_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, -1, @Start_Date)));
SET @Month_1_Begin = DATEADD(d, 1, EOMONTH(@Start_Date));
SET @Month_2_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 1, @Start_Date)));
SET @Month_3_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 2, @Start_Date)));
SET @Month_4_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 3, @Start_Date)));
SET @Month_5_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 4, @Start_Date)));
SET @Month_6_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 5, @Start_Date)));
SET @Month_7_Begin = DATEADD(d, 1, EOMONTH(DATEADD(MM, 6, @Start_Date)));

/*
select @Start_Date start_date;
SELECT @Current_Month_Begin Current_Month_Begin;
SELECT @Month_1_Begin Month_1_Begin;
SELECT @Month_2_Begin Month_2_Begin;
SELECT @Month_3_Begin Month_3_Begin;
SELECT @Month_4_Begin Month_4_Begin;
SELECT @Month_5_Begin Month_5_Begin;
SELECT @Month_6_Begin Month_6_Begin;
SELECT @Month_7_Begin Month_7_Begin;
*/
-- Accounting_p_AR_Invoices_Get_Routed_All
/*
WHERE (DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) >= @Current_Month_Begin 
  AND DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) < @Month_1_Begin)

What is the Timezone_offset? 0 except -1 for alabama
select lt.timezone_offset,cg.* from Plexus_Control_v_Customer_Group_Member AS CG  -- all PCN
LEFT OUTER JOIN Plexus_Control_v_Logical_Timezone AS LT
  ON LT.Timezone_Key = CG.Timezone_Key
  
How many Albion AR_Dist records have an offset other than 0
select distinct(d.offset)
select d.offset,count(*) 
from accounting_v_AR_Invoice_Dist d
group by d.offset -- 0 = 37,633 and 1 = 21,186
  
*/

/*
Taken from AR_Invoice_Dist_Get customer data source

*/
select 'The following was taken from AR_Invoice_Dist_Get customer data source'
select 
I.Plexus_Customer_No,
I.Invoice_Link,
I.Invoice_No,
--       ID.Description,
D.Part_Key,
p.part_no,
I.Invoice_Date,

d.quantity,
d.line_item_no,
d.account_no,
d.description,
d.debit,
d.credit
--select count(*)
FROM accounting_v_AR_Invoice_e AS I 
JOIN accounting_v_AR_Invoice_Dist_e AS D 
  ON D.Plexus_Customer_No = I.Plexus_Customer_No
  AND D.Invoice_Link = I.Invoice_Link
 -- AND D.Offset = 0  -- we don't know
join part_v_part_e p
on d.plexus_customer_no=p.plexus_customer_no
and d.part_key=p.part_key
where d.part_key = 2796137
and I.Invoice_Date >= @Current_Month_Begin
and I.Invoice_Date < @Month_1_Begin
order by d.part_key

select 
'tot_quantity using AR_Invoice_Dist_Get_customer_data_source method=' method,
sum(d.quantity) tot_quantity
--select count(*)
FROM accounting_v_AR_Invoice_e AS I 
JOIN accounting_v_AR_Invoice_Dist_e AS D 
  ON D.Plexus_Customer_No = I.Plexus_Customer_No
  AND D.Invoice_Link = I.Invoice_Link
 -- AND D.Offset = 0
where d.part_key = 2796137
and I.Invoice_Date >= @Current_Month_Begin
and I.Invoice_Date < @Month_1_Begin
--and d.offset = 0 
--and d.offset = 1  -- no records
--order by d.part_key
  -- select * from part_v_part where part_no = '10037203'  -- 2796137
  /*
  What is the offset field?
  */
--select distinct(d.offset) from accounting_v_AR_Invoice_Dist AS D -- 0 and 1
--select d.offset,count(d.offset) from accounting_v_AR_Invoice_Dist AS D group by d.offset 
-- 0 = 37,633 and 1 = 21,186
-- select * from part_v_part where part_key = 2796137
/*
How does plante_moran get the quantity
*/
select
*
into #plante_moran
from
(
SELECT DISTINCT
       AI.Plexus_Customer_No,
       AI.Invoice_Link,
       CG.Currency_Key,
       AI.Invoice_No,
--       ID.Description,
       ID.Part_Key,
       AI.Invoice_Date,
       LT.Timezone_Offset,
       DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) invoice_date_wo, 
       SUM(ID.Unit_Price) AS Unit_Price,
       ID.Quantity,
       SUM(ID.Taxable_Amount) AS Taxable_Amount,
       AI.Exchange_Rate,
       --C.Currency_Key,
       AI.Currency_Code--,
--       AI.Ship_To_Address
---select count(*)
--into #matt

FROM Accounting_v_AR_Invoice_e AS AI  -- 91626
LEFT OUTER JOIN Accounting_v_AR_Invoice_Dist_e AS ID  -- 1 to many, Line items for invoice
  ON ID.Plexus_Customer_No = AI.Plexus_Customer_No
  AND ID.Invoice_Link = AI.Invoice_Link --, 363533
LEFT OUTER JOIN Plexus_Control_v_Customer_Group_Member AS CG
  ON CG.Plexus_Customer_No = AI.Plexus_Customer_No
LEFT OUTER JOIN Plexus_Control_v_Logical_Timezone AS LT
  ON LT.Timezone_Key = CG.Timezone_Key
LEFT OUTER JOIN Common_v_Currency AS C
  ON C.Currency_Code = AI.Currency_Code
WHERE (DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) >= @Current_Month_Begin 
  AND DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) < @Month_1_Begin)
GROUP BY
  AI.Plexus_Customer_No,
  AI.Invoice_Link,
  CG.Currency_Key,
  AI.Invoice_No,
  ID.Part_Key,
  AI.Invoice_Date,
  LT.Timezone_Offset,
  ID.Quantity,
  AI.Exchange_Rate,
  C.Currency_Key,
  AI.Currency_Code
having id.part_key = 2796137
)s

select 'The following is detail records if we use the Campfire_Extract_V2 Invoice group clause' description

select 'Notice there is only 1 record for invoice AB19747' description
select * from #plante_moran
select 
'tot_quantity using Campfire_Extract_V2 = ' method,
sum(quantity) tot_quantity
from #plante_moran
select 'This is 48 less parts than we got when using the AR_Invoice_Dist_Get_customer_data_source method'

select 'Which quantity is correct?'

--AB19747

select 'Notice the 2 distinct line_item_no for AB19747 in the following set' description
---select count(*)
select 
ai.invoice_no,
id.line_item_no,
--id.*,
a.account_no,
a.account_name,
id.quantity,
  AI.Plexus_Customer_No,
  AI.Invoice_Link,
  CG.Currency_Key,
  AI.Invoice_No,
  ID.Part_Key,
  AI.Invoice_Date,
  LT.Timezone_Offset,
  ID.Quantity,
  AI.Exchange_Rate,
  C.Currency_Key,
  AI.Currency_Code

FROM Accounting_v_AR_Invoice_e AS AI  -- 91626
LEFT OUTER JOIN Accounting_v_AR_Invoice_Dist_e AS ID  -- 1 to many, Line items for invoice
  ON ID.Plexus_Customer_No = AI.Plexus_Customer_No
  AND ID.Invoice_Link = AI.Invoice_Link --, 363533
LEFT OUTER JOIN Plexus_Control_v_Customer_Group_Member AS CG
  ON CG.Plexus_Customer_No = AI.Plexus_Customer_No
LEFT OUTER JOIN Plexus_Control_v_Logical_Timezone AS LT
  ON LT.Timezone_Key = CG.Timezone_Key
LEFT OUTER JOIN Common_v_Currency AS C
  ON C.Currency_Code = AI.Currency_Code
left outer join accounting_v_account a
on id.plexus_customer_no= a.plexus_customer_no
and id.account_no= a.account_no
WHERE (DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) >= @Current_Month_Begin 
  AND DATEADD(HOUR, LT.Timezone_Offset, AI.Invoice_Date) < @Month_1_Begin)
and id.part_key = 2796137

select 'Notice the 2 shipper line items for this invoice.'  
select sl.release_key,sl.part_key,sl.quantity,sl.*
from sales_v_shipper_e s 
inner join sales_v_shipper_line_e sl
on s.pcn=sl.pcn
and s.shipper_key=sl.shipper_key
where s.shipper_no = 'AB19747'
and sl.part_key = 2796137

select 'Notice the 2 shipper_container serial numbers for the shipper line itemss' note
select * from sales_v_shipper_container c
where shipper_line_key in (30148143,30148144)

select 'We verified this data by clicking on the shipper associated with the invoice from the Plex customer invoice screen'
select 'It looks like there were 2 container with quantity of 48 shipped to the customer so the quantity for this part number should be 288.'
/*
pn: 10037203
start: 10/1/21
end: 11/1/21
select * from accounting_v_account_link  -- 0
select * from accounting_v_account where account_no in ('11010-000-0000','40000-000-0000')
-- category_type 
-- '11010-000-0000' = Asset
--'40000-000-0000' = Revenue

*/