select count(*)
FROM 
(
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(8) AS bfToolBossItemsInPlant_1
where job IN (41365,41364)
--185
)s1


select count(*)
FROM 
(
SELECT     distinct item
FROM         dbo.bfToolBossItemsInPlant(8) AS bfToolBossItemsInPlant_1
where job IN (41365,41364)
--166
)s1

SELECT   distinct  [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(8) AS bfToolBossItemsInPlant_1
where job in (63731,62435)

where job IN (41365,41364)
-- dbo.bvToolBossItemsInPlants source

select * from bvToolListItemsInPlants
where job in (63731,62435)
where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
and processid = 12818

SELECT * FROM bvToolBossItemsInPlants

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
				and processid = 12818
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

select * from toolitems
