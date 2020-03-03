--drop table station0224

-- I messed up and called 1223 files 1213.
select * 
into station0302
from STATION

select count(*) cnt from station0302
--12680
--12679
--12696
--12696
--12695
--12695
--12674
--12674
--12673
--12677
--12676
--12673
--12675
--12674
--12668
--12666
--12660
--12653
--12624
--verify backup of station
select top 100 * from station0302
-- Upload the item_location table into PlxSupplyItemLocation table.
--drop table dbo.PlxSupplyItemLocation0224
CREATE TABLE Cribmaster.dbo.PlxSupplyItemLocation0302 (
	item_no varchar(50),
	location varchar(50),
	quantity integer
)
--update purchasing.dbo.item set Description=Brief_Description + ', ' + Description where Brief_Description <> Description
-- Verify table was created and has zero records
--drop table PlxSupplyItemLocation1125
select count(*) from PlxSupplyItemLocation0302  --
-- truncate table PlxSupplyItemLocation0730
-- Insert Plex item_location data into CM
Bulk insert PlxSupplyItemLocation0302
from 'c:\il0302GE12500.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select
count(*)
--top 1000 * 
from PlxSupplyItemLocation0302 --0
--13350
--13349
--13338
--13325
--13311
--13302
--13299
--13294
--13291
--13288
--13283
--13285
--13260
--13258
--13256
--13254
--13245
--13242
--13232
--13222
--13221
--13220
--13215
--13204
--13196
/*
 * Item locations in plex but not in CM: 2563
 * Plex Item locations not in CM not having location '01-002A01': 22
 * Plex '01-002A01' Item locations with quantity = 0: 2534
 * Plex '01-002A01' Item locations with quantity <> 0: 7
 */
--drop table dbo.nic0224

select 
il.item_no
--il.item_no,il.location,il.quantity
into nic0302 --Plex supply items with the default location and a quantity = 0
--count(*) --2587,2592,2591,2595,2585,2580,2578,2581,2578,2578,2577,2581,2563,2563,2563,2562,2561,236	
--il.item_no,inv.ItemClass,inv.Description1,il.location,il.quantity as PlexQuantity,st.BinQuantity as CribMasterQty,st.Quantity as CMQuantity
from (
	select --distinct incase I inserted items more than once
		distinct item_no,location,quantity
	from PlxSupplyItemLocation0302 
) il
left outer join STATION st 
on il.location=st.CribBin
and il.item_no=st.Item
--13291 0726 13193 --0628 13206
left outer join INVENTRY inv
on il.item_no=inv.ItemNumber
where st.CribBin is null  
and il.location='01-002A01'
and il.quantity = 0 
--and il.location<>'01-002A01'
--and il.quantity is null
--and il.quantity = 0 
--and il.quantity <> 0 

	select COUNT(*)
	from nic0302
	--2587
	--2592
	--2591
	--2595
	--2585
	--2580
	--2578
	--2581
	--2578
	--2578
	--2577
	--2581
	--2563
	--2563
	--2562
	--2561
	--2562
	--2560
	--2553
	--2554
	--2551
	--2550
	--2541

/*
 * Set CM item stations with Plex Supply Item Locations = '01-002A01' and a quantity = 0
 * equal to 0.
 * There are only 1965 of these items in CM.
 */
--update STATION 
set BinQuantity = 0,
Quantity = 0
--select 
--count(*) cnt --1972,1970
--	item
	from STATION st
	where 
	item in 
	(
	select item_no
	from nic0302
	)
	and (st.BinQuantity<>0 or st.Quantity <> 0 ) --14,13,19,14,13,12,11,12,12,12, 12, 12,12,12,13,13,15,12,13,12, 10, 8,9,10
--	and (st.BinQuantity=0 and st.Quantity = 0 )  --1919,1960,1963

--Join these 2 tables on item number and location.
--Set the station table’s quantity equal to PlxItemLocation.quantity value. 
--update STATION 
set BinQuantity = il.quantity,
Quantity = il.quantity
--select 
--il.item_no
--il.item_no,il.location,il.quantity
--count(*) 
from (
	select --distinct incase I inserted items more than once
		distinct item_no,location,quantity
	from PlxSupplyItemLocation0302
) il
inner join STATION st 
on il.location=st.CribBin
and il.item_no=st.Item
--0729=10630, 0726=10630, --0628=11285
where 
il.quantity <> st.BinQuantity --409,341,421,375,304,409,312, 213,177,1330,1319,510,293,376,416,417,472, 342,353, 455,406,384	
--il.quantity > st.BinQuantity --164,123,154,149,122, 124, 124,77,51, 492,538,134,140,171,172,177,120,138,131,61
--il.quantity < st.BinQuantity --245,218,267,226,182,285,188,136,126,838,781,376,168,236,245,245,295,222,311,215, 316,275,105
--80 more items dropped in quantity 0820
--385
--0813=389
--0806=272
--0801=181
--0729=183


/*
 * 
 * Plex and CM Item location Differences
 * CM item locations not in Plex with a quantity <> 0: 10
 * Plex Item locations not in CM not having location '01-002A01': 22
 * Plex '01-002A01' Item locations with quantity <> 0: 7
 * 
 */

/*
 * Plex 'BPG Central Stores' Item Location not in CM: 2563
 * Plex Item locations not in CM not having location '01-002A01': 22
 * Plex '01-002A01' Item locations with quantity = 0: 2534
 * Plex '01-002A01' Item locations with quantity <> 0: 7
 * 
 *  
 */
select * from dbo.INVENTRY 
where 
ItemNumber in 
('16718','16772','16647','16166','0004235')

select item,quantity,received
FROM PODetail
where item in ('16718','16772','16647','16166','0004235')



ItemNumber like '%16718%'
select 
il.item_no,il.location,il.quantity
--count(*) 
from (
	select --distinct incase I inserted items more than once
		distinct item_no,location,quantity
		--COUNT(*)
	from PlxSupplyItemLocation0729 
) il
left outer join STATION st 
on il.location=st.CribBin
and il.item_no=st.Item
where 
st.CribBin is NULL
and il.location <> '01-002A01'
and il.quantity <> 0


/*
 * CM item locations not in Plex: 63
 * CM item locations not in Plex with a quantity <> 0: 10
 * We are expecting the nic0729 records to not be in plex because there locations have been removed
 * 
 */
select 
st.Item,st.CribBin,st.BinQuantity
--count(*)cnt
from STATION st
left outer join PlxSupplyItemLocation0729 il --there are no dups in this table
on st.CribBin=il.location
and st.Item=il.item_no
where il.item_no is null  --2023
and st.Item not in
(
	select item_no from nic0729
) --63
and st.BinQuantity <> 0