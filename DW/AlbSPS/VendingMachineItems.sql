-- select * from VendingMachineItems vmi 
/* details query */
select 300758 pcn,vmi.VMID,
dci.picnumber,dci.drawerNumber,dci.compartmentnumber,dci.QTYCURRENT,
vmi.ITEMNUMBER,i.DESCR,
i.ITEMALIASNUMBER,i.SUPPLIERNUMBER,i.SUPPLIERPARTNUMBER,vmi.MINQTY,vmi.MAXQTY, 
i.UNITCOST,i.datecreated,i.DATELASTMODIFIED
from items i -- 177
inner join VendingMachineItems vmi  -- 1 to many
on i.ITEMNUMBER = vmi.ITEMNUMBER -- 158
inner join DrawerCompartmentItems dci 
on vmi.VMID = dci.VMID 
and vmi.ITEMNUMBER = dci.ITEMNUMBER  -- 1830 
where vmi.vmid in (4)  -- 183

/* summary query */

select 300758 pcn,vmi.VMID,
vmi.ITEMNUMBER,i.DESCR,
i.ITEMALIASNUMBER,i.SUPPLIERNUMBER,i.SUPPLIERPARTNUMBER,vmi.MINQTY,vmi.MAXQTY, 
case 
when dci.onhandqty is null then 0
else dci.onhandqty
end onhandqty,
case 
when dci.onhandqty is null then 0
else 1
end locationexist, 
i.UNITCOST,i.datecreated,i.DATELASTMODIFIED
--select count(*)
from items i -- 177
inner join VendingMachineItems vmi  -- 1 to many
on i.ITEMNUMBER = vmi.ITEMNUMBER -- 158
left outer join 
(
  select dci.vmid,dci.itemnumber,sum(dci.qtycurrent) onhandqty 
  -- dci.picnumber,dci.drawerNumber,dci.compartmentnumber,
  from DrawerCompartmentItems dci 
  group by dci.VMID,dci.ITEMNUMBER 
  having dci.VMID = 4  -- 148
) dci
on vmi.VMID = dci.VMID 
and vmi.ITEMNUMBER = dci.ITEMNUMBER  -- 1830 
where vmi.vmid = 4  -- 158

-- and SUPPLIERNUMBER = 'MSC ARCH'  -- 
-- and SUPPLIERNUMBER = 'MSC'  -- 121
-- and SUPPLIERNUMBER = 'BUSCHE'  -- 6
--and SUPPLIERNUMBER = ''  -- 6
-- 158 item 
--and DONOTORDER = 1


