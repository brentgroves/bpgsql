
-- -- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
select count(*)
from dbo.PlexToolBOMAvilla -- 1291

-- select * from PlexToolBOM0910B

-- truncate table PlexToolBOMAvilla
-- drop table PlexToolBOMAvilla
create table PlexToolBOMAvilla
(
	Assembly_No	varchar (50), --Assembly No,
	Part_No	varchar (100), --Part No,
	Part_Revision	varchar (8), --Part Revision,
	Operation_Code	varchar (30), --Operation_Code in Plex
	Tool_No	varchar (50),
	Qty int, -- Plex decimal (18,2) Quantity_Required
	Matched_Set varchar(5),
	Station varchar(5),
	Optional varchar(5),
	Workcenter varchar(5),
	Sort_Order int
)
-- select top 10 * from  bvToolListItemsInPlants inner join [ToolList
/*
 * First insert ToolList Items
 */
insert into dbo.PlexToolBOMAvilla (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
-- select count(*) from (
	select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from 
	(
		select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation Operation_Code,
		-- select * from TL_Plex_PN_Op_Map
		-- select * from TL_Plex_PN_Map
		-- select top 10 * from bvToolListsInPlants tl
		lv1.itemNumber Tool_No, lv1.Quantity Qty,
		-- select Matched_Set_Key from part_v_tool_BOM where Matched_Set_Key is not null  -- 0
		'' Matched_Set,
		-- select Station_Key from part_v_tool_BOM where Station_Key is not null  -- 0
		'' Station,
		-- select Optional from part_v_tool_BOM where Optional <> 0  -- 0
		'' Optional,
		-- select Workcenter_Key from part_v_tool_BOM where Workcenter_Key is not null  -- 0
		'' Workcenter,
		-- select Sort_Order from part_v_tool_BOM where Sort_Order <> 0  -- 0
		0 Sort_Order
		-- select count(*) cnt
		from PlexToolListAssemblyTemplateAvilla a  -- 359 
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolID=lv1.ToolID  -- 1168
		-- where a.processid <> 61258  -- 1090 LC5C 5K651 CE 'LC5C 5K651 CE' this part_no had dashes originally until i remapped it.
		-- AFTER I UPDATE btDistinctToolList this count jumped to 1133
		-- select * from [Toollist Master] tm where tm.processid = 61258 -- LC5C-5K651-CC CD6 CONTROL ARM
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	-- THERE ARE DUPS BECAUSE MULTIPLE CNC OPERATIONS MAP TO A SINGLE PLEX OPERATION AND HAVE THE SAME TOOLNUMBER.
-- )s2  -- 1171
-- having Part_No = '26090196'
-- where a.Operation <> 'Machine Complete'

	/*
	 * Test regular items only
	 */
	select count(*) cnt from PlexToolBOMAvilla -- 1171
	-- select * from PlexToolBOMAvilla where tool_no  = '14758'
	where Part_No != '28245973' -- 1198
	where Part_No = '26090196' 
	-- where tool_no = '16219'
	-- where Part_No = '28245973' -- 93
	and Assembly_No like '%T01%3RD%'
	order by Assembly_No,Part_No,Tool_No 

	select tm.processid,tm.PartFamily,tm.OperationDescription,tt.ToolNumber,tt.OpDescription
	,tt.ToolID,ti.CribToolID,ti.ToolType,ti.Manufacturer
	from [Toollist Master] tm
	inner join [Toollist Partnumbers] pn 
	on tm.processid=pn.processid
	inner join [ToolList Tool] tt  
	on tm.processid = tt.ProcessID  -- 1 to many
	inner join [TOOLLIST ITEM] as ti 
	-- when a tool gets deleted the toollist item remains?
	on ti.toolid=tt.toolid  -- 1 to many
	-- where PartNumbers = '26090196L'
	-- where tm.ProcessID = 62568  -- 1ST OP LATHE
	-- where tm.ProcessID = 56675  -- 2ND OP LATHE
	 where tm.ProcessID = 56673  -- 3RD OP MILL
	and tt.ToolNumber = 1
	order by tm.OperationDescription,ti.CribToolID	-- 72
	/*
	 where tm.ProcessID = 56673  -- 3RD OP MILL
	and tt.ToolNumber = 1
370944|0003966 
370944|0005114 
370944|0005495 
370944|006829  
370944|006830  
370944|006831  
370944|006832  
370944|006833  
370944|006839  
370944|007052  
370944|007106  
370944|007319  
370944|007320  */

	where tm.ProcessID = 61581  -- 1ST OP LATHE
	-- where tm.ProcessID = 62019 -- 2ND OP LATHE
	-- where tm.ProcessID = 56679 -- 3RD OP MILL
	-- where tm.ProcessID in (56679,62019,61581)  -- 72
	and tt.toolid = 384818
	-- and tt.ToolNumber = 1
	order by tm.OperationDescription,ti.CribToolID	-- 72
	/*
	where tm.ProcessID = 61581  -- 1ST OP LATHE
	and tt.ToolNumber = 1
FACE AND FINISH OD|384818|0002445  
FACE AND FINISH OD|384818|0003730  
FACE AND FINISH OD|384818|0003881  
FACE AND FINISH OD|384818|0003882  
FACE AND FINISH OD|384818|0003883  
FACE AND FINISH OD|384818|16219    	
*/
select * from bvToolListItemsOnlyLv1	where processid = 61581 
and toolid = 384818
and toolNumber = 1 order by itemNumber 
select a.processid,a.toolid, a.toolnumber from PlexToolListAssemblyTemplateAvilla a  where processid = 61581 and a.toolid = 384818 order by a.ToolNumber 

select *
from PlexToolListAssemblyTemplateAvilla a  -- 359 
-- select * from PlexToolListAssembly a	
inner join bvToolListItemsOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
on a.processid=lv1.processid   -- 1 to many
and a.ToolID=lv1.ToolID 
-- where processid = 61581 and toolid = 384818
where a.processid = 61581 
 and a.toolid = 384818
order by itemNumber 

	/*
	where tm.ProcessID = 62019 -- 2ND OP LATHE
	and tt.ToolNumber = 1
TURN GEAR OD ROUGH FACE/OD|389928|0002445 
TURN GEAR OD ROUGH FACE/OD|389928|0003730 
TURN GEAR OD ROUGH FACE/OD|389928|0003881 
TURN GEAR OD ROUGH FACE/OD|389928|0003882 
TURN GEAR OD ROUGH FACE/OD|389928|0003883 
TURN GEAR OD ROUGH FACE/OD|389928|17232   	
*/	

/*
	where tm.ProcessID = 62019 -- 3RD OP LATHE
	and tt.ToolNumber = 1
MILL OUTSIDE TEETH AND KEYWAY|370967|0003966
MILL OUTSIDE TEETH AND KEYWAY|370967|0005114
MILL OUTSIDE TEETH AND KEYWAY|370967|0005495
MILL OUTSIDE TEETH AND KEYWAY|370967|006829 
MILL OUTSIDE TEETH AND KEYWAY|370967|006830 
MILL OUTSIDE TEETH AND KEYWAY|370967|006831 
MILL OUTSIDE TEETH AND KEYWAY|370967|006832 
MILL OUTSIDE TEETH AND KEYWAY|370967|006833 
MILL OUTSIDE TEETH AND KEYWAY|370967|006839 
MILL OUTSIDE TEETH AND KEYWAY|370967|007052 
MILL OUTSIDE TEETH AND KEYWAY|370967|007106 
MILL OUTSIDE TEETH AND KEYWAY|370967|007319 
MILL OUTSIDE TEETH AND KEYWAY|370967|007320 	
 */	
	
	/*
	where tm.ProcessID = 61581  -- 1ST OP LATHE
	and tt.ToolNumber = 9
THREAD I.D.-CELL 2     |384822|006825  
THREAD I.D.-CELL 2     |384822|007497  
THREAD I.D.-CELL 2     |384822|007681  
ROUGH DRILL HOLE-CELL 3|384817|011756  
ROUGH DRILL HOLE-CELL 3|384817|011812  
ROUGH DRILL HOLE-CELL 3|384817|14350   
 * */	
	
/*
	where tm.ProcessID = 62019 -- 3RD OP LATHE
	and tt.ToolNumber = 11
 */	

	/*
	where tm.ProcessID = 62019 -- 2ND OP LATHE
	and tt.ToolNumber = 11
 */	

	/*
	where tm.ProcessID = 61581  -- 1ST OP LATHE
	and tt.ToolNumber = 11
	passed
OpDescription          |ToolID|CribToolID
-----------------------|------|----------
THREAD I.D.-CELL 3     |384816|006825    
THREAD I.D.-CELL 3     |384816|007497    
THREAD I.D.-CELL 3     |384816|007681    
ROUGH DRILL HOLE-CELL 2|384823|011756    
ROUGH DRILL HOLE-CELL 2|384823|011812    
ROUGH DRILL HOLE-CELL 2|384823|14350     
 */	
	/*
	-- where tm.ProcessID = 56679 -- 3RD OP MILL
	toolNumber = 1
	-- passed
0003966   
0005114   
0005495   
006829    
006830    
006831    
006832    
006833    
006839    
007052    
007106    
007319    
007320    
	 */
	/*
	where tm.ProcessID = 62019 -- 2ND OP LATHE
	toolNumber = 1
	passed
0002445
0003730
0003881
0003882
0003883
17232  
	 */
	/*
	where tm.ProcessID = 61581  -- 1ST OP LATHE
	toolNumber = 1
	passed
0002445
0003730
0003881
0003882
0003883
16219  	
	*/
	 */
	
	-- where tl.ProcessID = 56679  -- Machine Complete
-- where tl.ProcessID = 62019 -- Machine B - WIP
where tl.ProcessID = 61581 -- Machine B - WIP

	
/*
 * 2nd insert ToolList Fixture items
 */
insert into dbo.PlexToolBOMAvilla(Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)

-- select count(*) from (
	select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from 
	(
		select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation Operation_Code,
		-- select * from TL_Plex_PN_Op_Map
		-- select * from TL_Plex_PN_Map
		-- select top 10 * from bvToolListsInPlants tl
		lv1.itemNumber Tool_No, lv1.Quantity Qty,
		-- select Matched_Set_Key from part_v_tool_BOM where Matched_Set_Key is not null  -- 0
		'' Matched_Set,
		-- select Station_Key from part_v_tool_BOM where Station_Key is not null  -- 0
		'' Station,
		-- select Optional from part_v_tool_BOM where Optional <> 0  -- 0
		'' Optional,
		-- select Workcenter_Key from part_v_tool_BOM where Workcenter_Key is not null  -- 0
		'' Workcenter,
		-- select Sort_Order from part_v_tool_BOM where Sort_Order <> 0  -- 0
		0 Sort_Order
		-- select count(*) cnt
		from PlexToolListAssemblyTemplateAvilla a  -- 367
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsFixtureOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolNumber=lv1.ToolNumber  -- 30; = 111111
		-- where a.processid <> 61258  -- 30
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
-- )s2  -- 94 + 1171 

select count(*) cnt from PlexToolBOMAvilla -- 1265

select * from PlexToolBOMAvilla 
where Part_No = '28245973' -- 93
and Assembly_No like '%3RD%'
-- and Assembly_No like '%TF%1ST%'
order by Assembly_No,Part_No,Tool_No 

/*
-- where tf.ProcessID = 61581  -- 1ST OP LATHE
007947 
009386 
009411 
010189 
13728  
*/

/*
-- where tm.ProcessID = 62019 -- 2ND OP LATHE
007947 
009453 
009890 
010589 
*/

/*
-- where tm.ProcessID = 56679 -- 3RD OP MILL
0004752 
0004792 
007260  
14792   
15517   
15947   
*/
select tm.processid,tm.PartFamily,tm.OperationDescription,tf.CribToolID,tf.ToolType,tf.Manufacturer
from [Toollist Fixture] tf
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
 where tf.ProcessID = 61581  -- 1ST OP LATHE
-- where tm.ProcessID = 62019 -- 2ND OP LATHE
-- where tm.ProcessID = 56679 -- 3RD OP MILL
-- where tm.ProcessID in (56679,62019,61581)  -- 72
-- and tt.ToolNumber = 1
order by tf.CribToolID	-- 72


/*
 * 3rd insert ToolList Misc items
 */
insert into dbo.PlexToolBOMAvilla (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)

-- select count(*) from (
	select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from 
	(
		select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation Operation_Code,
		-- select * from TL_Plex_PN_Op_Map
		-- select * from TL_Plex_PN_Map
		-- select top 10 * from bvToolListsInPlants tl
		lv1.itemNumber Tool_No, lv1.Quantity Qty,
		-- select Matched_Set_Key from part_v_tool_BOM where Matched_Set_Key is not null  -- 0
		'' Matched_Set,
		-- select Station_Key from part_v_tool_BOM where Station_Key is not null  -- 0
		'' Station,
		-- select Optional from part_v_tool_BOM where Optional <> 0  -- 0
		'' Optional,
		-- select Workcenter_Key from part_v_tool_BOM where Workcenter_Key is not null  -- 0
		'' Workcenter,
		-- select Sort_Order from part_v_tool_BOM where Sort_Order <> 0  -- 0
		0 Sort_Order
		-- select count(*) cnt
		from PlexToolListAssemblyTemplateAvilla a  -- 367
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsMiscOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolNumber=lv1.ToolNumber  -- 9
		-- where a.processid <> 61258  -- 9
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
 -- )s2  -- 26

	
select count(*) cnt from PlexToolBOMAvilla -- 1291

select * from PlexToolBOMAvilla 
where Part_No = '28245973' -- 72
and Assembly_No like '%TM%3RD%'
order by Assembly_No,Part_No,Tool_No 

/*
-- where tf.ProcessID = 61581  -- 1ST OP LATHE
1ST OP LATHE        |007852
*/

/*
-- where tm.ProcessID = 62019 -- 2ND OP LATHE
2ND OP LATHE        |007852
*/

/*
-- where tm.ProcessID = 56679 -- 3RD OP MILL
3RD OP MILL         |006986  
3RD OP MILL         |009996  
3RD OP MILL         |009997  
3RD OP MILL         |010144  
*/
select tm.processid,tm.PartFamily,tm.OperationDescription,m.CribToolID,m.ToolType,m.Manufacturer
from [Toollist Misc] m
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
ON m.PROCESSID = tm.PROCESSID 
-- where m.ProcessID = 61581  -- 1ST OP LATHE
-- where tm.ProcessID = 62019 -- 2ND OP LATHE
 where tm.ProcessID = 56679 -- 3RD OP MILL
-- where tm.ProcessID in (56679,62019,61581)  -- 72
-- and tt.ToolNumber = 1
order by m.CribToolID	-- 72

select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
FROM 
(
	select 
	ROW_NUMBER() OVER (
		ORDER BY part_no,operation_code,assembly_no
	) row_number,
	
	Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from dbo.PlexToolBOM b
) s1 
order by Assembly_No,Part_No,Tool_No 
where Tool_No in ('16793')
and Part_No = 'W11033021'

