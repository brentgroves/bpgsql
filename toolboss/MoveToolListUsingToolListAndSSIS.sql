/*
 * Create set of jobs to add to tool boss from busche tool list.
 */

DECLARE	@return_value int
DECLARE @plant INT
set @plant = 11

-- jobNumber is OriginalProcessId
select char(39) + CAST(jobNumber as varchar(10)) + char(39) + ',', alias from bfGetToolBossJobList(@plant)
where alias like '001-0408%'
or alias like '001-0518%'
order by Descr

/*
 * Get jobs straight from the tool boss
 */
SELECT     JOBNUMBER, DESCR, ALIAS, JOBGROUP, JOBENABLE, DATERANGEENABLE, DATERANGEEND, DATERANGESTART, DATECREATED, CREATEDBY, 
                      DATELASTMODIFIED, LASTMODIFIEDBY
FROM         Jobs
WHERE     (JOBNUMBER IN (
'12857',
'13821',
'12858',
'12788',
'740',  
'12587',
'12859',
'12860',
'12861',
'2092', 
'12791',
'12593',
'12590',
'741'))

DECLARE	@return_value int
DECLARE @plant INT
set @plant = 11
-- jobNumber is OriginalProcessId
select CAST(jobNumber as varchar(10)) + ',', alias from bfGetToolBossJobList(@plant)
where alias like '001-0408%'
or alias like '001-0518%'
order by Descr

/*
 * Get restrictions from the source Tool Boss
 */
select * from dbo.btDistinctToolLists bdtl 
select count(*) from -- 579
(
SELECT DISTINCT [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bvToolBossRestrictions2
WHERE     (processid IN 
(  
63810,63811
)) AND (plant = 8)
)s1
/*
 * 	where ProcessId in (63810,63811)
	OriginalProcessId in (49396,49265)
SELECT DISTINCT [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bvToolBossRestrictions2
WHERE     (processid IN (63810,63811) AND (plant = 8))
SELECT DISTINCT [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bvToolBossRestrictions2
WHERE     processid IN (63810,63811)
WHERE     (processid IN (63810,63811) AND (plant = 8))



SELECT     COUNT(item) AS Expr1
FROM         (SELECT DISTINCT item
                       FROM          bvToolBossRestrictions2
                       WHERE      (processid IN (63810, 63811)) AND (plant = 8)) AS s1
 */
/*
 * Distinct count of items in tool lists to move
 */
select count(*) from -- 96
(
SELECT DISTINCT item
FROM         dbo.bvToolBossRestrictions2
WHERE     (Job IN (12857,
13821,
12858,
12788,
740,  
12587,
12859,
12860,
12861,
2092, 
12791,
12593,
12590,
741  )) AND (plant = 11)
)s1

/*
 * Where did the restrictions go?
 */

select * from bvToolListItemsInPlants
where originalProcessID in 
( 12857,
13821,
12858,
12788,
740,  
12587,
12859,
12860,
12861,
2092, 
12791,
12593,
12590,
741
)

/*
 * Can't find them with bvToolListItemsInPlants
 */



/*
 * What are the current processid
 */
select CAST(ProcessID as varchar(10)) + ',',* from [ToolList Master]
where originalProcessID in 
( 12857,
13821,
12858,
12788,
740,  
12587,
12859,
12860,
12861,
2092, 
12791,
12593,
12590,
741
)
order by partfamily

/*
 * Are they in ToolList Item under the current process id?
 */

select * from [ToolList Item]
where processid in 
(
63734,
63735,
63736,
63737,
63738,
63739,
63740,
63741,
63742,
63743,
63744,
63745,
63746,
63747
)

/*
 * Yes
 */


/*
 * Can we use bvToolListItemsInPlants using the processid
 */

select * from bvToolListItemsInPlants
where processid in 
(
63734,
63735,
63736,
63737,
63738,
63739,
63740,
63741,
63742,
63743,
63744,
63745,
63746,
63747
)

/*
 * NO
 */

/*
 * bvToolListsInPlants is working ok.
 */
select * 
from bvToolListsInPlants tl
where tl.processid in 
(
63734,
63735,
63736,
63737,
63738,
63739,
63740,
63741,
63742,
63743,
63744,
63745,
63746,
63747
)
/*
 * Yes it is
 */

/*
 * Is bvToolListItemsLv1 working
 */


select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
left outer join 
-- inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where tl.processid in 
(
63734,
63735,
63736,
63737,
63738,
63739,
63740,
63741,
63742,
63743,
63744,
63745,
63746,
63747
)

/*
 * NO it is not
 */

/*
 * How about btDistinctToolLists
 */

select tb.* 
from
btDistinctToolLists tb
where tb.processid in 
(
63734,
63735,
63736,
63737,
63738,
63739,
63740,
63741,
63742,
63743,
63744,
63745,
63746,
63747
)

/*
 * It needs to be regenerated
 */


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
select lv2.*
-- select lv2.*,ti.itemClass,ti.UDFGLOBALTOOL,ti.cost
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
where lv2.processid in 
(
63734,
63735,
63736,
63737,
63738,
63739,
63740,
63741,
63742,
63743,
63744,
63745,
63746,
63747
)


-- drop items that are not in the crib
inner join
toolitems ti
on lv2.itemNumber=ti.itemnumber
--32438;




select * from toolItems
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


create view dbo.bvToolBossRestrictions2
as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

	select processid,'$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
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


EXEC	@return_value = [dbo].[bpGetToolBossJobList] @plant

create PROCEDURE [dbo].[bpGetToolBossJobList] 
	-- Add the parameters for the stored procedure here
	@plant int
AS
BEGIN
select * from bfGetToolBossJobList(@plant)
order by Descr
END;

create FUNCTION [dbo].[bfGetToolBossJobList]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select * from bvToolBossJobList
where plant = @plant;

create view [dbo].[bvToolBossJobList]
as
		select 
		OriginalProcessID AS JobNumber, 
		subDescript as Descr, 
	--	SUBSTRING(Customer + ' - ' + PartFamily + ' - ' + OperationDescription, 1, 50) descript, 
		partNumber as alias, 
		Plant,
		'SSIS' AS CreatedBy, 
		'6/9/2011' AS DATECREATED, 
		'6/9/2011' AS DATELASTMODIFIED, 
		'SSIS' AS LASTMODIFIEDBY, 
		1 AS JOBENABLE, 
		0 AS DATERANGEENABLE
		from bvToolListsInPlants
		
		--803;
		
create VIEW [dbo].[bvToolListsInPlants]
AS
	select lv1.Originalprocessid,lv1.processid, 
		lv1.customer,lv1.partfamily,lv1.OperationDescription,
		lv1.descript,lv1.descr,	
		lv1.subDescript,lv1.subDescr,
		lv1.partNumber,tp.Plant 

	from
	( 
		select * from bvToolListsAssignedPN
		--732
	) lv1
	INNER JOIN
	[ToolList Plant] AS tp 
	ON lv1.ProcessID = tp.ProcessID;

create VIEW [dbo].[bvToolListsAssignedPN]
AS
		-- Pick only one part number for each active and approved toollist
		select lv1.Originalprocessid,lv1.processid, 
			customer,partfamily,OperationDescription,descript,descr,subDescript,subDescr,partNumber 
		from
		(
			select * from bvListOfActiveApprovedToolLists
			-- 733  
		) lv1
		inner join
		(
			-- Engineering sometimes adds more than one part number on a tool list
			-- we must pick one and drop the rest.  Tool lists with multiple Part numbers
			-- will show up on the Multi PN Tool List report. 
			select  ProcessID, MAX(PartNumbers) AS PartNumber
			FROM   [ToolList PartNumbers]
			GROUP BY ProcessID
		) lv2
		on lv1.ProcessID = lv2.ProcessID
		-- tool lists with no part numbers assigned have been dropped
		--732;

		select * from bvListOfActiveApprovedToolLists tl where tl.processid in (63734,63735,63736)
					select * from bvToolListsAssignedPN where processid in (63734,63735,63736)
		ProcessID|PartNumbers
---------|-----------
    63734|001-0408-04
    63735|001-0408-05
    63736|001-0408-06

    	select lv1.Originalprocessid,lv1.processid, 
		lv1.customer,lv1.partfamily,lv1.OperationDescription,
		lv1.descript,lv1.descr,	
		lv1.subDescript,lv1.subDescr,
		lv1.partNumber,tp.Plant 
		from
		( 
			select * from bvToolListsAssignedPN
			--732
		) lv1
		INNER JOIN
		[ToolList Plant] AS tp 
		ON lv1.ProcessID = tp.ProcessID
		 where lv1.processid in (63734,63735,63736)

	
	select  ProcessID, PartNumbers
			FROM   [ToolList PartNumbers] 
			where partnumbers like '%0408%'
			
			select * from bvListOfActiveApprovedToolLists
			where 
			
