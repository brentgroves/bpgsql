/*
 * Find originalprocessid, processid
 */
select * from [ToolList PartNumbers] m where PartNumbers like '%51393%'
select *
from bvToolListsInPlants tl
where plant = 8
--and tl.Originalprocessid = 40750
and partnumber like '%51393TJB%'

select * from [ToolList Toolboss Stock Items] tbs
--create view [dbo].[bvToolBossItemsInPlants] 
--as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

--	select '$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
select '(''' + itemnumber + '''),' 
	from
	(
			select originalprocessid,processid,descript,partNumber,plant,
			itemNumber,lv1.itemClass,UDFGLOBALTOOL,toolbossStock  
			from
			(
			/* Used for generating tool list item list */
				select '(''' + itemNumber + '''),' 
				from bvToolListItemsInPlants
				where processid =  40129
				and toolbossstock=0 and UDFGLOBALTOOL <> 'YES'-- 40
			/* Used for generating tool boss item list */
				select '(''' + itemNumber + '''),' -- 14
				from bvToolListItemsInPlants i
				inner join
				[ToolList Toolboss Stock Items] tbs
				on i.itemClass=tbs.ItemClass
				where processid =  40129 -- 33 --62372 -- 26
				and toolbossstock=0 and UDFGLOBALTOOL <> 'YES'-- 40
			/* Used for generating toolbossstock item list */
				select '(''' + itemNumber + '''),' -- 14
				from bvToolListItemsInPlants i
				where processid =  40129 
				and toolbossstock=1

				/* This is the actual sql for the original query. */
				-- select itemNumber from bvToolListItemsInPlants
				--where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
				-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA
			) lv1
			inner join
			[ToolList Toolboss Stock Items] tbs
			on lv1.itemClass=tbs.ItemClass
			-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA -- 19
			--14347
		union
			-- stocked in toolboss no matter the item
			-- class
			SELECT *
			from
			bvToolListItemsInPlants
			where toolbossstock=1 and UDFGLOBALTOOL <> 'YES'
			and processid = 40750  -- 0
		-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA			
			--17
		/* These are already in the Plex master tool list			
		union
			-- add these global items to all tool lists 
			select *
			from
			bvToolListItemsInPlants
			where UDFGLOBALTOOL = 'YES'
			*/
) lv2;

-- dbo.bvToolListItemsInPlants source

--///////////////////////////////////////////////////////////////////////////////
-- This view does not take into consideration the [ToolList Toolboss Stock Items]
-- table which lists the item classes to be stocked in the toolbosses. See
-- bvToolBossItemsInPlants to determine items to be stocked in the ToolBosses.
-- This list would be appropriate to list restrictions for the Cribmaster if you
-- grouped the recordset on all fields except plant.
--///////////////////////////////////////////////////////////////////////////////
--create view [dbo].[bvToolListItemsInPlants]
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

select * from toolitems

select count(*)
FROM 
(
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(8) AS bfToolBossItemsInPlant_1
where job IN (63810)
-- 14218|    14218 NEXTEER |26088054 ALUMINUM ASSEMBLY  -- No tool boss items
-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA
--185
)s1

select * from bvToolListItemsInPlants
where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
and processid = 14218

SELECT * FROM bvToolBossItemsInPlants
