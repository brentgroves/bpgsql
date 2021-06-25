/*
This total cost maybe derived by taking the quantity * the most recent cost at the time of the checkout.
If it is zero then pull it from the last purchasing_item_summary cost in the Dw.
*/
select 
row_number() over(order by u.pcn,i.item_no) id,
u.pcn, u.item_key,i.item_no,
CAST(CAST(i.item_no AS INT) AS VARCHAR(50)) trim,
j.accounting_job_key,u.account_no,u.location,
cast(- u.quantity as int) quantity, -- removed negative sign
u.usage_date, 
- u.cost total_cost, -- removed negative sign
u.transaction_type_key,tt.transaction_type
from purchasing_v_item_usage_e u
inner join accounting_v_accounting_job_e j
on u.pcn=j.pcn
and u.accounting_job_key = j.accounting_job_key
inner join purchasing_v_item_usage_transaction_type_e tt
on u.pcn=tt.pcn
and u.transaction_type_key= tt.transaction_type_key
inner join 
(
  select i.plexus_customer_no pcn,i.item_key,i.item_no from purchasing_v_item_e i
  where i.plexus_customer_no = @PCN
  and i.item_no not like '%[A-Z-]%'  --17558
) i
on u.pcn=i.pcn
and u.item_key=i.item_key
where u.pcn = @PCN
and u.accounting_job_key in (105727,105728,105730,105729)  -- These are all the acounting_job_key in the DW.Map.ToolPartOpToJob table. 06-23-2021
and transaction_type = 'Checkout'

/*
decimal (19,4)
*/
-- select operation_code from part_v_operation
/*
Add 3 sets to DW
1. purchaseing_item_summary_DW
2. purchasing_item_usage_DW
3. purchasing_item_inventory_DW
*/
