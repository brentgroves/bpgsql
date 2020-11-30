select * from dbo.bvToolBossRestrictions2 
where processid = 63647 -- 76

select distinct item from dbo.bvToolBossRestrictions2 
where processid = 63647 -- 38

select * from dbo.bvToolBossRestrictions2 
where job = 12818 -- 76

select distinct item from dbo.bvToolBossRestrictions2 
where job = 12818 -- 38


select count(*) from bvToolBossRestrictions2
SELECT count(*) from (  -- 548
select distinct processid,job from (
select [User],processid,Job,Machine,D_Consumer,item,D_Item,plant from dbo.bvToolBossItemsWithProcessId 
-- select count(*) from dbo.bvToolBossItemsWithProcessId 
-- select distinct job from dbo.bvToolBossItemsWithProcessId 
where processid in (63647,63649,63651,63653,63655,63657,63659) -- 548
)s1
-- WHERE     (r.R_JOB IN ('12818','12819', '12820', '12821', '12822', '12824', '12825'))  -- 236 in toolboss 3
select count(*) -- 274
from 
( 
select distinct [User],Job,Machine,D_Consumer,item,D_Item,plant from dbo.bvToolBossRestrictions2
where processid in (63647,63649,63651,63653,63655,63657,63659) -- 
and plant = 3
)s1

select count(*) -- 274
from 
( 
select distinct [User],Job,Machine,D_Consumer,item,D_Item,plant from dbo.bvToolBossRestrictions2
where processid in (63647,63649,63651,63653,63655,63657,63659) -- 
-- and job not in (12819, 12820, 12821, 12822, 12824, 12825)  --12818  
and plant = 3
)s1

12818	63647
12819	63649
12820	63651
12821	63653
12822	63655
12824	63657
12825	63659

select count(*) -- 1534
from 
( 
select distinct [User],Job,Machine,D_Consumer,item,D_Item,plant from dbo.bvToolBossRestrictions2
where job in (12865,
12866,
12867,
12868,
12826,
12831,
12842,
12818,
12843,
12819,
12844,
12820,
12845,
12821,
12846,
12822,
12847,
12824,
12848,
12825,
4312,
12827,
12830,
12832,
12864,
12911,
12833,
12912,
12834,
12913,
12835,
12914,
12836,
12869,
12837,
12870,
12838,
12874,
12839,
9023
) -- 
and plant = 3
)s1



select distinct [User],Job,Machine,D_Consumer,item,D_Item,plant from dbo.bvToolBossItemsWithProcessId 
where job = 


/*
 * Find the process id of the parts
 * 
 */
select * from [ToolList Master] 
where partFamily like '%501-1234-06%'
order by partfamily

-- where partFamily like '%0994%'
where processid = 63659
-- ﻿
COPELAND - 501-1234-06 K-BODY TEST 50TAPER - 63659

-- drop view bvToolBossRestrictions2
-- toollists items that have a category that is to be stocked in the toolbosses
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