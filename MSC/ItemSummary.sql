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


/*
 * 
 * 
"select 300758 pcn,vmi.VMID,
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
where vmi.vmid = @[User::VMID]"  -- 158
 '"  +  @[User::VMID] + "'"

"SELECT '300758' PCN,
tlid,
VMID,
transtartdatetime,
TRANENDDATETIMe,
TRANSCODE,
USERNUMBER,
USERGROUP01, 
JOBNUMBER, 
ITEMNUMBER,
UNITCOST,
qty,
QTYNEW,
QTYONORDER,
ITEMGROUP, 
ITEMALIASNUMBER, 
SUPPLIERNUMBER,
SUPPLIERPARTNUMBER
FROM sps.dbo.TransactionLog
 where VMID in (4) 
and transcode = 'WN'
and jobnumber <> ''
and tranenddatetime > '"  +  @[User::LastImportTransactionLog] + "'"
