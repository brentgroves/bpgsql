/*
 * plxAllPartsSetX will be used in other
 * queries so will make it a table.  This
 * set contains all non-kendallville part
 * records.
 * Dont make a view with with clause because
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
select top 100 * from plxAllPartsSetWithDups

--drop table plxAllPartsSet
create table plxAllPartsSet
(
	minRecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	BEItemNumber varchar(50),
	suffix varchar(2)
);
select top 100 * from plxAllPartsSet


-- This does not include the Kendallville parts but does contain duplicate part numbers.
-- which are part numbers stored in multiple locations
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
 * To be used for sets requiring all non-kenallville parts
 * and no duplicate part numbers.  For those parts with
 * multiple locations the one with the lowest record number 
 * has been chosen to represent the part for description and
 * other non location related information.  Some part numbers
 * are in both Kendallville and non-Kendallville sites.  The
 * part number record of duplicate parts is NOT from a Kendallville
 * site.
 */
select count(*) from dbo.plxAllPartsSet
--11146

/*
 * To be used for sets requiring all non-kendallville parts.
 * It includes part numbers with multiple locations multiple times
 * once for each location.  It also includes a record number to 
 * ensure exactly which part record we are referring to.  Some
 * part numbers are in both Kendallville and non-kendallville 
 * sites.  There are no Kendallville part records included in this
 * list.
 */
select count(*) from dbo.plxAllPartsSetWithDups
--11159




select top 100 * from plxItemLocationSub
select COUNT(*) cnt from (
select min(recordnumber) minRecordNumber, itemnumber,BEItemNumber,plxSite,building_code,location 
/*
 * 
 * 
 * ITEM LOCATION SUB MODULE
 * Contains the fields other queries need
 * plxItemLocationSub is used to generate the plex supply item and supply item location upload sets.
 * 
 * 
 * 
 * 
 */

--drop table plxItemLocationSub
into plxItemLocationSub
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
	from dbo.Parts p
	--select top 10 * from plxAllPartsSetWithDups
	inner join plxAllPartsSetWithDups ap
	on p.RecordNumber=ap.recordnumber
	-- we want the set created of all non-kendallville parts in EM
	-- including duplicate parts which are stored in different locations.
	left outer join dbo.btSiteMap sm
	on p.Site=sm.emSite
	left outer join dbo.btSiteBuildingMap bm
	on sm.plxSite=bm.plxSite
	--)tst --11159
)set1
group by itemnumber,BEItemNumber,plxSite,building_code,location
)tstDistinct --11154


/*
 * 
 * 
 * 
 * PLEX LOCATION UPLOAD
 * 
 * 
 * 
 * 
 * 
 * 
 */
select * 
from plxTestSetLocation

select
top 10
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
		 * Drop the itemnumber from this set.  Since there are many parts that share
		 * locations the set count will drop significantly at this point. 
		 */
		--select count(*) cnt from (
		select DISTINCT location,building_code 
		from dbo.plxItemLocationSub il
		--)tst --3309 Dropped itemnumber from set
	)set1
	--)tst --3309 Dropped itemnumber from set
)set2
--)tst  --3309 
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
 * 
 * 
 * 
 * 
 * 
 * 
 */
select * from plxTestSetItemLocation
select top 10 * from plxItemLocationSub
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
	from plxItemLocationSub il
	left outer join dbo.Parts p
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

-- FINISH WITH SUPPLY ITEM UPLOADS


