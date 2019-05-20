select * 
into btInventry0423
from INVENTRY 
where itemnumber in (
--	'0000105'
'008614', 
'0001447',
'13934'
)
our 2 fields our varchar(50)
plex Description is varchar(800)
update btInventry0423 set Description1 = Description1 + ', ' + SUBSTRING(Description2,1, 5) where Description2 is not null
select * from btInventry0423
select itemnumber,st.cribbin,st.BinQuantity 
from INVENTRY inv
left outer join STATION st
on inv.ItemNumber=st.item
where itemnumber = '16957'
--5/
Create View bvCribItems
as
select item
from
(
	select 	
	Item_No,Brief_Description,Description,Note,Item_Type,Item_Group,Item_Category,
	Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
	Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,Location,Supplier_Code,
	Supplier_Part_No,Supplier_Std_Purch_Qty,Currency,Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
	Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
	Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
	Cube_Unit			
	from
	(
			select 
				--top 100
				row_number() OVER(ORDER BY inv.ItemNumber ASC) AS Row#,
				inv.itemnumber as "Item_No",
				--'"' + inv.itemnumber + '"' as "Item_No",
				--inv.ItemNumber as Item_No,
				Description1 as "Brief_Description", 
--				isnull(Description2,Description1) as Description,
				case 
					when Description2 is null then Description1
					else Description1 + ', ' + Description2
				end as Description,
				case 
					when inv.Comments is null then ' '
					else inv.Comments
				end as Note,
				case
					when InactiveItem = 1 then 'Obsolete'
					else 'Tooling'
				end as item_type,
				case 
					when CHARINDEX('R',right(inv.ItemNumber,1)) <> 0 then 'Regrinds-Repair-Retip'
					else 'Tooling'
				end as Item_Group,
				case
					-- Added these 2 item classes to table
					-- when inv.ItemClass = 'HYDRUALIC VALVE' then 'Hydraulic Valve' 
					-- when inv.ItemClass = 'PIVOT PIN' then 'Pivot Pin'
					when inv.ItemClass is null then 'Misc'
					else cat.ItemClass 
				end as Item_Category,
				case
					when CriticalItemOption = 1 then 'High'
					when InactiveItem = 1 then 'Low'
					else 'Medium'
				end as Item_Priority,
				av.Cost as Customer_Unit_Price,
				'' as Average_Cost,
				'Ea' as Inventory_Unit,
				minQty.Min_Quantity,
				maxQty.Max_Quantity,
				70 as Tax_Code,
				'' as Account_No,
				'' as Manufacturer,
				Description1 as Manf_Item_No,
				'' as Drawing_No,
				'' as Item_Quantity,
				'' as Location,
				sc.Supplier_Code,
				Description1 as Supplier_Part_No,
				'' as Supplier_Std_Purch_Qty,
				'USD' as Currency,
				av.Cost as Supplier_Std_Unit_Price,
				'Ea' as Supplier_Purchase_Unit,
				1 as Supplier_Unit_Conversion,
				'' as Supplier_Lead_Time,
				'Y' as Update_When_Received,
				'' as Manufacturer_Item_Revision,
				'' as Country_Of_Origin,
				'' as Commodity_Code_Key,
				'' as Harmonized_Tariff_Code,
				'' as Cube_Length,
				'' as Cube_Width,
				'' as Cube_Height,
				'' as Cube_Unit
			-- select 
			-- count(*) -- 16631 
			-- distinct inv.ItemNumber --16631
			-- btRemoveItems count	    -  982
			--                          =15649     
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
				)lv1
				group by item
			) minQty
			on inv.ItemNumber = minQty.Item
			left outer join (
				select item,  max(Maximum) as Max_Quantity
				from 
				(
					select item, Maximum from STATION
					where Maximum is not null and CHARINDEX('R',right(item,1)) = 0 
				)lv1
				group by item
			) maxQty
			on inv.ItemNumber = maxQty.Item
			--left outer join btPlexItem pi
			--on inv.ItemNumber=pi.item_no
			where inv.ItemNumber <> '' 
			and left(inv.ItemNumber,1) <> ' ' 
			and inv.ItemNumber <> ' 00729'
			and ri.itemnumber is null
			--and pi.item_no is null
			and inv.ItemNumber not in (
			' 00729',
			'0000001',
			'0005348'
			)
			--2122
	)lv1
	where Supplier_Std_Unit_Price is null
	where item_no in (
	'17038','17039','17040','17041','17042','17043',
	'17038R','17039R','17040R','17041R','17042R','17043R'
--'17005','16957','17031','16296'
	)
	or ((item_no >= '17044') and (item_no <= '17064'))
)lv2
select * from INVENTRY where itemnumber = '30729'
select * from btRemoveItems2 where itemnumber = '0002008'
--
select distinct ItemClass from INVENTRY
-- Supply Items in Plex
--CREATE TABLE Cribmaster.dbo.btPlexItem (
	Item_No varchar(50) NOT NULL,
)

-- Drop table 

-- DROP TABLE Cribmaster.dbo.btPlexItem
select itemnumber from INVENTRY order by itemnumber 


CREATE TABLE Cribmaster.dbo.btPlexItem (
	Item_No varchar(50) NOT NULL,
	active int
)


--Bulk insert btPlexItem
from 'C:\PlexItemGT15000.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)
--5000 
--5000
--5000
--3237
--=18237

-- Inactive Items in plex but not it Cribmaster = 4418.
-- Mostly because of Extra zeros
select 
count(*)
--pi.*
from btPlexItem pi
left outer join INVENTRY inv
on pi.item_no=inv.ItemNumber
where inv.ItemNumber is null
and pi.active=0

-- Active Items in plex but not it Cribmaster.
select 
--count(*)
pi.*
from btPlexItem pi
left outer join INVENTRY inv
on pi.item_no=inv.ItemNumber
where inv.ItemNumber is null
and pi.active=1
--delete from btPlexItem where Item_No like 'n++%'
select * from INVENTRY 
where ItemNumber like '%7675%'
where Description1 like '%05518-12.50%'

-- Items in Cribmaster but not in Plex = 2122 Supply items
-- 00729 this has a space in front of it
--0000001  This is IN PLEX? 
--0001611R Crib / 00001611R Plex
--0003345  Crib / only has 0003345R Plex
--005715R  Crib / 0005715 and 005715 Plex
--005717  Crib / Nothing in plex
--005945 
-- Items in Cribmaster but not in Plex = 2122 Supply items
select 
distinct(cat.itemclass)
--count(*)
--top 1000 inv.itemnumber,item_no,description1 S
from INVENTRY inv --16631
left outer join btItemClassCatKey cat 
	on upper(cat.itemclass) = inv.ItemClass
left outer join btRemoveItems2 ri
	on inv.ItemNumber=ri.itemnumber
--where ri.itemnumber is null --15709
left outer join btPlexItem pi
on inv.ItemNumber=pi.item_no
where 
ri.itemnumber is null
and pi.item_no is null
--and inv.ItemNumber <> ' 00729'

-- Is all the needed item classes in plex?
select DISTINCT ItemClass
from
(
	select inv.ItemClass, cat.itemclass class 
	from INVENTRY inv 
	left outer join btItemClassCatKey cat 
	on upper(cat.itemclass) = inv.ItemClass
	where cat.ItemClass is null
)lv1


--and inv.ItemNumber in ('005863',
--'005946','009740R','009737',
--'009719','009730','009731',
--'009535','009540','009541'
--)
--2122
select * from INVENTRY 
where ItemNumber in ('005863',
'005946','009740R','009737',
'009719','009730','009731',
'009535','009540','009541'
)-- Items in Cribmaster but inactive Plex = 
select 
--count(*)
top 100 inv.itemnumber,item_no,description1 
from INVENTRY inv --16631
left outer join btRemoveItems2 ri
	on inv.ItemNumber=ri.itemnumber
--where ri.itemnumber is null --15709
left outer join btPlexItem pi
on inv.ItemNumber=pi.item_no
where 
ri.itemnumber is null
and pi.item_no is null
and inv.ItemNumber <> ' 00729'

select * from btPlexItem
select * from INVENTRY where ItemNumber = ' 00729'
select * from btPlexItem where Item_No like '%00729%'
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



-- btRemoveItems csv import file was saved in excel so some leading zeros got deleted.
-- select top 10 * from btRemoveItems --982
-- insert records with 1 and 2 zeros
-- select count(*) 	--982*3=2946
-- select * into btRemoveItems2 
from (
	--982*3=2946
	select ItemNumber from btRemoveItems
	UNION
	select '0' + ItemNumber from btRemoveItems
	UNION
	select '00' + ItemNumber from btRemoveItems
)lv1
--select * from btRemoveItems2 where itemnumber like '%15222%'

-- Is all the needed item classes in plex?
select DISTINCT ItemClass
from
(
	select inv.ItemClass, cat.itemclass class 
	from INVENTRY inv 
	left outer join btItemClassCatKey cat 
	on upper(cat.itemclass) = inv.ItemClass
	where cat.ItemClass is null
)lv1
-- Pivot Pin is in plex so insert in table
-- Hydraulic Valve is spelled wrong in Cribmaster so insert with misspelling but correct cat key.
INSERT INTO Cribmaster.dbo.btItemClassCatKey
(ItemClass, ItemCategoryKey)
VALUES('HYDRUALIC VALVE', '18201');
--VALUES('Pivot Pin', '14734');

select * from btItemClassCatKey cat where cat.ItemClass like '%Pivot%'

--Are there any item classes in Plex we don't need?
select distinct rm.itemclass
from 
(
select cat.itemclass, inv.ItemClass class 
from btItemClassCatKey cat
left outer join INVENTRY inv 
on upper(cat.itemclass) = inv.ItemClass
where inv.ItemClass is null
) rm


-- DROP TABLE Cribmaster.dbo.btPlexItem

CREATE TABLE Cribmaster.dbo.btPlexItem (
	Item_No varchar(50) NOT NULL,
	active int
)


--Bulk insert btPlexItem
from 'C:\PlexItemGT15000.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)

