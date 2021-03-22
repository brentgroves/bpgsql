/*
TOTAL AR
*/
select
i.plexus_customer_no,
i.invoice_date,
sum (i.amount) daily_invoice_total
into #ar_total
-- select count(*)
from accounting_v_ar_invoice_e as i 
  where void = 0
  and upper(invoice_note) NOT LIKE '%TOOL%'
  and plexus_customer_no IN (300757, 300758, 310507, 306766, 295932, 295933, 123681)  -- 78021
group by i.plexus_customer_no, i.invoice_date 


/*
BEGIN SUB_PART_OP_COST
*/
select
-- top 180 
p.plexus_customer_no pcn,
p.part_key,
po.part_operation_key,
poc.cost_model_key,
sum(cc.cost) labor_var_cost
-- select count(*)
into #LaborVarCost
from part_v_part_e as p  -- 3559,1
inner join part_v_part_cost_e as pc  -- 1 to many COST MODELS
on p.plexus_customer_no= pc.pcn
and p.part_key = pc.part_key -- 45,720,21 -- 

inner join part_v_cost_model_e as cm  -- 1 to 1 
on pc.pcn= cm.pcn
and pc.cost_model_key = cm.cost_model_key -- 45,720,21 -- 

inner join part_v_part_operation_e po -- 259,797 / 84 -- 3 OPERATIONS per part
on p.plexus_customer_no=po.plexus_customer_no
and p.part_key=po.part_key  -- 1 to many

inner join part_v_part_operation_cost_e poc  --36,712 / 83  -- Missing 1?
on po.plexus_customer_no=poc.pcn
and po.part_key=poc.part_key  -- 
and po.part_operation_key=poc.part_operation_key 
and pc.cost_model_key = poc.cost_model_key -- 1 to 1

-- look at cost structure screen 
-- not all part_operation_cost records have a variable / labor cost?
left outer join part_v_Cost_Component_e cc  -- 34,089 / 126  Labor / Variable W/C cost.
on poc.pcn=cc.pcn
and poc.cost_model_key=cc.cost_model_key
and poc.part_key=cc.part_key
and poc.part_operation_key=cc.part_operation_key -- 1 to many


-- inner join Common_v_Cost_Sub_Type_e cst
-- on cc.cost_sub_type_key=cst.cost_sub_type_key

group by p.plexus_customer_no,p.part_key,po.part_operation_key,poc.cost_model_key,cm.primary_model
having p.plexus_customer_no = 300758 
AND p.part_key = 	2684942
and cm.primary_model = 1

-- select * from #LaborVarCost
-- START SUB PART SECTION

-- select count(*)
select distinct pc.pcn,
pc.part_key,
poc.part_operation_key,
cm.cost_model_key
into #operation_with_cost_component
from part_v_part_cost_e as pc  -- 

inner join part_v_cost_model_e as cm  -- 1 to 1 
on pc.pcn= cm.pcn
and pc.cost_model_key = cm.cost_model_key -- 


inner join part_v_part_operation_cost_e poc  --
on pc.pcn=poc.pcn
and pc.part_key=poc.part_key  -- 
and pc.cost_model_key = poc.cost_model_key -- 1 to many

inner join part_v_Cost_Component_e cc  -- Filters operation with no cost component.
on poc.pcn=cc.pcn
and poc.cost_model_key=cc.cost_model_key
and poc.part_key=cc.part_key
and poc.part_operation_key=cc.part_operation_key -- 1 to many

where pc.pcn = 300758 
AND pc.part_key = 	2684942
and cm.primary_model = 1;

-- select * from #operation_with_cost_component
select
ROW_NUMBER() OVER (
  PARTITION BY oc.pcn,oc.part_key,oc.cost_model_key
  ORDER BY po.operation_no
) row_no,
oc.pcn,
oc.part_key,
oc.part_operation_key,
oc.cost_model_key,
po.operation_no,
case
  when sum(pc.cost) is null then 0
  else sum(pc.cost) 
end sub_parts_cost

-- select count(*)
-- select po.operation_no
into #sub_parts
from #operation_with_cost_component oc
inner join part_v_part_operation_e po
on oc.pcn=po.plexus_customer_no
and oc.part_key=po.part_key
and oc.part_operation_key=po.part_operation_key -- 1 to 1
-- material cost
-- not all part_operation_cost records have a material cost
left outer join part_v_cost_BOM_e cb 
on oc.pcn=cb.pcn
and oc.part_key=cb.part_key
and oc.part_operation_key=cb.part_operation_key -- 1 to 1
and oc.cost_model_key=cb.cost_model_key

left outer join part_v_part_cost_e as pc  -- 1 to 1 
on cb.pcn= pc.pcn
and cb.cost_model_key=pc.cost_model_key
and cb.Component_Part_Key = pc.part_key --  

left outer join part_v_part_e as p  --
on cb.pcn=p.plexus_customer_no
and cb.component_part_key = p.part_key -- 1 to 1 

group by oc.pcn,oc.part_key,oc.part_operation_key,po.operation_no,oc.cost_model_key
order by oc.pcn,oc.part_key,oc.part_operation_key

-- select * from #sub_parts

select 
sp.row_no,
sp.pcn,
sp.part_key,
sp.part_operation_key,
sp.operation_no,
sp.cost_model_key,
sp.sub_parts_cost,
poc.cost part_op_cost,
(
  select sum(sp2.sub_parts_cost) 
  from #sub_parts sp2
  where sp2.pcn=sp.pcn
  and sp2.part_key=sp.part_key 
  and sp2.cost_model_key=sp.cost_model_key
  and sp2.operation_no <= sp.operation_no
) sub_part_op_cost
into #sub_part_op_cost
from #sub_parts sp
inner join part_v_part_operation_cost_e poc  --
on sp.pcn=poc.pcn
and sp.part_key=poc.part_key  -- 
and sp.part_operation_key=poc.part_operation_key 
and sp.cost_model_key = poc.cost_model_key -- 1 to 1

-- COMBINE SET
select 
-- sp.row_no,
sp.pcn,
sp.part_key,
sp.part_operation_key,
-- sp.cost_model_key,
p.part_no,
p.revision,
sp.operation_no,
pc.cost part_cost,
sp.part_op_cost,
sp.sub_part_op_cost,
sp.part_op_cost-sp.sub_part_op_cost part_op_cost_lab_var_only,
sp.sub_parts_cost,
lv.labor_var_cost,
cm.cost_model
-- select count(*)
into #SubPartOpCost
from #LaborVarCost lv
inner join #sub_part_op_cost sp
on lv.pcn=sp.pcn
and lv.part_key=sp.part_key
and lv.part_operation_key=sp.part_operation_key
and lv.cost_model_key=sp.cost_model_key
inner join part_v_part_e p 
on lv.pcn=p.plexus_customer_no 
and lv.part_key=p.part_key -- 1 to 1
inner join part_v_cost_model_e as cm  -- 1 to 1 
on lv.pcn= cm.pcn
and lv.cost_model_key = cm.cost_model_key 
inner join part_v_part_cost_e as pc  -- 1 to 1
on lv.pcn= pc.pcn
and lv.part_key = pc.part_key 
and lv.cost_model_key = pc.cost_model_key

select * from #SubPartOpCost

/*
END SUB_PART_OP_COST
*/
select
top 100
s.plexus_customer_no,
s.part_key,
s.part_operation_key,
CONVERT(date, s.scrap_date) scrap_date,
s.quantity,
s.unit_cost part_op_cost,
sp.sub_part_op_cost,
s.unit_cost-sp.sub_part_op_cost part_op_cost_sub_mat,
s.quantity*(s.unit_cost-sp.sub_part_op_cost) tot_part_op_cost_sub_mat
--s.extended_cost--

from part_v_scrap_e as s
inner join #SubPartOpCost sp 
on s.plexus_customer_no=sp.pcn
and s.part_key=sp.part_key 
and s.part_operation_key=sp.part_operation_key
where s.plexus_customer_no = 300758 
AND s.part_key = 	2684942
order by s.plexus_customer_no, s.scrap_date desc
-- group by s.plexus_customer_no, s.scrap_date, s.extended_cost
/*
TO-DO USE THE UNIT-COST TO LINK SCRAP TO #SubPartOpCost
in order to do this we must calc sub-part-op-cost for each cost model.
Reason: there is no cost_model_key in the scrap table
*/