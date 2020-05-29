
inner	
(
select 
il.item_no,il.location,il.quantity

--count(*) --236	
--il.item_no,inv.ItemClass,inv.Description1,il.location,il.quantity as PlexQuantity,st.BinQuantity as CribMasterQty,st.Quantity as CMQuantity
from (
	select --distinct incase I inserted items more than once
		distinct item_no,location,quantity
--	from PlxSupplyItemLocation0418 
	from PlxSupplyItemLocation0628 
) il
left outer join STATION st --12614 / 11284
on il.location=st.CribBin
and il.item_no=st.Item
left outer join INVENTRY inv
on il.item_no=inv.ItemNumber
where st.CribBin is null  --1922
and il.quantity = 0 --17
)set1	


/*
 * Total Costs:
 * All Item Locations in CM:  $6,632,516.20 --Before update
 * 							  $5,424,225.17 --After update
 * All Item Location in Plex: $5,438,397.18

 * Diff in CM and Plex costs:  1,194,119.02  --Before update
 *                               (14,172.01) --After update 
 *
 * Plex greater than CM cost: $14,172.01  
 * In Plex but not in CM: 	   $9,521.24
 * 					    Diff:   4,650.77
 */


/*
 * Make backup of station
 */
/*
select * 
into station0701
from 
station
*/
--select * from station0701

--select 
--sum(cmItemLocCost) TotalCost
--count(*) cnt
--from
--update STATION
set Quantity=0,
BinQuantity=0

select 
sum(cmitemLocCost) TotalCost  --1290766.22 /1245640.03
--count(*) cnt
from
(
	
	select Item,cribbin,binquantity,quantity,av.cost,BinQuantity*av.cost cmItemLocCost 
	from
	(	
		--update STATION
		--set Quantity=0,
		--BinQuantity=0
		select Item,cribbin,binquantity,quantity--,av.cost,st.BinQuantity*av.cost cmItemLocCost 
		from STATION st
		where item+'-'+cribbin in 
		(
			select ltrim(rtrim(cm.itemnumber))+'-'+ltrim(rtrim(cm.cribbin)) itemloc 
			--cm.itemnumber,cm.cribbin,cm.binquantity,cm.cost,cm.cmItemLocCost
			from
			(
				/*
				 * All item locations in CM
				 */
				select 
				sum(cmitemLocCost) TotalCost
				--count(*) cnt
				from
				(
					SELECT
					--top 10 
					inv.ItemNumber,st.item,st.CribBin,st.BinQuantity,av.cost,st.BinQuantity*av.cost cmItemLocCost 
					from station st
					inner join INVENTRY inv
					on st.item= inv.ItemNumber
					inner join AltVendor av
					ON inv.AltVendorNo = av.RecNumber
					and RIGHT(ltrim(rtrim(st.item)),1)<>'R'
					--5,424,225.1700
				)tst
			)cm
			left outer join
			(
				/* 
				 * All item locations in Plex
				 */
				--select 
				--sum(plxItemLocCost) TotalCost
				--count(*) cnt
				--from
				--(
				/*
				 * Rework inventry records are not linked to vendors so there will be no cost.
				 * inventry where not rework 
				 */
					SELECT
					--top 10 
					item_no,location,quantity,av.Cost,quantity*av.cost plxItemLocCost
					from PlxSupplyItemLocation0628 il
					inner join INVENTRY inv
					on il.item_no= LTRIM(RTRIM(inv.ItemNumber))
					inner join AltVendor av
					ON inv.AltVendorNo = av.RecNumber
					and RIGHT(ltrim(rtrim(item_no)),1)<>'R'
					where quantity <> 0 and av.RecNumber is not null
		
				--)tst  --5438397.1812
					
			)plx
			on cm.CribBin=plx.location
			and ltrim(rtrim(cm.ItemNumber))=plx.item_no
			where plx.location is null
			
		)
	)set1
	inner join INVENTRY inv
	on set1.item= LTRIM(RTRIM(inv.ItemNumber))
	inner join AltVendor av
	ON inv.AltVendorNo = av.RecNumber
)set2




select 
sum(plxItemLocCost) TotalCost
--count(*) cnt
from
(
	select plx.item_no,plx.location,plx.quantity,plx.plxItemLocCost--,cm.binquantity,cm.cost,cm.cmItemLocCost
	from
	(
		/*
		 * All item locations in CM
		 */
		--select 
		--sum(cmItemLocCost) TotalCost
		--count(*) cnt
		--from
		--(
			SELECT
			--top 10 
			inv.ItemNumber,st.item,st.CribBin,st.BinQuantity,av.cost,st.BinQuantity*av.cost cmItemLocCost 
			from station st
			inner join INVENTRY inv
			on st.item= inv.ItemNumber
			inner join AltVendor av
			ON inv.AltVendorNo = av.RecNumber
			and RIGHT(ltrim(rtrim(st.item)),1)<>'R'
		--)tst
	)cm
	RIGHT outer join
	(
		/* 
		 * All item locations in Plex
		 */
		--select 
		--sum(plxItemLocCost) TotalCost
		--count(*) cnt
		--from
		--(
		/*
		 * Rework inventry records are not linked to vendors so there will be no cost.
		 * inventry where not rework 
		 */
			SELECT
			--top 10 
			item_no,location,quantity,av.Cost,quantity*av.cost plxItemLocCost
			from PlxSupplyItemLocation0628 il
			inner join INVENTRY inv
			on il.item_no= LTRIM(RTRIM(inv.ItemNumber))
			inner join AltVendor av
			ON inv.AltVendorNo = av.RecNumber
			and RIGHT(ltrim(rtrim(item_no)),1)<>'R'
			where quantity <> 0 and av.RecNumber is not null

		--)tst  --5438397.1812
			
	)plx
	on cm.CribBin=plx.location
	and ltrim(rtrim(cm.ItemNumber))=plx.item_no
	where cm.CribBin is null
	and plx.quantity <> 0
	
)tst --1367


select itemNumber from INVENTRY where ItemNumber like '%00729%'

/* 
 * 		In CribMaster and No item plex '01-002A01' record
 * 
 */
select 
set1.itemnumber,set1.cribbin,set2.location,set1.binquantity,set2.quantity,set1.cost
from
(
	select cm.itemnumber,cm.cribbin,cm.binquantity,cm.cost,cm.cmItemLocCost
	from
	(
		/*
		 * All item locations in CM
		 */
		--select 
		--sum(cmItemLocCost) TotalCost
		--count(*) cnt
		--from
		--(
			SELECT
			--top 10 
			inv.ItemNumber,st.item,st.CribBin,st.BinQuantity,av.cost,st.BinQuantity*av.cost cmItemLocCost 
			from station st
			inner join INVENTRY inv
			on st.item= inv.ItemNumber
			inner join AltVendor av
			ON inv.AltVendorNo = av.RecNumber
			and RIGHT(ltrim(rtrim(st.item)),1)<>'R'
		--)tst
	)cm
	left outer join
	(
		/* 
		 * All item locations in Plex
		 */
		--select 
		--sum(plxItemLocCost) TotalCost
		--count(*) cnt
		--from
		--(
		/*
		 * Rework inventry records are not linked to vendors so there will be no cost.
		 * inventry where not rework 
		 */
			SELECT
			--top 10 
			item_no,location,quantity,av.Cost,quantity*av.cost plxItemLocCost
			from PlxSupplyItemLocation0628 il
			inner join INVENTRY inv
			on il.item_no= LTRIM(RTRIM(inv.ItemNumber))
			inner join AltVendor av
			ON inv.AltVendorNo = av.RecNumber
			and RIGHT(ltrim(rtrim(item_no)),1)<>'R'
			where quantity <> 0 and av.RecNumber is not null

		--)tst  --5438397.1812
			
	)plx
	on cm.CribBin=plx.location
	and ltrim(rtrim(cm.ItemNumber))=plx.item_no
	where plx.location is null
	
)set1 
inner JOIN
(
	SELECT
	--top 10 
	item_no,location,quantity,av.Cost,quantity*av.cost plxItemLocCost
	from PlxSupplyItemLocation0628 il
	inner join INVENTRY inv
	on il.item_no= LTRIM(RTRIM(inv.ItemNumber))
	left outer join AltVendor av
	ON inv.AltVendorNo = av.RecNumber
	where location <> '01-002A01'
	and right(item_no,1)<>'R'
)set2
on set1.itemnumber=set2.item_no
--and set1.cribbin<> set2.location
and set1.binquantity <> 0 or set2.quantity <> 0

