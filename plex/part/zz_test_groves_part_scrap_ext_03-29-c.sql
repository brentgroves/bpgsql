select 
-- top 100
s.plexus_customer_no pcn,
s.scrap_key,
s.scrap_date,
-- s.report_date,
-- s.add_date,
-- ch.change_date,
s.part_key,
s.part_operation_key,
s.unit_cost,
case
--  when ch.cost_model_key is null then 0
  when convert(date,s.scrap_date)<=convert(date,ch.change_date) then 1 
  else 2
--  when convert(date,s.scrap_date)>convert(date,ch.change_date) then 0 
end le,
--case
--  when ch.pcn is null then 1
--  else 0
--end no_ch 
case
  when ch.cost_model_key is null then 0  -- 2172 only 8 have unit_cost > 0
  else ch.cost_model_key
end cost_model_key
into #scrap_1x
-- select count(*)
from part_v_scrap_e s -- 1,312,335
left outer join part_v_part_operation_cost_history_e ch  --3,836,753 
on s.plexus_customer_no=ch.pcn
and s.part_key=ch.part_key
and s.part_operation_key=ch.part_operation_key
and s.unit_cost=ch.cost  -- 1 to many
-- where ch.pcn is null  -- 2172
-- and s.unit_cost <> 0  -- 8

-- select count(*) from #scrap_1x -- 3,836,753
 
-- max cost_model_key whose change date is less than the scrap date.
select 
s1.pcn,s1.scrap_key,
s1.scrap_date,
s1.part_key,s1.part_operation_key,s1.unit_cost,
min(s1.le*s1.cost_model_key) exact_cost_model_key,
max(s1.cost_model_key) max_cost_model_key 
into #scrap_2x 
from #scrap_1x s1  -- --3,836,753 
-- select count(*) from #scrap_2x
group by s1.pcn,s1.scrap_key,s1.scrap_date,s1.part_key,
s1.part_operation_key,s1.unit_cost
-- having s1.lt = 1

-- select count(*) from #scrap_2x  --  1,312,335

select
top 500
p.part_no,
po.operation_no,
s2.scrap_date,
s2.unit_cost,
s2.exact_cost_model_key,
s2.max_cost_model_key
-- select count(*)
from #scrap_2x s2
inner join part_v_part_e p
on s2.pcn=p.plexus_customer_no
and s2.part_key=p.part_key
inner join part_v_part_operation_e po
on s2.pcn=po.plexus_customer_no
and s2.part_key=po.part_key
and s2.part_operation_key=po.part_operation_key -- 1,312,335
where s2.pcn = 295932
-- and s2.exact_cost_model_key = 0  -- 43,027
-- and s2.max_cost_model_key = 0  -- 74
-- and s2.unit_cost <> 0  -- 4
-- order by s2.scrap_date desc
and p.part_no='5242'
and po.operation_no = 65
and s2.unit_cost =	21.22663
order by s2.scrap_date desc
-- order by p.part_no,po.operation_no, s2.scrap_date desc

