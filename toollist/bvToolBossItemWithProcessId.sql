select * from dbo.bvToolBossItemsWithProcessId 
where processid = 63659  -- 76

select count(*) from dbo.bvToolBossItemsWithProcessId 
select [User],Job,Machine,D_Consumer,item,D_Item,plant from dbo.bvToolBossItemsWithProcessId 
where processid in (63647,63649,63651,63653,63655,63657,63659) -- 548

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

-- toollists items that have a category that is to be stocked in the toolbosses
create view dbo.bvToolBossItemsWithProcessId
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