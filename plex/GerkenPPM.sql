-- isolate this set since it may be used in multiple locations
create table #pcn
(
pcn int
)
insert into #pcn (pcn)
values
(300757), 
(300758), 
(310507), 
(306766), 
(295932), 
(295933), 
(123681)



select 
-- top 10
si.pcn,
pc.Plexus_Customer_Code plant_name,
ai.invoice_no,
ai.invoice_date date,
-- ai.invoice_note,
-- si.invoice_link,
sh.shipper_no,
-- si.shipper_key,
-- si.shipper_line_key,
-- si.invoice_line_item_no, 
c.customer_code,
c.customer_no,
p.part_key,
p.part_no,
p.part_status,
sl.quantity li_qty, 
-- ard.quantity li_qty, -- same as sl.quantity
-- ard.unit_price li_price,  -- same sl.price
sl.price li_price,
ard.credit li_amount,
ai.amount tot_amount,
-- ai.currency_amount ai_currency_amount,  -- same as ai.amount
-- ai.discount inv_discount,
-- ai.balance inv_balance,
ard.description
-- select count(*)
-- select sl.*
-- select si.pcn,sh.shipper_no
into #sales_line_item
from sales_v_shipper_ar_invoice_e as si --224608
inner join sales_v_shipper_line_e as sl -- 224608
on si.pcn = sl.pcn
and si.shipper_line_key = sl.shipper_line_key  -- 1 to 1
inner join sales_v_shipper_e as sh -- 224608
on sl.pcn = sl.pcn
and sl.shipper_key = sh.shipper_key  -- 1 to 1
left outer join common_v_customer c --inner join count = 27947, outer join count 224608
on sh.pcn=c.plexus_customer_no
and sh.customer_no=c.customer_no -- 1 to upto 1
-- where c.customer_no is null 
left join part_v_customer_part cp -- inner join count = 27947, outer join count 224608
on sl.pcn=cp.plexus_customer_no
and sl.customer_part_key=cp.customer_part_key  -- 1 upto 1
left outer join part_v_part p -- inner join count = 27947, outer join count 224608
on sl.pcn=p.plexus_customer_no
and sl.part_key=p.part_key
left outer join Accounting_v_AR_Invoice ai -- inner join count = 27947, outer join count 224608
on si.pcn=ai.plexus_customer_no
and si.invoice_link=ai.invoice_link
left outer join accounting_v_AR_Invoice_Dist ard-- inner join count = 27944, outer join count 224608
on si.pcn=ard.plexus_customer_no
and si.invoice_link= ard.invoice_link
and si.invoice_line_item_no=ard.line_item_no  -- 1 to upto 1
left outer join plexus_control_v_customer_group_member as pc
on pc.plexus_customer_no = si.pcn

where ai.void = 0
and upper(ai.invoice_note) not like '%TOOL%'
and si.pcn IN (select pcn from #pcn)
and pc.plexus_customer_code NOT LIKE '%Metal%'
and invoice_date >= '1/1/2020'
-- where sl.quantity is not null  -- 224608
-- where ard.quantity is not null  -- 27944
order by ai.invoice_no

select pcn,plant_name,customer_no,customer_code,date,part_key,part_status,sum(li_qty) ship_quantity 
into #ship_quantity
from #sales_line_item
group by pcn,plant_name,customer_no,customer_code,date,part_key,part_status 
order by date,pcn,customer_code,part_key

Select
  r.pcn,
  pc.Plexus_Customer_Code plant_name,
  r.customer_no,
  c.customer_code,
  r.return_date date,
  rl.part_key,
  p.part_status,
  rl.reported_quantity return_quantity
into #return_line
-- select count(*)  
from sales_v_return_e as r -- 1031
inner join sales_v_return_line_e as rl  -- 2466
  on r.pcn = rl.pcn
  and r.return_key = rl.return_key  -- 1 to many
left outer join common_v_customer_e as c  -- 2462  *** 4 returns do not have a customer number
  on c.plexus_customer_no = r.pcn
  and c.customer_no = r.customer_no  -- 1 upto 1
left outer join part_v_part as p -- 133  ** not many returns have a valid part_key, where they deleted.
  on p.plexus_customer_no = r.pcn
  and p.part_key = rl.part_key  -- 1 upto 1
inner join plexus_control_v_customer_group_member as pc
  on pc.plexus_customer_no = r.pcn
where r.pcn IN (select pcn from #pcn)
and r.return_date >= '1/1/2020'

select pcn,plant_name,customer_no,customer_code,date,part_key,part_status,sum(return_quantity) return_quantity 
into #return_quantity
from #return_line
group by pcn,plant_name,customer_no,customer_code,date,part_key,part_status 
order by date,pcn,customer_code,part_key

-- select count(*) from (  --9510
select sq.pcn,sq.plant_name,sq.date,sq.customer_no,sq.customer_code,sq.part_key,p.part_no,sq.part_status,
cast(sq.ship_quantity as int) ship_quantity,
case 
  when rq.return_quantity is null then 0
  else cast(rq.return_quantity as int)
end return_quantity
from #ship_quantity sq
left outer join part_v_part p
on sq.part_key = p.part_key
left outer join #return_quantity rq 
on 
sq.pcn=rq.pcn
and sq.customer_no=rq.customer_no
and sq.date=rq.date
and sq.part_key=rq.part_key
-- where rq.return_quantity is not null
order by sq.date,sq.pcn,sq.customer_code,sq.part_key
-- )s1

