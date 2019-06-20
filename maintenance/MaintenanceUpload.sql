
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

/*
 * plxAllPartsSetWithDups
 * 
	RecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	BuildingCode varchar(50),
	Location varchar(50),
	QuantityOnHand numeric(18,5),	
	Suffix varchar(2)

 * To be used for sets requiring all non-kendallville parts.
 * It includes part number duplicates.  It also includes a 
 * record number to ensure exactly which part record we are 
 * referring to.  Some part numbers are in both Kendallville 
 * and non-kendallville sites and neither may have the 'K' suffix.
 * Of these parts no Kendallville part record numbers are 
 * included in this set. If duplicate part numbers have 
 * "distinct locations" then they both will be in this set, 
 * but only the part number with the lowest record number 
 * will be included if the duplicate part numbers have the 
 * same plxSite and EM shelf.
 */ 
 
		/*
 * As a result of duplicatate parts with the same plxSite and
 * EM shelf dropping all but the part with the lowest record
 * number.  We will loose the quantity found in the records
 * that were dropped.  For example we will not add the
 * QuantityOnHand values for records with the exact same part
 * number, plxSite, and shelf. There are 5 duplicate parts
 * with the same location. I informed Kristen of this
 * and she did not mind because the quantities have not been
 * updated since April anyway.
 */

/*
 * To reiterate duplicate parts with different locations
 * will have a distinct record so we will not loose any
 * item,location,quantity,etc. data in these cases. 
 */
	select count(*) from dbo.plxAllPartsSetWithDups

--drop table plxAllPartsSetWithDups
create table plxAllPartsSetWithDups
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
from plxAllPartsSetWithDups
--11159

-- truncate table plxAllPartsSetWithDups
insert into plxAllPartsSetWithDups (RecordNumber,ItemNumber,NSItemNumber,BEItemNumber,Location,BuildingCode,QuantityOnHand,Suffix)
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
	(
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
				--)tst --11160
				--)tst group by itemnumber --12
				--having count(*) > 1
				--)tst --11147
				
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
			--)tst --11155
		)set2 
		inner join dbo.Parts p
		on set2.MinRecordNumber=p.RecordNumber
		--)tst --11155
	)set3
	--)tst --11155
)--11155


select 
--top 100 *
count(*) 
from dbo.plxAllPartsSetWithdups





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
	BuildingCode as building_code,
	'Maintenance' as location_type,  
	'' as note,
	'Maintenance Crib' as location_group
	from
	(
		/*
		 * plxAllPartsSetWithDups
		 * 
			RecordNumber numeric(18,0),
			ItemNumber varchar(50),
			NSItemNumber varchar(50),
			BEItemNumber varchar(50),
			BuildingCode varchar(50),
			Location varchar(50),
			QuantityOnHand numeric(18,5),	
			Suffix varchar(2)
		
		 * To be used for sets requiring all non-kendallville parts.
		 * It includes part number duplicates.  It also includes a 
		 * record number to ensure exactly which part record we are 
		 * referring to.  Some part numbers are in both Kendallville 
		 * and non-kendallville sites and neither may have the 'K' suffix.
		 * Of these parts no Kendallville part record numbers are 
		 * included in this set. If duplicate part numbers have 
		 * "distinct locations" then they both will be in this set, 
		 * but only the part number with the lowest record number 
		 * will be included if the duplicate part numbers have the 
		 * same plxSite and EM shelf.
		 */ 
 
		/*
		 * As a result of duplicatate parts with the same plxSite and
		 * EM shelf dropping all but the part with the lowest record
		 * number.  We will loose the quantity found in the records
		 * that were dropped.  For example we will not add the
		 * QuantityOnHand values for records with the exact same part
		 * number, plxSite, and shelf. There are 5 duplicate parts
		 * with the same location. I informed Kristen of this
		 * and she did not mind because the quantities have not been
		 * updated since April anyway.
		 */
		
		/*
		 * To reiterate duplicate parts with different locations
		 * will have a distinct record so we will not loose any
		 * item,location,quantity,etc. data in these cases. 
		 */
	
	
		/*
		 * Since there are many parts that share locations the set
		 *  count will drop significantly at this point. 
		 */
		--select count(*) cnt from (
		select DISTINCT Location,BuildingCode 
		from plxAllPartsSetWithDups ap
		--)tst --3307 
	)set1
	--)tst --3307 
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
Item_No,Location,Quantity,Building_Default,Transaction_Type
--drop table plxTestSetItemLocation
--into plxTestSetItemLocation
from 
(
	--select COUNT(*) cnt from (
	select
	ROW_NUMBER() over(order by Location asc) as row#,
	BEItemNumber as Item_No,
	Location,
	QuantityOnHand as Quantity,
	'N' as Building_Default,
	'' Transaction_Type
	/*
	 * plxAllPartsSetWithDups
	 * 
		RecordNumber numeric(18,0),
		ItemNumber varchar(50),
		NSItemNumber varchar(50),
		BEItemNumber varchar(50),
		BuildingCode varchar(50),
		Location varchar(50),
		QuantityOnHand numeric(18,5),	
		Suffix varchar(2)
	
	 * To be used for sets requiring all non-kendallville parts.
	 * It includes part number duplicates.  It also includes a 
	 * record number to ensure exactly which part record we are 
	 * referring to.  Some part numbers are in both Kendallville 
	 * and non-kendallville sites and neither may have the 'K' suffix.
	 * Of these parts no Kendallville part record numbers are 
	 * included in this set. If duplicate part numbers have 
	 * "distinct locations" then they both will be in this set, 
	 * but only the part number with the lowest record number 
	 * will be included if the duplicate part numbers have the 
	 * same plxSite and EM shelf.
	 */ 
 
		/*
	 * As a result of duplicatate parts with the same plxSite and
	 * EM shelf dropping all but the part with the lowest record
	 * number.  We will loose the quantity found in the records
	 * that were dropped.  For example we will not add the
	 * QuantityOnHand values for records with the exact same part
	 * number, plxSite, and shelf. There are 5 duplicate parts
	 * with the same location. I informed Kristen of this
	 * and she did not mind because the quantities have not been
	 * updated since April anyway.
	 */
	
	/*
	 * To reiterate duplicate parts with different locations
	 * will have a distinct record so we will not loose any
	 * item,location,quantity,etc. data in these cases. 
	 */
	from plxAllPartsSetWithDups
	)tst --11155
)set1
inner join plxTestSetLocation ts -- only pull records we want to test
on set1.Location= ts.Location
--)tst --65
--group by location  
order by set1.Location

where row# >=1
and row# <= 100
order by item_no,location

select * from plxTestSetLocation
select * from plxTestSetItemLocation

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
--drop table plxSupplyItemRecNoSet
create table plxSupplyItemRecNoSet
(
	NSItemNumber varchar(50),
	minRecordNumber numeric(18,0),
	BEItemNumber varchar(50)
);
--truncate table dbo.plxSupplyItemRecNoSet
select * from dbo.plxSupplyItemRecNoSet
-- Create plxSupplyItemSetRecNoSet first then create plxSupplyItemSet 
	insert into plxSupplyItemRecNoSet (NSItemNumber,minRecordNumber,BEItemNumber)
	(
		--select COUNT(*) from ( --are there any dups
		select set4.NSItemNumber,p.minRecordNumber,set4.BEItemNumber
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
						/*
						 * plxAllPartsSetWithDups
						 * 
							RecordNumber numeric(18,0),
							ItemNumber varchar(50),
							NSItemNumber varchar(50),
							BEItemNumber varchar(50),
							BuildingCode varchar(50),
							Location varchar(50),
							QuantityOnHand numeric(18,5),	
							Suffix varchar(2)
						
						 * To be used for sets requiring all non-kendallville parts.
						 * It includes part number duplicates.  It also includes a 
						 * record number to ensure exactly which part record we are 
						 * referring to.  Some part numbers are in both Kendallville 
						 * and non-kendallville sites and neither may have the 'K' suffix.
						 * Of these parts no Kendallville part record numbers are 
						 * included in this set. If duplicate part numbers have 
						 * "distinct locations" then they both will be in this set, 
						 * but only the part number with the lowest record number 
						 * will be included if the duplicate part numbers have the 
						 * same plxSite and EM shelf.
						 */ 
					 
						/*
						 * As a result of duplicatate parts with the same plxSite and
						 * EM shelf dropping all but the part with the lowest record
						 * number.  We will loose the quantity found in the records
						 * that were dropped.  For example we will not add the
						 * QuantityOnHand values for records with the exact same part
						 * number, plxSite, and shelf. There are 5 duplicate parts
						 * with the same location. I informed Kristen of this
						 * and she did not mind because the quantities have not been
						 * updated since April anyway.
						 */
						
						/*
						 * To reiterate duplicate parts with different locations
						 * will have a distinct record so we will not loose any
						 * item,location,quantity,etc. data in these cases. 
						 */
						plxAllPartsSetWithDups ap						
						--)tst --11155
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
					--)tst  --10274
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
			--)tst1 --10274 check for multiple copies of same nsitemnumber
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
		--)tst --10274
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
	) -- #10274
	select COUNT(*)
	from
	(
		select 
		--*
		--COUNT(*)
		nsitemnumber 
		from dbo.plxSupplyItemRecNoSet
		group by nsitemnumber
	)tst --10274	


--CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
select count(*) cnt from (
--select top 100 * from (
select 
	top 100
	row_number() OVER(ORDER BY NSItemNumber ASC) AS Row#,
	p.Numbered,  -- Not in final set
	BEItemNumber as "Item_No",
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
from dbo.plxSupplyItemRecNoSet si
left join dbo.Parts p
on si.minRecordNumber=p.RecordNumber	
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName
left outer join btMfgMap mm
on p.Manufacturer=mm.plexMfg
inner join plxTestSetItemLocation ts  -- only pull records we want to test
	on #set7.location= ts.location

)tst
--where manufacturer = ''  --8132
--where manufacturer is null  --0
where manufacturer <> '' --2156
)tst2  --10288

--manufacturer is null  --0
select count(*) from (
select top 100 nsitemnumber,
case 
when p.Vendor is null then 'Null'
when p.Vendor = '' then 'Empty'
when LTRIM(RTRIM(p.Vendor)) = '' then 'Whitespace'
else p.Vendor
end as ven,
--p.Vendor,
case 
when sc.VendorName is null then 'Null'
when sc.VendorName = '' then 'Empty'
when LTRIM(RTRIM(sc.VendorName)) = '' then 'Whitespace'
else sc.VendorName
end as venName
from #set7
left join dbo.Parts p
	on #set7.minRecordNumber=p.RecordNumber	
--)tst --10288
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName
)tst --10288






















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

