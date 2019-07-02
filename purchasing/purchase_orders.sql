
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

/*
PO Type
Raw Materials
Components
Customer Supplied Components
Subcontract
MRO/Supply
Supplies
Maintenance
Tooling
Tooling - Service
Gaging
Customer Owned
Capital Equipment
Miscellaneous

Department
Created from Upload on 03/21/2019
100 - Mfg	Manufacturing
300 - EngOps	Engineering Ops
310 - QA	Quality
320 - Maint	Maintenance
330 - Facil	Facilities
340 - Tool	Tool & Die
350 - GProd	General Prod (Materials / Indirect)
360 - Stockroom	Store/Stockroom
810 - Sales	Sales
820 - EngAdm	Engineering Admin and Design
850 - Admin	Administration
855 - EHS	Environmental, Health and Safety
860 - Pers	Personnel
865 - Fin	Finance
870 - Pur	Purchasing
875 - IT	Information Technology
880 -ProDev	Project and Development
Supplier	Supplier

Maintenance Accounts 
Each line item can be assigned to 1 Accounting.Account
70100-000-0000	Repairs & Maint - Building
70100-100-0000	Repairs & Maint - Building-Manufacturing-General
70100-320-0000	Repairs & Maint - Building Maint
70200-100-0000	Repairs & Maint - Machine MFG
70200-320-0000	Repairs & Maint - Machine Maint
70250-100-0000	Repairs & Maint - Material Handling Equipment MFG
70250-100-1800	Repairs & Maint - Material Handling Equipment Shipping
70250-320-0000	Repairs & Maint - Material Handling Equipment Maint
70300-100-0000	Repairs & Maint - Tooling MFG
70350-100-0000	Repairs & Maint - Gages MFG
70350-310-0000	Repairs & Maint - Gages QA
70350-320-0000	Repairs & Maint - Gages Maint
70375-100-0000	Repair & Maint - PM-Manufacturing-General
70400-310-0000	Repairs & Maint - Other QA
70400-320-0000	Repairs & Maint - Other Maint
70400-330-0000	Repairs & Maint - Other Fac
70400-850-0000	Repairs & Maint - Other Admin

Each Line Item can be assigned to 1 Accounting.AccountJob
MNT00000000018	RM-Plant 2-Oil
MNT00000000019	RM-Plant 3-Oil
MNT00000000020	RM-Plant 5-Oil
MNT00000000021	RM-Plant 6-Oil
MNT00000000022	RM-Plant 7-Oil
MNT00000000023	RM-Plant 8-Oil
MNT00000000024	RM-Plant 9-Oil
MNT00000000025	RM-Edon-Oil
MNT00000000026	RM-Plant 2-Coolant
MNT00000000027	RM-Plant 3-Coolant
MNT00000000028	RM-Plant 5-Coolant
MNT00000000029	RM-Plant 6-Coolant
MNT00000000030	RM-Plant 7-Coolant
MNT00000000031	RM-Plant 8-Coolant
MNT00000000032	RM-Plant 9-Coolant
MNT00000000033	RM-Edon-Coolant
MNT00000000034	RM-Plant 2-Equip. Repair
MNT00000000035	RM-Plant 3-Equip. Repair
MNT00000000036	RM-Plant 5-Equip. Repair
MNT00000000037	RM-Plant 6-Equip. Repair
MNT00000000038	RM-Plant 7-Equip. Repair
MNT00000000039	RM-Plant 8-Equip. Repair
MNT00000000040	RM-Plant 9-Equip. Repair
MNT00000000041	RM-Edon-Equip. Repair
MNT00000000042	RM-Plant 2-Prev. Maint.
MNT00000000043	RM-Plant 3-Prev. Maint
MNT00000000044	RM-Plant 5-Prev. Maint
MNT00000000045	RM-Plant 6-Prev. Maint.
MNT00000000046	RM-Plant 7-Prev. Maint.
MNT00000000047	RM-Plant 8-Prev. Maint.
MNT00000000048	RM-Plant 9-Prev. Maint.
MNT00000000049	RM-Edon-Prev. Maint.
MNT00000000050	RM-Plant 2-Cont. Serv.
MNT00000000051	RM-Plant 3-Cont. Serv.
MNT00000000052	RM-Plant 5-Cont. Serv.
MNT00000000053	RM-Plant 6-Cont. Serv.
MNT00000000054	RM-Plant 7-Cont. Serv.
MNT00000000055	RM-Plant 8-Cont. Serv.
MNT00000000056	RM-Plant 9-Cont. Serv.
MNT00000000057	RM-Edon-Cont. Serv.
MNT00000000058	RM-Plant 2-Safety Exp.
MNT00000000059	RM-Plant 3-Safety Exp.
MNT00000000060	RM-Plant 5-Safety Exp.
MNT00000000061	RM-Plant 6-Safety Exp.
MNT00000000062	RM-Plant 7-Safety Exp.
MNT00000000063	RM-Plant 8-Safety Exp.
MNT00000000064	RM-Plant 9-Safety Exp.
MNT00000000065	RM-Edon-Safety Exp.
MNT00000000066	RM-Plant 2-M&R Misc.
MNT00000000067	RM-Plant 3-M&R Misc.
MNT00000000068	RM-Plant 5-M&R Misc.
MNT00000000069	RM-Plant 6-M&R Misc.
MNT00000000070	RM-Plant 7-M&R Misc.
MNT00000000071	RM-Plant 8-M&R Misc.
MNT00000000072	RM-Plant 9-M&R Misc.
MNT00000000073	RM-Edon-M&R Misc.
*/
--select po.po_no,po.po_type,po.po_date,dpt.Department_Code,
--sup.supplier_code 

--select po.po_no,po.po_type,po.po_date,dpt.Department_Code,
--sup.supplier_code 

Declare @min_date datetime
set @min_date = '6/10/2019 00:00:00 AM'
Declare @max_date datetime
set @max_date = '7/2/2018 10:42:43 AM'
--select count(*) --8

--from
--(
select po.po_no,
po.po_type,
li.item_key,
li.part_key,
li.updated_by,
i.item_no,
i.description,
i.manufacturer_key,
m.manufacturer_code,
po.supplier_no,
sup.supplier_code,
sup.name,
po.po_type,po.po_date,
Issued_By,
pu.last_name,
li.Manufacturer_No,
li.account_no,
a.account_name,
j.accounting_job_no,
li.for_job_key,
--dpt.name,
dpt.name as Dept_Name, 
li.Supplier_Part_No
from purchasing_v_po po
left outer join Purchasing_v_po_type pt
on po.po_type=pt.po_type
left outer join common_v_supplier sup
on po.supplier_no = sup.supplier_no
left outer join common_v_department dpt
on po.department_no=dpt.department_no
left outer join purchasing_v_line_item li
on po.po_key = li.po_key
left outer join accounting_v_account a
on li.account_no=a.account_no
left outer join accounting_v_accounting_job j
on li.accounting_job_key=j.accounting_job_key
left outer join purchasing_v_item i
on li.item_key=i.item_key
left outer join common_v_manufacturer m
on i.manufacturer_key=m.manufacturer_key
left outer join Plexus_Control_v_Plexus_User pu
on po.issued_by=pu.Plexus_User_No
--left outer join Plexus_Control_v_Plexus_User pu
--on li.updated_by=pu.Plexus_User_No
--where pu.last_name = 'Swank'
where pu.last_name = 'Try'

--and j.accounting_job_no is not null 
--where i.item_no = '0001035'
--where po.po_no = 'BM001568'
and  po.po_date > @min_date
--)tst


select * from Plexus_Control_v_Plexus_User pu
where pu.last_name = 'Swank'
--where pu.last_name = 'Try'
--where po.po_type = 'Tooling'
--where po.po_no = '001126'

--where po.po_type like '%Tooling%'
--left outer join common_v_department dpt
--on dpt.department_no=dpt.department_no
--where po.po_type = 'Tooling'
--and po.po_date > @min_date
--and li.item_key is not null

select * from common_v_department where department_no = '32197'
select Manf_Item_No,brief_description,* from purchasing_v_item
select * from  Accounting_v_Account where Account_name like '%erishable%'

select distinct po_type from purchasing_v_po po where po.po_no like '%0171%'

select * from accounting_v_accounting_job
select * from accounting_v_account
