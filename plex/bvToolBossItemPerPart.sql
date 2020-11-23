create view [dbo].[bvToolBossItemsPerPart] 
as
-- toollists items that have a category that is to be stocked in the toolbosses
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
