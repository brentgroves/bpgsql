--Create map from Plex supplier_code to Crib vendorName	
--Busche Albion,Busche 
-- Cant find these in plex
-- CUSTOMER SUPPLIED
--Busches Enterprises maps to Busche Albion?
-- delete from btsupplycode where supplier_code like '%n++%'
--select * from btSupplyCode where supplier_code like '%2l%'
select * 
from btSupplyCode
where vendorname = 'BUSCHE ENTERPRISES'
update btSupplyCode
set VendorName = 'BUSCHE ENTERPRISES'
where Supplier_Code = 'Busche Albion'
-- SP3 Cutting Tools, and Tri-Star Engineering,Whittet-Higgins (Pending)
select *
from
(
select ROW_NUMBER() OVER(ORDER BY VendorName ASC) AS Row#, VendorName
from (
select 
--top 100 inv.ItemNumber,inv.Description1,vn.VendorName,sc.supplier_code
distinct vn.VendorName  --159
-- done 3/159
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
left outer join STATION st 
	on inv.ItemNumber=st.Item
where ri.ItemNumber is null --15709

--and item='15977'
--and sc.vendorname is not null
--order by vn.VendorName
)lv1
)lv2
where row# > 154
--******************START AT ROW 53
-- What items are not in plex?
-- Are all the items in plex marked inactive that are not supposed to be in there.

--Bulk insert btRemoveItems
--from 'C:\itemsremove2.csv'
Bulk insert btSupplyCode
from 'C:\supplier_code.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)

