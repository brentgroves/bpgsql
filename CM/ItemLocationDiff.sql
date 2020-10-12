-- DO drops later in case you spot an error somewhere else in the process
-- I messed up and called 1223 files 1213.
select * 
into station101220
from STATION
select count(*) cnt from station101220
-- 12679 10/12
--12679 10/05
--12679 10/01
--12679 09/28
--12679 09/21
--12679 09/14
--12679 09/08
--12679 09/01
--12679 08/17
--12679 07/20
--12679 07/13
--12677 07/01
--12677 06/30
--12677 06/22
--12676 --06/15
--12676 --06/09
--12676 --06/02
--12676
--12676
--12676 --05/18
--12680
--12681
--12682
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

select top 100 * from station101220
-- Upload the item_location table into PlxSupplyItemLocation table.
CREATE TABLE Cribmaster.dbo.PlxSupplyItemLocation101220 (
	item_no varchar(50),
	location varchar(50),
	quantity integer
)

-- Insert Plex item_location data into CM
Bulk insert PlxSupplyItemLocation101220
from 'c:\il1012GT12500.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)


select
count(*)
-- top 1000 * 
from PlxSupplyItemLocation101220 
-- Check for duplicates
select count(*)
from 
(
select distinct item_no,location from PlxSupplyItemLocation101220
)s1
-- 14590 10/12
-- 14583 10/05
-- 14570 10/01
-- 14547 09/28
-- 14487 09/21
-- 14547 09/14
-- 14685 09/08
-- 14634 09/01
-- 14426 08/17
-- 14146 07/20
-- 14114 07/13
-- 14036 07/01
-- 14016 06/30
-- 14007 06/22
-- 13991 06/15 
-- 13991 06/09
-- 13990 06/02
-- 13990 06/01
--,13990
--13992 --05/18
/*
 * Item locations in plex but not in CM: 2563
 * Plex Item locations not in CM not having location '01-002A01': 22
 * Plex '01-002A01' Item locations with quantity = 0: 2534
 * Plex '01-002A01' Item locations with quantity <> 0: 7
 */


select 
  il.item_no
--il.item_no,il.location,il.quantity
 into nic101220 --Plex supply items with the default location and a quantity = 0
-- count(*) 
 -- 3779 10/12
 -- 3779 10/01
 --3783 10/01
 --3773 09/28
--3714 09/21
--3685 09/09
-- 3678 09/08
--3628 09/01
--3460 08/17
--3301 07/20
--3214 07/01
--3211 06/30
--3206 06/22
--3192 06-15
--3194 06/09
--3196 06/02
-- 3196 05/26, 3197 05/18
--2615,2614,2591,2590,2591,2595,2585,2580,2578,2581,2578,2578,2577,2581,2563,2563,2563,2562,2561,236	
--il.item_no,inv.ItemClass,inv.Description1,il.location,il.quantity as PlexQuantity,st.BinQuantity as CribMasterQty,st.Quantity as CMQuantity
from (
	select --distinct incase I inserted items more than once
		distinct item_no,location,quantity
	from PlxSupplyItemLocation101220
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
	from nic101220
	-- 3779 10/05
	--3779 10/05
	--3783 10/01
	--3771 09/28
	--3714 09/21
	--3685 09/14
	-- 3678 09/08
	--3628 09/01
	--3460 08/17
	--3301 07/20
	--3271 07/13
	--3114 07/01
	--3211 06/30
	--3206 06/22
	--3192 06/15
	--3194 06/09
	--3196 06/02
	--3196 06/01
	--3196 05/26
	--3197 05/18
	--2611 05/11
	--2615 --03/24??
	--2614
	--2591
	--2590
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
-- count(*) cnt
--10/01 11
--09/08 11
--07/02 14
--05/18 11 items
--05/11 11 items,
--	item,st.BinQuantity,st.Quantity 
	from STATION st
	where 
	item in 
	(
	select item_no
	from nic101220
	)
	and (st.BinQuantity<>0 or st.Quantity <> 0 )
	-- 13 10/12/20
	-- 11 10/05/20
	-- 11 10/01/20
	-- 11 09/28/20
	-- 11 09/21/20
	-- 11 09/14/20
	-- 11 09/08/20
	-- 11 09/01/20
	-- 11 08/17/20
	-- 9 07/20/20
	-- 9 07/13/20
	-- 12 06/30
	-- 12 06/22
	-- 11 06/15
	-- 11 06/09
	-- 11 06/02
	-- 11 06/01
	--05/26 11 more
	-- 05/18
	-- 05/11 = 11
	-- 03/24?? 12,11,12,14,19,14,13,12,11,12,12,12, 12, 12,12,12,13,13,15,12,13,12, 10, 8,9,10
--	and (st.BinQuantity=0 and st.Quantity = 0 )  --1919,1960,1963

--Join these 2 tables on item number and location.
--Set the station table’s quantity equal to PlxItemLocation.quantity value. 
--update STATION 
set BinQuantity = il.quantity,
Quantity = il.quantity
--select 
--il.item_no
--il.item_no,il.location,il.quantity
-- count(*) 
from (
	select --distinct incase I inserted items more than once
		distinct item_no,location,quantity
	from PlxSupplyItemLocation101220
) il
inner join STATION st 
on il.location=st.CribBin
and il.item_no=st.Item
--0729=10630, 0726=10630, --0628=11285
where 
 il.quantity <> st.BinQuantity -- 242 10/12,130 10/05, 247 10/01, 267 09/28, 291, 09/21,184 09/14,212 09/08, 581 09/01,158 08/17,261 07/20, 246 07/13, 386 07/01,309 06/30, 179 06/15,06/09 333,06/02 89,06/01 126, --05/26=115,05/18=172,340,334,351,381,421,375,304,409,312, 213,177,1330,1319,510,293,376,416,417,472, 342,353, 455,406,384	
-- il.quantity > st.BinQuantity -- 93 10/12,89 10/05,112 10/01,142 09/21,74 09/14,77 09/08, 211 09/01,48 08/17,50 07/20, 148 07/01,112 06/30,60 06/22,43 06/15,145 06/09,12 06/02,58 06/01 05/26=40,05/18=84,120,143,107,95,154,149,122, 124, 124,77,51, 492,538,134,140,171,172,177,120,138,131,61
-- il.quantity < st.BinQuantity -- 149 10/12, 41 10/05,135 10/01,125 09/28,167 09/21,110 09/14,135 09/11, 370 09/01,110 08/17/20,211 07/20,173 07/13,238 07/01, 197 06/30,190 06/22,136 06/15,188 06/09, 77 06/02 --68 06/01--05/26=75,05/18=88,220,191,244,286,267,226,182,285,188,136,126,838,781,376,168,236,245,245,295,222,311,215, 316,275,105
--80 more items dropped in quantity 0820
--385
--0813=389
--0806=272
--0801=181
--0729=183
-- DROP OLD TABLES
--drop table PlxSupplyItemLocation092120
--drop table station092120
--drop table nic092120



/*
 * TESTING
 */
-- Don't know why 0418/0411 don't have as many blank locations
select 
--s0518.*
-- s0203.*
count(*)
from PlxSupplyItemLocation0518 s0518
full join dbo.PlxSupplyItemLocation0203 s0203
on s0518.item_no=s0203.item_no 
and s0518.location=s0203.location 
where s0203.item_no is NULL 
and s0518.location = '01-002A01'  --625
where s0518.item_no is NULL 
and s0203.location = '01-002A01'  -- 6

--update purchasing.dbo.item set Description=Brief_Description + ', ' + Description where Brief_Description <> Description
-- Verify table was created and has zero records
--drop table PlxSupplyItemLocation1125
select count(*) from PlxSupplyItemLocation0518  --
select count(*)
from 
(
select distinct item_no,location from PlxSupplyItemLocation0518
)s1  --13992 --05/18
--top 1000 * 
-- Don't know why 0418/0411 don't have as many blank locations
select count(*) from PlxSupplyItemLocation0518 where location = '01-002A01' --3217
select count(*) from PlxSupplyItemLocation0418 where location = '01-002A01' --95
select count(*) from PlxSupplyItemLocation0411 where location = '01-002A01' --1
select count(*) from PlxSupplyItemLocation0203 where location = '01-002A01' --1  --2617
SELECT count(*) from nic0511  --2611


/*
 * Between 05-11 and 05-18 it looks like there have been 587 items that have had all of 
 * their item_location removed from Plex. Since we regularly only remove about 12 items per week 
 * it made me wonder what was going on.  So I verified that there were no bin locations for these items in CM.  
 * None of the 587 items had a bin location in CM so everything should be ok with this large update. 
 */
select
nic0526.item_no
into rm0518
-- nic0518.*
-- count(*)  --587
from nic0518  --3197
left outer join nic0511
on nic0518.item_no=nic0511.item_no
where nic0511.item_no is null 

SELECT count(*) 
from nic0526  
--3197 05/18
--2611 05/11


--Bev Rathburn updated on 05/14/20
--16704
--Farkas, Justin  --05/13/20
select count(*) from rm0518  --587



select 
*
from rm0518 rm
inner join station st 
on rm.item_no=item
where st.BinQuantity <> 0 
or st.quantity <> 0
--05/18 -- 0

select 
--itemnumber
count(*)
from dbo.nic0518 nic
inner join inventry inv
on nic.item_no=inv.ItemNumber --3168
inner join station st 
on nic.item_no=st.item  --1864

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