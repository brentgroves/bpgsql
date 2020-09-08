--////////////////////////////////////////////////
-- Each toolid/item could have a different items
-- per part ratio, but the toolbosses dont currently
-- have an opsdescription in the restrictions2 table
-- so we have to choose the toolids items per part ratio
-- for costing purposes.
-- /////////////////////////////////////////////////
-- select * from bvToolListItemsFixtureOnlyLv1
-- drop view bvToolListItemsFixtureOnlyLv1
select * 
FROM [ToolList Fixture] as m 
where processID in (62421,62422,62423)  -- 0 recods

create View [dbo].[bvToolListItemsFixtureOnlyLv1] 
AS
select lv2.*,ti.itemClass,ti.UDFGLOBALTOOL,ti.cost
from
(
	select tl.partNumber,tl.Description as tlDescription, lv1.*
	from
	(
		SELECT tm.originalprocessid, tm.processid,CribToolID as itemNumber, 
		0 as ToolID, 0 as ttpid, 111111 ToolNumber,'Fixture' as OpDescription, 
		tf.itemid,tf.tooltype,tf.tooldescription,  
		Quantity,AnnualVolume,0 as AdjustedVolume,0 as QuantityPerCuttingEdge,0 as NumberOfCuttingEdges,
		'fixture' as itemType,0 as partspecific, 0 as Consumable, 
		case 
			when toolbossStock is null then 0
			when toolbossStock = 0 then 0
			when toolbossStock = 1 then 1
			else 0
		end as toolbossStock,
		cast(0.0 as numeric(19,8)) itemsPerPart, 
		0 as MonthlyUsage, 0 as DailyUsage
		FROM [TOOLLIST Fixture] as tf 
		INNER JOIN 
		(
			-- these are the toollist which are added to the toolbosses
			select tm.* 
			from
			btDistinctToolLists tb
			inner join
			[ToolList Master] tm
			on tb.ProcessId=tm.ProcessID
			--731
		) as tm 
		ON tf.PROCESSID = tm.PROCESSID 
	)lv1
	inner join 
	btDistinctToolLists tl
	on lv1.ProcessID=tl.processid
	--32571
)lv2  -- 1654
-- drop items that are not in the crib
/*
left outer join toolitems ti 
on lv2.itemNumber=ti.itemnumber
where ti.itemnumber is null  -- 3  item numbers are null
 */

inner join
toolitems ti
on lv2.itemNumber=ti.itemnumber
--32438;