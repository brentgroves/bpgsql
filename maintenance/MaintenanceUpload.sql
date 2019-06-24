

/********************************
 * plxItemLocationBase
 ******************************** 
	RecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	BuildingCode varchar(50),
	Location varchar(50),
	QuantityOnHand numeric(18,5),	
	Suffix varchar(2)
 *********************************
 *
 * To be used for sets requiring non-kendallville EM part records.
 * Both the suffix of the part and the site field is used to 
 * determine if a part is located in Kendallville since some
 * Kendallville parts do not have a 'K' suffix. The set
 * includes supply item, location, and quantity information
 * that other queries rely on.  A few EM part records have 
 * a duplicate part number and location. If duplicate part numbers
 * have distinct locations then they both will be in this set, 
 * but only the part number with the lowest record number will 
 * be included if the duplicate part numbers have the same plxSite
 * and EM shelf.
 * 
 * As a result of duplicatate parts with the same plxSite and
 * EM shelf dropping all but the part with the lowest record
 * number.  We will loose the quantity found in the records
 * that were dropped.  For example we will not add the
 * QuantityOnHand values for records with the exact same part
 * number, plxSite, and shelf. There are 5 duplicate parts
 * with the same location. I informed Kristen of this
 * and she did not mind because the quantities have not been
 * updated since April so the count is probably not accurate.
 *
 * To reiterate duplicate parts with different locations
 * will have a distinct record so we will not loose any
 * item,location,quantity,etc. data in these cases. 
 */

--drop table plxItemLocationBase
create table plxItemLocationBase
(
	RecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	BuildingCode varchar(50),
	Location varchar(50),
	QuantityOnHand numeric(18,5),	
	Suffix varchar(2)
);
select 
top 100 *
--count(*) 
from plxItemLocationBase
--11159

-- truncate table plxItemLocationBase
insert into plxItemLocationBase (RecordNumber,ItemNumber,NSItemNumber,BEItemNumber,BuildingCode,Location,QuantityOnHand,Suffix)
(
	--select COUNT(*) cntParts from (
	select 
		MinRecordNumber,
		ItemNumber,
		NSItemNumber,
		'BE' + NSItemNumber as BEItemNumber,
		BuildingCode,
		Location,
		QuantityOnHand,
		Suffix
	from
	(	--Add Quantity for each item location record selected.
		--select COUNT(*) cntParts from (
		select 
		MinRecordNumber,
		ItemNumber,
		case 
			when ItemNumber like '%[A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -2) 
			when ItemNumber like '%[^A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -1) 
			else ItemNumber
		end as NSItemNumber,
		set2.BuildingCode,
		set2.Location,
		QuantityOnHand,
		case 
			when ItemNumber like '%[A-Z][A-Z]' then right(ItemNumber,2) 
			when ItemNumber like '%[^A-Z][A-Z]' then right(ItemNumber,1) 
			else 'N' --none
		end as Suffix
		from 
		(
			--Reduce the set by selecting 1 record number to represent itemNumber,Location duplicates.
			--select COUNT(*) cntParts from (
			select 
			min(RecordNumber) MinRecordNumber,
			ItemNumber,
			BuildingCode,
			Location
			from 
			(
				--select COUNT(*) cntParts from (
				--select itemnumber from (
				--select COUNT(*) cntParts from (
				select 
				ltrim(rtrim(Numbered)) ItemNumber, 
				recordnumber,
				bm.building_code as BuildingCode,
				case 
					when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
					when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
					when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+LTRIM(RTRIM(p.Shelf)) --10 ASK KRISTEN FOR SITE
					when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+LTRIM(RTRIM(p.Shelf)) --11
					--else '???'
				end Location
				from dbo.Parts p
				left outer join dbo.btSiteMap sm
				on p.Site=sm.emSite
				left outer join dbo.btSiteBuildingMap bm
				on sm.plxSite=bm.plxSite
				where 
				--sm.emSite is null or bm.plxSite is null --0
				(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO')
				)tst --11189
				--)tst group by itemnumber --11176
				--having count(*) > 12
				--)tst --11176  --This is NOT item_no,recordNumber. This IS exact same item numbers only.
				
			)set1	
			/*
			 * If duplicate part numbers have distinct locations then
			 * they both will be in this set, but only the part number 
			 * with the lowest record number will be included if the
			 * duplicate part numbers have the same plxSite and EM shelf.
			 * There were only 5 parts with duplicate plxSite and EM shelf.
			 */
			group by ItemNumber,Location,BuildingCode
			--having count(*) > 1  --5
			--)tst --11184
		)set2 
		inner join dbo.Parts p
		on set2.MinRecordNumber=p.RecordNumber
		--)tst --11184
	)set3
	--order by location,itemNumber
	--)tst --11184
)--11189


select 
top 100 *
--count(*) 
from dbo.plxItemLocationBase


/*
 * plxLocation
 * PLEX LOCATION UPLOAD
 * Ctrl-m Location List screen
 * This query has been formatted to the Plex Location upload
 * specification except that it includes row numbers.
 * 
 * The CSV is in five columns in this exact order:
 * 1) Location
 * 2) Building Code 
 * 3) Location Type * (Must Exist in Location Type Setup Table)
 * 4) Note *  (50 Characters Maximum)
 * 5) Location Group * (Must Exist in Location Group Setup Table)
 * template: ~/src/sql/csv/location_template.csv
 */

--select count(*) cnt from (
select 
ROW_NUMBER() over(order by location asc) as row#,
Location,
BuildingCode as building_code,
'Maintenance' as location_type,  
'' as note,
'Maintenance Crib' as location_group
into plxLocation
from
(
	/*******************************
	 * plxItemLocationBase
	 * *****************************
		RecordNumber numeric(18,0),
		ItemNumber varchar(50),
		NSItemNumber varchar(50),
		BEItemNumber varchar(50),
		BuildingCode varchar(50),
		Location varchar(50),
		QuantityOnHand numeric(18,5),	
		Suffix varchar(2)
	/***********************************
	 * Since there are many parts that share locations the set
	 *  count will drop significantly at this point. 
	 */
	--select count(*) cnt from (
	select DISTINCT Location,BuildingCode 
	--select DISTINCT Location --Should be the same set as distinct location, buildingcode 
	from plxItemLocationBase base
	--)tst --3320 
)set1
--)tst --3319
order by location 

/*
 * 
 * plxItemLocation
 * 
 * ITEM LOCATION UPLOAD
 * This set is used for the plex supply item location upload.
 * It contains row# for uploading a range of item locations
 * at a time.
 * 
 * Ctrl-m supply list screen
 *  
 * Item_No (Required)
 * Location  (Required)
 * Quantity (Must be a number)
 * Building_Default (needs to be either Y or N)
 * Transaction_Type (optional)
 * Template: ~/src/sql/templates/item_location_template.csv
 * 
 */

--select COUNT(*) cnt from (
select
ROW_NUMBER() over(order by Location asc) as row#,
BEItemNumber as Item_No,
Location,
QuantityOnHand as Quantity,
'N' as Building_Default,
'' Transaction_Type
/********************************
 * plxItemLocationBase
 ******************************** 
	RecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	BuildingCode varchar(50),
	Location varchar(50),
	QuantityOnHand numeric(18,5),	
	Suffix varchar(2)
*********************************
*/
--drop table plxItemLocation
--into plxItemLocation
from plxItemLocationBase
--)tst --11184


/*
 * plxSupplyItem 
 * SUPPLY ITEM UPLOAD
 * Ctrl-m supply list screen
 * 
 *  This set is used for the plex supply item upload.
 * Template: ~/src/sql/templates/supply_item_template.csv
 * 
 * Field List:
   1. Item_No (Required)
   2. Brief_Description
   3. Description
   4. Note
   5. Item_Type (Required, must already exist)
   6. Item_Group (Required, must already exist)
   7. Item_Category (Required, must already exist)
   8. Item_Priority  (Required, must already exist)
   9. Customer_Unit_Price (If specified,must be a number)
   10. Average_Cost (If specified,must be a number)
   11. Inventory_Unit  (If specified, it must exist)
   12. Min_Quantity (If specified, must be a number)
   13. Max_Quantity (If specified, must be a number)
   14. Tax_Code (If specified, it must exist)
   15. Account_No (If specified, it must exist)
   16. Manufacturer
   17. Manf_Item_No (50 character limit)
   18. Drawing_No
   19. Item_Quantity  (If specified, must be a number and have a location)
   20. Location (If specified, it must exist)
   21. Supplier_Code (If specified, it must exist. If it is not, Supplier data is ignored)
   22. Supplier_Part_No
   23. Supplier_Std_Purch_Qty (If specified, must be a number)
   24. Currency (Required, must be a valid currency code per the currency table)
   25. Supplier_Std_Unit_Price (If specified, must be a number)
   26. Supplier_Purchase_Unit (If specified, it must exist)
   27. Supplier_Unit_Conversion (If specified, it must be a number.  Recommended greater than 0 as this affects extended price values)
   28. Supplier_Lead_Time (If specified, it must be a number)
   29. Update_When_Received (must be either Y for yes, or N or no)
   30. Manufacturer_Item_Revision (max 8 characters)
   31. Country_Of_Origin (if specified must exist)
   32. Commodity_Code (if specified must exist)
   33. Harmonized_Tariff_Code (if specified must exist)
   34. Cube_Length (If specified, it must be a number)
   35. Cube_Width (If specified, it must be a number)
   36. Cube_Height (If specified, it must be a number)
   37. Cube_Unit (if specified must exist)
 */

/* *************************************
 * plxSupplyItemBase
 * *************************************
	minRecordNumber numeric(18,0),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50)
	
 ************************************
 * When creating this set we have the task of picking which 
 * EM part records to insert into the plex purchasing.supplyitem table.
 * The EM part records have a suffix that identifies which site it
 * is located. This was required because there is no separate location
 * table in EM and if a part was stored in multiple location a separate
 * part record was created differing only in its suffix.  This suffix 
 * is not needed in Plex and will be dropped because Plex has a
 * one-to-many relationship between supply items and item location 
 * tables. For parts with multiple EM part records we choose only 
 * one to upload into plex. This chosen part will be used to retrieve 
 * description,unit price,vendor and other non-location information. 
 * 
 * 850325AV = Avilla
 * 850325E = Edon
 * 850325A = PlT8
 * 850325 = Albion
 */


--drop table plxSupplyItemBase
create table plxSupplyItemBase
(
	RecordNumber numeric(18,0),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50)
);


--truncate table dbo.plxSupplyItemBase
insert into plxSupplyItemBase (RecordNumber,NSItemNumber,BEItemNumber)
(
	--select COUNT(*) from ( --are there any dups
	select p.minRecordNumber RecordNumber, set4.NSItemNumber, set4.BEItemNumber
	FROM
	(
		--select COUNT(*) from ( --are there any dups
		--select DISTINCT NSItemNumber -- TEST form dups nsitemnumber record
		select DISTINCT ItemNumber,NSItemNumber,BEItemNumber
		--dups for multiple columns eliminated, distinct is not necessary 
												--should not be any but do above TEST to be sure
												--This set should not have any changes from previous set 
												--except for the reduction of columns
		from
		(
			select 
			CASE
				when right(NSItemNumberPriority,1) = '1' then NSItemNumber
				when right(NSItemNumberPriority,1) = '2' then NSItemNumber + 'AV'
				when right(NSItemNumberPriority,1) = '3' then NSItemNumber + 'E'
				when right(NSItemNumberPriority,1) = '4' then NSItemNumber + 'A'
			end as ItemNumber,
			NSItemNumber,
			BEItemNumber
			from
			(
				--select count(*) cnt from (
				select MIN(NSItemNumberPriority) NSItemNumberPriority,
				NSItemNumber,
				BEItemNumber
				from
				(
					--select count(*) from (
					select 
					ItemNumber, 
					NSItemNumber,
					BEItemNumber,
					case 
						when suffix = 'N' then NSItemNumber + '-1'
						when suffix = 'AV' then NSItemNumber + '-2'
						when suffix = 'E' then NSItemNumber + '-3'
						when suffix = 'A' then NSItemNumber + '-4'
					end as NSItemNumberPriority
					from
				/********************************
				 * plxItemLocationBase
				 ******************************** 
					RecordNumber numeric(18,0),
					ItemNumber varchar(50),
					NSItemNumber varchar(50),
					BEItemNumber varchar(50),
					BuildingCode varchar(50),
					Location varchar(50),
					QuantityOnHand numeric(18,5),	
					Suffix varchar(2)
				*********************************
				*/
					plxItemLocationBase il						
					--)tst --11189
					/*
					where 
					itemnumber like '000003%'
					or itemnumber like '000054%'
					or itemnumber like '000091%'
					or itemnumber like '000547%'
					or itemnumber like '200382%'
					order by nsitemnumber
					--000003A -- 450  
					--000054 (AV) --9145 
					--000091 (E) --839  
					--000547AV --13043  
					--200382E  --14322
					--	when suffix = 'N' then NSItemNumber + '-1'
					--	when suffix = 'AV' then NSItemNumber + '-2'
					--	when suffix = 'E' then NSItemNumber + '-3'
					--	when suffix = 'A' then NSItemNumber + '-4'
					*/
				)set1 
				group by NSItemNumber, BEItemNumber
				--)tst  --10275
				/*
				having 
				nsitemnumber like '000003%'
				or nsitemnumber like '000054%'
				or nsitemnumber like '000091%'
				or nsitemnumber like '000547%'
				or nsitemnumber like '200382%'
				order by nsitemnumber
				*/
				--000003A -- 450  
				--000054 (AV) --9145 
				--000091 (E) --839  
				--000547AV --13043  
				--200382E  --14322
				--	when suffix = 'N' then NSItemNumber + '-1'
				--	when suffix = 'AV' then NSItemNumber + '-2'
				--	when suffix = 'E' then NSItemNumber + '-3'
				--	when suffix = 'A' then NSItemNumber + '-4'
				
			)set2 
			/*
			where 
			nsitemnumber like '000003%'
			or nsitemnumber like '000054%'
			or nsitemnumber like '000091%'
			or nsitemnumber like '000547%'
			or nsitemnumber like '200382%'
			order by nsitemnumber
			--000003A -- 450  
			--000054 (AV) --9145 
			--000091 (E) --839  
			--000547AV --13043  
			--200382E  --14322
			--	when suffix = 'N' then NSItemNumber + '-1'
			--	when suffix = 'AV' then NSItemNumber + '-2'
			--	when suffix = 'E' then NSItemNumber + '-3'
			--	when suffix = 'A' then NSItemNumber + '-4'
			*/
			--where right(NSItemNumberPriority,1) = '4'
		)set3 --
		--)tst1 --10275 check for multiple copies of same nsitemnumber
	)set4 --
	/*
	 * To be used for sets requiring all non-kenallville parts
	 * and no duplicate part numbers.  For those parts with
	 * multiple locations the one with the lowest record number 
	 * has been chosen to represent the part for description and
	 * other non location related information.  Some part numbers
	 * are in both Kendallville and non-Kendallville sites.  The
	 * part number record of duplicate parts is NOT from a Kendallville
	 * site.
	 */
	left outer join 
	(
		/*
		 * There are some parts with duplicate part numbers, but since
		 * we need exactly one record to retrieve description, category,
		 * etc. information for any dups we will choose the one with the 
		 * lowest record number. There are also some numbers with spaces
		 * so use trim functions.
		 */
		select min(RecordNumber)minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber  
		from dbo.Parts
		group by numbered
	)p
	on set4.ItemNumber=p.ItemNumber
	--)tst --10275
	/*
	where 
	set4.nsitemnumber like '000003%'
	or set4.nsitemnumber like '000054%'
	or set4.nsitemnumber like '000091%'
	or set4.nsitemnumber like '000547%'
	or set4.nsitemnumber like '200382%'
	order by set4.nsitemnumber
	--000003A -- 450  
	--000054 (AV) --9145 
	--000091 (E) --839  
	--000547AV --13043  
	--200382E  --14322
	--	when suffix = 'N' then NSItemNumber + '-1'
	--	when suffix = 'AV' then NSItemNumber + '-2'
	--	when suffix = 'E' then NSItemNumber + '-3'
	--	when suffix = 'A' then NSItemNumber + '-4'
	*/
) -- #10275

select COUNT(*)
from
(
	select 
	--*
	--COUNT(*)
	nsitemnumber 
	from dbo.plxSupplyItemBase
	group by nsitemnumber
)tst --10276	

select * 
from plxItemLocationTS il 
--163
inner join dbo.plxLocationTS l
on il.Location=l.Location
--163
inner join plxSupplyItemsTS si
on il.Item_No=si.item_no
--133
--CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
select 
Item_No,Brief_Description,Description,Note,Item_Type,Item_Group,Item_Category,
Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,Location,Supplier_Code,
Supplier_Part_No,Supplier_Std_Purch_Qty,Currency,Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
Cube_Unit			
--drop table plxSupplyItem
--into plxSupplyItem
from (
	--select count(*) cnt from (
	select 
	--top 100
	row_number() OVER(ORDER BY si.BEItemNumber ASC) AS Row#,
	si.BEItemNumber as "Item_No",
	--'BE' + RTRIM(LTRIM(NSItemNumber)) as "Item_No",
	SUBSTRING(p.Description,1,50) as "Brief_Description",  -- Description field is varchar(60) so there could be some data loss
	CASE
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN p.Description --000
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber --001
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN p.Description + ', ' + 'Mfg: ' + p.Manufacturer --010
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN p.Description + ', ' + 'Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --011
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		then '#' + p.VendorNumber + ', ' + p.Description -- 100
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', Mfg#' + p.ManufacturerNumber --101
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', Mfg: ' + p.Manufacturer  --110
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --111
	end as Description,  -- Description field is on the ordering screen so make sure it has all the information needed to order the part.
	-- used xxd on plex csv file and dbeaver binary viewer on em and both seem to use 0D0A combo for \n so replace 
	-- should not be necessary.  DBeaver exports NotesText unicode field as ascii so you don't need to convert it at
	-- all to upload it into varchar field.
	--REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note, --
	-- BUT to make sure CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
	NotesText as Note, 
	'Maintenance' as item_type,
	CASE
		when ((p.CategoryID is null) or (ltrim(rtrim(p.CategoryID))) = '') then 'General'
		when p.CategoryID = '-PLATE' then 'PLATE'  -- Kristen did not change this in EM 06-04 
		else LTRIM(RTRIM(CategoryID))
	end as Item_Group,
	--select categoryid from dbo.Parts where CategoryID LIKE '%PLATE%'
	--select distinct categoryid from parts order by categoryid	--192  looks like there are extra in plex such as welding
	'General' as Item_Category,
	'Low' as Item_Priority,
	CASE
		when p.BillingPrice is NOT null AND BillingPrice > 0 then BillingPrice
		else p.CurrentCost
	end as Customer_Unit_Price,
	'' as Average_Cost,
	-- Standardize on units found in common_v_unit
-- Add units as needed and assign default
	CASE 
		when LTRIM(RTRIM(Units)) is null or LTRIM(RTRIM(Units)) = '' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Box' then 'Box'
		when LTRIM(RTRIM(Units)) = 'Case' then 'case'
		when LTRIM(RTRIM(Units)) = 'Dozen' then 'dozen'
		when LTRIM(RTRIM(Units)) = 'Each' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Electrical' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Feet' then 'Feet'
		when LTRIM(RTRIM(Units)) = 'Gallons' then 'Gallons'
		when LTRIM(RTRIM(Units)) = 'INCHES' then 'inches'
		when LTRIM(RTRIM(Units)) = 'Meters' then 'meters'
		when LTRIM(RTRIM(Units)) = 'Per 100' then 'hundred'
		when LTRIM(RTRIM(Units)) = 'Per Package' then 'Package'
		when LTRIM(RTRIM(Units)) = 'Package' then 'Package'
		when LTRIM(RTRIM(Units)) = 'Pounds' then 'lbs'
		when LTRIM(RTRIM(Units)) = 'Quart' then 'quart'
		when LTRIM(RTRIM(Units)) = 'Roll' then 'Roll'
		when LTRIM(RTRIM(Units)) = 'Set' then 'set'
		else 'Ea'
	end as Inventory_Unit,
	-- check 0000007 and other items
 	MinimumOnHand as Min_Quantity, -- if there are multiple parts,21 at last count, this will contain the value of the one chosen.
 	/*
 	select numbered,description,minimumonhand,maxonhand from dbo.Parts
 	where (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0)
 	-- only 2 items where min > max
 	select count(*) notZero
 	from
 	(
 	select numbered,description,minimumonhand,maxonhand from dbo.Parts
 	where (minimumOnHand is not null) and (MaxOnHand is not null)
	and (minimumOnHand <> 0) and (MaxOnHand <> 0) 
	)tst --7875
 	*/
	CASE
		when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then 0
		else MaxOnHand
	end as Max_Quantity,
	-- purchasing_v_tax_code / did not put this in for MRO supply items
	-- but before you update the item in plex it has to be filled with something
	-- and accountant said I could use tax exempt.
	-- Found that EM Parts are already marked as taxable 'Y' or 'N'
	-- where taxable = 'N' --2044
	-- where taxable = 'Y'--10619
	-- Talked with Kristen about taxable = 'Y' and she said that is wrong and the 
	-- accountant also said this so I'm going to mark them all as Tax Exempt
	'Tax Exempt - Labor / Industrial Processing' as Tax_Code,
	-- I worked hard to fill the account_no with an account that could be used to catagorize items as electrical, pumps, and something
	-- else I cant remember so that Pat could use the account field to keep track of the information he needs.  But was told to quit by Casey.
	-- and leave it blank.
	'' as Account_No,
	/* Not sure if this is the manufacturer_key, manufacturer_code, or Manufacturer_Name 
	 * If not configured to use Suppliers as Supply Item manufacturers, then this field,manufacturer_text varchar(25), contains the name of the Manufacturer.
	 * All the Manufacturer fields are greater than varchar(25) so don't know what is going on?
	 * */
	--select distinct plexVendor from dbo.btMfgMap order by plexvendor --173
	/*
	case 
		when mm.plexVendor is null then 'null' --many
		when mm.plexVendor = '' then 'Empty'  --0
		when LTRIM(RTRIM(mm.plexVendor)) = '' then 'WhiteSpace' --0
		else mm.plexVendor
	end as ManufacturerTest,
	*/
	case 
		when mm.plexMfg is null then ''
		else mm.plexMfg
	end as Manufacturer,
	--mm.plexVendor as Manufacturer,  
	p.ManufacturerNumber as Manf_Item_No,
	/* do manufacturer and vendor numbers look ok -- all varchar(50) so no truncation
	select top 100 numbered, manufacturerNumber,vendornumber, description from dbo.Parts
	*/
	'' as Drawing_No,
	'' as Item_Quantity,
	'' as Location,
	sc.Supplier_Code,
	/* item_supplier.Supplier_Item_No is varchar(50) and so is vendorNumber so there should be no truncation */
	VendorNumber Supplier_Part_No, 
	'' as Supplier_Std_Purch_Qty,
	'USD' as Currency,
	CASE
		when p.BillingPrice is NOT null AND BillingPrice > 0 then BillingPrice
		else p.CurrentCost
	end as Supplier_Std_Unit_Price,
	CASE 
		when LTRIM(RTRIM(Units)) is null or LTRIM(RTRIM(Units)) = '' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Box' then 'Box'
		when LTRIM(RTRIM(Units)) = 'Case' then 'case'
		when LTRIM(RTRIM(Units)) = 'Dozen' then 'dozen'
		when LTRIM(RTRIM(Units)) = 'Each' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Electrical' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Feet' then 'Feet'
		when LTRIM(RTRIM(Units)) = 'Gallons' then 'Gallons'
		when LTRIM(RTRIM(Units)) = 'INCHES' then 'inches'
		when LTRIM(RTRIM(Units)) = 'Meters' then 'meters'
		when LTRIM(RTRIM(Units)) = 'Per 100' then 'hundred'
		when LTRIM(RTRIM(Units)) = 'Per Package' then 'Package'
		when LTRIM(RTRIM(Units)) = 'Package' then 'Package'
		when LTRIM(RTRIM(Units)) = 'Pounds' then 'lbs'
		when LTRIM(RTRIM(Units)) = 'Quart' then 'quart'
		when LTRIM(RTRIM(Units)) = 'Roll' then 'Roll'
		when LTRIM(RTRIM(Units)) = 'Set' then 'set'
		else 'Ea'
	end as Supplier_Purchase_Unit,
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
	
	/************************************
	 *  plxSupplyItemBase
	 ************************************
		minRecordNumber numeric(18,0),
		NSItemNumber varchar(50),
		BEItemNumber varchar(50)
	 *************************************/
	--select count(*) from (
	--select si.*	
	from dbo.plxSupplyItemBase si
	--)tst --10276
	left join dbo.Parts p
	on si.RecordNumber=p.RecordNumber
	--)tst --10276
	left outer join (
		select * from btSupplyCode sc
		where VendorName <> ''
	) sc
	on p.Vendor=sc.VendorName 
	--)tst --10276
	left outer join btMfgMap mm
	on p.Manufacturer=mm.plexMfg 
	--)tst  --10276
)set1
order by item_no

/*
 * Query to upload plex supply items.
 */
--select count(*) cnt from (
select * from dbo.plxSupplyItem
--)tst --
where row# >=1
and row# <=5






/*
 * 
 * 
 * 
 * 
 *             Create Test Sets 
 * 
 * 
 * 
 * 
 */

/* 
 * plxLocationTS
 * Test set for Plex location uploads.
 * 
 * Process 
 * 1. Create plxLocationTS. Query location records for all supply items and locations you want to test.  
 *    Join this  query to the plxLocation set to get a reduced set of all the location for 
 *    the supply items and locations you want to test. 
 * 
 * 2. Create plxItemLocationTS. Use location test set to reduce the plxItemLocation table with inner join clause
 *    on the location field.  
 * 
 * 3. Create plxSupplyItemTS. Use plxItemLocationTS set to reduce the plxSupplyItem set with inner join clause
 * 	  on the ItemNumber field.
 * 
 * Result:
 * The above process should ensure that every supply item in your test set should have all its location and 
 * ItemLocation records also
 */
 
 
 /*
  * Per step 1 of the above proces make sure all locations for whatever items you wish to perform tests
  * on is included in the plxLocationTS table.
  * 1. Add up to 10 location records for each each plex site.
  * 2. Add all location records for 5 parts which have a category of Electronics, Pumps, and Covers categories.
  */

/*
 *   Add up to 10 location records for each each plex site.
 */
--drop table plxLocationTS
select * from dbo.plxLocationTS
select count(*) from (
select
top 10
Location,
building_code,
location_type,  
note,
location_group
into plxLocationTS
from
dbo.plxLocation
--)tst  --3319
where SUBSTRING(location,1,2)='MD'
order by location

insert into dbo.plxLocationTS 
select
top 10
Location,
building_code,
location_type,  
note,
location_group
from
dbo.plxLocation
where SUBSTRING(location,1,3)='MPB'
order by location
select * from dbo.btSiteMap order by emSite

select * from dbo.plxLocationTS  
--65  All sites

--15 Pumps,Electronics,Covers

/*
 * Add all locations for union of part set which includes 5 parts each 
 * with an item category of Electronic, Pumps, and Covers.
 */
insert into dbo.plxLocationTS 
select 
l.Location,
building_code,
location_type,  
note,
location_group
from dbo.plxLocation l
inner join 
(
	select distinct location 
	/*******************************
	 * plxItemLocationBase
	 * *****************************
		RecordNumber numeric(18,0),
		ItemNumber varchar(50),
		NSItemNumber varchar(50),
		BEItemNumber varchar(50),
		BuildingCode varchar(50),
		Location varchar(50),
		QuantityOnHand numeric(18,5),	
		Suffix varchar(2)
	 ********************************/
	--select base.recordnumber,location,vendor
	from plxItemLocationBase base
	inner join 
	(
	 	select top 5 recordnumber,numbered,vendor
	 	from dbo.Parts p
		where p.CategoryID = 'Electronics' and vendor <> ''
		and (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K')
		and shelf <> ''
		and vendor <> ''

		UNION
	 	select top 5 recordnumber,numbered,vendor
	 	from dbo.Parts p
		where p.CategoryID = 'Pumps' and vendor <> ''
		and (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K')
		and shelf <> ''
		and vendor <> ''
		
		UNION
	 	select top 5 recordnumber,numbered,vendor
	 	from dbo.Parts p
		where p.CategoryID = 'Cover' and vendor <> ''
		and (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K')
		and shelf <> ''
		and vendor <> ''
	
	)epc
	on base.recordnumber=epc.recordnumber
)c
on l.location=c.location


/* 
 *	Per step 2 of the Test set generation process above.
 * 
 *  Create plxItemLocationTS. Use location test set to reduce the plxItemLocation table with inner join clause
 *  on the location field.  
 * 
 */
SELECT
Item_No,il.Location,Quantity,Building_Default,Transaction_Type
--drop table plxItemLocationTS
--into plxItemLocationTS
from 
dbo.plxItemLocation il
inner join plxLocationTs ts -- reduce set by joining to the location test set table.
on il.Location= ts.Location
order by item_no,location
--163 

/*
 * Per set# 3 of the above Test Set generation process create the plxSupplyItemTS table.
 * 
 * 3. Use plxItemLocationTS set to reduce the plxSupplyItem set with inner join clause
 * 	  on the ItemNumber field.
 */

select si.*
from dbo.plxSupplyItem si
inner JOIN plxItemLocationTS il
on si.item_no=il.item_no


/*
 * Validate that our test sets include all the records we need.
 * 
 * 1. Validate that each item location has exactly one location record.
 * 2. Validate that each item location record has exactly on supply item record.
 * 
 */
select * 
from plxItemLocationTS il 
--163
inner join dbo.plxLocationTS l
on il.Location=l.Location
--163

select il.*
from dbo.plxItemLocationTS il
inner join dbo.plxSupplyItemTS si
on il.item_no=si.item_no

/*
 * 
 * 
 * 			Production Upload section
 * 
 * 
 */


/*
 * Quere to upload a range of locations
 */
select select 
Location,building_code,location_type,note,location_group
from dbo.plxLocation
where row# >=1
and row# <= 100
order by location

/*
 * Query to upload a range of item locations
 */
select Item_No,il.Location,Quantity,Building_Default,Transaction_Type 
from plxItemLocation  --
where row# >=1
and row# <= 100
order by location,item_no

/*
 * Query to upload a range of supply items.
 */

select
Item_No,Brief_Description,Description,Note,Item_Type,Item_Group,Item_Category,
Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,Location,Supplier_Code,
Supplier_Part_No,Supplier_Std_Purch_Qty,Currency,Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
Cube_Unit			
from dbo.plxSupplyItem
where row# >=1
and row# <= 100
order by item_no






/*
 * 
 * 
 *  		Express Maintenance 
 * 
 * 			 Database
 * 
 * 			Cleanup Section
 * 
 */


/*
 * How many parts have a site of Kendallville but do not have 
 * a 'K' suffix.  Ask Kristen about these.
 */

select 
Numbered,Description,Vendor,Site,Shelf
from dbo.Parts p
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
left outer join dbo.btSiteBuildingMap bm
on sm.plxSite=bm.plxSite
where 
(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite = 'MO')


/*
 * Create a set of locations which have multiple parts assigned.
 */

select count(*) cnt from (
select Location, count(*) cnt 
from plxItemLocation il
group by Location
--having COUNT(*) > 10  --86
--having COUNT(*) > 5  --428
--having COUNT(*) > 4  --648
--having COUNT(*) > 3  --941
--having COUNT(*) > 2  --1311
having COUNT(*) > 1  --1957
and location not like '%YET%'
)tst 

/*
 * Create a set of locations which Kristen can look through
 * which have more than 10 parts assigned.
 */

select set1.*
from
(
select 
ap.Location,
ap.ItemNumber,
p.Description,
p.Vendor
from plxAllPartsSetWithDups ap
inner join dbo.Parts p
on ap.RecordNumber=p.RecordNumber
)set1
inner join 
(
select Location 
--count(*) cnt
from plxItemLocation 
group by Location
having COUNT(*) > 10  --86
and location not like '%YET%'
)set2
on set1.location=set2.location
order by Location


/* 
 * Create a set of parts shelf length under 4 characters.
 */



















/* OBSOLETE
 * Does not look like we need this set use
 * the plxAllPartsSetWithDups table 
 * instead.  
 */
--drop table plxAllPartsSet
create table plxAllPartsSet
(
	minRecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	suffix varchar(2)
);
select 
--top 100 *
count(*) 
from plxAllPartsSet
--11146

-- OBSELETE SET DONT USE. USE plxAllPartsSetWithDups instead.
-- This does not include the Kendallville parts and does NOT contain duplicate part numbers.
-- For part number duplicates all but the part number with the minimum record number have
-- been removed.
insert into plxAllPartsSet (minRecordNumber,ItemNumber,NSItemNumber,BEItemNumber,suffix)
(
	--select COUNT(*) cntParts from (
	select 
	minRecordNumber,
	ItemNumber,
	NSItemNumber,
	'BE' + NSItemNumber as BEItemNumber,
	suffix
	from
	(
		--select COUNT(*) cntParts from (
		select 
		min(RecordNumber) minRecordNumber,
		ItemNumber,
		case 
			when ItemNumber like '%[A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -2) 
			when ItemNumber like '%[^A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -1) 
			else ItemNumber
		end as NSItemNumber,
		case 
			when ItemNumber like '%[A-Z][A-Z]' then right(ItemNumber,2) 
			when ItemNumber like '%[^A-Z][A-Z]' then right(ItemNumber,1) 
			else 'N' --none
		end as suffix
		from 
		(
			--select COUNT(*) cntParts from (
			select 
			ltrim(rtrim(Numbered)) ItemNumber, 
			recordnumber
			from dbo.Parts p
			left outer join dbo.btSiteMap sm
			on p.Site=sm.emSite
			left outer join dbo.btSiteBuildingMap bm
			on sm.plxSite=bm.plxSite
			where (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') 
			--)tst --11159
		)set1 -- no kendallville parts
		group by ItemNumber
		--)tst --11146
	)set2
	--)tst --11146
) --11146

/*
 * OBSELETE DO NOT USE UNLESS UPDATE WITH QuantityOnHand field
 * plxAllPartsSet
 * 
	MinRecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	suffix varchar(2)
 *
 * To be used for sets requiring all non-kenallville parts
 * and no duplicate part numbers.  For the part number duplicates
 * the one with the lowest record number has been chosen to 
 * represent the part for description and other non location 
 * related information.  Some part numbers are in both Kendallville
 * and non-Kendallville sites and neither have the 'K' suffix.  
 * For these parts only the ones with the non-Kendallville site 
 * are included in this set.
 */
select count(*) from dbo.plxAllPartsSet
--11146


/*
 * OBSOLETE
 * 
 * ITEM LOCATION SUB MODULE
 * Contains the fields other queries need.
 * 

	minRecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	location varchar(50),
	QuantityOnHand numeric(18,5),	
	suffix varchar(2)


 *  * 
 * plxItemLocationSub is used to generate the plex supply item and 
 * supply item location upload sets.  It uses the plxAllPartsSetWithDups
 * set and adds the plxSite,building_code,location fields.
 * If duplicate part numbers have distinct locations then
 * they both will be in this set, but only the part number 
 * with the lowest record number will be included if the
 * duplicate part numbers have the same plxSite and EM shelf.
 * 
 * 
 */

select
count(*)
--top 100 * 
from plxItemLocationSub
--11154

select COUNT(*) cnt from (
	select set2.*,p.QuantityOnHand
	--drop table plxItemLocationSub
	into plxItemLocationSub
	from
	(
		select min(recordnumber) minRecordNumber, itemnumber,BEItemNumber,plxSite,building_code,location 
		from (
			--select COUNT(*) cnt from (
			select 
			ap.recordnumber,
			ap.itemnumber,  
			ap.BEItemNumber,
			--quantityonhand,
			sm.plxSite,
			bm.building_code,
			case 
				when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
				when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
				when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+LTRIM(RTRIM(p.Shelf)) --10 ASK KRISTEN FOR SITE
				when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+LTRIM(RTRIM(p.Shelf)) --11
				--else '???'
			end location
			from dbo.Parts p  --contains KendallVille parts. count: 12286
			--select top 10 * from plxAllPartsSetWithDups
			--select count(*) from plxAllPartsSetWithDups  --11159
			inner join plxAllPartsSetWithDups ap
			on p.RecordNumber=ap.recordnumber
			-- we want the set created of all non-kendallville parts in EM
			-- including duplicate parts which may or may not contain different locations.
			left outer join dbo.btSiteMap sm
			on p.Site=sm.emSite
			left outer join dbo.btSiteBuildingMap bm
			on sm.plxSite=bm.plxSite
			--)tst --11159
		)set1
		/*
		 * If duplicate part numbers have distinct locations then
		 * they both will be in this set, but only the part number 
		 * with the lowest record number will be included if the
		 * duplicate part numbers have the same plxSite and EM shelf.
		 */
		group by itemnumber,BEItemNumber,plxSite,building_code,location
	)set2
	left outer join dbo.Parts p
	on set2.minRecordNumber=p.RecordNumber
)tstDistinct --11154

select COUNT(*)
from dbo.Parts
--12286
select count(*) from plxAllPartsSetWithDups  --11159
