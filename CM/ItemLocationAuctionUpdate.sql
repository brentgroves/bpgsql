/*
 * Zero quantity of all CM station locations that have a Plex location of '%-NC-%'
 * Date: 01/05/2021
 * 
 */

/*
 * 1st backup station table prior to zeroing quantities
 */

select * 
into StationAuction
from STATION
select count(*) cnt from StationAuction

select top 10 * from StationAuction

/*
 * Create set of all supply list items that have an auction location 
 */

declare @AuctionItems Table(item_no varchar(50))
insert into @AuctionItems 
select 
--il.item_no
il.item_no
-- ,il.location Plex,il.quantity
-- select count(*) 
from (
	select 
	distinct item_no  -- 1561  There are no duplicate items with an '%-NC-%' location
	-- item_no -- 1561  
	from PlxSupplyItemLocation010421
	where location like '%-NC-%'  -- 1561

) il
inner join STATION st 
on il.item_no=st.Item  -- 1564 -- some items have multiple station locations

-- select count(*) from @AuctionItems  -- 1564

-- update station 
-- set BinQuantity = 0,
-- Quantity = 0
 select 
 count(*) -- 1564
-- item,BinQuantity,Quantity
from station st  
where st.item in 
(
	select item_no from @AuctionItems
)  -- 3128  1 update for BinQuantity and one for Quantity, OK

select 
-- count(*) 
'"' + plx.item_no + '"',plx.LocQty Plex,cm.LocQty CM
from 
(
	select --distinct incase I inserted items more than once
	distinct item_no,
	(
	    SELECT SUBSTRING((
	        SELECT ',' + location + '/' + CAST(quantity as varchar(10)) 
	        FROM PlxSupplyItemLocation010421
	        WHERE item_no = il.item_no FOR XML PATH('')
        ), 2, 200000)
	) AS LocQty	
	from @LocDiff il
)plx
left outer join 
(
	SELECT 
	distinct item,
	(
		select SUBSTRING((
			select ',' + CribBin + '/' + cast(Quantity as varchar(10))
			from station 
			where item = st.item FOR XML PATH('')
		), 2, 200000) 
	) as LocQty 
	from station st
)cm 
on plx.item_no=cm.item


