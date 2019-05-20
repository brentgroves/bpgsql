select 
--count(*) 
inv.itemnumber,InactiveItem,Description1,Description2, cat.ItemClass
,inv.CriticalItemOption,minQty.Min_Quantity,maxQty.Max_Quantity
,av.cost,vn.VendorName,sc.supplier_code
from INVENTRY inv 
left outer join btRemoveItems2 ri
	on inv.ItemNumber=ri.itemnumber
-- where ri.ItemNumber is null --15709
left outer join btItemClassCatKey cat
	on inv.ItemClass = upper(cat.itemclass)
--where inv.ItemClass is null  -- 20 null items
-- where cat.ItemClass is null --15709
left outer join AltVendor av
	ON inv.AltVendorNo = av.RecNumber
left outer join VENDOR vn
	on av.VendorNumber = vn.VendorNumber
left outer join btSupplyCode sc
	on vn.VendorName=sc.VendorName
left outer join (
	select item, max(OverrideOrderPoint) as Min_Quantity
	from 
	(
		select item, OverrideOrderPoint from STATION
		where OverrideOrderPoint is not null and CHARINDEX('R',right(item,1)) = 0 
		--order by Item
		--and item = '0000003'
	)lv1
	group by item
) minQty
on inv.ItemNumber = minQty.Item
left outer join (
	select item, max(Maximum) as Max_Quantity
	from 
	(
		select item, Maximum from STATION
		where Maximum is not null and CHARINDEX('R',right(item,1)) = 0 
		--order by Item
		--and item = '007381'
	)lv1
	group by item

) maxQty
on inv.ItemNumber = maxQty.Item
left outer join btPlexItem pi
on inv.ItemNumber=pi.item_no
where inv.ItemNumber <> '' 
and left(inv.ItemNumber,1) <> ' ' 
and ri.itemnumber is null
and pi.item_no is null
and inv.ItemNumber not in (
' 00729',
'0000001',
'0005348',
'006805'
)
and vn.VendorName is not null
and sc.VendorName is null


,sc.supplier_code
--where minQty.min_quantity
where inv.itemnumber = '005949'

select * from btSupplyCode where Supplier_Code = ''
--min items
select top 5 item, OverrideOrderPoint from STATION
where item = '0000826'
where (OverrideOrderPoint is not null and CHARINDEX('R',right(item,1)) = 0 )
order by item
-- Max Items
select top 5 item, Maximum from STATION
where item = '0000826'
where Maximum is not null and CHARINDEX('R',right(item,1)) = 0 
order by item

select item,Maximum from STATION
where item in (
'009840',
'009841',
'009740',
'007374',
'007381'
)

select item,OverrideOrderPoint from STATION
where item in (
'009840',
'009841',
'009740',
'007374',
'007381'
)

select InactiveItem,ItemClass,CriticalItemOption, * 
from INVENTRY 
where  
ItemNumber = '005715R'

ItemNumber = '005756R'

select item, OverrideOrderPoint,Maximum 
from station
where item in (
--select 
--count(*)
--distinct itemnumber
--from INVENTRY
--where itemnumber in (
'006976R',
'006988R',
'006994R',
'006995R',
'006996R',
'006997R',
'006999R',
'007002R',
'007004R',
'007017',
'007018',
'007020',
'007025R',
'007029R',
'007033R',
'007035R',
'007037R',
'007051R',
'007052R',
'007053R',
'007060R',
'007062R',
'007067R',
'007069R',
'007070R',
'007076',
'007093',
'007107R',
'007111R',
'007112R',
'007114R',
'007115R',
'007119R',
'007123R',
'007125R',
'007126R',
'007134R',
'007140R',
'007145R',
'007168R',
'007171R',
'007172R',
'007173R',
'007175R',
'007176R',
'007178R',
'007179R',
'007180R',
'007182R',
'007187R',
'007191R',
'007192R',
'007197R',
'007205R',
'007209R',
'007211R',
'007212R',
'007220R',
'007222R',
'007225R',
'007226R',
'007229R',
'007231R',
'007232R',
'007235R',
'007237R',
'007251R',
'007253R',
'007254R',
'007255R',
'007260',
'007262R',
'007293R',
'007297R',
'007333',
'007364R',
'007370R',
'007373R',
'007374R',
'007387R',
'007395R',
'007402R',
'007403R',
'007405R',
'007406R',
'007408R',
'007410',
'007424R',
'007425R',
'007426R',
'007430R',
'007432R',
'007446R',
'007448R',
'007449',
'007468R',
'007474R',
'007478R',
'007480R',
'007481R'
)

select * from btItemClassCatKey