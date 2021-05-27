select 
--top 100 j.*
j.name pname,j.* 
from accounting_v_accounting_job j
where 
-- j.accounting_job_no like 'tlg%'
--and name = '2010927'
j.name like '%53379%'

select * from purchasing_v_item i where i.item_no = '14710'
/*
 * Make a SPROC GetItemUsage(LastImportItemUsage)
 */
select top 100 u.accounting_job_key,
-- j.accounting_job_no,
-- j.name,
-- u.location,
u.transaction_type_key,
--tt.transaction_type,
u.quantity,
u.usage_date,
u.cost,
u.account_no
--a.account_name 
from purchasing_v_item_usage u
-- inner join purchasing_v_item_usage_transaction_type tt 
-- on u.pcn=tt.pcn
-- and u.transaction_type_key=tt.transaction_type_key
inner join accounting_v_accounting_job j 
on u.pcn=j.pcn
and u.accounting_job_key=j.accounting_job_key
inner join accounting_v_account a
on u.pcn=j.pcn
and u.account_no = a.account_no
where u.accounting_job_key in 
(105727,105727,105728,105728)
and u.usage_date > '2021-04-27 00:00:00'

select top 100 j.accounting_job_no,j.name,u.* 
from purchasing_v_item_usage u
inner join accounting_v_accounting_job j
on u.accounting_job_key = j.accounting_job_key
where u.item_key = 1017258

-- where j.accounting_job_no like 'tlg%'
-- and j.name = '2010927'

select distinct j.accounting_job_no,j.name 
from purchasing_v_item_usage u
inner join accounting_v_accounting_job j
on u.accounting_job_key = j.accounting_job_key
where j.accounting_job_no like 'tlg%'

SELECT TOP 100 *
from part_v_part p 
-- where p.name like '%7k%'
where p.name like '%gmt%'
-- where p.part_no like '%10103351%'
where p.name like '%6k%'
where p.name like '%P558%6k%'

