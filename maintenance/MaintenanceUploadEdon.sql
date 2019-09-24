

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
--truncate table dbo.plxItemLocationBase
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
/*
 * 
 * Generate CSV Files
 * 
 * Start: 7/9 11:00
 * Count: 11,376
 * 
 * 
 * 
 */
-- truncate table plxItemLocationBase

insert into plxItemLocationBase (RecordNumber,ItemNumber,NSItemNumber,BEItemNumber,BuildingCode,Location,QuantityOnHand,Suffix)
select * from dbo.btTemp  -- This is the only way to order the records before inserting them 
select * from dbo.plxItemLocationBase
--	select BEItemNumber,location,count(*) cnt
--	from
--	(

	--Add Quantity for each item location record selected.
	--select COUNT(*) cntParts from (
	select 
	MinRecordNumber as RecordNumber,
	ltrim(rtrim(Numbered)) ItemNumber, 
	NSItemNumber,
	BEItemNumber,
	BuildingCode,
	set2.Location,
	--QuantityOnHand,
	case 
		when (QuantityOnHand is null) then 0  
		when QuantityOnHand < 0 then 0
		else QuantityOnHand
	end QuantityOnHand,
	/*
	case 
		when QuantityOnHand is null then 'Null'
		when QuantityOnHand ='' then 'Blank'
		when QuantityOnHand < 0 then 'less than 0'
		when QuantityOnHand >= 0 then 'greater than or equal to zero'
		else 'Unknown'
	end WhatsInQty,
	*/
	case 
		when ltrim(rtrim(Numbered)) like '%[A-Z][A-Z]' then right(ltrim(rtrim(Numbered)),2) 
		when ltrim(rtrim(Numbered)) like '%[^A-Z][A-Z]' then right(ltrim(rtrim(Numbered)),1) 
		else 'N' --none
	end as Suffix --705627 has a plant 8 and albion number
	-- with the same location so suffix is figured after choosing a record number to
	--0715A-- represent BEItemNumber,Location pair. 
	--drop table btTemp
	--into btTemp
	from 
	(
		--Reduce the set by selecting 1 record number to represent BEItemNumber,Location duplicates.
		--select COUNT(*) cntParts from (
		select 
		min(RecordNumber) MinRecordNumber,
		NSItemNumber,
		'BE' + NSItemNumber as BEItemNumber,
		Location,
		BuildingCode
		from 
		(

			select 
			RecordNumber,
			case 
				when ItemNumber like '%[A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -2) 
				when ItemNumber like '%[^A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -1) 
				else ItemNumber
			end as NSItemNumber,
			BuildingCode,
			Location
			from 
			(
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
				--select count(*) cnt
				--sm.emSite,sm.plxSite
				from dbo.Parts p  --12475 08/02
				left outer join dbo.btSiteMap sm
				on p.Site=sm.emSite
				--where sm.emSite is null --0 08/02
				left outer join dbo.btSiteBuildingMap bm
				on sm.plxSite=bm.plxSite
				where 
				--sm.emSite is null or bm.plxSite is null --0 08/02
				(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') --08/02  11399
				--and Numbered like '%000219%'
				--)tst --11399 08/02
			)set1
			--where ItemNumber like '%000219%'

		/*
		 * If duplicate part numbers have distinct locations then
		 * they both will be in this set, but only the part number 
		 * with the lowest record number will be included if the
		 * duplicate part numbers have the same location.
		 * There were only 5 parts with duplicate locations.
		 * 
		 * ERROR: if you have same ItemNumber except for the suffix
		 * and both item numbers have the same location
		 * then both ItemNumbers will be mapped to the same
		 * BE number and there will be a duplicate BE number location pair
		 * I.e. 705627. So group on NSItemNumber instead of ItemNumber. 
		 */
		)set2	
		group by NSItemNumber,Location,BuildingCode
		--having NSItemNumber like '%000219%'
		--having NSItemNumber ='705627'
		--having count(*) > 1  --6 --08/02
		--)tst
		--group by NSItemNumber,Location,BuildingCode
		--having count(*) > 1  --0 --08/02
		/*
		 * select Numbered,Shelf,* from dbo.Parts
		 * where Numbered like '%208220%'
		 * The following items have duplicate numbered,location pairs.
		 * In addition 705627 and 705627A have identical locations.
		MinRecordNumber|NSItemNumber|BEItemNumber|Location     |BuildingCode           
		---------------|------------|------------|-------------|-----------------------
		           6368|208220      |BE208220    |M8-CAB H-2-4 |BPG Plant 8            
		           4798|404012      |BE404012    |M5-CHIPROOM  |BPG Plant 5            
		           4622|701063      |BE701063    |M5-20-07-03  |BPG Plant 5            
		           5383|201206      |BE201206    |M5-17-01-03  |BPG Plant 5            
		           1292|705627(A)   |BE705627    |MD-RACK B-3-3|BPG Distribution Center
		          10698|000529      |BE000529    |M5-27-04-05  |BPG Plant 5            
		 */
	)set2 
	inner join dbo.Parts p
	on set2.MinRecordNumber=p.RecordNumber
	--where QuantityOnHand < 0  --22 08/02
	--where QuantityOnHand is null  -- 3 08/02
	--where NSItemNumber like '%450599%'
	order by set2.location,set2.BEItemNumber
	--)tst --11392 --08/02
	--where QuantityOnHand < 0  or QuantityOnHand is null-- 0 --08/02  Null values make item location upload fail.



	
/*
beitemnumber|location     | |
------------|-------------|-|
BE705627    |MD-RACK B-3-3|2|

705627  |Distribution Center|RACK B-3-3
705627A |Distribution Center|RACK B-3-3
*/ 


/*
 * Test: 200 
 * Verify that the item number has no spaces
 */
select * 
from plxItemLocationBase
--where NSItemNumber like '%000219%'
where ItemNumber <> LTRIM(RTRIM(itemnumber)) --08/02

/*
 * Test: 210 
 * Verify that we have the correct number of records in plxItemLocationBase.
 * Wrap each section of query with select COUNT(*) cntParts from (
 * and verify record count makes sense
 * 
 */

select 
--top 100 *
count(*) 
from dbo.plxItemLocationBase --11392 --08/02

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
where sm.emSite is null --08/02

/*
 * Verify that every part record has an plex site.
 */
select 
count(*) 
--sm.*
--p.Site 
from dbo.Parts p  --12490 07/15A
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
where sm.emSite is null --0 --08/02

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
from dbo.btSiteBuildingMap --08/02

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
on sm.plxSite=bm.plxSite  --08/02

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
or bm.building_code='' or bm.building_code is null  --08/02

/*
 * Test: 240 
 * Verify there are no Kendallville part records in plxItemLocationBase.
 * 
 */

select 
count(*) cnt
--sm.emSite,sm.plxSite
--from dbo.Parts p  --12474
from dbo.plxItemLocationBase ilb
left outer join dbo.Parts p
on ilb.RecordNumber=p.RecordNumber
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
--where sm.emSite is null --0
--left outer join dbo.btSiteBuildingMap bm
--on ilb.BuildingCode=bm.building_code
where 
--(RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') --11392 08/02
(RIGHT(LTRIM(RTRIM(Numbered)),1) = 'K'  or sm.plxSite = 'MO')     --0 08/02

/*
 * Test: 250 
 * Kristen entered 'NO LOCATION' with all caps in the shelf field.
 * this is different than what I did when there was a blank shelf field 
 * and entered EM.site + 'no location yet' for the Plex location.
 *
 * Verify record count of shelves that contain 'NO LOCATION'
 * New test 07/15.  These locations are in EM with this 'NO LOCATION' as a shelf.
 * 
 * Verify that if shelf and site are blank plxItemLocationBase location field contains 'no location yet'. --00
 * Verify that if shelf is blank but site is not the plxItemLocationBase location field is in form of plxSite + 'no location yet' --01
 * Verify that if shelf is not blank and site is blank the plxItemLocationBase location field is in the form of 'No site' + shelf; --10
 * Verify that if there is both an site and shelf in EM part record the plxItemLocationBase field is in the form of plxSite + shelf --11
 * Verify that the correct count of each category above gets transferred to plex.
 * Verify that all plxItemLocationBase records fall into one of these categories.
 */

/*
 * Verify record count of shelves that contain 'NO LOCATION'
 * New test 07/15.  These locations are in EM with this 'NO LOCATION' as a shelf.
 */
select 
count(*) cnt  -- 0 records
--Numbered,site,Shelf,il.Location
from dbo.plxItemLocationbase ilb  --11384
where ilb.Location COLLATE Latin1_General_BIN like '%NO LOCATION%'  --110 08/02

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
(p.Site = '' or p.Site is null)  --0  08/02

/*
 * Verify that if shelf is blank but site is not the plxItemLocationBase location field is in form of plxSite + 'no location yet' --01
 */

select
count(*) cnt
--fp.numbered,ilb.RecordNumber,fp.recordnumber,fp.site,fp.shelf,sm.plxSite,ilb.Location
from
dbo.plxItemLocationBase ilb
inner join
(
	select 
	RecordNumber,numbered,shelf,site
	--count(*) cnt  --331 match this criteria
	--top 100 Numbered,site,Shelf
	from dbo.Parts p 
	where 
	(p.Shelf = '' or p.Shelf is null) 
	and 
	(p.Site <> '' and p.Site is not null)  
)fp
on ilb.RecordNumber=fp.recordnumber --312 08/02
left outer join dbo.btSiteMap sm
on fp.Site=sm.emSite 
where ilb.Location = sm.plxSite + '-no location yet' --312 --08/02


/*
 * Verify that if shelf is not blank and site is blank the plxItemLocationBase location field is in the form of 'No site' + shelf; --10
 * No records match this criteria
 */

select 
--RecordNumber,numbered,shelf,site
count(*) cnt  --331 match this criteria
--top 100 Numbered,site,Shelf
from dbo.Parts p  --12490  --07/15A
where 
(p.Shelf <> '' and p.Shelf is not null) 
and 
(p.Site = '' or p.Site is null)  --0  08/02

/*
 * Verify that if there is both a site and shelf in EM part record the plxItemLocationBase field is in the form of plxSite + shelf --11
 */

--update dbo.plxItemLocationBase 
--set Location=sm.plxSite + '-' + ltrim(RTRIM(fp.Shelf))

select
count(*) cnt
--top 5 fp.numbered,ilb.BEItemNumber,ilb.RecordNumber,fp.recordnumber,fp.site,fp.shelf,ilb.Location
from
dbo.plxItemLocationBase ilb --11392 08/02
inner join
(
select 
RecordNumber,numbered,shelf,site
from dbo.Parts p 
where 
(p.Shelf <> '' and p.Shelf is not null) --
and 
(p.Site <> '' and p.Site is not null)  
)fp  
on ilb.RecordNumber=fp.recordnumber --11080 08/02
left outer join dbo.btSiteMap sm
on fp.Site=sm.emSite
--where beitemnumber like '%200434%'
--where fp.Shelf like '%B-3-5%'
where 
--(ilb.Location = sm.plxSite + '-' + ltrim(RTRIM(fp.Shelf)))  --11080 08/02
not (ilb.Location = sm.plxSite + '-' + ltrim(RTRIM(fp.Shelf)))  --0 08/02


/*
 * Verify that all plxItemLocationBase records fall into one of these categories.
 * Both site and shelf: 		   11080  One item changed in EM 200434E
 * Shelf is blank but site is not:   312
 *      Total plxItemLocationBase: 11392
 * Totals Match: YES  --07/15C
 */

/*
 * Test: 255 
 * Verify that for dup numbered, location, building code records all but one record is removed. 
 * This test is done in the query itself above.
 *
 * The following items have duplicate numbered,location pairs.
 * In addition 705627 and 705627A have identical locations.
RecordNumber|ItemNumber|Location     |BuildingCode           
------------|----------|-------------|-----------------------
       10698|000529    |M5-27-04-05  |BPG Plant 5            
        5383|201206    |M5-17-01-03  |BPG Plant 5            
        6368|208220A   |M8-CAB H-2-4 |BPG Plant 8            
        4798|404012    |M5-CHIPROOM  |BPG Plant 5            
        4622|701063    |M5-20-07-03  |BPG Plant 5            
        1292|705627    |MD-RACK B-3-3|BPG Distribution Center         
 */


/*
 * Must be only one record for each of these item location dups.
 */
select 
--COUNT(*)
RecordNumber,  
ItemNumber,
Location,
BuildingCode
from dbo.plxItemLocationBase
where ItemNumber in
(
'404012', 
'208220A', 
'701063',--
'201206',
'000529',
'705627',
'705627A'  --This record is dropped because it has the same location as 705627 
)
order by ItemNumber  --08/02

/*
RecordNumber|ItemNumber|site                     |Shelf     
------------|----------|-------------------------|----------
       10698|000529    |Plant 5 Maint. Crib      |27-04-05  
       14223|000529    |Plant # 5                |27-04-05  
        5383|201206    |Plant 5 Maint. Crib      |17-01-03  
       12390|201206    |Plant 5 Maint. Crib      |17-01-03  
       14658|208220A   |Plant # 8                |CAB H-2-4 
        6368|208220A   |Plant 8 Maint Crib, Albio|CAB H-2-4 
        7907|404012    |Plant 5 Maint. Crib      |CHIPROOM  
        4798|404012    |Plant 5 Maint. Crib      |CHIPROOM  
        4803|404012    |Plant 5 Maint. Crib      |CHIPROOM  
       14194|701063    |Plant # 5                |20-07-03  
        4622|701063    |Plant 5 Maint. Crib      |20-07-03  
        1292|705627    |Distribution Center      |RACK B-3-3
        6728|705627A   |Distribution Center      |RACK B-3-3 
 */

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
'000529',
'705627',
'705627A'  --This record is dropped because it has the same location as 705627 
)
order by Numbered  --08/02


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
order by BEItemNumber  --08/02

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
 * Verify 5 part number with multiple locations 
 * get uploaded to plex including quantities.
 * 
 * Verify the correct number of parts with multiple locations
 * get uploaded correctly.
 * Verify the correct number of parts with single locations
 * get uploaded correctly.
 */

/*
 * Verify the correct number of parts with multiple locations
 * get uploaded correctly.
 * Verify the correct number of parts with single locations
 * get uploaded correctly.
 */
select count(*) cnt from (
select 
COUNT(*) cnt
--BEItemNumber
--RecordNumber,ItemNumber,BEItemNumber,location,QuantityOnHand
from dbo.plxItemLocationBase  
group by BEItemNumber --10376 08/02 

--HAVING count(*) > 1 --  838 08/02
--HAVING count(*) = 1  --9538 08/02
					 -- 10376 08/02
)tst  




/*
 * Verify parts with no location are not in the list of
 * parts with multiple locations
 */

select BEItemNumber
from dbo.plxItemLocationBase ilb
where BEItemNumber in
(
/*
 * Kristen should have this list of items with multiple locations
 * and one that has location = 'No location'
 */

	--select count(*) cnt from (
	--Multiple item locations and a record with 'No location'
	select 
	BEItemNumber
	--BEItemNumber,location
	from dbo.plxItemLocationBase ilb
	where BEItemNumber in
	(
		--Multiple item locations
		--select count(*) cnt from (
		select 
		--COUNT(*) cnt
		BEItemNumber
		--RecordNumber,ItemNumber,BEItemNumber,location,QuantityOnHand
		from dbo.plxItemLocationBase ilb 
		group by BEItemNumber --10376 08/02
		HAVING count(*) > 1   --  838 08/02
		--)tst
	)
	and ilb.location like '%no locat%' --38 08/02
	--Multiple item locations and a record with 'No location'
)
group by BEItemNumber, SUBSTRING(location,1,3) 
having count(*) >1 
--Are records in different sites.  If so it is ok.
order by BEItemNumber
--All but 3 are in different sites

/*
/*
 * Todo: Kristen should have this list of items with multiple locations
 * the same site and one that has location = 'No location' 
 */
 */
select 
--COUNT(*) cnt
--BEItemNumber
RecordNumber,ItemNumber,BEItemNumber,location,QuantityOnHand
from dbo.plxItemLocationBase ilb 
where BEItemNumber in
(
'BE120502',
'BE900322',
'BE980036'
)

/*
 * Verify 5 part number with multiple locations 
 * get uploaded to plex including quantities.
 */
--select count(*) cnt from (
	SELECT
	count(*) cnt
	--BEItemNumber
	from
	(
		select 
		--COUNT(*) cnt
		--BEItemNumber
		RecordNumber,ItemNumber,BEItemNumber,location,QuantityOnHand
		from dbo.plxItemLocationBase ilb 
		where SUBSTRING(ilb.location,1,3)  = 'M11'  --812 08/02
	)set1	
	group by BEItemNumber  --812 
	--HAVING count(*) > 1   --  0 08/02
)tst  


/*
 * Verify 5 part number with single locations 
 * get uploaded to plex including quantities.
 */

select 
--COUNT(*) cnt
top 5 
RecordNumber,ItemNumber,BEItemNumber,location,QuantityOnHand
from dbo.plxItemLocationBase ilb 
where SUBSTRING(ilb.location,1,3)  = 'M11'  --812 08/02
order by BEItemNumber



/*
RecordNumber|ItemNumber|BEItemNumber|location           |QuantityOnHand|
------------|----------|------------|-------------------|--------------|
         503|000029AV  |BE000029    |M11-NO LOCATION YET|       8.00000|
       13424|000054AV  |BE000054    |M11-B-02-03        |       7.00000|
        1385|000119AV  |BE000119    |M11-NO LOCATION YET|       1.00000|
       12540|000139AV  |BE000139    |M11-CAB B-04-04    |      14.00000|
       12539|000140AV  |BE000140    |M11-D-11-04        |       5.00000|
where item_no in
(
'BE000029',
'BE000054',
'BE000119',
'BE000139',
'BE000140'
)
       
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

--drop table plxLocation

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
	select 
	DISTINCT 	Location,BuildingCode 
	--select DISTINCT Location --Should be the same set as distinct location, buildingcode 
	from plxItemLocationBase ilb
	where SUBSTRING(ilb.location,1,3)  = 'M11'  --382 08/02
	--order by location
	--)tst --382  08/02 
)set1 
)tst --382  08/12  
--order by location 

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
 * Verify count of locations with location_type of 'Maintenance' 
 * and location_group of 'Maintenance Crib'
 * 
 * Verify 5 locations were created in correct format
 * use the plex supply item screen to verify location

 * Verify count of location with each building code.
 * and quantity is as expected.
 */

/*
 * Verify count of all locations
 */
select 
count(*) cnt
--top 100 row#,Location,building_code,location_type,note,location_group
from dbo.plxLocation l
--382 08/15 

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
and location_group = 'Maintenance Crib'  --382 08/02 

/*
 * Verify 5 locations were created in correct format
 * use the plex supply item screen to verify location
 * and quantity is as expected.
 * 
 */
select 
--count(*) cnt
top 100  
bil.BEItemNumber,bil.Location,
p.site,p.shelf
from dbo.plxItemLocationBase bil
inner join dbo.Parts p
on bil.RecordNumber=p.RecordNumber

where bil.Location in
(
'M11-A-02-03',
'M11-A-02-04',
'M11-A-02-05',
'M11-A-03-02',
'M11-A-03-02'
)  --08/02

select 
--count(*) cnt
--top 100  
Location,building_code,location_type,note,location_group
from dbo.plxLocation
--3325
where Location in
(
'M11-A-02-03',
'M11-A-02-04',
'M11-A-02-05',
'M11-A-03-02',
'M11-A-03-02'
)  --08/02




/*
 * Verify count of location with each building code.
 * Verify no records have a building code other than the 
 * expected ones.
 */
select 
count(*) cnt
--distinct building_code
--top 100  
--Location,building_code,location_type,note,location_group
from dbo.plxLocation
--where building_code = 'BPG Central Stores' --1
--where building_code = 'BPG Distribution Center' --212
--where building_code = 'BPG Edon'  --328
--where building_code = 'BPG Plant 11'  --382
--where building_code = 'BPG Plant 5'  --1741
--where building_code = 'BPG Plant 8'  --518
--where building_code = 'BPG Pole Barn'  --225
--where building_code = 'BPG Workholding'  --2
--07/15C 

where building_code <> 'BPG Central Stores' 
and building_code <> 'BPG Distribution Center' 
and building_code <> 'BPG Edon'  
and building_code <> 'BPG Plant 11'  
and building_code <> 'BPG Plant 5'  
and building_code <> 'BPG Plant 8'  
and building_code <> 'BPG Pole Barn'
and building_code <> 'BPG Workholding' 
--0 07/15C 
order by building_code
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
)tst  --11384
--07/15C
 * 
 * 
 */



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
			--test purposes does the case statement below work correctly?
			--Pass 07/15A
			--NSItemNumberPriority, 
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
					/*
					 * Todo: instead of basing the priority by suffix base it on priority field.
					 * The priority field is deterimined by a case statement which gives a 
					 * higher value to part records with more information such as vendor
					 * or manufacturer.
					 */
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
					plxItemLocationBase il  --11384	 07/15C					
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
				--)tst  --10371 07/15C
				/* Are there any duplicates left?  If there were multiple
				 * Albion records for a part number is there only one now?
				 * Since these items would have the same NSItemNumberPriority
				 * which one is chosen in the min(NSItemNumberPriority) function? 
				 * THIS PRIORITY METHOD GIVES US SOME CONTROL OF PICKING WHICH
				 * PART RECORD WE WILL CHOOSE BUT IF THERE ARE MULTIPLE RECORDS
				 * FOR THE ALBION PART NUMBER WE DON'T CONTROLL WHICH ONE THE
				 * QUERY SELECTS WITH MIN(NSItemNumberPriority).
				 */
				--group by NSItemNumber,BEItemNumber
				--having count(*) > 1 --0 07/12C
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
			--where right(NSItemNumberPriority,1) = '4'
			*/
		)set3 --
		--)tst1 --10371 check for multiple copies of same nsitemnumber
		--Pass No dups 07/15C
	)set4 --
	inner join 
	(
		/*
		 * There are many parts with multiple locations and
		 * there are some part/locations with duplicates and there
		 * are even some parts with different suffixes but the same
		 * location. 
		 * Since, we need to pick exactly one record for each part to 
		 * retrieve non-location type information such as description, 
		 * category,unit, etc. We will choose the part record  
		 * which has the lowest record number. There are also some numbers 
		 * with spaces so use trim functions when picking this record.
		 */
		select min(RecordNumber)minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber  
		from dbo.Parts
		group by ltrim(rtrim(Numbered))  
	)p
	on set4.ItemNumber=p.ItemNumber
	--)tst --10371  07/15C
	/*
	where 
	set4.nsitemnumber like '000003%'
	or set4.nsitemnumber like '000054%'
	or set4.nsitemnumber like '000091%'
	or set4.nsitemnumber like '000547%'
	or set4.nsitemnumber like '200382%'
	order by set4.nsitemnumber
	Pass: 07/15C
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
)--tst 


select count(*)cnt
--from dbo.plxSupplyItemBase0715A --10370
--from plxsupplyitem  --10371
from dbo.plxSupplyItemBase --10371
/*
 * 
 *   Validate SupplyItemBase
 *   Some of these tests are duplicated in the
 *   Validate for SupplyItem section
 * 
 */

/*
 * Test: 5B 
 *  
 * Verify the count of plxSupplyItemBase records
 * Are there any duplicate records?
 * 
 */  


select COUNT(*)
from
(
	select 
	--*
	--COUNT(*)
	nsitemnumber 
	from dbo.plxSupplyItemBase
	--10371 records before grouping clause.
	group by nsitemnumber
)tst --10371 records after grouping clause.
--Pass 07/15C

/*
 * Test: 10B 
 *  
 * Verify that there are no spaces in the item number field.
 * 
 */  
select BEItemNumber from plxSupplyItemBase 
WHERE LTRIM(RTRIM(BEItemNumber)) like '%' + ' ' + '%'  --are there any spaces
--Pass 07/15C




-- plxSupplyItem:


select
row_number() OVER(ORDER BY set1.item_no ASC) AS Row#,
set1.item_no,
Brief_Description,
case
	when bn.item_no is not NULL then Description + char(13) + bn.Note1to450  --append big notes to varchar(800) description field
	else Description
end as Description,
SUBSTRING(Note,1,200) Note,  -- 26 Notes are to big to fit in this field
Item_Type,Item_Group,Item_Category,
Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,
Location,
Supplier_Code,
Supplier_Part_No,Supplier_Std_Purch_Qty,
Currency,
Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
Cube_Unit			
--drop table plxSupplyItem
--into plxSupplyItem
from
(
	--select count(*) cnt from (
	select 
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
	-- There are 31 records in which the NotesText field is > 200 characters.  
	SUBSTRING(REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(13)),1,200) as Note, --
	--SUBSTRING(Note,1,200) Note,  --Asking Kristen if this is ok it will truncate around 30 EM parts records notes field. 
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
	/* This field seems to be the manufacturer_code 
	 * If not configured to use Suppliers as Supply Item manufacturers, then this field,manufacturer_text varchar(25), contains the name of the Manufacturer.
	 * All the Manufacturer fields are greater than varchar(25) so don't know why it says Manufacturer instead of Manufacturer_Code?
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
	--sc.Supplier_Code,
	case 
		when Supplier_Code = 'UNKNOWN' or Supplier_Code is null then ''
		else Supplier_Code
	end Supplier_Code,  
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
	select si.*	
	from dbo.plxSupplyItemBase si
	--)tst --10371 07/12C
	inner join dbo.Parts p
	on si.RecordNumber=p.RecordNumber
	--)tst --10371 07/12C
	left outer join (  
	--If the EM parts record that was chosen does not have a vendor sc.Supplier_Code will be null
	--Todo instead of picking a parts record by min record number choose the one with a vendor.
	--It the EM parts record that was chosen has a vendor but it is not in Plex the sc.Supplier_Code 
	--will be 'UNKNOWN'
	--select count(*) cnt from dbo.Parts where vendor = '' or Vendor is null --520 07/15A
		select * from btSupplyCode sc  
		--where Supplier_Code ='UNKNOWN'  -- 22 07/15C EM Vendors with no Supplier Code in Plex
		where VendorName <> ''            --319 07/12C The Supplier is not in EM 
	) sc
	on p.Vendor=sc.VendorName 
	--select count(*) cnt from dbo.Parts where vendor = '' --517 07/12A
	left outer join btMfgMap mm  --Every valid EM manufacturer is in plex but there are many EM parts without manufactuers
	on p.Manufacturer=mm.plexMfg 
	--select * from	btMfgMap mm order by emMfg  --Only contains valid manufacturers no nulls or '' records
	--select count(*) cnt from dbo.Parts where manufacturer = '' or manufacturer is null --7104 07/15C
	--)tst  --10371 07/15C	select * from btSupplyCode sc  
)set1
left outer join dbo.plxBigNote bn
on set1.Item_No=bn.item_no
--10371 07/15A

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
--top 100 *
from plxSupplyItem 
--10371 07/15C

/*
 * Test: 15 
 * 
 * Verify that the description field is being formatted correctly
 * for EM part records with a notes_text field <= 200 characters. 
 *  
 * Testing has shown that there are no EM parts records with a valid
 * Note_text field > 450 characters.  See issue: 1.
 * 
 * Verify EM parts with notes_text fields > 200 characters have been
 * appended to the plxSupplyItems Description field.
 * 
 * Verify the plxSupplyItems Note field has been truncated to 200 characters.
 * 
 * Verify EM parts with notes_text fields > 200 look ok in Plex supply item
 * detail screen
 * 
 * Verify there are no nulls in manufactuer,manufactuernumber,vendor
 * 
 */  

/*
 * Verify that the description field is being formatted correctly
 * for EM part records with a notes_text field <= 200 characters. 
 */
select
si.item_no,si.Description,p.Description,
p.VendorNumber,
p.Manufacturer,
p.ManufacturerNumber
from plxSupplyItem si 
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber
where si.item_no in
(
'BE800300','BE999997','BE139987','BE000668','BE600005','BE999000','BE200703','BE650002' 
)
order by item_no
--pass 07/15B
--------------VendorNumber,Manufacturer,ManufactuerNumber 
--000 800300 
--001 999997  |            |            |02120             | 
--010 139987  |            |MORI SEIKI  |                  | 
--011 000668  |            |SIEMENS     |1FT6044-4AF71-4AA6| 
--100 600005  |6408M-22MM  |            |                  | 
--101 999000  |945         |            |945               | 
--110 200703  |800EPMJ3    |Allen Bradley|                  | 
--111 650002AV|54041462    |Kendall Electric|SUPER33+          | 


/*
 * Verify EM parts with notes_text fields > 200 characters have been
 * appended to the plxSupplyItems Description field.  See 
 * issue 1 for details.
 * 
 * Verify the plxSupplyItems Note field has been truncated to 200 characters.
 * 
 * Verify EM parts with notes_text fields > 200 look ok in Plex supply item
 * detail screen
 */
select count(*) cnt from (
	select item_no,
	case
		when note=substring(Note,1,200) then 'Pass'
		else 'Fail'
	end PassFail,
	Note,
	description
	from dbo.plxSupplyItem si
	where item_no in
	(
	select
	--top 5 item_no
	item_no
	--item_no,Note1to450
	from
	dbo.plxBigNote bn
	)
)tst --26 
--26 pass 07/15C
--top 5 item_no with big notes
where item_no
(
'BE000195'
'BE000665'
'BE000743'
'BE100025'
'BE100100'
)



/*
 * Test: 20 
 * field: Note
 * 
 * Issue: 1
 * How many EM part notes field will be truncated? 31
 * Combine notes field with description field for parts with notes field over 200 characters.
 * 
 * Verify Note field has been trucated to 200 characters for EM parts records 
 * with Notestext field > 200 characters and looks ok on the supply item detail screen.
 * 
 * Verify that items with a newline in the notes field display correctly on the Supply Item detail screen. 
 * 
 * 
*/

/*
 * Verify that items with a newline in the notes field display correctly on the Supply Item detail screen. 
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
--pass 07/15C
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
si.item_no,
si.item_group,
p.CategoryID
from plxSupplyItem si 
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber
where 
--item_group is null or item_group = ''
-- and item_group like '%cover%   
si.item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
order by si.item_no
--pass 07/15B
/*
item_no |item_group     |CategoryID     
--------|---------------|---------------
BE100011|B Axis         |B Axis         
BE100012|B Axis         |B Axis         
BE100988|OEM Okuma parts|OEM Okuma parts
BE200800|Switch, General|Switch, General
BE708991|Pumps          |Pumps            
*/

/*
Test: 33 
Verify that all parts have a item_category of ‘general’. 
*/
select
count(*)
--top 1 numbered,categoryid
from dbo.plxSupplyItem si
where Item_Category <> 'General'
--pass 07/15C

/*
Test: 40 
Verify that Customer_Unit_Price is being populated correctly. 
*/

select  
--count(*) 
top 10 
si.item_no,
si.Customer_Unit_Price,
p.BillingPrice,p.CurrentCost
from plxSupplyItem si
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber
--where billingprice is null and currentcost is null --00
--where billingprice is null and currentcost <> 0 --01
--where billingprice <> 0 and currentcost is null --10
--where billingprice <> 0 and currentcost <> 0 --11
where si.item_no
in
(
'BE000007','BE000002','BE000030','BE000001'
)
--pass 07/15C
/*
item_no |Customer_Unit_Price|BillingPrice|CurrentCost
--------|-------------------|------------|-----------
BE000007|                   |            |             --00
BE000002|          713.00000|            |  713.00000  --01
BE000030|          652.35000|   652.35000|             --10
BE000001|           20.04300|    20.04300|   22.27000  --11


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
--where LTRIM(RTRIM(Units)) is null or LTRIM(RTRIM(Units)) = '' --Ea 665
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
--where LTRIM(RTRIM(Units)) = 'Set'

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
count(*) 
--si.item_no,si.inventory_unit,p.Units
from plxSupplyItem si
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber
--where inventory_unit = '' or inventory_unit is null  --0
where inventory_unit = 'Box' --6
--where p.Units = 'Box' --6
--where inventory_unit = 'case' --2
--where p.Units = 'Case' --2
--where inventory_unit = 'dozen'  --5
--where p.Units = 'Dozen' --5
--where inventory_unit = 'Ea' --9930
--where p.Units = '' or p.Units is null --
--or p.Units = 'Electrical' --
--or p.Units = 'Each' --
--9930
--p.Units '','Electrical','Each': 9930
--where inventory_unit = 'Feet' --256
--where p.Units = 'Feet' --256
--where inventory_unit = 'Gallons' --9
--where p.Units = 'Gallons' --9
--where inventory_unit = 'inches' --2
--where p.Units = 'Inches' --2
--where inventory_unit = 'meters'  --5
--where p.Units = 'Meters' --5
--where inventory_unit = 'hundred'  --7
--where p.Units = 'Per 100' --7
--where inventory_unit = 'Package'  --11
--where p.Units = 'Per Package' or p.Units = 'Package'  --11
--where inventory_unit = 'lbs'  --2
--where p.Units = 'Pounds'  --2
--where inventory_unit = 'quart'  --1
--where p.Units = 'Quart'  --1
--where inventory_unit = 'Roll'  --10
--where p.Units = 'Roll'  --10
--where inventory_unit = 'set'  --125
--where p.Units = 'Set'  --125
-- Pass 07/15A

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
'BE800300',--quart / Quart
'BE850014', --inches /Inches
'BE990003',--lbs / Pounds
'BE999000',--Ea / Each
'BE999002'--Gallons / Gallons
)
order by item_no
--Pass 07/15A
/*
where inventory_unit = 'Box' --6
or inventory_unit = 'case' --2
or inventory_unit = 'dozen'  --5
or inventory_unit = 'Ea' --9929
or inventory_unit = 'Feet' --256
or inventory_unit = 'Gallons' --9
or inventory_unit = 'inches' --2
or inventory_unit = 'meters'  --5
or inventory_unit = 'hundred'  --7
or inventory_unit = 'Package'  --11
or inventory_unit = 'lbs'  --2
or inventory_unit = 'quart'  --1
or inventory_unit = 'Roll'  --10
or inventory_unit = 'set'  --125
--10371 Pass 07/15A
*/


/*
Test: 55 
Verify that Min_Quantity is not null 
Verify that Min_Quantity contains EM.MinimumOnHand. 
*/

select numbered,MinimumOnHand
from dbo.Parts
--where MinimumOnHand is null  -- 0  07/12A
where ltrim(rtrim(numbered))
in
(
'100988','708991','200800','100012','100011'
)
order by numbered

select  
--count(*) 
p.numbered,
si.Item_No,
si.Min_Quantity,--numeric(18,5)
p.MinimumOnHand --numeric(18,5)
from plxSupplyItem si
--where Min_Quantity is null --07/12A
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber
--where si.Min_Quantity is null --0 --07/15B
--where si.Min_Quantity<> p.MinimumOnHand  --1 --07/15B I think this changed in EM
where si.Item_No
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
--Pass 07/15B
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
Verify that when Max_Quantity is null Max_Quantity gets uploaded to plex correctly
Verify that when EM.minimumOnHand > EM.maxOnHand then plex Max_Quantity gets set to 0
Verify that in other cases that Max_Quantity gets set to EM.MaxOnHand
CASE
	when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then 0
	else MaxOnHand
end as Max_Quantity,

numbered|RecordNumber|MinimumOnHand|MaxOnHand
--------|------------|-------------|---------
100988  |        9901|      0.00000|  1.00000  
200277  |       15430|      2.00000|  8.00000|
200277E |        2162|     10.00000|  8.00000|
705286A |        6223|     10.00000|  1.00000
705334A |        6274|      2.00000|  1.00000  
800300  |        4852|      0.00000|  Null    

*/

select Numbered,RecordNumber,MinimumOnHand,MaxOnHand
from dbo.Parts
where (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) 
order by numbered

select numbered,RecordNumber,MinimumOnHand,MaxOnHand
from dbo.Parts
where 
numbered like '%100988%'
or numbered like '%200277%'
or numbered like '%705334%'
or numbered like '%705286%'
or numbered like '%800300%'
order by numbered,RecordNumber

select  
--count(*) 
--top 10 
item_no,p.MinimumOnHand,Min_Quantity,p.MaxOnHand,Max_Quantity
from plxSupplyItem si
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber
--where Max_Quantity is null --1255 -- 07/15A
--where si.item_no = 'BE800300'  -- Max_Quantity is null --07/15A
where si.Item_No 
in
(
'BE100988','BE200277','BE705334','BE705286','BE800300'
)
order by item_no
--Pass 07/15A
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
--item_no,
--tax_code
from plxSupplyItem  
--where tax_code = 'Tax Exempt - Labor / Industrial Processing' --10371
where tax_code <> 'Tax Exempt - Labor / Industrial Processing' --0
--Pass 07/15B

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
--where account_no = '70200-320-0000' --10371
where Account_No <> '70200-320-0000' --0
--Pass 07/15B

/*
Test: 75 

Pretty sure this is the manufacturer_code in common_v_manufacturer field.

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
2. Verify the count of plxSupplyItem records without a manufacturer is equal to the count 
 of supply items without a manufacture in plex 

3. Verify that 5 supply items with manufactures got uploaded correctly using the ‘supply items detail screen’ 
4. Verify that 5 supply items without a manufacture got uploaded correctly using the ‘supply items detail screen’ 

**/


/*
 * 1. Verify the count of supply items with mapped manufacturers in plxSupplyItems is equal 
 * to the count of supply items with manufacturers in plex.
 * 2. Verify the count of plxSupplyItem records without a manufacturer is equal to the count 
 * of supply items without a manufacture in plex 
 */
select 
count(*)
from
(
	select
	--count(*) cnt
	--sb.*
	--top 100
	sb.BEItemNumber, p.Manufacturer EM,si.Manufacturer Plex
	--distinct p.Manufacturer --
	--distinct si.Manufacturer --169 
	from dbo.plxSupplyItemBase sb  --10371
	inner join dbo.plxSupplyItem si
	on sb.BEItemNumber=si.Item_No  --10371
	inner join dbo.Parts p
	on sb.RecordNumber=p.RecordNumber --10371
	left outer join btMfgMap mm
	on p.Manufacturer=mm.emMfg 
	where si.Manufacturer <> '' and si.Manufacturer is not null --2184 07/15C
	--where mm.emMfg is not null  --2184 07/15B
	--where si.Manufacturer = '' or si.Manufacturer is null         --8187 --Pass 07/15C
	-- There are 4 manufacturers uploaded to plex count is 173     07/15B
	-- that have no supply item's manufacturer assigned
)tst

select 
count(*)
from btMfgMap mm --173 --Pass 07/15A

/*
 * 3. Verify that 5 supply items with manufactures got uploaded correctly using the ‘supply items detail screen’
 * 4. Verify that 5 supply items without a manufacture got uploaded correctly using the ‘supply items detail screen’ 
 * 
 */

select
--count(*) cnt
--sb.*
--top 100
sb.BEItemNumber, p.Manufacturer EM,si.Manufacturer Plex
--distinct p.Manufacturer --168 distinct
from dbo.plxSupplyItemBase sb  --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
left outer join btMfgMap mm
on p.Manufacturer=mm.emMfg 
/*
where si.Item_No in
(
'BE200800', --Omron
'BE100012', --Okuma America Corporation
'BE700801', --Barksdale
'BE706202', --MITSUBISHI ELECTRIC
'BE701996'  --BOSCH-REXROTH
) --Pass 07/15A
*/
--No manufacturers
where si.Item_No in
(
'BE000001',
'BE000002',
'BE000003',
'BE000005',
'BE000007'
)
--Pass 07/15

/*
 * Number of manufacturers in EM that are not in btMfgMap
 */
select 
count(*) cnt
from
(
	select
	--top 100
	distinct p.Manufacturer
	--p.Manufacturer EM,si.Manufacturer Plex
	from dbo.plxSupplyItemBase sb
	inner join dbo.plxSupplyItem si
	on sb.BEItemNumber=si.Item_No
	inner join dbo.Parts p
	on sb.RecordNumber=p.RecordNumber
	left outer join btMfgMap mm
	on p.Manufacturer=mm.emMfg 
	where 
	(p.Manufacturer is not null and p.Manufacturer <> '')
	and mm.emMfg is null
)tst
--214  --Pass 07/15B

/*
 * Why aren't some of these manufacturer in plex
 * Is it a case problem? No
 * Did Kristen not want them in because they were not manufacturers? Yes
 * 
 */


/*
 * There are select 283 manufacturers in Plex
 * There are 398 distinct manufacturer in EM
 * and 173 in the btMfgMap
 *      Total EM manufacturers: 398
 * 
 * plxSupplyItem Manufacturer Totals:
 * EM Manufacturers not mapped: 214
 *        Mapped Manufacturers: 173
 *                              387
 */


select 
count(*) cnt
from btmfgmap --173 07/15B

select 
count(*)
from
(
select
--top 100
DISTINCT p.Manufacturer
--p.Numbered,p.Manufacturer,mm.emMfg
from dbo.Parts p --398 --Pass 07/15B
)tst
--order by Manufacturer

select mm.* 
from 
dbo.btMfgMap mm

/*
 * Are there any of EM manufacturers that are not in plex
 * that should be there? Probably but Kristen has chosen
 * the manufacturers that she wants in Plex.  Also I 
 * asked that she be given rights to add/update/delete manufacturers
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
	--order by count(*) desc
)tst
--51 --Pass 07/15B

/*
 *
 * Test: 80 
 * Verify the count of Manf_Item_no that are valid and are blank
 * Verify that 5 Manf_Item_No were uploaded correctly. 
 * 
 * 
 *  
 */
select count(*)cnt from (
select
--count(*) cnt
--sb.*
--top 100
si.Item_No,si.Manufacturer,si.Manf_Item_No,p.ManufacturerNumber
--si.Item_No,si.Manufacturer,si.Manf_Item_No,p.ManufacturerNumber
--sb.BEItemNumber, p.Manufacturer EM,si.Manufacturer Plex
--distinct p.Manufacturer --168 distinct
from dbo.plxSupplyItemBase sb  --10371 
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371 
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371 
left outer join btMfgMap mm
on p.Manufacturer=mm.emMfg 
--where si.Manf_Item_No = '' or si.Manf_Item_No is null     --4172 --Pass 07/15B
--where si.Manf_Item_No <> '' and si.Manf_Item_No is not null --6199 --Pass 07/15B
--)tst --4172
where si.Item_No in
(
'BE200800', --Omron
'BE100012', --Okuma America Corporation
'BE700801', --Barksdale
'BE706202', --MITSUBISHI ELECTRIC
'BE701996'  --BOSCH-REXROTH
)
--07/15A
/*
Item_No |Manufacturer             |Manf_Item_No |ManufacturerNumber
--------|-------------------------|-------------|------------------
BE700801|Barksdale                |E1H-H90      |E1H-H90           
BE706202|MITSUBISHI ELECTRIC      |B40055-1     |B40055-1          
BE100012|Okuma America Corporation|H0031-0021-16|H0031-0021-16     
BE200800|Omron                    |D4C-1602     |D4C-1602          
BE701996|BOSCH-REXROTH            |3842519117   |3842519117        
 */

/*
 *
 * Test: 85 
 * Verify that all but 15 supply items that have a vendor 
 * also have a supplier code. 
 * 
 * 1. Verify that all but 15 supply items that have a vendor 
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
COUNT(*) cnt
--top 100
--item_no,sc.Supplier_Code,p.Vendor
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
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
--07/15A
/*
 * 
 * 5. Verify that 5 supply items with a supplier uploaded correctly
 * 
 */
select 
COUNT(*) cnt
--top 100
--item_no,sc.Supplier_Code,p.Vendor
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
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
 * Verify that all but 15 supply items that have a vendor 
 * also have a supplier code. 
 */
select 
COUNT(*) cnt
--top 100
--item_no,p.QuantityOnHand, p.vendor,sc.Supplier_Code
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName 
where 
p.Vendor <> '' and p.Vendor is not null
and (sc.Supplier_Code is null or sc.Supplier_Code ='' )
--15 --Pass 07/15A

select 
count(*) cnt
from dbo.Parts p
where p.Vendor is null or p.Vendor = ''
/*
 * Verify the count of em.parts with no vendors 
 * Verify the count of supply items with no supplier_code  
 * Verify the count of supply items with a supplier_code
 * 
 */

select 
count(*) cnt
from dbo.Parts p
where p.Vendor is null or p.Vendor = '' --520 --Pass 07/15A

select 
--distinct si.Supplier_Code
COUNT(*) cnt
--top 100
--item_no,p.QuantityOnHand, p.vendor,sc.Supplier_Code
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName 
where 
--si.Supplier_Code <> ''  --9861  --Pass 07/15A
--si.Supplier_Code = '' and sc.Supplier_Code <> 'UNKNOWN' --0 --Pass 07/15A
--si.Supplier_Code = ''  --510 --Pass 07/15A
--si.Supplier_Code is null  --0 --Pass 07/15A


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
from dbo.plxSupplyItemBase sb --10371 07/15C
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371 07/15C
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371 07/15C
where 
--si.Supplier_Code=''  --510  if there is no supplier there can be no supplier part number in plex
si.Supplier_Code='' or (si.Supplier_Part_No = '' or si.Supplier_Part_No is null) --1029
--si.Supplier_Code<>'' and (si.Supplier_Part_No = '' or si.Supplier_Part_No is null)      --519 --Pass 07/15A
--si.Supplier_Code<>'' and si.Supplier_Part_No <> '' and si.Supplier_Part_No is not null --9342 --Pass 07/15A
order by si.item_no
/*
 * Verify that 5 supply item with a supplier_part_no were uploaded correctly 
 */
select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,si.Supplier_Part_No, p.VendorNumber
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where 
item_no in (
--item_no |Supplier_Part_No  |VendorNumber  
----------|------------------|--------------
'BE000001',--|E5552-192-010     |E5552-192-010 
'BE000002',--|505-1000-88-03    |505-1000-88-03
'BE000003',--|505-1000-89-04    |505-1000-89-04
'BE000005',--|H0002-0015-55     |H0002-0015-55 
'BE000007'--|H1023-0037-35     |H1023-0037-35 
)
--07/15A
/*
 * Verify that 5 supply item without a supplier_part_no were uploaded correctly 
 */
select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,si.Supplier_Part_No, p.VendorNumber
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where 
item_no in (
'BE800300',
'BE702391',
'BE999997',
'BE700001',
'BE000033'
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

select 
--distinct si.Supplier_Code
COUNT(*) cnt
--top 100
--item_no,si.Supplier_Part_No, p.VendorNumber
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where
si.Currency <> 'USD'
or si.Supplier_Std_Purch_Qty <> 0
or si.Supplier_Unit_Conversion <> 1
--Pass 07/15A

/*
 *
 * Test: 100 
 * Supplier_Std_Unit_Price
 * Verify that if there is a billing or current price and no supplier code an error does not occur
 * Verify count of parts with a billing price are uploaded.
 * Verify 5 parts with a billing price that this price is uploaded.
 * Verify count of parts which have no billing price but have a current cost is uploaded.
 * Verify 5 parts which have no billing price that the current cost is uploaded.
 * Verify count of parts which have no billing price and no current cost is uploaded.
 * Verify that if there is no billing price or current cost no error occurs.
 *
 */

/*
 * Verify that if there is a billing or current price and no supplier code an error does not occur.
 * 
 */

select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
si.item_no,si.Supplier_Code,p.BillingPrice,p.CurrentCost
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where 
item_no in 
(
'BE850355'
)
--07/15A

select 
--distinct si.Supplier_Code
COUNT(*) cnt
--top 100
--item_no,si.Supplier_Code,p.BillingPrice,p.CurrentCost
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where 
--p.BillingPrice is null or BillingPrice <= 0
--and p.Vendor <> '' and p.Vendor is not null
p.BillingPrice is NOT null AND BillingPrice > 0 
and p.Vendor = '' or p.Vendor is null

/*
 * Verify count of parts which have no billing price and no current cost is uploaded. --00
 * Verify count of parts which have no billing price but have a current cost is uploaded. --01
 * Verify count of parts which have a billing price but have no current cost is uploaded. --10
 * Verify count of parts which have a billing price and a current cost is uploaded. --11
 */

select 
--distinct si.Supplier_Code
COUNT(*) cnt
--top 100
--item_no,si.Supplier_Code,p.BillingPrice,p.CurrentCost
from dbo.plxSupplyItemBase sb --10371
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  --10371
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where 
--(p.BillingPrice is null or BillingPrice <= 0) and (p.CurrentCost is null or p.CurrentCost <= 0) --00 --3828 --Pass 07/15A
--(p.BillingPrice is null or BillingPrice <= 0) and (p.CurrentCost is not null and p.CurrentCost > 0) --01 --4955 --Pass 07/15A
--(p.BillingPrice is not null or BillingPrice > 0) and (p.CurrentCost is null or p.CurrentCost <= 0) --10 --42 --Pass 07/15A
--(p.BillingPrice is not null or BillingPrice > 0) and (p.CurrentCost is not null and p.CurrentCost > 0) --11 --1546 --Pass 07/15A
(p.BillingPrice is null or BillingPrice <= 0) and (p.CurrentCost is null or p.CurrentCost <= 0) --00 
or (p.BillingPrice is null or BillingPrice <= 0) and (p.CurrentCost is not null and p.CurrentCost > 0) --01 
or (p.BillingPrice is not null or BillingPrice > 0) and (p.CurrentCost is null or p.CurrentCost <= 0) --10 
or (p.BillingPrice is not null or BillingPrice > 0) and (p.CurrentCost is not null and p.CurrentCost > 0) --11 
--10371 --Pass 07/15A

/*
 * Verify 5 parts with a billing price that this price is uploaded correctly. 
 */

select 
--distinct si.Supplier_Code
--COUNT(*) cnt
--top 100
item_no,si.Supplier_Code,p.BillingPrice,p.CurrentCost,si.Customer_Unit_Price,si.Supplier_Std_Unit_Price
from dbo.plxSupplyItemBase sb 
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
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
COUNT(*) cnt
--top 100
--item_no,si.Supplier_Code,p.BillingPrice,p.CurrentCost,si.Supplier_Std_Unit_Price,si.Customer_Unit_Price
from dbo.plxSupplyItemBase sb 
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
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
item_no,si.Supplier_Code,p.BillingPrice,p.CurrentCost,si.Supplier_Std_Unit_Price,si.Customer_Unit_Price
from dbo.plxSupplyItemBase sb 
inner join dbo.plxSupplyItem si
on sb.BEItemNumber=si.Item_No  
inner join dbo.Parts p
on sb.RecordNumber=p.RecordNumber --10371
where
--(p.BillingPrice is null or BillingPrice <= 0)
--and
--(p.CurrentCost is null or p.CurrentCost <=0)
item_no in (
'BE000007',   
'BE000008',
'BE000025',
'BE000079',
'BE000090'
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
si.item_no,si.Supplier_Purchase_Unit,p.Units,si.Inventory_Unit
from plxSupplyItem si
inner join dbo.plxSupplyItemBase sib
on si.Item_No=sib.BEItemNumber
inner join dbo.Parts p
on sib.RecordNumber=p.RecordNumber  --10371
--where Supplier_Purchase_Unit = '' or Supplier_Purchase_Unit is null --0
--where Supplier_Purchase_Unit = 'Box' and Supplier_Code <> ''--5
--where p.Units = 'Box' 
--where Supplier_Purchase_Unit = 'case' and Supplier_Code <> ''  --2
--where p.Units = 'Case' --2
--where Supplier_Purchase_Unit = 'dozen'  and Supplier_Code <> ''--5
--where p.Units = 'Dozen' --5
--where Supplier_Purchase_Unit = 'Ea' and Supplier_Code <> '' --9431
--where p.Units = '' or p.Units is null --
--or p.Units = 'Electrical' --
--or p.Units = 'Each' --
--p.Units '','Electrical','Each': 9930
--where Supplier_Purchase_Unit = 'Feet' and Supplier_Code <> ''--251
--where p.Units = 'Feet' --256
--where Supplier_Purchase_Unit = 'Gallons' and Supplier_Code <> ''--9
--where p.Units = 'Gallons' --9
--where Supplier_Purchase_Unit = 'inches' and Supplier_Code <> ''--2
--where p.Units = 'Inches' --2
--where Supplier_Purchase_Unit = 'meters'  and Supplier_Code <> ''--5
--where p.Units = 'Meters' --5
--where Supplier_Purchase_Unit = 'hundred' and Supplier_Code <> ''  --6
--where p.Units = 'Per 100' --7
--where Supplier_Purchase_Unit = 'Package'  and Supplier_Code <> '' --11
--where p.Units = 'Per Package' or p.Units = 'Package'  --11
--where Supplier_Purchase_Unit = 'lbs' and Supplier_Code <> '' --1
--where p.Units = 'Pounds'  --2
--where Supplier_Purchase_Unit = 'quart'  and Supplier_Code <> ''--1
--where p.Units = 'Quart'  --1
--where Supplier_Purchase_Unit = 'Roll'  and Supplier_Code <> '' --10
--where p.Units = 'Roll'  --10
--where Supplier_Purchase_Unit = 'set'  and Supplier_Code <> '' --122
--where p.Units = 'Set'  --125
--10371 --Pass 07/15A
/*
where Supplier_Purchase_Unit = 'Box' --6
or Supplier_Purchase_Unit = 'case' --2
or Supplier_Purchase_Unit = 'dozen'  --5
or Supplier_Purchase_Unit = 'Ea' --9930
or Supplier_Purchase_Unit = 'Feet' --256
or Supplier_Purchase_Unit = 'Gallons' --9
or Supplier_Purchase_Unit = 'inches' --2
or Supplier_Purchase_Unit = 'meters'  --5
or Supplier_Purchase_Unit = 'hundred'  --7
or Supplier_Purchase_Unit = 'Package'  --11
or Supplier_Purchase_Unit = 'lbs'  --2
or Supplier_Purchase_Unit = 'quart'  --1
or Supplier_Purchase_Unit = 'Roll'  --10
or Supplier_Purchase_Unit = 'set'  --125
--10371 07/15C Supplier_Purchase_Unit
*/

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
'BE850014', --inches /Inches
'BE800300',--quart / Quart
'BE990003',--lbs / Pounds
'BE999000',--Ea / Each
'BE999002'--Gallons / Gallons
)
-- Pass 07/15A

order by item_no

/*
 * 
 * 
 * 
 * 
 *             Create Upload CSV files
 * 
 * 
 * 
 * 
 */
select count(*) cnt from dbo.plxLocation     --3409 07/15A
select count(*) cnt from dbo.plxSupplyItem  --10371 07/15A
select count(*) cnt from dbo.plxItemLocation--11384 07/15A  Error should be 11384 but was 11382, i forgot to generate this table befor last upload.
											--25164 07/15A
/*
 * Create Location CSV files
 */

select count(*) cnt from dbo.plxLocation  --3409 07/15A
select count(*) cnt from (  --looks ok
select DISTINCT Location from dbo.plxItemLocationBase
)tst

select
Location,
building_code,
location_type,  
note,
location_group
from dbo.plxLocation l
where 
Row# >2100 and Row# <= 4100
--Row# >=1 and Row# <= 2100

/*
 * Create Supply Item CSV files
 */



select count(*) cnt from dbo.plxSupplyItem  --10371 07/15A


select 
si.Item_No,Brief_Description,
Description,Note,
Item_Type,Item_Group,Item_Category,
Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,si.Location,
Supplier_Code,
Supplier_Part_No,Supplier_Std_Purch_Qty,
Currency,
Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
Cube_Unit			
from dbo.plxSupplyItem si
--where Row# >=1 and Row# <= 900
--where Row# >=901 and Row# <= 1800
--where Row# >=1801 and Row# <= 2700
--where Row# >=2701 and Row# <= 3600
--where Row# >=3601 and Row# <= 4500  
--where Row# >=4501 and Row# <= 5400  
--where Row# >=5401 and Row# <= 6300  
--where Row# >=6301 and Row# <= 7200  
--where Row# >=7201 and Row# <= 8100  
--where Row# >=8101 and Row# <= 9000  
--where Row# >=9001 and Row# <= 9900  
where Row# >=9901 and Row# <= 10800 


/*
 * Create Item Location CSV files
 */

select count(*) cnt from dbo.plxItemLocation  --11384 07/15A

SELECT
Item_No,il.Location,Quantity,
Building_Default,Transaction_Type
--drop table plxItemLocationTS
--into plxItemLocationTS
from dbo.plxItemLocation il
--where Row# >=1 and Row# <= 4000
--where Row# >=4001 and Row# <= 8000
where Row# >=8001 and Row# <= 12000












/