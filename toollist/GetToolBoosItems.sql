SELECT * 
from bvToolListsInPlants tl
where processid in (49995,49716)
where plant = 112;

select * from bvToolBossItemsInPlants

select * from bvToolListItemsInPlants
where processid in (49995,49716)
create function [dbo].[bfToolBossItemsInPlant]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select * from bvToolBossItemsInPlants
where plant = @plant;

-- dbo.bvToolBossItemsInPlants source

create view [dbo].[bvToolBossItemsInPlants] 
as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

	select '$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
	from
	(
			select originalprocessid,processid,descript,partNumber,plant,
			itemNumber,lv1.itemClass,UDFGLOBALTOOL,toolbossStock  
			from
			(
				select * from bvToolListItemsInPlants
				where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
				--27791
			) lv1
			inner join
			[ToolList Toolboss Stock Items] tbs
			on lv1.itemClass=tbs.ItemClass
			--14347
		union
			-- stocked in toolboss no matter the item
			-- class
			SELECT *
			from
			bvToolListItemsInPlants
			where toolbossstock=1 and UDFGLOBALTOOL <> 'YES'
			--17
		union
			-- add these global items to all tool lists 
			select *
			from
			bvToolListItemsInPlants
			where UDFGLOBALTOOL = 'YES'
			--2388
	--16752
	--16752
) lv2;

-- dbo.bvToolListItemsInPlants source

--///////////////////////////////////////////////////////////////////////////////
-- This view does not take into consideration the [ToolList Toolboss Stock Items]
-- table which lists the item classes to be stocked in the toolbosses. See
-- bvToolBossItemsInPlants to determine items to be stocked in the ToolBosses.
-- This list would be appropriate to list restrictions for the Cribmaster if you
-- grouped the recordset on all fields except plant.
--///////////////////////////////////////////////////////////////////////////////
create view [dbo].[bvToolListItemsInPlants]
as
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'
--27838
union
	-- 796 select count(*) from bvToolListsInPlants
	select tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant
	,ti.itemNumber, ti.itemclass, ti.UDFGLOBALTOOL, 0 as toolbossStock 
	FROM  toolitems ti
	CROSS JOIN
	bvToolListsInPlants tl
	WHERE (ti.UDFGLOBALTOOL = 'YES');



select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'

-- dbo.bvToolListItemsLv1 source

--////////////////////////////////////////////////
-- Each toolid/item could have a different items
-- per part ratio, but the toolbosses dont currently
-- have an opsdescription in the restrictions2 table
-- so we have to choose the toolids items per part ratio
-- for costing purposes.
-- /////////////////////////////////////////////////
create View [dbo].[bvToolListItemsLv1] 
AS
select lv2.*,ti.itemClass,ti.UDFGLOBALTOOL,ti.cost
from
(
	select tl.partNumber,tl.Description as tlDescription, lv1.*
	from
	(
		SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber,
		tt.ToolID, tt.processid as ttpid, tt.toolNumber,tt.OpDescription, 
		ti.itemid,ti.tooltype,ti.tooldescription,
		Quantity,
		AnnualVolume,
		AdjustedVolume,
		QuantityPerCuttingEdge,
		NumberOfCuttingEdges,
		'item' as itemType,partspecific,
		Consumable, 
		case 
			when toolbossStock is null then 0
			when toolbossStock = 0 then 0
			when toolbossStock = 1 then 1
			else 0
		end as toolbossStock,
		case
			when (Quantity=0) or (NumberofCuttingEdges =0) or (QuantityPerCuttingEdge=0) or
			(Quantity is null) or (NumberofCuttingEdges is null) or (QuantityPerCuttingEdge is null)
				then 0
			when (Consumable = 1)
				then 1/((QuantityPerCuttingEdge/cast( ti.quantity as numeric(19,8)))*NumberofCuttingEdges)
			when Consumable = 0 then 0.0
		end itemsPerPart, 
		case 
			when tt.PartSpecific = 0 and ti.Consumable = 1 then (Quantity * (AnnualVolume/12.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/12)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when ti.Consumable = 0 then ti.Quantity
		end MonthlyUsage,  
		case 
			when tt.PartSpecific = 0 and ti.Consumable = 1 then (ti.Quantity * (tm.AnnualVolume/365.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/365)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8))
			when ti.Consumable = 0 then ti.Quantity/30
		end DailyUsage  
		FROM [TOOLLIST ITEM] as ti 
		-- when a tool gets deleted the toollist item remains?
		inner join [TOOLLIST TOOL] as tt on ti.toolid=tt.toolid
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
		ON tt.PROCESSID = tm.PROCESSID 
		--30432
	union
		SELECT tm.originalprocessid, tm.processid,CribToolID as itemNumber, 
		0 as ToolID, 0 as ttpid, 0 as toolNumber,'Fixture' as OpDescription, 
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
		--1648
	union
		SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber, 
		0 as ToolID, 0 as ttpid, 0 as toolNumber,'Misc' as OpDescription, 
		m.itemid,m.tooltype,m.tooldescription,  
		Quantity,AnnualVolume,0 as AdjustedVolume,QuantityPerCuttingEdge,NumberOfCuttingEdges,
		'misc' as itemType, 0 as partspecific,m.Consumable, 
		case 
			when toolbossStock is null then 0
			when toolbossStock = 0 then 0
			when toolbossStock = 1 then 1
			else 0
		end as toolbossStock,
		case
			when (Quantity=0) or (NumberofCuttingEdges =0) or (QuantityPerCuttingEdge=0) or
			(Quantity is null) or (NumberofCuttingEdges is null) or (QuantityPerCuttingEdge is null)
				then 0
			when (Consumable = 1)
				then 1/((QuantityPerCuttingEdge/cast( quantity as numeric(19,8)))*NumberofCuttingEdges)
			when Consumable = 0 then 0.0
		end itemsPerPart, 
		case 
			when m.Consumable = 1 then (m.Quantity * (tm.AnnualVolume/12.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8))
			else m.Quantity
		end MonthlyUsage,  
		case 
			when m.Consumable = 1 then (m.Quantity * (tm.AnnualVolume/365.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			else m.Quantity/30
		end DailyUsage  
		FROM [ToolList Misc] as m 
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
		)  
		as tm 
		ON m.PROCESSID = tm.PROCESSID 
		--371
	--32571
	)lv1
	inner join 
	btDistinctToolLists tl
	on lv1.ProcessID=tl.processid
	--32571
)lv2
-- drop items that are not in the crib
inner join
toolitems ti
on lv2.itemNumber=ti.itemnumber
--32438;

select 
i.*
from 
(
		SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber,
		tt.ToolID, tt.processid as ttpid, tt.toolNumber,tt.OpDescription, 
		ti.itemid,ti.tooltype,ti.tooldescription,
		Quantity,
		AnnualVolume,
		AdjustedVolume,
		QuantityPerCuttingEdge,
		NumberOfCuttingEdges,
		'item' as itemType,partspecific,
		Consumable, 
		case 
			when toolbossStock is null then 0
			when toolbossStock = 0 then 0
			when toolbossStock = 1 then 1
			else 0
		end as toolbossStock,
		case
			when (Quantity=0) or (NumberofCuttingEdges =0) or (QuantityPerCuttingEdge=0) or
			(Quantity is null) or (NumberofCuttingEdges is null) or (QuantityPerCuttingEdge is null)
				then 0
			when (Consumable = 1)
				then 1/((QuantityPerCuttingEdge/cast( ti.quantity as numeric(19,8)))*NumberofCuttingEdges)
			when Consumable = 0 then 0.0
		end itemsPerPart, 
		case 
			when tt.PartSpecific = 0 and ti.Consumable = 1 then (Quantity * (AnnualVolume/12.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/12)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when ti.Consumable = 0 then ti.Quantity
		end MonthlyUsage,  
		case 
			when tt.PartSpecific = 0 and ti.Consumable = 1 then (ti.Quantity * (tm.AnnualVolume/365.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/365)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8))
			when ti.Consumable = 0 then ti.Quantity/30
		end DailyUsage  
		FROM [TOOLLIST ITEM] as ti 
		-- when a tool gets deleted the toollist item remains?
		inner join [TOOLLIST TOOL] as tt on ti.toolid=tt.toolid
		INNER JOIN 
		(
			-- these are the toollist which are added to the toolbosses
			select tm.* 
			from
			-- btDistinctToolLists tb
			bvDistinctToolLists tb
			inner join
			[ToolList Master] tm
			on tb.ProcessId=tm.ProcessID
			--731
		) as tm 
		ON tt.PROCESSID = tm.PROCESSID 
) i
inner join 
(
select  processid,partfamily from dbo.bfToolListsInPlant(11) 
where customer = 'JOHN DEERE'
) jd 
on i.processid=jd.processid

select tm.* 
from

bvDistinctToollists tb
-- btDistinctToolLists tb
inner join
[ToolList Master] tm
on tb.ProcessId=tm.ProcessID
inner join 
(
select  processid,partfamily from dbo.bfToolListsInPlant(11) 
where customer = 'JOHN DEERE'
) jd 
on tb.processid=jd.processid

--///////////////////////////////////////////////////////////////////////////////////
-- Generate Distinct ToolList table
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpDistinctToolLists] 
AS
BEGIN
	IF
	OBJECT_ID('btDistinctToolLists') IS NOT NULL
		DROP TABLE btDistinctToolLists
	select * 
	into btDistinctToolLists
	from bvDistinctToollists
end;

-- dbo.bvDistinctToolLists source

create view [dbo].[bvDistinctToolLists]
as
-- Remove duplicates only differing in plant
select OriginalProcessId,ProcessId,
Customer,PartFamily,OperationDescription,PartNumber,descript Description,descr CustPartFamily
from
bvToolListsInPlants
group by 
OriginalProcessId,ProcessId,
Customer,PartFamily,OperationDescription,PartNumber,Descript,descr;

SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(11) AS bfToolBossItemsInPlant_1
