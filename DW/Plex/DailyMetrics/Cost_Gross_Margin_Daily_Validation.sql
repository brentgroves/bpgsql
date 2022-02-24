
Are there the correct number of records?

select distinct pcn,Report_Date  
select count(*)
from Plex.Cost_Gross_Margin_Daily_View g 
where g.PCN = 300758 and g.Report_Date = '2022-02-15'  -- 30
order by pcn,Report_Date 

select distinct pcn,report_date 
select count(*)
from Plex.cost_gross_margin_daily_download d 
where d.PCN = 300758 and d.Report_Date = '2022-02-15' -- 30

Do the columns we need in the Daily Metrics 
have the same values as in the daily shift report CSV download?

unit_price and quantity

select 
g.customer_code,d.customer_code, 
g.order_no,d.order_no,
g.po_no,d.po_no,
g.invoice_no,d.invoice_no, 
g.part_no,d.part_no, 
g.revision,d.part_revision, 
g.sales_qty,d.sales_qty,  -- THIS IS USED ON THE DAILY METRICS REPORT NOT PRODUCTION QTY
g.quantity,d.production_qty,
g.unit_price,d.unit_price 
--select count(*)
from Plex.Cost_Gross_Margin_Daily_View g 
left outer join Plex.cost_gross_margin_daily_download d 
on g.pcn = d.pcn 
and g.report_date = d.report_date 
and g.customer_code = d.customer_code 
and g.order_no = d.order_no 
and g.po_no=d.po_no
and g.invoice_no=d.invoice_no 
and g.part_no =d.part_no 
and g.revision=d.part_revision
where g.PCN = 300758 and g.Report_Date = '2022-02-15'  -- 30
--and g.sales_qty = d.sales_qty -- 30
--and g.quantity = d.production_qty -- 30
--and g.unit_price = d.unit_price -- 23
and (((g.unit_price - d.unit_price) < -0.01) or ((g.unit_price - d.unit_price) > 0.01)) -- 0
--and (g.quantity != d.production_qty)  ---0
order by g.pcn,g.Report_Date 

