/*
Account_no, Account_Name
2	12200-000-0000	Raw Materials - Packaging
3	16700-000-0000	Tooling - Owned
4	70300-100-0000	Repairs & Maint - Tooling MFG
5	70750-100-1800	Supplies Expense - Production Shipping
6	70800-000-0000	Supplies Expense - Packaging
7	70900-850-0000	Supplies Expense - Other Admin
8	71000-100-5005	Perishable Tools Expense-Manufacturing-PT - Sharpening
9	71000-100-5010	Perishable Tools Expense-Manufacturing-PT - Drills
10	71000-100-5015	Perishable Tools Expense-Manufacturing-PT - Tool Holders
11	71000-100-5020	Perishable Tools Expense-Manufacturing-PT - Fixtures
12	71000-100-5025	Perishable Tools Expense-Manufacturing-PT - Inserts
13	71000-100-5030	Perishable Tools Expense-Manufacturing-PT - Hardware
14	71000-100-5040	Perishable Tools Expense-Manufacturing-PT - Taps
15	71000-100-5090	Perishable Tools Expense-Manufacturing-PT - Misc
16	76200-850-0000	Advertising Expense Admin
*/

select account_no,account_name
from accounting_v_account act
where account_name like '%Repair%'
--where account_no = '70200-100-0000'
--select distinct account_no,account_name
--select distinct tax_code_no
--select count(*)
--select distinct account_no,account_name
select top 10 item_no, item_category, newDescription,tax_code_no, tax_code 
from
(
select 
--top 100
  i.item_no,
  i.active,
  i.Brief_Description,
  i.description as CurDescription,
  case
    when i.brief_description = i.description then i.description
    else i.brief_description + ', ' + i.description
  end as NewDescription,
  i.note,
  t.Item_Type,
  g.Item_Group,
  c.Item_Category,
  p.Item_Priority,
  ip.Customer_Unit_Price, -- nothing in this table???
  isp.Unit_Price,
  i.Average_Cost,
  i.Inventory_Unit,
  i.min_quantity,
  i.max_quantity,
  i.tax_code_no,
  tx.tax_code,
  i.account_no, -- dont fill
  act.account_name, -- not on upload
  i.manufacturer,
  i.Manf_Item_No,
  i.Drawing_No,
  l.quantity as Item_Quantity, 
  l.location,
  sup.supplier_code,
  ' ' as Supplier_Part_No, 
  ' ' as Supplier_Std_Purch_Qty, 
  'USD' as Currency, -- not sure how to link to item. Check item_localization or supplier_* table
  '' as Supplier_Std_Unit_Price, 
  '' as Supplier_Purchase_Unit, 
  1 as Supplier_Unit_Conversion, 
  '' as Supplier_Lead_Time, 
  'Y' as Update_When_Received, 
  i.Manufacturer_Item_Revision,
  i.Country_Of_Origin,
  i.Commodity_Code_Key,
  '' as Harmonized_Tariff_Code, -- No info on this
	i.Cube_Length,
	i.Cube_Width,
	i.Cube_Height,
	i.Cube_Unit_key
from purchasing_v_item_location l
left outer join purchasing_v_item i
  on l.item_key=i.item_key
left outer join Purchasing_v_Tax_Code tx 
on i.tax_code_no=tx.tax_code_no 
left outer join common_v_location cl
  on l.location=cl.Location
  --13591
left outer join common_v_building cb
  on cl.building_key = cb.building_key
  --13591
left outer join common_v_location_type lt
  on cl.location_type=lt.location_type
  --13591
left outer join common_v_location_group lg
  on cl.location_group_key=lg.location_group_key
left outer join purchasing_v_item_type as t
  on i.item_type_key = t.item_type_key
left outer join Purchasing_v_Item_Group as g
  on i.item_group_key = g.item_group_key
left outer join purchasing_v_item_category as c
  on i.item_Category_key = c.item_Category_key
left outer join purchasing_v_item_priority as p
  on i.item_priority_key = p.item_priority_key 
left outer join purchasing_v_item_supplier isu
  on i.item_key = isu.item_key
left outer join Purchasing_v_Item_Supplier_Price isp
on isu.Item_Key=isp.Item_Key and isu.Supplier_No=isp.Supplier_No
left outer join common_v_supplier sup
  on isu.supplier_no = sup.supplier_no
left outer join common_v_supplier_part par
  on sup.supplier_no = par.supplier_no
left outer join accounting_v_account act
  on i.account_no = act.account_no  
left outer join Purchasing_v_Item_Price ip
  on i.item_key = ip.item_key
  
--Building_code and location_group uniquely identify the locations as being for
--the MRO.  Location_group of Maintenance Crib are messed up Maintenance locations
--that should be excluded.
where cb.building_code = 'BPG Central Stores' --12700
--lt.location_type='Supply Crib' --13525
and --12700
lg.location_group = 'MRO Crib' --12700
and i.account_no = '' or i.account_no is null

)set1
where tax_code_no = '70'
