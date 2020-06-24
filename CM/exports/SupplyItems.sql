--select * from (
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
				-- this is the most important field because it shows up on the ordering screen
				-- at first I did not put description1 in this field as on the line above I commented out
				-- we had to pay plex to exchange the contents of brief_description and description field because initially description 
				-- did not contain description1 which had the all important part number needed for ordering
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
				--70 as Tax_Code, Plex says 70 does not exist
				--'' as Tax_Code,
 			    'Tax Exempt - Labor / Industrial Processing' as tax_code,  -- DON'T KNOW IF I SHOULD USE THIS
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
--	inner join dbo.PlexImportSupplyItem0623 si 
--	on lv1.item_no = si.itemNumber
	where lv1.item_no > '17255' and lv1.item_no <= '17307' 
	--where lv1.supplier_code ='Arch Cutting Tools -Mento'
	--order by si.itemnumber
	--where supplier_code is null
	
	--where Supplier_Std_Unit_Price is null
--	where item_no in (
--	'16718R','17071','17072','17073','16705R','16707R','17074','17074R','17075','17075R','17076'
--	'17066','17066R','17067','17067R','17068','17069','17070','17070R'
--	'17038','17039','17040','17041','17042','17043',
--	'17038R','17039R','17040R','17041R','17042R','17043R'
--'17005','16957','17031','16296'
--	)
--	or ((item_no >= '17044') and (item_no <= '17064'))
--)lv2
--order by lv2.itemNumber
--select * from PlexImportSupplyItem0623
/*
	select * from dbo.btSupplyCode 
where VendorName = 'Competitive Carbide'
select * 
-- into dbo.btSupplyCode0623 
from dbo.btSupplyCode 

-- update dbo.btSupplyCode 
-- set Supplier_Code = 'Arch Cutting Tools -Mento'
where Supplier_Code = 'Competitive Carbide'
*/