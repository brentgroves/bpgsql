/*
 * plxAllPartsSetX will be used in other
 * queries so will make it a table.  This
 * set contains all non-kendallville part
 * records.
 * Dont make a view with the with clause because
 * it will be needed over time in other
 * SQL files
 * 
 */
--drop table plxAllPartsSetWithDups
create table plxAllPartsSetWithDups
(
	RecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	suffix varchar(2)
);
select 
--top 100 *
count(*) 
from plxAllPartsSetWithDups
--11159

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

-- This does not include the Kendallville parts but does contain duplicate part numbers.
-- which are part numbers stored in multiple locations and/or database corruption errors.
insert into plxAllPartsSetWithDups (RecordNumber,ItemNumber,NSItemNumber,BEItemNumber,suffix)
(
	--select COUNT(*) cntParts from (
	select 
		RecordNumber,
		ItemNumber,
		NSItemNumber,
		'BE' + NSItemNumber as BEItemNumber,
		suffix
	from
	(
		select 
		RecordNumber,
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
			--select itemnumber from (
			--select COUNT(*) cntParts from (
			select 
			ltrim(rtrim(Numbered)) ItemNumber, 
			recordnumber
			from dbo.Parts p
			left outer join dbo.btSiteMap sm
			on p.Site=sm.emSite
			left outer join dbo.btSiteBuildingMap bm
			on sm.plxSite=bm.plxSite
			where 
			--sm.emSite is null or bm.plxSite is null --0
			(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO')
			--)tst --11159
			--)tst group by itemnumber 
			--having count(*) > 1
			--)tst --11146
		)set1 -- no kendallville parts  but has duplicate part numbers because of 
		-- multiple locations.
	)set2
	--)tst --11159
	
)


select * from dbo.plxAllPartsSetWithdups

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
 * plxAllPartsSetWithDups
 * 
 * 	RecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	suffix varchar(2)

 * To be used for sets requiring all non-kendallville parts.
 * It includes part number duplicates.  It also includes a 
 * record number to ensure exactly which part record we are 
 * referring to.  Some part numbers are in both Kendallville 
 * and non-kendallville sites and neither have the 'K' suffix.
 * Of these parts no Kendallville part record numbers are 
 * included in this set.
 */
select count(*) from dbo.plxAllPartsSetWithDups
--11159


/*
 * 
 * 
 * ITEM LOCATION SUB MODULE
 * Contains the fields other queries need.
 * 
	minRecordNumber numeric(18,0),
	itemnumber varchar(50),
	BEItemNumber varchar(50),
	plxSite varchar(25),
	building_code varchar(50),
	location varchar(51),
	QuantityOnHand numeric(18,5)
 * 
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

/*
 * 
 * 
 * 
 * PLEX LOCATION UPLOAD
 * Ctrl-m Location List screen
 * This query has been formatted to the Location upload
 * specification.
 * The CSV is in five columns in this exact order:
 * 1) Location
 * 2) Building Code 
 * 3) Location Type * (Must Exist in Location Type Setup Table)
 * 4) Note *  (50 Characters Maximum)
 * 5) Location Group * (Must Exist in Location Group Setup Table)
 * template: ~/src/sql/csv/location_template.csv
 * 
 * 
 * 
 */
select 
--*
count (*) 
from plxTestSetLocation  --65

select count(*) from (
select
--top 10
Location,
building_code,
location_type,  
note,
location_group
--into plxTestSetLocation
from
(
/*
 * Plex Location Upload
 */
	--select count(*) cnt from (
	select 
	ROW_NUMBER() over(order by location asc) as row#,
	Location,
	building_code,
	'Maintenance' as location_type,  
	'' as note,
	'Maintenance Crib' as location_group
	from
	(

		/*
		 * plxAllPartsSetWithDups
		 * 
		 * 	RecordNumber numeric(18,0),
			ItemNumber varchar(50),
			NSItemNumber varchar(50),
			BEItemNumber varchar(50),
			suffix varchar(2)
		
		 * To be used for sets requiring all non-kendallville parts.
		 * It includes part number duplicates.  It also includes a 
		 * record number to ensure exactly which part record we are 
		 * referring to.  Some part numbers are in both Kendallville 
		 * and non-kendallville sites and neither have the 'K' suffix.
		 * Of these parts no Kendallville part record numbers are 
		 * included in this set.
		 */
	
		/*
			minRecordNumber numeric(18,0),
			itemnumber varchar(50),
			BEItemNumber varchar(50),
			plxSite varchar(25),
			building_code varchar(50),
			location varchar(51),
			QuantityOnHand numeric(18,5)
		 * 
		 * plxItemLocationSub is used to generate the plex supply item and 
		 * supply item location upload sets.  It uses the plxAllPartsSetWithDups
		 * set and adds the plxSite,building_code,location fields.
		 * If duplicate part numbers have "distinct locations" then
		 * they both will be in this set, but only the part number 
		 * with the lowest record number will be included if the
		 * duplicate part numbers have the same plxSite and EM shelf.
		 * 
		 * 
		 */
	
		/*
		 * Drop the itemnumber from this set.  Since there are many parts that share
		 * locations the set count will drop significantly at this point. 
		 */
		--select count(*) cnt from (
		select DISTINCT location,building_code 
		from dbo.plxItemLocationSub il
		--)tst --3307 Dropped itemnumber from set
	)set1
	--)tst --3307 Dropped itemnumber from set
)set2
)tst  --3307 
where SUBSTRING(location,1,3)='MPB'
--where SUBSTRING(location,1,2)='MD'
order by location


/*
 * 
 * 
 * 
 * 
 * 
 * ITEM LOCATION UPLOAD
 * This set is used for the plex supply item location upload.
 * Ctrl-m supply list screen
 *  
 * Item_No (Required)
 * Location  (Required)
 * Quantity (Must be a number)
 * Building_Default (needs to be either Y or N)
 * Transaction_Type (optional)
 * Template: ~/src/sql/templates/item_location_template.csv
 * 
 * 
 * 
 * 
 * 
 */
select * from plxTestSetItemLocation

--select location from (
SELECT
Item_No,set1.Location,Quantity,Building_Default,Transaction_Type
--drop table plxTestSetItemLocation
into plxTestSetItemLocation
from 
(
	--select COUNT(*) cnt from (
	select
	ROW_NUMBER() over(order by il.location asc) as row#,
	BEItemNumber as item_no,
	il.location,
	p.QuantityOnHand as quantity,
	'N' as Building_Default,
	'' Transaction_Type

	/*
	 * plxAllPartsSetWithDups
	 * 
	 * 	RecordNumber numeric(18,0),
		ItemNumber varchar(50),
		NSItemNumber varchar(50),
		BEItemNumber varchar(50),
		suffix varchar(2)
	
	 * To be used for sets requiring all non-kendallville parts.
	 * It includes part number duplicates.  It also includes a 
	 * record number to ensure exactly which part record we are 
	 * referring to.  Some part numbers are in both Kendallville 
	 * and non-kendallville sites and neither have the 'K' suffix.
	 * Of these parts no Kendallville part record numbers are 
	 * included in this set.
	 */

	/*
		minRecordNumber numeric(18,0),
		itemnumber varchar(50),
		BEItemNumber varchar(50),
		plxSite varchar(25),
		building_code varchar(50),
		location varchar(51),
		QuantityOnHand numeric(18,5)
	 * 
	 * plxItemLocationSub is used to generate the plex supply item and 
	 * supply item location upload sets.  It uses the plxAllPartsSetWithDups
	 * set and adds the plxSite,building_code,location fields.
	 * If duplicate part numbers have "distinct locations" then
	 * they both will be in this set, but only the part number 
	 * with the lowest record number will be included if the
	 * duplicate part numbers have the same plxSite and EM shelf.
	 * 
	 * 
	 */

	/*
	 * As a result of duplicatate parts with the same plxSite and
	 * EM shelf dropping all but the part with the lowest record
	 * number.  We will loose the quantity found in the records
	 * that were dropped.  For example we will not add the
	 * quantityOnHand values for records with the exact same part
	 * number, plxSite, and shelf. There are under 5 duplicate parts
	 * with the same location. I informed Kristen of this
	 * and she did not mind because the quantities have not been
	 * updated since April anyway.
	 */
	
	/*
	 * To reiterate duplicate parts with different locations
	 * will have a distinct item location (quantity) record 
	 * for each location.
	 */
	from plxItemLocationSub il
	inner join dbo.Parts p  --join parts table to get quantity on hand.
	-- I wanted to add quantity on hand field into plxItemLocationSub
	-- but could not because of the 
	on il.minRecordNumber=p.RecordNumber
	--)tst --11154
)set1
inner join plxTestSetLocation ts -- only pull records we want to test
on set1.location= ts.location
--)tst --65
--group by location  
order by set1.location

where row# >=1
and row# <= 100
order by item_no,location

select * from plxTestSetLocation
select * from plxTestSetItemLocation


create table #set7
(
	NSItemNumber varchar(50),
	minRecordNumber numeric(18,0),
	BEItemNumber varchar(50)
);

/*
 * 
 * 
 * 
 * 
 * 
 * SUPPLY ITEM UPLOAD
 * Ctrl-m supply list screen
 * 
 *  * This set is used for the plex supply item upload.
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
 * 
 * 
 * 
 * 
 * 
 */


