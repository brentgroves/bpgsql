SELECT -- * from TransactionLog tl 
-- TLID,
-- VMID, 
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
SUPPLIERNUMBER
-- SUPPLIERPARTNUMBER
-- select *
FROM sps.dbo.TransactionLog
-- FROM sps.dbo.InvAdjTransactionLog iatl 
where VMID = 4
and transcode = 'WN'
--and transtartdatetime > '2021-05-13 00:00:00' -- AND '2021-05-18 00:00:00'
and jobnumber <> ''
--and ITEMGROUP = 'INSERTS'
order by TRANENDDATETIME 


SELECT -- * from TransactionLog tl 
TLID,
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
-- select *
FROM sps.dbo.TransactionLog
-- FROM sps.dbo.InvAdjTransactionLog iatl 
where VMID = 4
and transcode = 'WN'
--and transtartdatetime BETWEEN '2021-05-13 00:00:00' AND '2021-05-18 00:00:00'
--and ITEMGROUP = 'INSERTS'
order by TRANENDDATETIME 

select distinct transcode from Transactions t 
select 
--itemaliannumber = 36207330
-- SUPPLIERPARTNUMBER = 2960855

select 
j.JOBNUMBER,j.DESCR 
from Jobs j  -- 37
-- 1 job is Marker

select * 
from Jobs_VendingMachineAssignment jvma  
-- where vmid = 2 -- 36
where vmid = 1 -- 36
[ADO NET Source [47]] Error: An error occurred executing the provided SQL command: "SELECT 
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
where transtartdatetime > Apr 27 2021 12:00AM". Incorrect syntax near '27'.

select * from sps.dbo.TransactionLog tl where TRANSTARTDATETIME > '2021-05-17 00:00:00'
SELECT 
t.tlid,
t.VMID, 
j.JOBNUMBER,j.DESCR, 
t.JOBNUMBER, 
t.transtartdatetime,
t.TRANENDDATETIMe,
t.TRANSCODE,
t.USERNUMBER,
t.USERGROUP01, 
t.ITEMNUMBER,
t.UNITCOST,
t.qty,
t.QTYNEW,
t.QTYONORDER,
t.ITEMGROUP, 
t.ITEMALIASNUMBER, 
t.SUPPLIERNUMBER,
t.SUPPLIERPARTNUMBER
FROM sps.dbo.TransactionLog t 
inner join Jobs j 
on t.JOBNUMBER = j.JOBNUMBER 
where transtartdatetime BETWEEN '2021-05-13 00:00:00' AND '2021-05-14 00:00:00'
and ITEMGROUP = 'INSERTS'


SELECT '300758' PCN,
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
-- select count(*) -- 1213, 6/8/2021
FROM sps.dbo.TransactionLog
 where VMID = 4 -- Plant 6
and transcode = 'WN'
and jobnumber <> ''
and tranenddatetime > '2021-04-27 00:00:00'

