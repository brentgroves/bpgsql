
/*
Item number picker query
*/
select  
item_no,Description,  
sup.supplier_code,
isp.Unit_Price,
i.Inventory_Unit
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
left outer join purchasing_v_item_supplier isu
on i.item_key = isu.item_key
left outer join common_v_supplier sup
on isu.supplier_no = sup.supplier_no
left outer join Purchasing_v_Item_Supplier_Price isp
on isu.Item_Key=isp.Item_Key and isu.Supplier_No=isp.Supplier_No
where item_type = 'Maintenance'
order by item_no
