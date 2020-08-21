/*
 * Used Plex supply list to make table in MasterToolList upload template format.
 * Uploaded to PlxMasterToolList table.
 * Join to bvToolListItemsInPlant view to filter Plex supply items that are not on active tool lists.
 * Join to bvToolBossItemsInPlant view to change PlxMasterToolList StorageLocation field to say 'Tool Boss'
 * for items in vending machines.
 */
/*
select
itemNumber 
--count(*) cnt -- 888
from bvToolListItemsInPlants 
where plant = 12
*/
/*
--drop table PlexMasterToolList
create table PlexMasterToolList
(
  Part_No	varchar (100),
  Tool_No	varchar (50),
  Drawing_No	varchar (50),
  Revision	varchar (50),
  Description	varchar (50),
  Extra_Description	varchar (200),
  Tool_Type	varchar (20), -- Tool_Type_Code in plex
  Tool_Group	varchar (5), -- Tool_Group_Code in plex
  Tool_Status	varchar (50), -- Description in plex
  Grade	varchar (40),
  Storage_Location	varchar (50),
  Min_Quantity	int,
  Tool_Life	int,
  
  Reworked_Tool_Life	int,
  Std_Reworks varchar (5), -- Maybe this is true or false for a reworked no,
  Action varchar(5), -- Not using
  Serialize int, -- 0 or 1, Only 0 for us
  
  Purchasing_Description varchar(5), -- Always blank in Alabama
  Tool_Product_Line	varchar (10), --Tool_Product_Line_Code in Plex
  Source	varchar (50), --Tool_Source in Plex
  Replenish_Quantity	int,
  Supplier_Code	varchar (25), -- The items that I uploaded included supply codes but the ones that others uploaded did not.
  Price	decimal (18,4),
  Accounting_Job_No	varchar (25),
  Customer_Code	varchar (35),
  Max_Recuts	int,
  Recut_Length	decimal (9,3),
  Recut_Unit	varchar (20),
  
  Auto_Pick	smallint,
  
  Storage_Section	varchar (50),
  Storage_Row	varchar (50),
  Storage_Rack	varchar (50),
  Storage_Rack_Side	varchar (50),
  Storage_Position	varchar (50),
  Tool_Dimensions	varchar (30), -- part_v_tool_attributes
  Tool_Weight	int, -- part_v_tool_attributes
  Output_Per_Cycle	int,  -- part_v_tool_attributes
  Design_Cycle_Time	int,  -- part_v_tool_attributes
  Press_Size	varchar (25),	-- part_v_tool_attributes
  Data_Date	datetime 
)
*/
/*
-- Truncate table PlexMasterToolList
-- Bulk insert PlexMasterToolList
from 'c:\MasterToolListFromAlbion.csv'  -- 181
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)
select count(*) from 
(
select distinct tool_no from dbo.PlexMasterToolList -- 502,  321
)s1  -- 502
*/
/*
update dbo.PlexMasterToolList 
set Description = REPLACE(REPLACE(REPLACE(REPLACE(Description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13)),
Extra_Description = REPLACE(REPLACE(REPLACE(REPLACE(Extra_Description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13))
*/

/*
 * Are we missing any supply items in Plex 
 */
-- 3397
/*
select 
count(*) cnt  --321
--tl.Tool_No,
-- char(39) + p.itemNumber + char(39) + ','
--tl.*
--into dbo.PlexMasterToolListBak  If you have problems with import because of \n then restore this and change update statement above
from
(
	select itemNumber from 
 	bvToolListItemsInPlants  where plant = '12'  -- 993
) p
left outer join PlexMasterToolList tl
on p.itemNumber = tl.Tool_No  -- 504
--where tl.Tool_No is not null  -- 993
where tl.Tool_No is null  -- 0 

select count(*) cnt 
from dbo.PlexMasterToolList p -- 502

select count(*) cnt 
from 
(
  select distinct itemnumber from bvToolListItemsInPlants where plant = '12'
)s1  -- 357	

select count(*) cnt 
from dbo.PlexMasterToolList p -- 502
inner join
(
  select distinct itemnumber from bvToolListItemsInPlants where plant = '12'
)tl  -- 357	
on p.Tool_No = tl.ItemNumber  -- 357


select count(*)cnt
from 
(
  select distinct itemnumber from bvToolListItemsInPlants where plant = '12'
)tl  -- 357	
inner join 
(
	select distinct item from bvToolBossItemsInPlants where plant = '12'  -- 512
)tb -- 164
on tl.itemnumber=tb.item 
*/
/*
 * How many tool lists
 */
/*
select distinct processid from 
 	bvToolListItemsInPlants  where plant = '12'  -- 30
*/
/*
select distinct itemnumber 
into btToolListItemsInPlant12  -- 357
from bvToolListItemsInPlants where plant = '12' 	

select distinct item 
into btToolBossItemsInPlant12  -- 164
from bvToolBossItemsInPlants where plant = '12'  -- 512
 	*/
-- select char(39) + Tool_No + char(39) + ','
-- select count(*) cnt
-- select p.tool_no,l.item_no,p.Storage_Location,l.Storage_Location EdonStorage_Location
-- select count(*)
select 
Part_No
,Tool_No
,Drawing_No
,Revision
,Description
,Extra_Description  
,Tool_Type
,Tool_Group
,Tool_Status
,Grade
,Storage_Location
,Min_Quantity
,Tool_Life
,Reworked_Tool_Life
,Std_Reworks
,Action
,Serialize
,Purchasing_Description
,Tool_Product_Line
,Source
,Replenish_Quantity
,Supplier_Code
,Price
,Accounting_Job_No
,Customer_Code
,Max_Recuts
,Recut_Length
,Recut_Unit
,Auto_Pick
,Storage_Section
,Storage_Row
,Storage_Rack
,Storage_Rack_Side
,Storage_Position
,Tool_Dimensions
,Tool_Weight
,Output_Per_Cycle
,Design_Cycle_Time
,Press_Size
,Data_Date
from 
(
	select 
	Row_No
	,Part_No
	,Tool_No
	,Drawing_No
	,Revision
	,Description
	,Extra_Description  
	,case 
	when Tool_Type = 'Tap' then 'Taps'
	when Tool_Type = 'Collets' then 'Collet'
	when Tool_Type = 'Fixture Comp.' then 'Fixture Components'
	when Tool_Type = 'Screw' then 'Insert Screw'
	when Tool_Type = 'Arbor' then 'Arbor Spacer'
	when Tool_Type = 'Probe Tip' then 'Probe'
	else Tool_Type 
	end Tool_Type
	,Tool_Group
	,Tool_Status
	,Grade
	,case 
		when s1.item is not null then 'Tool Boss'
		else s1.Storage_Location 
	end Storage_Location
	,Min_Quantity
	,Tool_Life
	,Reworked_Tool_Life
	,Std_Reworks
	,Action
	,Serialize
	,Purchasing_Description
	,Tool_Product_Line
	,Source
	,Replenish_Quantity
	,Supplier_Code
	,Price
	,Accounting_Job_No
	,Customer_Code
	,Max_Recuts
	,Recut_Length
	,Recut_Unit
	,Auto_Pick
	,Storage_Section
	,Storage_Row
	,Storage_Rack
	,Storage_Rack_Side
	,Storage_Position
	,Tool_Dimensions
	,Tool_Weight
	,Output_Per_Cycle
	,Design_Cycle_Time
	,Press_Size
	,Data_Date
	from
	( 	
		select 
		row_number() OVER(ORDER BY tool_no ASC) AS Row_No,
		* 
		-- select count(*) cnt
		from  PlexMasterToolList p	--502
		inner join btToolListItemsInPlant12 tl 
		on p.Tool_No = tl.ItemNumber  -- 357
		left outer join 
		btToolBossItemsInPlant12 tb
		on tl.itemnumber=tb.item  -- 357 
		where p.Tool_No not in	
		(
		'0000138',
		'0000480',
		'0000602',
		'0000959',
		'0001556',
		'0002008',
		'0002021',
		'0002441',
		'0003107',
		'0003144',
		'0003224',
		'0003262',
		'0003397',
		'0003458',
		'0003600',
		'0003607',
		'0004003',
		'0005203',
		'007396',
		'007398',
		'007811',
		'008009',
		'008343',
		'008672',
		'010463',
		'010560',
		'010602',
		'010695',
		'011050',
		'13024',
		'15640',
		'15653',
		'15683',
		'16128',
		'16276',
		'16277',
		'16278',
		'16279',
		'16282',
		'16293',
		'16303',
		'16304',
		'16309',
		'16572',
		'16646',
		'16676',
		'16677',
		'16678',
		'16679',
		'16705',
		'16706',
		'16707',
		'16718',
		'16719',
		'16720',
		'16721',
		'16722',
		'16723',
		'16725',
		'16726',
		'16727',
		'16730',
		'16770',
		'16771',
		'16773',
		'16775',
		'16777',
		'17061',
		'17071',
		'17072',
		'17114'	
		)
	)s1
)p  -- 286
--where p.Row_No <= 200
where p.Row_No > 200

-- inner join EdonLocation l 
--  p.tool_no=l.item_no
-- where p.Storage_Location is null  -- 9
-- where p.Storage_Location = ''  -- 0
-- where p.Storage_Location <> ''  -- 277
 -- where p.Storage_Location = 'Tool Boss'  -- 132

-- where p.Storage_Location = l.Storage_Location  64
-- where p.Storage_Location <> 'Tool Boss' and p.Storage_Location <> l.Storage_Location
-- where substring(Storage_Location,1,2) not in ('12','To')  -- 73
 
--s2.Row_No <= 200
-- and s2.Location like '%Too%'
-- and rtrim(ltrim(substring(Storage_Location,1,2))) = 'To'
-- substring(Storage_Location,1,2) in ('12','To')  -- 204
/*
create table EdonLocation
(
  item_no	varchar (50),
  Storage_Location	varchar (50)
)

Bulk insert EdonLocation
from 'c:\EdonItemLocations.csv'  -- 181
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select * 
select count(*)

from EdonLocation l  -- 121
inner join dbo.PlexMasterToolList p -- 121
on l.item_no=p.Tool_No -- 
*/




