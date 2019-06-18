/*
For MRO we use the following:
'BPG Central Stores' as building_code,
'Supply Crib' as location_type,
'' as note,
'MRO Crib' as location_group
*/


/* 
For Maintenance use the following:
Location_type: Maintenance - has not been added to plex.
location_group: Maintenance Crib
building_code: 
BPG Central Stores
BPG Distribution Center
BPG Edon
BPG Metrology Lab
BPG Plant 11
BPG Plant 2
BPG Plant 3
BPG Plant 5
BPG Plant 6
BPG Plant 7
BPG Plant 8
BPG Plant 9
BPG Pole Barn
BPG Warehouse
BPG Workholding
Dependable Metal Treating, Inc.
Edon
Winona Powder Coatings 
 */

select * from dbo.btSiteMap
select * from dbo.btSiteBuildingMap

select 
site,shelf,Location,numbered, COUNT(*) 
from dbo.Parts
group by site,shelf,Location,Numbered
HAVING count(*) > 1
--insert into dbo.btSiteBuildingMap VALUES ('MO','Kendallville')
--insert into dbo.btSiteMap VALUES ('Plant # 7','MO')

Select numbered, description, site,shelf
from dbo.Parts
where site = '' or site is null
where site = 'POLE BARN E-2' --101211
where site = 'Pole Barn'  --100988
where site = 'Plant 8 HR Office'  --103232
where site = 'Plant 8 Maint Crib, Albio'  --706202A
where site = 'Plant # 8'  -- 700377A
where site = 'Plant # 5 Offices'  --450800
where site = 'VPlant # 5' --000902
where site = 'Plant 5 Maint. Crib'  --999000
where site = 'Plant # 5'  --200240
where site = 'Plant # 4'  --200133
where site = 'Plant # 11'  --650002AV
where site = 'MRO Building'  --450768
where site ='Edon'  --200003E
where site ='Distribution Center'  --200713
select * from dbo.btSiteMap
select * from dbo.btSiteBuildingMap
insert into dbo.btSiteBuildingMap VALUES ('M5R','BPG Plant 5')
Plant # 5 Offices /M5R
select Row#,Location,Building_Code,Location_Type,Note,Location_Group
from
(
select 
ROW_NUMBER() over(order by location asc) as row#,
sm.plxSite+'-'+p.Shelf as Location,
bm.building_code as building_code,
'Maintenance' as location_type,  -- has not been added to plex.
'' as note,
'Maintenance Crib' as location_group
from 
(

--drop table 
create table 
(
	plxSite varchar(25),
	building_code varchar(50),
	location varchar(50)
);

select * from #set1


			plxSite,
			building_code,
			location


select 
--COUNT(*) c
*
from
(
	select 
	ROW_NUMBER() over(order by location asc) as row#,
	Location,
	building_code,
	'Maintenance' as location_type,  
	'' as note,
	'Maintenance Crib' as location_group
	from
	(
		--select 
		--COUNT(*),
		--plxSite,building_code,location
		--from
		--(
		--select 
		--count(*) cntLocation
		--from
		--(
			select
			--top 100
			DISTINCT
			plxSite,
			building_code,
			location
			--drop table plxLocationSet
			--into plxLocationSet
			from
			(
				select COUNT(*) cnt from (
				select 
				--top 10
				--p.Site,
				--sm.emSite,f
				--bm.plxSite
				--Numbered,
				--sm.plxSite,
				--COUNT(*) c
				--Numbered,
				--quantityonhand,
				sm.plxSite,
				bm.building_code,
				case 
					when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
					when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
					when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE
					when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+p.Shelf --11
					--else '???'
				end location

				select itemnumber,COUNT(*) from (

				--select itemnumber from (
				select p.Numbered,ap.itemnumber
				from dbo.Parts p
				left outer join plxAllPartsSet ap
				on LTRIM(RTRIM(p.Numbered))=ap.itemnumber
				where (ap.itemnumber is not null) 
				)tst
				
				group by tst.itemnumber
				having count(*) > 1

				select set1.itemnumber FROM
				(
				
				select itemnumber
				from plxAllPartsSet
				--group by itemnumber
				--having COUNT(*) >1
				)set1
				join (
				select LTRIM(RTRIM(Numbered)) itemnumber
				from dbo.Parts
				group by LTRIM(RTRIM(Numbered))
				having COUNT(*) >1
				)set2
				on set1.itemnumber=set2.itemnumber
				left outer join dbo.btSiteMap sm
				on p.Site=sm.emSite
				left outer join dbo.btSiteBuildingMap bm
				on sm.plxSite=bm.plxSite
				where (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') 
				)tst
				--11158
			)setLocation
			
		--)tst --3309
		--)tst
		--group by plxSite,building_code,location
		--HAVING count(*) > 1
	)set2
)set3
where row# >=1
and row# <= 100
--3309

-- Used for Plex Supply Item Locations upload screen
select 
item as item_no,
CribBin as location,
BinQuantity as quantity,
'N' as Building_Default,
'' Transaction_Type
from 


SELECT
COUNT(*) c
from

select 
p.numbered,
ap.NSItemNumber,
p.QuantityOnHand,
case 
	when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
	when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
	when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE
	when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+p.Shelf --11
	--else '???'
end location
from 
dbo.Parts p
left outer join 
dbo.plxAllPartsSet ap  -- No Kendallville parts
on nkp.numbered=ltrim(RTRIM(p.Numbered)
where nkp.numbered is not null
--dbo.plxAllPartsSet
select * from dbo.plxLocationSet


(
	select
	--top 100
	DISTINCT
	plxSite,
	building_code,
	location
	from
	(
		select 
		--top 10
		--p.Site,
		--sm.emSite,
		--bm.plxSite
		--Numbered,
		--sm.plxSite,
		--COUNT(*) c
		--Numbered,
		--quantityonhand,
		sm.plxSite,
		bm.building_code,
		case 
			when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
			when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
			when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE
			when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+p.Shelf --11
			--else '???'
		end location
		from dbo.Parts p  
		left outer join dbo.btSiteMap sm
		on p.Site=sm.emSite
		left outer join dbo.btSiteBuildingMap bm
		on sm.plxSite=bm.plxSite
		--Non Kendallville parts
		where (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO')  --00 =11158 
	)set1
	
)set2


select count(*) cntSameSiteShelf --2259
FROM
(

select set1.site,set1.shelf,p.Numbered,p.Description,p.QuantityOnHand
from
(
	select site,Shelf,COUNT(*) cntSameSiteShelf 
	FROM
	dbo.Parts
	group by site,Shelf
	having count(*) > 1
	and shelf is not null and shelf <> ''
)set1
left outer join dbo.Parts p
on set1.site=p.site and set1.shelf=p.Shelf
order by set1.site,set1.shelf

)set1

where Shelf = '20-08-02'

	--and COUNT(*) > 1
--and (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) --then sm.plxSite+'-'+p.Shelf --11

--and (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) --then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE

--and (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null)  -- then sm.plxSite+'-'+ 'no location yet' --01

--and (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) --then 'no location yet' --00
	
)tst

select COUNT(*)
from
(
	select 
	DISTINCT Shelf,Numbered,site
	from dbo.Parts p  
	left outer join dbo.btSiteMap sm
	on p.Site=sm.emSite
	left outer join dbo.btSiteBuildingMap bm
	on sm.plxSite=bm.plxSite
	--Non Kendallville parts
	where (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO')  --00 =11158 
--	and Shelf is not null and Shelf <> ''
)tst

select Numbered,site,shelf,*
FROM
parts 
where 
Numbered in ('851280','900040')
select Numbered, COUNT(*)
	from dbo.Parts p  
	group by Numbered
	having 
	RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'
	and 
	COUNT(*) > 1

select COUNT(*) c
select 
top 100
location
from 
(
	select 
	case 
		when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
		when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
		when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE
		when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+p.Shelf --11
		else '???'
	end location
	from dbo.Parts p
	left outer join dbo.btSiteMap sm
	on p.Site=sm.emSite
)set1

order by location

dbo.Parts p
WHERE
(Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) --then sm.plxSite+'-'+p.Shelf --11

(Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) --then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE

(Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null)  -- then sm.plxSite+'-'+ 'no location yet' --01

(Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) --then 'no location yet' --00


-- Used for Plex Location List Upload screen
select 
Location,Building_Code,Location_Type,Note,Location_Group
--count(*)
from
(
select Row#,Location,Building_Code,Location_Type,Note,Location_Group
from
(
select 
ROW_NUMBER() over(order by location asc) as row#,
sm.plxSite+'-'+p.Shelf as Location,
bm.building_code as building_code,
'Maintenance' as location_type,  -- has not been added to plex.
'' as note,
'Maintenance Crib' as location_group
from 
(
	select DISTINCT plxSite,building_code,location from
	(
		select 
		--top 100
		--p.Site,p.Shelf,
		sm.plxSite,
		bm.building_code,
		case 
			when (Shelf = '' or Shelf is null) and (p.Site='' or p.site is null) then 'no location yet' --00
			when (Shelf = '' or Shelf is null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+ 'no location yet' --01
			when (Shelf <> '' and Shelf is not null) and (p.Site='' or p.site is null) then 'No site'+'-'+p.Shelf --10 ASK KRISTEN FOR SITE
			when (Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) then sm.plxSite+'-'+p.Shelf --11
			else '???'
		end location
		from dbo.Parts p  
		left outer join dbo.btSiteMap sm
		on p.Site=sm.emSite
		left outer join dbo.btSiteBuildingMap bm
		on sm.plxSite=bm.plxSite
		where quantityonhand > 0
		-- do not include Kendallville numbers.
		and RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'
	)set1
)set2
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
left outer join dbo.btSiteBuildingMap bm
on sm.plxSite=bm.plxSite
where p.Shelf = '' or p.Shelf is null
/*
p.Numbered in (
'000003A',  
'000054', 
'000091',  
'000547AV',  
'200382E'
)
*/
--and CribBin in ('12-AA3B03','12-AA3A03','12-AA1C02')
)lv1
-- where row# > 500 -- and row# <= 1000
-- order by location
)lv2
--Test set for all shelf categories:
select 
top 10
numbered,description,site, shelf 
from parts p
where 
-- below 0 records
--(p.Shelf = '' or p.Shelf is null) and (p.Site='' or p.site is null) --'no location yet' --00
-- below many records
--(p.Shelf = '' or p.Shelf is null) and (p.Site<>'' and p.site is not null) -- sm.plxSite+'-'+ 'no location yet' --01
-- 999000
-- below 0 records
-- (p.Shelf <> '' and p.Shelf is not null) and (p.Site='' or p.site is null) -- 'No site'+'-'+p.Shelf --10 
-- below many records
--(Shelf <> '' and Shelf is not null) and (p.Site<>'' and p.site is not null) -- sm.plxSite+'-'+p.Shelf --11
--200240


-- What locations should be uploaded?
select 
sm.plxSite+'-'+p.Shelf as Location
FROM dbo.Parts p
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
--Should we add locations to plex that have no quantities?
/*
 * If we have locations assigned for parts with no inventory the location will still show up on the supply item detail 
 * screen.  When we receive in a po item for a part that previously had no quantity can we receive it into the location record 
 * that we previously set up?
 * 1. Find an item with no location or create one.
 * 2. order that item
 * 3. receive it in.
 */




select top 10 numbered from dbo.Parts
CREATE TABLE btSiteBuildingMap (
	plxSite varchar(25),
	building_code varchar(50)
) 
				
insert into dbo.btSiteBuildingMap values ('M4','BPG Workholding')
select * from dbo.btSiteBuildingMap

CREATE TABLE btSiteMap (
	emSite varchar(25),
	plxSite varchar(25)
) 
--Are there any parts without a site? NO
--Are there any parts in plant 4? 2 but kristen said there were none.
--How many total parts? 12307 
--How many parts have quantities? 10088
--How many parts have 0 quantity?2192
--How many parts have null quantity? 3
--How many parts have null quantity an no shelf? 3
--How many parts have negative quantities? 24 
--Kristen says I can make them all zeros.
--How many parts have negative quantities and no shelves? 3 
--How many parts have quantities but no shelves? 142
--Compile a list of parts with quantities without shelves.
--Compile a list of negative quantities.
--Should we have a separate site(s),M3-no location yet, for parts with no assigned locations or just a location of: “no location yet”
--Take note of the inventory in Plant 7 that is not being transferred into plex. 
select COUNT(*) cntOnHandQty
from
(
select numbered,description,site,Shelf,quantityonhand 
from parts
where quantityonhand < 0 
--and site = 'Plant # 4'
--where (quantityonhand > 0 or quantityonhand < 0 or quantityonhand is null)
and (shelf = '' or shelf is null)
order by site, shelf
/*
where QuantityOnHand is not null
and QuantityOnHand != 0
and QuantityOnHand !> 0
*/
)tst

select DISTINCT site
from
(
select numbered,description,site,Shelf 
from parts
--where site = '' or site is null
)tst

insert into dbo.btSiteMap (emSite,plxSite)
values ('POLE BARN E-2','MPB')
--values ('Distribution Center','MD')
select * from dbo.btSiteMap
--delete from btsitemap where emSite = 'Plant 8 HR Office'
select count(*) siteCnt from (
select p.Numbered,p.Description,p.Site,sm.plxSite,
sm.plxSite+'-'+p.Shelf as Location
from dbo.Parts p
left outer join dbo.btSiteMap sm
on p.Site=sm.emSite
where sm.plxSite = 'MPB' --1167 
--and sm.emSite='POLE BARN E-2' --1
--and sm.emSite='Pole Barn' --1166
--where sm.plxSite = 'M8' --1960 
--and sm.emSite = 'Plant 8 Maint Crib, Albio'  --1834
--and sm.emSite = 'Plant # 8'  --126
--where sm.plxSite = 'M5R' --1 
--where sm.plxSite = 'M5' --6282 
--and sm.emSite ='VPlant # 5' --1
--and sm.emSite ='Plant 5 Maint. Crib' --3851
--and sm.emSite ='Plant # 5' --2430
--where sm.plxSite = 'M4' --2
--where sm.plxSite = 'M11' --811
--where sm.plxSite = 'MM' --1
--where sm.plxSite = 'ME' --391
--where sm.plxSite = 'MD' --540
)tst

select 
--top 10 
site,location,shelf from parts
where site like '%Plant 8%'
--and site = ''
order by location

/*
 * sampling of parts from each site
 */
select site,
(
	stuff(
			(
			select top 10 cast(CHAR(10) + Shelf as varchar(max)) 
			from dbo.Parts p
			where (p.site=set1.site)
			and p.shelf <> ''
			order by p.site, p.shelf
			FOR XML PATH ('')
			), 1, 1, ''
		)
) as Parts 
from
(
select distinct site from parts
)set1

/*
where site in ( 
'Plant # 4',
'MRO Building',
'Plant # 5 Offices',
'POLE BARN E-2',
'VPlant # 5'
)
*/

/*
<All>
Distribution Center
Edon
MRO Building
Plant # 11
Plant # 4 
Plant # 5 
Plant # 5 Offices
Plant # 7 
Plant # 8
Plant 5 Maint. Crib
Plant 7 Maint Crib
Plant 7 Maint. Crib
Plant 8 HR Office
Plant 8 Maint Crib, Albio
Pole Barn
POLE BARN E-2

select count(*) cnt from parts
where shelf = '' --349
where site = '' -- 0
where location ='' --7206
VPlant # 5 

*/



select distinct site from parts

-- Used for Plex Location List Upload screen
select 
Location,Building_Code,Location_Type,Note,Location_Group
--count(*)
from
(
select Row#,Location,Building_Code,Location_Type,Note,Location_Group
from
(
select 
ROW_NUMBER() over(order by CribBin asc) as row#,
CribBin  as location,
'BPG Central Stores' as building_code,
'Supply Crib' as location_type,
'' as note,
'MRO Crib' as location_group
from station
where 
item in (
'16705R','16707R'
)
--and CribBin in ('12-AA3B03','12-AA3A03','12-AA1C02')
)lv1
-- where row# > 500 -- and row# <= 1000
-- order by location
)lv2

-- Used for Plex Supply Item Locations upload screen
select 
item as item_no,
CribBin as location,
BinQuantity as quantity,
'N' as Building_Default,
'' Transaction_Type
from station
where item in
(
'16705R','16707R'
)
--and CribBin not in ('01-N202A02','01-R03B03','01-C212A04')


-- Remove previous days backup of station and PlxSupplyItemLocation tables
-- drop table PlxSupplyItemLocation0503
-- drop table  station0502
-- Make backup of station quantities table before changing it in Cribmaster. 
select * 
into station0524
from STATION
--12624
--verify backup of station
select count(*) from station0524
--12637
-- Upload the item_location table into PlxSupplyItemLocation table.
CREATE TABLE Cribmaster.dbo.PlxSupplyItemLocation0524 (
item_no varchar(50),
location varchar(50),
quantity integer
)
--update purchasing.dbo.item set Description=Brief_Description + ', ' + Description where Brief_Description <> Description
-- Verify table was created and has zero records
select count(*) from PlxSupplyItemLocation0524
-- truncate table PlxSupplyItemLocation0416
-- Insert Plex item_location data into CM
Bulk insert PlxSupplyItemLocation0524
from 'c:\il0524GE12500.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)

select
count(*) 
from PlxSupplyItemLocation0524 --0

select count(*)
from
(
select
distinct item_no,location,quantity
--count(*) 
--*
from PlxSupplyItemLocation0524 --0
)lv1
--12998
--12997
--12822

--Join these 2 tables on item number and location.
--Set the station table’s quantity equal to PlxItemLocation.quantity value. 
--update station
--update STATION 
set BinQuantity = il.quantity,
Quantity = il.quantity
select 
count(*) --236 
--il.item_no,inv.ItemClass,inv.Description1,il.location,il.quantity as PlexQuantity,st.BinQuantity as CribMasterQty,st.Quantity as CMQuantity
from (
select --distinct incase I inserted items more than once
distinct item_no,location,quantity
from PlxSupplyItemLocation0524 
) il
inner join STATION st --12614
on il.location=st.CribBin
and il.item_no=st.Item
inner join INVENTRY inv
on il.item_no=inv.ItemNumber
--12608
--where il.quantity < st.BinQuantity 
--and inv.InactiveItem = 0  
--530
where il.quantity <> st.BinQuantity 
and inv.InactiveItem = 0  
--1126
--145
--130
--61
--213
--124
--98
--90
-- 4 inactive items changed quantities in plex and 
-- would like to know why
--0001377
--15313  
--15762  
--16711  

--81
--233

--Update the items Nancy told me to
--16520,006944,14396,009259
select *
--from station st
from PlxSupplyItemLocation0422 il 
where item_no in
('16520','006944','14396','009259')
--update station
set BinQuantity = 9,
Quantity = 9 
from station st
where item = '009259'
--How many of these 


--Why is there 86 more item locations in Plex than Cribmaster
--Are there any item locations in cribmaster that are not in plex?
select 
--count(*)
st.item,st.cribbin,st.BinQuantity,
inv.InactiveItem
from STATION st --12614
left outer join INVENTRY inv
on st.item=inv.ItemNumber
left outer join PlxSupplyItemLocation0416 il
on st.CribBin=il.location
and il.item_no=st.Item
where il.location is null
order by st.item
--17


-- Are there any item locations in Plex that are not in Cribmaster? YES 96
select 
count(*)
--il.*
from PlxSupplyItemLocation0416 il 
left outer join STATION st --12614
on il.location=st.CribBin
and il.item_no=st.Item
where st.CribBin is null

-- What quantities have changed in plex since the import from CM 
select 
--count(*) --236 
inv.InactiveItem,il.item_no,inv.ItemClass,inv.Description1,il.location,il.quantity as PlexQuantity,st.BinQuantity as CribMasterQty,st.Quantity as CMQuantity
from PlxSupplyItemLocation0411 il 
inner join STATION st --12614
on il.location=st.CribBin
and il.item_no=st.Item
inner join INVENTRY inv
on il.item_no=inv.ItemNumber
--12597
where il.quantity <> st.BinQuantity 
and inv.InactiveItem = 1
--233
select *
from 
STATION where item = '005825R'


--Plex screen location list
--Location,Building Code,Location Type,Note,Location Group


--Are there any Plex locations which are not in the Cribmaster
-- No There are no locations 'Supply Crib','MRO Crib','BPG Central Stores'
-- that are not supposed to be there
select count(*)
from btPlexLocation pl
left outer join station st
on pl.location=st.CribBin
where st.CribBin is NULL
--11734

--Are all the Crib locations in Plex
select
count(*)
--st.item,st.CribBin,pl.location 
from station st
left outer join btPlexLocation pl
on st.CribBin=pl.location
where crib=11 and pl.location is not NULL



-- Uploaded 12000 Locations with Quantities on 04-11 and
-- this table is a snapshot of this upload
CREATE TABLE Cribmaster.dbo.PlxSupplyItemLocation0411 (
item_no varchar(50),
location varchar(50),
qty integer,
Building_Default varchar(5),
Transaction_Type varchar(50)
)
-- truncate table PlxSupplyItemLocation0411
Bulk insert PlxSupplyItemLocation0411
from 'c:\il0411LE13000.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)
select 
--*
--count(*)
count(distinct location)
from PlxSupplyItemLocation0411
--3967
--4964
--5960
-- Determine items in Cribmaster that have changed since this upload
SELECT
--count(*)
--st.cribbin,sil.location
sil.item_no,sil.location,sil.qty as plexQty,st.BinQuantity as cribmasterQty
from PlxSupplyItemLocation0411 sil
left outer join STATION st
on st.cribbin = sil.location
--where st.CribBin = sil.location
where st.BinQuantity<>sil.qty

-- Used to Supply Item Location upload
--truncate TABLE Cribmaster.dbo.PlxSupplyItemLocation
CREATE TABLE Cribmaster.dbo.PlxSupplyItemLocation (
item_no varchar(50),
location varchar(50),
qty integer,
Building_Default varchar(5),
Transaction_Type varchar(50)
)


select * from PlxSupplyItemLocation
-- Store purchasing.item_location. 
-- Failed item location upload because item not in plex.
-- Linux note don't use double quote and change file format
-- to dos in vim https://vim.fandom.com/wiki/File_format
Bulk insert PlxSupplyItemLocation
from 'c:\noitem.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)


-- Import all locations in plex
select * from btPlexLocation --11734
where location like 'n++%'
update btPlexLocation
set location = '01-I03D01'
where location = 'n++01-I03D01'

Bulk insert btPlexLocation
from 'c:\PlexLocationGE7000.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)

select distinct cribbin from STATION order by cribbin where cribbin like '09%'


--This table contain

-- DROP TABLE [Busche ToolList].dbo.ToolBoss GO

CREATE TABLE [Busche ToolList].dbo.PlxNotInPlex (
Part_No varchar (100)
) 

select * from PlxPartNumber
Bulk insert PlxPartNumber
from 'c:\PlexPartNumbers.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)


--Plex screen location list
--Location,Building Code,Location Type,Note,Location Group
select 
Location,Building_Code,Location_Type,Note,Location_Group
--count(*)
from
(
select Row#,Location,Building_Code,Location_Type,Note,Location_Group
from
(
select 
ROW_NUMBER() over(order by CribBin asc) as row#,
CribBin  as location,
'BPG Central Stores' as building_code,
'Supply Crib' as location_type,
'' as note,
'MRO Crib' as location_group
from station
where 
item in (
'16947'
)
--or crib = 11
--or crib = 12
)lv1
where row# > 500 -- and row# <= 1000
-- order by location
)lv2