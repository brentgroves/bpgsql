/*
For MRO we use the following:
'BPG Central Stores' as building_code,
'Supply Crib' as location_type,
'' as note,
'MRO Crib' as location_group
*/

select 
--top 10 
site,location,shelf from parts
where site like '%Plant 8%'
--and site = ''
order by location

select distinct shelf from parts
--where site like '%All%' --CAB, 06-10
--where site like '%Distribution Center%' --211
--where site like '%Edon%' --228
/* A- TOP
A-1-1
A-1-2
A-1-3
A-1-4
A-1-5
A-1-6
A-10-1*/
where site like '%Plant # 11%' --383
/*
A-02-03
A-02-04
A-02-05
A-03-02
A-03-03
A-03-04
A-03-05
A-04-02
A-04-05
*/
order by shelf

select distinct site from parts
order by site
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
VPlant # 5 

*/
select distinct location from parts
order by location

select count(*) cnt from parts
where shelf = '' --349
where site = '' -- 0
where location ='' --7206

select numbered,quantityonhand,description,site,location,shelf from parts
where shelf = '' --349


select top 10 item,CribBin
FROM
STATION st
for xml path
for xml raw
for xml auto

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