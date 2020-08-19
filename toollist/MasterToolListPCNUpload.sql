/*
 * Used Plex supply list to make table in MasterToolList upload template format.
 * Uploaded to PlxMasterToolList table.
 * Join to bvToolListItemsInPlant view to filter Plex supply items that are not on active tool lists.
 * Join to bvToolBossItemsInPlant view to change PlxMasterToolList StorageLocation field to say 'Tool Boss'
 * for items in vending machines.
 */
select
itemNumber 
--count(*) cnt -- 888
from bvToolListItemsInPlants 
where plant = 12

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

-- Truncate table PlexMasterToolList
Bulk insert PlexMasterToolList
from 'c:\MasterToolListGT200.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)
/*
update dbo.PlexMasterToolList 
set Description = REPLACE(REPLACE(REPLACE(REPLACE(Description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13)),
Extra_Description = REPLACE(REPLACE(REPLACE(REPLACE(Extra_Description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13))
*/

-- 3397
select 
-- count(*) cnt  --321
p.itemNumber,
tl.*
--into dbo.PlexMasterToolListBak  If you have problems with import because of \n then restore this and change update statement above
from dbo.PlexMasterToolList tl
left outer join 
(
select itemNumber from 
 bvToolListItemsInPlants  where plant = '12'
) p
on tl.Tool_No=p.itemNumber 
 where Tool_No = 'BE206064'



