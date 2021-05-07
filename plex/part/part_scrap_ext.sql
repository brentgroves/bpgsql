/*
To be used in Fruitport where we must know the cost BOM for each
part operation to calculate scrap cost.
*/

select
-- top 180 
poc.pcn,
poc.part_key,
poc.part_operation_key,
po.operation_no,
max(poc.cost_model_key) cost_model_key,
poc.cost part_operation_cost
-- select count(*)
into #part_operation_cost
-- part_operation_cost is where part_v_scrap gets its unit_cost
-- select count(*)
from part_v_part_operation_cost_e poc  --78,783 
inner join part_v_part_operation_e po 
on poc.pcn=po.plexus_customer_no
and poc.part_key=po.part_key
and poc.part_operation_key=po.part_operation_key  -- 1 to 1
group by poc.pcn,poc.part_key,poc.part_operation_key,po.operation_no,poc.cost
having poc.pcn = 295932  -- 78,783, Fruitport only  

select count(*) cnt from #part_operation_cost  -- 46,253

select
ROW_NUMBER() OVER (
  PARTITION BY poc.pcn,poc.part_key,poc.cost_model_key
  ORDER BY poc.operation_no
) row_no,
poc.pcn,
poc.part_key,
poc.part_operation_key,
poc.operation_no,
poc.cost_model_key,
case
  when sum(cb.quantity * pc.cost) is null then 0
  else sum(cb.quantity * pc.cost) 
end material_cost
-- select count(*)
-- select po.operation_no
into #cost_BOM
from #part_operation_cost poc
-- material cost
-- not all part_operation_cost records have a cost BOM
left outer join part_v_cost_BOM_e cb 
on poc.pcn=cb.pcn
and poc.part_key=cb.part_key
and poc.part_operation_key=cb.part_operation_key -- 1 to 1
and poc.cost_model_key=cb.cost_model_key
left outer join part_v_part_cost_e as pc  -- 1 to 1 
on cb.pcn= pc.pcn
and cb.Component_Part_Key = pc.part_key --  
and cb.cost_model_key=pc.cost_model_key
group by poc.pcn,poc.part_key,poc.part_operation_key,poc.operation_no,poc.cost_model_key
order by poc.cost_model_key,poc.pcn,poc.part_key,poc.part_operation_key

select 
cb.pcn,
cb.part_key,
cb.part_operation_key,
cb.cost_model_key,
(
  select 
  sum(cb2.material_cost)
  from #cost_BOM cb2
  where cb2.pcn=cb.pcn
  and cb2.part_key=cb.part_key
  and cb2.cost_model_key=cb.cost_model_key
  and cb2.operation_no <= cb.operation_no
  
) material_part_op_cost
into #material_part_op_cost
from #cost_BOM cb

select count(*) cnt from #material_part_op_cost  -- 46,253



select
-- top 180 
poc.pcn,
poc.part_key,
poc.part_operation_key,
poc.operation_no,
poc.cost_model_key,
-- cc.cost_component_key,
case
  when sum(cc.cost) is null then 0
  else sum(cc.cost) 
end  component_cost
-- select count(*)
into #ComponentCost
-- select count(*)
from #part_operation_cost poc
-- look at cost structure screen 
-- not all part_operation_cost records have a variable / labor cost
left outer join part_v_Cost_Component_e cc  
on poc.pcn=cc.pcn
and poc.cost_model_key=cc.cost_model_key
and poc.part_key=cc.part_key
and poc.part_operation_key=cc.part_operation_key -- 1 to many
left outer join part_v_cost_model_e cm
on poc.pcn=cm.pcn
and poc.cost_model_key=cm.cost_model_key
group by poc.pcn,poc.part_key,poc.part_operation_key,poc.operation_no,poc.cost_model_key



select 
-- top 200
poc.pcn,poc.cost_model_key,poc.part_key,poc.part_operation_key,poc.part_operation_cost,mc.material_part_op_cost
-- s.scrap_key
--- from part_v_scrap_e s
from #part_operation_cost poc  
inner join #material_part_op_cost mc  
on poc.pcn=mc.pcn
and poc.cost_model_key=mc.cost_model_key
and poc.part_key=mc.part_key
and poc.part_operation_key=mc.part_operation_key  -- 1 to 1
inner join #ComponentCost cc
on poc.pcn=cc.pcn
and poc.cost_model_key=cc.cost_model_key
and poc.part_key=cc.part_key
and poc.part_operation_key=cc.part_operation_key  -- 1 to 1
inner join part_v_cost_model_e cm
on poc.pcn=cm.pcn
and poc.cost_model_key=cm.cost_model_key  -- 1 to 1

/*
TESTING SECTION
*/

/*
Do all the part_v_scrap records have a part_v_part_operation_cost record? All scrap records since 2018-01-01 do have at least 1 part_v_part_operation_cost record
*/
select count(*) 
from part_v_scrap_e s
where s.plexus_customer_no = 295932  -- 792,104 Fruitport only
and s.scrap_date > '2020-01-01' -- 170587

select count(*) 
from part_v_scrap_e s
left outer join part_v_part_operation_cost poc
on s.plexus_customer_no=poc.pcn
and s.part_key=poc.part_key
and s.part_operation_key=poc.part_operation_key
where s.plexus_customer_no = 295932  -- 792,104 Fruitport only
and s.scrap_date > '2018-01-01' -- 170587
and poc.pcn is null  -- 0

/*
How many scrap records have part_operation_cost record with the same cost?
Can these costs be found in the part_operation_cost_history table?
*/
/*
select count(*) 
from part_v_scrap_e s
left outer join part_v_part_operation_cost poc
on s.plexus_customer_no=poc.pcn
and s.part_key=poc.part_key
and s.part_operation_key=poc.part_operation_key
and s.unit_cost = poc.cost  -- 435095

where s.plexus_customer_no = 295932  -- 792,104 Fruitport only
and s.scrap_date > '2019-06-01' -- 328,634
and poc.pcn is null  -- 24,885
*/
-- and s.scrap_date > '2018-01-01' -- 170587
-- and poc.pcn is null  -- 239,613
