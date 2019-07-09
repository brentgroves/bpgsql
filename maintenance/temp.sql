

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
--

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
			--Remember at this point the itemnumber contains a suffix.
			--select COUNT(*) cntParts from (
			select 
			min(RecordNumber) MinRecordNumber,
			ItemNumber,
			BuildingCode,
			Location
			from 
			(
				--select COUNT(*) cntParts from (
				select itemnumber,location from (
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
				--select 
				--count(*) cnt
				--sm.emSite,sm.plxSite
				from dbo.Parts p  --12474
				left outer join dbo.btSiteMap sm
				on p.Site=sm.emSite
				--where sm.emSite is null --0
				left outer join dbo.btSiteBuildingMap bm
				on sm.plxSite=bm.plxSite
				where 
				--sm.emSite is null or bm.plxSite is null --0
				(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') --11369
				--)tst --11372
				)tst group by itemnumber,location --11176
				having count(*) > 1  --14, At this stage the item number has a suffix so were not including parts in different sites here.
				--)tst --11200  --
				
			)set1	
			/*
			 * If duplicate part numbers have distinct locations then
			 * they both will be in this set, but only the part number 
			 * with the lowest record number will be included if the
			 * duplicate part numbers have the same plxSite and EM shelf.
			 * There were only 5 parts with duplicate plxSite and EM shelf.
			 * Remember itemNumber has a suffix at this point.
			 */
			group by ItemNumber,Location,BuildingCode
			--having count(*) > 1  --5
			--)tst --11367
		)set2 
		inner join dbo.Parts p
		on set2.MinRecordNumber=p.RecordNumber
		--)tst --11367
	)set3
	--order by location,itemNumber
	--)tst --11210
)--11210


select 
top 100 *
--count(*) 
from dbo.plxItemLocationBase

/*
 * Test: 200 
 * Verify that the item number has no spaces
 */
select * 
from plxItemLocationBase
where ItemNumber <> LTRIM(RTRIM(itemnumber))

/*
 * Test: 210 
 * Verify that we have the correct number of records in plxItemLocationBase.
 * Wrap each section of query with select COUNT(*) cntParts from (
 * and verify record count makes sense
 * 
 */

/*
 * Test: 220 
 * Verify the btSiteMap looks correct and make spreadsheet for Maintenance
 * Verify that btSiteMap has a valid record for all EM site in plex
 * Verify that every part record has an plex site.
 * 
 * 
 */


/*
 * Verify that btSiteMap has a valid record for all EM site in parts
 * 
 */

select 
count(*) cnt
--ds.Site,
--sm.* --17
from
(
select 
--count(*)
--sm.*
DISTINCT Site --17
from dbo.Parts p  --12474
)ds
left outer join dbo.btSiteMap sm
on ds.Site=sm.emSite
where sm.emSite is null

/*
 * Verify that every part record has an plex site.
 */
select 
count(*) 
--sm.*
--p.Site 
from dbo.Parts p  --12474
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
where sm.emSite is null --0

/*
 * Test: 230 
 * Verify that btSiteBuildingMap looks correct.
 * Verify that btSiteBuildingMap has a valid record for all Plex site
 * in btSiteMap table
 * Verify that all records in the plxItemLocationBase table have a
 * valid BuildingCode
 * 
 */

/*
 * Verify that btSiteBuildingMap looks correct.
 */
select *
from dbo.btSiteBuildingMap

/*
 * Verify that btSiteBuildingMap has a valid record for all Plex site 
 * in btSiteMap table
 */
select 
--count(*) cnt
sm.emSite,sm.plxSite,bm.building_code
from 
dbo.btSiteMap sm
left outer join btSiteBuildingMap bm
on sm.plxSite=bm.plxSite

/*
 * Verify that all records in the plxItemLocationBase table have a
 * valid BuildingCode
 */
select ilb.BEItemNumber,ilb.BuildingCode,bm.building_code 
from dbo.plxItemLocationBase ilb
left outer JOIN 
dbo.btSiteBuildingMap bm
on
ilb.BuildingCode=bm.building_code
where Buildingcode ='' or Buildingcode is null
or bm.building_code='' or bm.building_code is null

/*
 * Test: 240 
 * Verify there are no Kendallville part records in plxItemLocationBase.
 * 
 */

select 
count(*) cnt
--sm.emSite,sm.plxSite
from dbo.Parts p  --12474
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
--where sm.emSite is null --0
left outer join dbo.btSiteBuildingMap bm
on sm.plxSite=bm.plxSite
where 
--(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') --11369
--(RIGHT(LTRIM(RTRIM(Numbered)),1) = 'K'  or sm.plxSite = 'MO')     --1105
--														Total Parts: 12474  Matches number of records in parts table.

/*
 * Test: 250 
 * Verify that if shelf and site are blank plxItemLocationBase location field contains 'no location yet'. --00
 * Verify that if shelf is blank but site is not the plxItemLocationBase location field is in form of plxSite + 'no location yet' --01
 * Verify that if shelf is not blank and site is blank the plxItemLocationBase location field is in the form of 'No site' + shelf; --10
 * Verify that if there is both an site and shelf in EM part record the plxItemLocationBase field is in the form of plxSite + shelf --11
 * Verify that the correct count of each category above gets transferred to plex.
 * Verify that all plxItemLocationBase records fall into one of these categories.
 */

/*
 * Verify that if shelf and site are blank plxItemLocationBase location field contains 'no location yet'. --00
 * No EM parts records match this criteria
 */

select 
count(*) cnt  -- 0 records
--top 100 Numbered,site,Shelf
from dbo.Parts p  --12474
where 
(p.Shelf = '' or p.Shelf is null) --331
and 
(p.Site = '' or p.Site is null)  --0

/*
 * Verify that if shelf is blank but site is not the plxItemLocationBase location field is in form of plxSite + 'no location yet' --01
 */

select
--count(*) cnt
fp.numbered,ilb.RecordNumber,fp.recordnumber,fp.site,fp.shelf,ilb.Location
from
dbo.plxItemLocationBase ilb
inner join
(
select 
RecordNumber,numbered,shelf,site
--count(*) cnt  --331 match this criteria
--top 100 Numbered,site,Shelf
from dbo.Parts p  --12474
where 
(p.Shelf = '' or p.Shelf is null) --331
and 
(p.Site <> '' and p.Site is not null)  --12474
)fp
on ilb.RecordNumber=fp.recordnumber --311
where ilb.BEItemNumber = 'BE000203'


/*
 * Verify that if shelf is not blank and site is blank the plxItemLocationBase location field is in the form of 'No site' + shelf; --10
 * No records match this criteria
 */

select 
--RecordNumber,numbered,shelf,site
count(*) cnt  --331 match this criteria
--top 100 Numbered,site,Shelf
from dbo.Parts p  --12474
where 
(p.Shelf <> '' and p.Shelf is not null) --12145
and 
(p.Site = '' or p.Site is null)  --0

/*
 * Verify that if there is both a site and shelf in EM part record the plxItemLocationBase field is in the form of plxSite + shelf --11
 */

select
--count(*) cnt
fp.numbered,ilb.BEItemNumber,ilb.RecordNumber,fp.recordnumber,fp.site,fp.shelf,ilb.Location
from
dbo.plxItemLocationBase ilb
inner join
(
select 
RecordNumber,numbered,shelf,site
--count(*) cnt  --331 match this criteria
--top 100 Numbered,site,Shelf
from dbo.Parts p  --12474
where 
(p.Shelf <> '' and p.Shelf is not null) --12145
and 
(p.Site <> '' and p.Site is not null)  --12476
)fp  --12145
on ilb.RecordNumber=fp.recordnumber --10899
where ilb.BEItemNumber = 'BE200240' --3 records

/*
 * Verify that all plxItemLocationBase records fall into one of these categories.
 * Both site and shelf: 		   10899
 * Shelf is blank but site is not:   311
 *      Total plxItemLocationBase: 11210
 * Totals Match: YES
 */
select COUNT(*)
from dbo.plxItemLocationBase

/*
 * Test: 255 
 * Verify that for dup numbered, location, building code records all but one record is removed. 
 * This test is done in the query itself above.
 */

select 
--COUNT(*)
RecordNumber,  
ItemNumber,
Location
from dbo.plxItemLocationBase
where LTRIM(RTRIM(ItemNumber)) in
(
'404012', 
'208220A', 
'701063',--
'201206',
'000529'
)
order by ItemNumber

select 
--COUNT(*)
RecordNumber,  
Numbered ItemNumber,
site,Shelf
from dbo.Parts
where LTRIM(RTRIM(Numbered)) in
(
'404012', 
'208220A', 
'701063',--
'201206',
'000529'
)
order by Numbered

--update dbo.Parts
set Shelf = 'CHIPROOM'
--select shelf,* from dbo.Parts
where 
RecordNumber = 7907

select * 
--into btparts0708
from dbo.Parts
/* Duplicate item/locationa
itemnumber|location    
----------|------------
404012    |M5-CHIPROOM 
208220A   |M8-CAB H-2-4
701063    |M5-20-07-03 
201206    |M5-17-01-03 
000529    |M5-27-04-05   

/*
 * Test: 260 
 * Verify that part number suffix are being handled correctly. 
 */


select 
--COUNT(*)
RecordNumber,  
ItemNumber,Suffix,BEItemNumber
from dbo.plxItemLocationBase
where BEItemNumber in
(
'BE000003', 
'BE000054', 
'BE000091',--
'BE000547',
'BE200382'
)
order by BEItemNumber

/*
RecordNumber|ItemNumber|Suffix|BEItemNumber
------------|----------|------|------------
         450|000003A   |A     |BE000003    
       13424|000054AV  |AV    |BE000054    
        9145|000054    |N     |BE000054    
         839|000091    |N     |BE000091    
       10986|000091E   |E     |BE000091    
       13043|000547AV  |AV    |BE000547    
       14322|200382E   |E     |BE200382    
*/

/*
 * Test: 265 
 * Verify that part number with multiple locations 
 * all get uploaded to plex including quantities
 */
select 

--COUNT(*)
--BEItemNumber
RecordNumber,ItemNumber,BEItemNumber,location,QuantityOnHand
from dbo.plxItemLocationBase
--group by BEItemNumber
--HAVING count(*) > 1
where BEItemNumber in
(
'BE200051',
'BE201069',
'BE451057',
'BE000054', 
'BE000091'
)
order by BEItemNumber
/*
RecordNumber|ItemNumber|BEItemNumber|location                 |QuantityOnHand
------------|----------|------------|-------------------------|--------------
        9145|000054    |BE000054    |M5-09-05-04              |      13.00000
       13424|000054AV  |BE000054    |M11-B-02-03              |       7.00000
         839|000091    |BE000091    |M5-19-05-05              |       2.00000
       10986|000091E   |BE000091    |ME-B-6-4                 |       6.00000
       15358|200051E   |BE200051    |ME-A-5-4                 |       6.00000
       14930|200051AV  |BE200051    |M11-COMP RM SHELF A-03-01|      14.00000
         385|200051    |BE200051    |M5-23-07-05              |      15.00000
        4985|201069    |BE201069    |M5-13-01-02              |       4.00000
        5033|201069E   |BE201069    |ME-B-5-5                 |       3.00000
       12822|451057    |BE451057    |MPB-C-4-2                |       4.00000
       12845|451057AV  |BE451057    |M11-B-03-04              |       4.00000          
 */



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
--drop table plxLocation
--into plxLocation
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
	 ***********************************
	 * Since there are many parts that share locations the set
	 *  count will drop significantly at this point. 
	 */
	--select count(*) cnt from (
	select DISTINCT Location,BuildingCode 
	--select DISTINCT Location --Should be the same set as distinct location, buildingcode 
	from plxItemLocationBase base
	--)tst --3325 
)set1
--)tst --3325
order by location 

/*
 * 
 * 
 * 			Location Testing
 * 
 * 
 * 
 * 
 * 
 */

/*
 * Test: 300 
 * Verify count of all locations
 * Verify 5 locations that they were uploaded correctly on Plex screen.
 * Verify count of locations with location_type of 'Maintenance' 
 * and location_group of 'Maintenance Crib'
 * Verify count of location with each building code.
 * Verify 5 locations were created in correct format
 * use the plex supply item screen to verify location
 * and quantity is as expected.
 */

/*
 * Verify count of all locations
 */
select 
count(*) cnt
--top 100  
--Location,building_code,location_type,note,location_group
from dbo.plxLocation
--3325

/*
 * Verify 5 locations that they were uploaded correctly on Plex screen.
 */
select 
--count(*) cnt
--top 100  
Location,building_code,location_type,note,location_group
from dbo.plxLocation
--3325
where Location in
(
'MM-AT MRO',
'MD-A-1',
'ME-A- TOP',
'M11-A-02-03',
'M5-0',
'M8-A-1',
'MPB-09-09-03',
'M4-C-1'
)
/*
 * Verify 5 locations were created in correct format
 * use the plex supply item screen to verify location
 * and quantity is as expected.
 * 
 */
select 
--count(*) cnt
--top 100  
bil.BEItemNumber,bil.Location,
p.site,p.shelf,bil.QuantityOnHand
from dbo.plxItemLocationBase bil
inner join dbo.Parts p
on bil.RecordNumber=p.RecordNumber
--3325
where bil.Location in
(
'MM-AT MRO',
'MD-A-1',
'ME-A- TOP',
'M11-A-02-03',
'M5-0',
'M8-A-1',
'MPB-09-09-03',
'M4-C-1'
)

/*
 * Verify count of locations with location_type of 'Maintenance' 
 * and location_group of 'Maintenance Crib'
 */
select 
count(*) cnt
--top 100  
--Location,building_code,location_type,note,location_group
from dbo.plxLocation
where location_type = 'Maintenance'
and location_group = 'Maintenance Crib'  --3325
/*
 * Verify count of location with each building code.
 */
select 
--count(*) cnt
--distinct building_code
--top 100  
Location,building_code,location_type,note,location_group
from dbo.plxLocation
--where building_code = 'BPG Central Stores'
--where building_code = 'BPG Distribution Center'
--where building_code = 'BPG Edon'
--where building_code = 'BPG Plant 11'
--where building_code = 'BPG Plant 5'
--where building_code = 'BPG Plant 8'
--where building_code = 'BPG Pole Barn'
where building_code = 'BPG Workholding'
order by building_code
/*
'MM-AT MRO',
'MD-A-1',
'ME-A- TOP',
'M11-A-02-03',
'M5-0',
'M8-A-1',
'MPB-09-09-03',
'M4-C-1',


 */
/*
building_code          
-----------------------
BPG Central Stores = 1    
BPG Distribution Center
BPG Edon               
BPG Plant 11           
BPG Plant 5            
BPG Plant 8            
BPG Pole Barn          
BPG Workholding        
 */


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
--)tst --11210


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
 * is located. This was required because there is no separate item location
 * table in EM and if a part was stored in multiple locations a separate
 * part record was created differing only in its suffix.  This suffix 
 * is not needed in Plex and will be dropped because Plex has a
 * one-to-many relationship between supply items and item location 
 * tables. For parts with multiple EM part records,ie. a part with multiple 
 * locations, we choose only one to upload into plex. This chosen part will 
 * be used to retrieve description,unit price,vendor and other non-location 
 * information. 
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
					--select count(*) cnt from 
					plxItemLocationBase il  --11210						
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
				--)tst  --10279
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
		--)tst1 --10279 check for multiple copies of same nsitemnumber
	)set4 --
	left outer join 
	(
		/*
		 * There are some parts with duplicate part numbers, but since
		 * we need exactly one record to retrieve description, category,
		 * etc. non-locatin information for any dups we will choose the 
		 * one with the lowest record number. There are also some numbers 
		 * with spaces so use trim functions.
		 */
		select min(RecordNumber)minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber  
		from dbo.Parts
		group by ltrim(rtrim(Numbered))  
	)p
	on set4.ItemNumber=p.ItemNumber
	--)tst --10279
	/*
	where 
	set4.nsitemnumber like '000003%'
	or set4.nsitemnumber like '000054%'
	or set4.nsitemnumber like '000091%'
	or set4.nsitemnumber like '000547%'
	or set4.nsitemnumber like '200382%'
	order by set4.nsitemnumber
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
) -- #10279

select COUNT(*)
from
(
	select 
	--*
	--COUNT(*)
	nsitemnumber 
	from dbo.plxSupplyItemBase
	group by nsitemnumber
)tst --10279	


/*
 * 
 *   Validate SupplyItemBase
 * 
 * 
 */


/*
 * BEItemNumber
 */
select BEItemNumber from plxSupplyItemBase 
WHERE LTRIM(RTRIM(BEItemNumber) like '%' + ' ' + '%'  --are there any spaces


--CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
--select count(*) cnt from (
select 
row_number() OVER(ORDER BY si.BEItemNumber ASC) AS Row#,
si.BEItemNumber as "Item_No",

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
-- used xxd on plex csv file and dbeaver binary viewer on em and both seem to use 0D0A combo for \n.
-- DBeaver exports NotesText unicode field as plain ascii text, but anywhere there is a \n, ie. 0D0A combo
-- we need to replace it.  If we don't the Plex upload process will interpret this as a completely new record to be uploaded.
-- So replace the \n (0x0D 0x0A) combo with 0x0D.  I tested with replacing the combo with 0x0A and the upload failed.
-- When Plex exports the notes column and it contains a \n it puts quotes around the field and inserts the 0x0D 0x0A ascii characters.
-- This seems like a hack but I don't see any way around it.
REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(13)) as Note, --
-- BUT to make sure CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
--Test with '100988','708991','200800','100012','100011'
--NotesText as Note, 
'Maintenance' as item_type,
CASE
	when ((p.CategoryID is null) or (ltrim(rtrim(p.CategoryID))) = '') then 'General'
	when p.CategoryID = '-PLATE' then 'PLATE'  -- Kristen did not change this in EM 06-04 
	else LTRIM(RTRIM(CategoryID))
end as Item_Group,
--select categoryid from dbo.Parts where CategoryID LIKE '%PLATE%'
--select distinct categoryid from parts order by categoryid	--192  looks like there are extra in plex such as welding
'General' as Item_Category
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
MinimumOnHand as Min_Quantity, 
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
-- 70	Tax Exempt - Labor / Industrial Processing
'Tax Exempt - Labor / Industrial Processing' as Tax_Code,

-- I worked hard to fill the account_no with an account that could be used to catagorize items as electrical, pumps, and something
-- else I cant remember so that Pat could use the account field to keep track of the information he needs.  But was told to quit by Casey.
-- and leave it blank.
-- 70200-320-0000	Repairs & Maint - Machine Maint
'70200-320-0000' as Account_No,
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
--drop table plxSupplyItem
--into plxSupplyItem
from dbo.plxSupplyItemBase si
--)tst --10279
inner join dbo.Parts p
on si.RecordNumber=p.RecordNumber
--)tst --10279
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName 
--select count(*) cnt from dbo.Parts where vendor = '' --485
left join btMfgMap mm
on p.Manufacturer=mm.plexMfg 
--select count(*) cnt from dbo.Parts where manufacturer = '' --6990
--)tst  --10279


/*
 * 
 * 
 * 			plxSupplyItem
 * 			Validation
 * 
 * 
 */

/*
Test: 5 
Verify the count of EM supply items to upload equals the count in Plex. 
*/
select 
count(*) 
from plxSupplyItem 
--10279

/*
Test: 15 
Verify that the description field is being formatted correctly 
*/

select 
item_no,Description 
from plxSupplyItem  
where item_no in
(
'BE800300','BE999997','BE139987','BE000668','BE600005','BE999000','BE200703','BE650002AV' 
)

--VendorNumber,Manufacturer,ManufactuerNumber 
--000 800300 
--001 999997  |            |            |02120             | 
--010 139987  |            |MORI SEIKI  |                  | 
--011 000668  |            |SIEMENS     |1FT6044-4AF71-4AA6| 
--100 600005  |6408M-22MM  |            |                  | 
--101 999000  |945         |            |945               | 
--110 200703  |800EPMJ3    |Allen Bradley|                  | 
--111 650002AV|54041462    |Kendall Electric|SUPER33+          | 

/*
Test: 20 
Verify that items with a newline in the notes field display correctly on the Supply Item detail screen. 
*/

select  
--count(*) 
--top 10 
item_no,Note
from plxSupplyItem  
where item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
--where notestext like '%'+CHAR(10)+'%' --2503 
--where notestext like '%'+char(13)+'%' --2503 
--where notestext like '%'+char(13)+CHAR(10)+'%' -- 2503 --THESE ARE THE ASCII VALUES THAT GET STORED IN THE DATABASE (0x0D 0x0A) 
--where notestext like '%'+char(13)+'%'  
--and notestext not like '%'+CHAR(10)+'%' --0 
--where notestext like '%'+char(10)+'%'  
--and notestext not like '%'+CHAR(13)+'%' --0 


/*
Test: 30 
Verify that Item_Group field is identical to EM categoryId.  Check for nulls 
*/

select  
--count(*) 
top 100 
item_no,
item_group
from plxSupplyItem  
where 
--item_group is null or item_group = ''
-- and item_group like '%cover%   
item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
/*
item_no |item_group     
--------|---------------
BE100011|B Axis         
BE100012|B Axis         
BE100988|OEM Okuma parts
BE200800|Switch, General
BE708991|Pumps          
*/

/*
Test: 33 
Verify that all parts have a item_category of ‘general’. 
*/
select
count(*)
--top 1 numbered,categoryid
from dbo.Parts
where categoryid <> 'General'

/*
Test: 40 
Verify that Customer_Unit_Price contains the same amounts as in EM. 
*/

select  
--count(*) 
--top 10 
item_no,
Customer_Unit_Price
from plxSupplyItem  
where item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)

/*
Test: 50
Inventory_Unit,
Verify that there are no blank units.
Verify blank parts.units map to Ea
Verify that Each maps to Ea
Verify that Electrical maps to Ea
Verify EA count is correct
Verify that Box maps to Box and count is correct
Verify that Case maps to case and count is correct
Verify that Dozen maps to dozen and count is correct
Verify that Feet maps to Feet and count is correct
Verify that Gallons maps to Gallons and count is correct
Verify that INCHES maps to inches and count is correct
Verify that Meters maps to meters and count is correct
Verify that Per 100 maps to hundred and count is correct
Verify that Per Package maps to Package 
Verify that Package maps to Package 
Verify count of Package correct
Verify that Pounds maps to lbs and count is correct
Verify that Quart maps to quart and count is correct
Verify that Roll maps to Roll and count is correct
Verify that Set maps to set and count is correct
*/
select 
COUNT(*)
--top 1 numbered,units 
from dbo.Parts
--where LTRIM(RTRIM(Units)) is null or LTRIM(RTRIM(Units)) = '' --Ea
--where LTRIM(RTRIM(Units)) = 'Each' --Ea
--where LTRIM(RTRIM(Units)) = 'Electrical' --Ea
--where LTRIM(RTRIM(Units)) is null or LTRIM(RTRIM(Units)) = ''
--or LTRIM(RTRIM(Units)) = 'Each' 
--or LTRIM(RTRIM(Units)) = 'Electrical' --Ea
--where LTRIM(RTRIM(Units)) = 'Box'
--where LTRIM(RTRIM(Units)) = 'Case'
--where LTRIM(RTRIM(Units)) = 'Dozen'
--where LTRIM(RTRIM(Units)) = 'Feet'
--where LTRIM(RTRIM(Units)) = 'Gallons'
--where LTRIM(RTRIM(Units)) = 'INCHES'
--where LTRIM(RTRIM(Units)) = 'Meters'
--where LTRIM(RTRIM(Units)) = 'Per 100'
--where LTRIM(RTRIM(Units)) = 'Per Package'
--where LTRIM(RTRIM(Units)) = 'Package'
--where LTRIM(RTRIM(Units)) = 'Per Package' 
--or LTRIM(RTRIM(Units)) = 'Package'
--where LTRIM(RTRIM(Units)) = 'Pounds'
--where LTRIM(RTRIM(Units)) = 'Quart'
--where LTRIM(RTRIM(Units)) = 'Roll'
where LTRIM(RTRIM(Units)) = 'Set'

/*  
numbered|units |
--------|-----------|
110000  |     |
999000  |Each |
200020  |Electrical|
All		|     | 11907
450820  |Box  | 7
200603  |Case | 3
700984  |Dozen| 5
200570  |Feet | 285
999002  |Gallons|9
705529A |INCHES|3
200539  |Meters|5
200000  |Per 100|10
500008  |Per Package|3
500025  |Package|10
All		|     | 13
990003  |Pounds|2
800300  |Quart|1
650006AV|Roll |12
000030  |Set  |141
*/

select  
--count(*) 
--top 10 
item_no,
inventory_unit
from plxSupplyItem 
--where inventory_unit = '' or inventory_unit is null
where item_no in 
(
--Plex/EM unit
'BE000030',--set / Set
'BE110000',--Ea / blank
'BE200000',--hundred / Per 100
'BE200020',--Ea / Electrical
'BE200539', --meters / Meters
'BE200570',--Feet / Feet
'BE200603',--case / Case
'BE450820',--Box / Box
'BE500008',--Package / Per Package
'BE500025',--Package / Package
'BE650006', --Roll / Roll
'BE700984',--dozen / Dozen
'BE705529', --inches /Inches
'BE800300',--quart / Quart
'BE990003',--lbs / Pounds
'BE999000',--Ea / Each
'BE999002'--Gallons / Gallons
)
where inventory_unit = 'Box' --count
where inventory_unit = 'case'
where inventory_unit = 'dozen'
where inventory_unit = 'Ea'
where inventory_unit = 'Feet'
where inventory_unit = 'Gallons'
where inventory_unit = 'inches'
where inventory_unit = 'meters'
where inventory_unit = 'hundred'
where inventory_unit = 'Package'
where inventory_unit = 'lbs'
where inventory_unit = 'quart'
where inventory_unit = 'Roll'
where inventory_unit = 'set'
order by item_no

/*
and item_no in 
(
'110000',--Ea
'999000',--Ea
'200020',--Ea
'450820',--Box
'200603',--case
'700984',--dozen
'200570',--Feet
'999002',--Gallons
'705529A', --inches
'200539', --meters
'200000',--hundred
'500008',--Package
'500025',--Package
'990003',--lbs
'800300',--quart
'650006AV', --Roll
'000030'--set
)
*/

/*
Test: 55 
Verify that EM.MinimumOnHand is not null 
Verify that Min_Quantity is not null 
Verify that Min_Quantity contains EM.MinimumOnHand. 
*/

select numbered,MinimumOnHand
from dbo.Parts
--where MinimumOnHand is null
where ltrim(rtrim(numbered))
in
(
'100988','708991','200800','100012','100011'
)
order by numbered

select  
--count(*) 
p.numbered,
b.BEItemNumber
from plxSupplyItemBase b
left outer join dbo.Parts p
on b.recordnumber=p.RecordNumber
where BEItemNumber
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)

select  
--count(*) 
--top 10 
item_no,
Min_Quantity
from plxSupplyItem  
--where Min_Quantity is null
where item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
order by item_no
/*
numbered|MinimumOnHand
--------|-------------
100011  |      4.00000
100012  |      8.00000
100988  |      0.00000
200800  |      1.00000
708991  |      1.00000
*/

/*
Test: 60 
Verify that EM.MaxOnHand is not null 
Verify that Max_Quantity is not null 
Verify that when EM.minimumOnHand > EM.maxOnHand then plex Max_Quantity gets set to 0
Verify that in other cases that Max_Quantity gets set to EM.MaxOnHand
CASE
	when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then 0
	else MaxOnHand
end as Max_Quantity,

numbered|RecordNumber|MinimumOnHand|MaxOnHand
--------|------------|-------------|---------
100988  |        9901|      0.00000|  1.00000
705286A |        6223|     10.00000|  1.00000
705334A |        6274|      2.00000|  1.00000

*/

select numbered,MinimumOnHand,MaxOnHand
from dbo.Parts
--where MaxOnHand is null
where (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) 
order by numbered

select numbered,RecordNumber,MinimumOnHand,MaxOnHand
from dbo.Parts
where 
numbered like '%100988%'
or numbered like '%200277%'
or numbered like '%705334%'
or numbered like '%705286%'
order by numbered,RecordNumber


select  
--count(*) 
--top 10 
item_no,
Min_Quantity,Max_Quantity
from plxSupplyItem  
--where Max_Quantity is null
where item_no
in
(
'BE705334','BE705286','BE100988'
)
order by item_no

/*

Test: 65 
Verify the tax code on the Supply Item detail screen the tax code 
says 'Tax Exempt - Labor / Industrial Processing'  for item_no = 'BE705334' 
Verify all maintenance supply items have a tax_code of 'Tax Exempt - Labor / Industrial Processing' 
and a tax_code_no = 70 

**/

select  
count(*) 
--top 10 
item_no,
tax_code
from plxSupplyItem  
--where tax_code = 'Tax Exempt - Labor / Industrial Processing'
where tax_code <> 'Tax Exempt - Labor / Industrial Processing'

/*
Test: 70 
Verify the account from the supply item detail screen for item_no = 'BE705334' 
Verify all maintenance supply items have been assigned the account:
‘Repairs & Maint - Machine Maint’ 70200-320-0000. 
*/

select  
count(*) 
--top 10 
--item_no,
--Account_No
from plxSupplyItem  
--where account_no = '70200-320-0000' 
where Account_No <> '70200-320-0000'


/*
Test: 75 

Not sure if this is the manufacturer_key, manufacturer_code, or Manufacturer_Name
common_v_manufacturer field.

Note on upload wiki:
If not configured to use Suppliers as Supply Item manufacturers, 
then this field,manufacturer_text varchar(25), contains the name of the Manufacturer. 
All the Manufacturer fields are greater than varchar(25) and I dont see a field
called manufacturer_text.

case  
    when mm.plexVendor is null then 'null' --many 
    when mm.plexVendor = '' then 'Empty'  --0 
    when LTRIM(RTRIM(mm.plexVendor)) = '' then 'WhiteSpace' --0 
    else mm.plexVendor 
end as ManufacturerTest, 
case  
    when mm.plexMfg is null then '' 
    else mm.plexMfg 
end as Manufacturer, 

1. Verify the count of supply items with mapped manufacturers in plxSupplyItems is equal 
to the count of supply items with manufacturers in plex. 

2. Verify that 5 supply items with manufactures got uploaded correctly using the ‘supply items detail screen’ 
*/


/*
 * 1. Verify the count of supply items with mapped manufacturers in plxSupplyItems is equal 
 * to the count of supply items with manufacturers in plex. 
 */
select 
count(*)
from
(
	select
	--sb.*
	--top 100
	--sb.BEItemNumber, p.Manufacturer EM,si.Manufacturer Plex
	--distinct p.Manufacturer --168 distinct
	from dbo.plxSupplyItemBase sb  --10279
	inner join dbo.plxSupplyItem si
	on sb.BEItemNumber=si.Item_No  --10279
	inner join dbo.Parts p
	on sb.RecordNumber=p.RecordNumber --10279
	left outer join btMfgMap mm
	on p.Manufacturer=mm.emMfg 
	where si.Manufacturer <> ''  --2162
	--where mm.emMfg is not null  --2162
	-- There are 5 manufacturers uploaded to plex
	-- that have no supply item's manufacturer assigned
)tst

/*
 * 2. Verify that 5 supply items with manufactures got uploaded correctly using the ‘supply items detail screen’ 
 * 
 */

select
--sb.*
--top 100
sb.BEItemNumber, p.Manufacturer EM,si.Manufacturer Plex
--distinct p.Manufacturer --168 distinct
from dbo.plxSupplyItemBase sb  --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
left outer join btMfgMap mm
on p.Manufacturer=mm.emMfg 
where si.Item_No in
(
'BE200800', --Omron
'BE100012', --Okuma America Corporation
'BE700801', --Barksdale
'BE706202', --MITSUBISHI ELECTRIC
'BE701996'  --BOSCH-REXROTH
)


-- Verify count for supply items that have no manufacturer assigned
select  
count(*) 
--top 10 
--item_no,
--Account_No
from plxSupplyItem  
where manufacturer <> '' or manufacturer is null  --2162

select 
top 100 *
from btmfgMap mm

-- Verify all parts with a manufacturer in EM have a manufacturer in Plex
select
top 100
p.Manufacturer EM,si.Manufacturer Plex
from dbo.plxSupplyItemBase sb
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber
left outer join btMfgMap mm
on p.Manufacturer=mm.emMfg 

/*
 * Why aren't some of these manufacturer in plex
 * Is it a case problem?
 * Did Kristen not want them in because they were not manufacturers?
 * 
 */


/*
 * There are select 283 manufacturers in Plex
 * There are 398 distinct manufacturer in EM
 * and 173 in the btMfgMap
 *      Total EM manufacturers: 398
 * 
 * EM Manufacturers not mapped: 213
 *        Mapped Manufacturers: 173
 *                              386
 */


select 
count(*) cnt
from btmfgmap 

select 
count(*)
from
(
select
--top 100
DISTINCT p.Manufacturer
--p.Numbered,p.Manufacturer,mm.emMfg
from dbo.Parts p --398
)tst
--order by Manufacturer

select mm.* 
from 
dbo.btMfgMap mm

/*
 * Are there any of EM manufacturers that are not in plex
 * that should be there? Probably but Kristen has chosen
 * the manufacturers that she wants in Plex.  Also I 
 * asked that she could add/update/delete manufacturers
 * as required.
 */

select 
count(*) cnt
FROM
(
	select
	--top 100
	p.Manufacturer EM, COUNT(*)cnt
	--si.Manufacturer Plex
	--distinct p.Manufacturer
	from dbo.plxSupplyItemBase sb
	inner join dbo.plxSupplyItem si
	on sb.BEItemNumber=si.Item_No
	inner join dbo.Parts p
	on sb.RecordNumber=p.RecordNumber
	left outer join btMfgMap mm
	on p.Manufacturer=mm.emMfg 
	where 
	(p.Manufacturer <> '' and p.Manufacturer is not null)
	and emMfg is null
	group by p.Manufacturer
	HAVING count(*) > 5
	order by count(*) desc
)tst
--213
order by p.Manufacturer

/*
 *
 * Test: 80 
 * Verify that 5 Manf_Item_No were uploaded correctly. 
 * 
 * 
 *  
 */

select
--sb.*
--top 100
--si.Item_No,si.Manufacturer,si.Manf_Item_No,p.ManufacturerNumber
si.Item_No,si.Manf_Item_No
--sb.BEItemNumber, p.Manufacturer EM,si.Manufacturer Plex
--distinct p.Manufacturer --168 distinct
from dbo.plxSupplyItemBase sb  --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
left outer join btMfgMap mm
on p.Manufacturer=mm.emMfg 
where si.Item_No in
(
'BE200800', --Omron
'BE100012', --Okuma America Corporation
'BE700801', --Barksdale
'BE706202', --MITSUBISHI ELECTRIC
'BE701996'  --BOSCH-REXROTH
)

/*
 *
 * Test: 85 
 * Verify that all but 14 supply items that have a vendor 
 * also have a supplier code. 
 * 
 * 1. Verify that all but 14 supply items that have a vendor 
 *    also have a supplier code. 
 * 2. Verify the count of em.parts with no vendors --435
 * 3. Verify the count of supply items with no supplier_code  --449
 * 4. Verify that 5 supply item without a supplier uploaded correctly
 * 5. Verify that 5 supply items with a supplier uploaded correctly
 * 
 *  
 */

/*
 * 
 * Verify that 5 supply item without a supplier uploaded correctly
 * 
 */
select 
--COUNT(*) cnt
--top 100
item_no,sc.Supplier_Code
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName 
where 
--p.Vendor <> ''
--sc.Supplier_Code is null or sc.Supplier_Code ='' --14
item_no in (
'BE000008',
'BE000033',
'BE000090',
'BE000190',
'BE000295'
)

/*
 * 
 * 5. Verify that 5 supply items with a supplier uploaded correctly
 * 
 */
select 
--COUNT(*) cnt
--top 100
item_no,sc.Supplier_Code
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName 
where 
--p.Vendor <> ''
--sc.Supplier_Code is not null
item_no in (
'BE000001', --Gosiger Indiana   
'BE000011',--Neff
'BE000018',--FEPCO INC.
'BE000022',--Kendall
'BE000023'--EWALD ENTERPRISES  
)

/*
 * Verify that all but 14 supply items that have a vendor 
 * also have a supplier code. 
 */
select 
COUNT(*) cnt
--top 100
--item_no,p.QuantityOnHand, p.vendor,sc.Supplier_Code
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName 
where 
p.Vendor <> ''
and sc.Supplier_Code is null or sc.Supplier_Code ='' --14

/*
 * Verify the count of em.parts with no vendors --435
 * Verify the count of supply items with no supplier_code  --449
 * 
 */
select 
--distinct si.Supplier_Code
COUNT(*) cnt
--top 100
--item_no,p.QuantityOnHand, p.vendor,sc.Supplier_Code
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName --10279
where 
si.Supplier_Code = ''  or si.Supplier_Code is null  --0/449
--p.RecordNumber is null  --0
--p.vendor is null  --3
--and p.Vendor = ''   --432
--p.Vendor <> '' --9844
                --10279

select * from dbo.btSupplyCode
	where VendorName <> ''
order by supplier_code

/* item_supplier.Supplier_Item_No is varchar(50) and so is vendorNumber so there should be no truncation */

/*
 *
 * Test: 90 
 * Note: On plex supply item detail screen referred to as
 * a supplier part number but in database it is item_supplier.Supplier_Item_No
 *  
 * 1. Verify that the count of supply items with and without a 
 * supplier_part_no in plex equals EM
 * 
 * 2. Verify that 5 supply item supplier_part_no were uploaded correctly 
 *  
 */


/*
 * Verify that the count of supply items with and without a 
 * supplier_part_no in plex equals EM
 */
select 
--distinct si.Supplier_Code
COUNT(*) cnt
--top 100
--item_no,si.Supplier_Part_No, p.VendorNumber
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where 
si.Supplier_Part_No = '' or si.Supplier_Part_No is null --657
--si.Supplier_Part_No <> '' and si.Supplier_Part_No is not null --9622

/*
 * Verify that 5 supply item supplier_part_no were uploaded correctly 
 */
select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,si.Supplier_Part_No, p.VendorNumber
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where 
item_no in (
'BE000001', --E5552-192-010   
'BE000011',--AVRF1-2-DEF
'BE000018',--3-542-1193A
'BE000022',--ELT16
'BE000023'--blank 
)


/*
 *
 * Test: 95 
 *  
 * Verify the following for all supply items
 * Currency = USD
 * Supplier_Std_Purch_Qty = 0
 * Supplier_Unit_Conversion = 1
 *
 */


/*
 *
 * Test: 100 
 * Supplier_Std_Unit_Price
 * Verify that if there is a billing or current price and no supplier code an error does not occur
 * Verify 5 parts with a billing price that this price is uploaded.
 * Verify 5 parts which have no billing price that the current cost is uploaded.
 * Verify that if there is no billing price or current cost no error occurs.
 *
 */
/*
sc.Supplier_Code,
/* item_supplier.Supplier_Item_No is varchar(50) and so is vendorNumber so there should be no truncation */
VendorNumber Supplier_Part_No, 
*/

/*
 * Verify that if there is a billing or current price and no supplier code an error does not occur.
 * 
 */

select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,
si.Supplier_Code,
p.BillingPrice,
p.CurrentCost
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where 
item_no in 
(
'BE850355'
)

select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,
si.Supplier_Code,
p.BillingPrice,
p.CurrentCost
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where 
--p.BillingPrice is null or BillingPrice <= 0
--and p.Vendor <> '' and p.Vendor is not null
p.BillingPrice is NOT null AND BillingPrice > 0 
and p.Vendor = '' or p.Vendor is null

/*
 * Verify 5 parts with a billing price that this price is uploaded. 
 */

select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,
si.Supplier_Code,
p.BillingPrice,
p.CurrentCost
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where 
item_no in (
--where p.BillingPrice is NOT null AND BillingPrice > 0 
'BE000001', --20.04300   
'BE000020',--295.70000
'BE000021',--253.75000
'BE000028',--19.07000
'BE000029'--3.15000 
)

/*
 * 
 * 
 * Verify 5 parts which have no billing price that this current cost is uploaded correctly.
 * 
 * 
 */

select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,
si.Supplier_Code,
p.BillingPrice,
p.CurrentCost
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where
--p.BillingPrice is null or BillingPrice <= 0
item_no in (
'BE000002', --713.00000   
'BE000003',--368.58000
'BE000005',--585.00000
'BE000009',--138.75
'BE000010'-- 735.00000
)
/*
 * 
 * Verify that if there is no billing price or current cost no error occurs.
 * 
 */


select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,
si.Supplier_Code,
p.BillingPrice,
p.CurrentCost
from dbo.plxSupplyItemBase sb --10279
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10279
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10279
where
--(p.BillingPrice is null or BillingPrice <= 0)
--and
--(p.CurrentCost is null or p.CurrentCost <=0)
item_no in (
'BE000007', --713.00000   
'BE000008',--368.58000
'BE000025',--585.00000
'BE000079',--138.75
'BE000090'-- 735.00000
)




/*
Supplier_Purchase_Unit,
Test: 105 
Verify that there are no blank units.
Verify blank parts.units map to Ea
Verify that Each maps to Ea
Verify that Electrical maps to Ea
Verify EA count is correct
Verify that Box maps to Box and count is correct
Verify that Case maps to case and count is correct
Verify that Dozen maps to dozen and count is correct
Verify that Feet maps to Feet and count is correct
Verify that Gallons maps to Gallons and count is correct
Verify that INCHES maps to inches and count is correct
Verify that Meters maps to meters and count is correct
Verify that Per 100 maps to hundred and count is correct
Verify that Per Package maps to Package 
Verify that Package maps to Package 
Verify count of Package correct
Verify that Pounds maps to lbs and count is correct
Verify that Quart maps to quart and count is correct
Verify that Roll maps to Roll and count is correct
Verify that Set maps to set and count is correct
*/

/*  
numbered|units |
--------|-----------|
110000  |     |
999000  |Each |
200020  |Electrical|
All		|     | 11907
450820  |Box  | 7
200603  |Case | 3
700984  |Dozen| 5
200570  |Feet | 285
999002  |Gallons|9
705529A |INCHES|3
200539  |Meters|5
200000  |Per 100|10
500008  |Per Package|3
500025  |Package|10
All		|     | 13
990003  |Pounds|2
800300  |Quart|1
650006AV|Roll |12
000030  |Set  |141
*/

select  
--count(*) 
--top 10 
item_no,
Supplier_Purchase_Unit
from plxSupplyItem 
--where inventory_unit = '' or inventory_unit is null
where item_no in 
(
--Plex/EM unit
'BE000030',--set / Set
'BE110000',--Ea / blank
'BE200000',--hundred / Per 100
'BE200020',--Ea / Electrical
'BE200539', --meters / Meters
'BE200570',--Feet / Feet
'BE200603',--case / Case
'BE450820',--Box / Box
'BE500008',--Package / Per Package
'BE500025',--Package / Package
'BE650006', --Roll / Roll
'BE700984',--dozen / Dozen
'BE705529', --inches /Inches
'BE800300',--quart / Quart
'BE990003',--lbs / Pounds
'BE999000',--Ea / Each
'BE999002'--Gallons / Gallons
)
where Supplier_Purchase_Unit = 'Box' --count
where Supplier_Purchase_Unit = 'case'
where Supplier_Purchase_Unit = 'dozen'
where Supplier_Purchase_Unit = 'Ea'
where Supplier_Purchase_Unit = 'Feet'
where Supplier_Purchase_Unit = 'Gallons'
where Supplier_Purchase_Unit = 'inches'
where Supplier_Purchase_Unit = 'meters'
where Supplier_Purchase_Unit = 'hundred'
where Supplier_Purchase_Unit = 'Package'
where Supplier_Purchase_Unit = 'lbs'
where Supplier_Purchase_Unit = 'quart'
where Supplier_Purchase_Unit = 'Roll'
where Supplier_Purchase_Unit = 'set'
order by item_no

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
row#,
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
row#,
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

select 
COUNT(*) 
from dbo.plxLocationTS  
--65  All sites

--15 Pumps,Electronics,Covers

/*
 * Add all locations for union of part set which includes 5 parts each 
 * with an item category of Electronic, Pumps, and Covers.
 */
insert into dbo.plxLocationTS 
select
row#,
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
 * Add locations from the plxLocation tests. 
 * 
 * 
 */



/* 
 *	Per step 2 of the Test set generation process above.
 * 
 *  Create plxItemLocationTS. Use location test set to reduce the plxItemLocation table with inner join clause
 *  on the location field.  
 * 
 */
SELECT
row#,Item_No,il.Location,Quantity,Building_Default,Transaction_Type
--drop table plxItemLocationTS
--into plxItemLocationTS
from 
dbo.plxItemLocation il
inner join plxLocationTs ts -- reduce set by joining to the location test set table.
on il.Location= ts.Location
order by location,item_no
--163 


/*
 * Per set# 3 of the above Test Set generation process create the plxSupplyItemTS table.
 * 
 * 3. Use plxItemLocationTS set to reduce the plxSupplyItem set with inner join clause
 * 	  on the ItemNumber field.
 */

select 
row#,
si.Item_No,Brief_Description,Description,Note,Item_Type,Item_Group,Item_Category,
Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,si.Location,Supplier_Code,
Supplier_Part_No,Supplier_Std_Purch_Qty,Currency,Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
Cube_Unit			
--drop table plxSupplyItemTS
--into plxSupplyItemTS
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
--163

select * 
from plxItemLocationTS il 
--163
inner join dbo.plxLocationTS l
on il.Location=l.Location
--163
inner join plxSupplyItemTS si
on il.Item_No=si.item_no
--163



/*
 * 
 * 
 * 			Test Upload section
 * 
 * 
 */

/*
 * Quere to upload a range of locations
 */
select  
Location,building_code,location_type,note,location_group
from dbo.plxLocationTS
--where row# >=1
--and row# <= 100
order by location

/*
 * Query to upload a range of supply items.
 */

select
top 1
Item_No+'B',Brief_Description,Description,
--REPLACE(REPLACE(convert(varchar(max),Note), CHAR(13), ''), CHAR(10), '') as Note, --
--REPLACE(REPLACE(REPLACE(convert(varchar(max),Note), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note, --
--'Line 1'+ char(13) + char(10) +'Line 2' + char(13)+char(10) + 'Line 3' Note,
--'Test' + char(10) + char(13) + 'Test' Note,
Item_Type,Item_Group,Item_Category,
Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,Location,Supplier_Code,
Supplier_Part_No,Supplier_Std_Purch_Qty,Currency,Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
Cube_Unit			
from dbo.plxSupplyItemTS
where 
item_no = 'BE000412'
--where row# >=1
--and row# <= 100
order by item_no
select notestext from dbo.Parts where numbered like '%000001%'
/*
 * Query to upload a range of item locations
 */
select Item_No,Location,Quantity,Building_Default,Transaction_Type 
from plxItemLocationTS  --
where row# >=1
and row# <= 100
order by location,item_no


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

