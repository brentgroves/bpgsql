-- select distinct transcode from Transactions t 

-- select * from sps.dbo.TransactionLog tl where TRANSTARTDATETIME > '2021-06-9 00:00:00'

SELECT 
'300758' PCN,
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
-- select count(*) -- 1316, 6/8/2021
FROM sps.dbo.TransactionLog
where VMID in (4) -- vmid 4/Plant 6 tooling
and transcode = 'WN'
and jobnumber <> ''
 and tranenddatetime > '2021-04-27 00:00:00'
-- and ITEMNUMBER like '%R'

select * from albsps.import
/*
 * 
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
where transtartdatetime BETWEEN '2021-05-13 00:00:00' AND '2021-06-11 00:00:00'
and ITEMGROUP = 'INSERTS'
and t.VMID <> 4


 */
*/