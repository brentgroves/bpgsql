-- Make backup of station quantities table before changing it in Cribmaster. 
select * into station0416
from STATION
-- Upload the item_location table into Cribmaster.PlxSupplyItemLocation0416 table.
CREATE TABLE Cribmaster.dbo.PlxSupplyItemLocation0416 (
	item_no varchar(50),
	location varchar(50),
	quantity integer
)
select count(*) from PlxSupplyItemLocation0416 --0
-- truncate table PlxSupplyItemLocation0416
Bulk insert PlxSupplyItemLocation0416
--from 'c:\il0416GE12500.csv'
from 'c:\il0416DiffsOnly.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)
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
from PlxSupplyItemLocation0416 il 
inner join STATION st --12614
on il.location=st.CribBin
and il.item_no=st.Item
inner join INVENTRY inv
on il.item_no=inv.ItemNumber
--12597
where il.quantity <> st.BinQuantity	
and inv.InactiveItem = 0
--233
select *
from 
STATION where item = '005825R'

select 
--	count(*) 
*
from PlxSupplyItemLocation0416 --0


--Join these 2 tables on item number and location.
--Set the station table’s quantity equal to PlxItemLocation.quantity value. 
--update station
--update STATION 
set BinQuantity = il.quantity,
Quantity = il.quantity
select 
--count(*) --236	
il.item_no,inv.ItemClass,inv.Description1,il.location,il.quantity as PlexQuantity,st.BinQuantity as CribMasterQty,st.Quantity as CMQuantity
from PlxSupplyItemLocation0416 il 
inner join STATION st --12614
on il.location=st.CribBin
and il.item_no=st.Item
inner join INVENTRY inv
on il.item_no=inv.ItemNumber
--12597
--where il.quantity <> st.BinQuantity	
--and inv.InactiveItem = 0
--233

--Update the items Nancy told me to
--16520,006944,14396,009259
select *
--from station st
from PlxSupplyItemLocation0416 il 
where item_no in
('16520','006944','14396','009259')
--update station
set BinQuantity = 9,
Quantity = 9 
from station st
where item = '009259'
--How many of these 

-- Determine what item locations are not in the Crib 
select item
FROM
STATION st
where item in
(
'0004735R',
'0004516R',
'000290'
)
--0004735R  |01-002A01 
--0004516R  |01-002A01 
--000290    |01-B03B04 60

select top 100 * from station0416

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
		'0003876',
		'16211R', 
		'15442R'
		)
		or crib = 11
		or crib = 12
	)lv1
	where row# > 500 -- and row# <= 1000
--	order by location
)lv2

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
--7
--9
--13
--17
--23
--31
--39
--50
--54
--60
select top 100 * from STATION

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

-- Supply Item Locations
select 
item as item_no,
CribBin as location,
BinQuantity as quantity,
'N' as Building_Default,
'' Transaction_Type
from station
where item in
(
'0004735R',
'0004516R',
'000290'
)

where item not in (
'0000677','0000007'
)

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
		'0003876',
		'16211R', 
		'15442R'
		)
		or crib = 11
		or crib = 12
	)lv1
	where row# > 500 -- and row# <= 1000
--	order by location
)lv2


