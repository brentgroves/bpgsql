declare @PCN int
set @PCN = 300758
declare @PartName varchar(50)
set @PartName = 'Sleeve - R568546 OP 10 Lathe'
declare @OperationKey int 
set @OperationKey = 7933023
exec MSCItemsToToolBOM @PCN,@PartName,@OperationKey 
-- drop procedure MSCItemsToToolBOM 
CREATE procedure MSCItemsToToolBOM 
@PCN int= 300758,
@PartName varchar(50) = 'Thermostat Cover - DZ107549',
@OperationKey int = 7895835
as
begin
	-- if there are leading zeros remove them by casting to int and append the 'R'
	-- the only rework items in the Albion VM do not have leading zeros as of 7/26/21
	-- so when joining the Plex.ToolBOM to MSC.items you must strip the leading zeros as 
	-- we do in the non-rework items.

select 
--distinct 
b.trm_toolno MSC#,
'''' + b.tool_no + ''''  item_no,
s.active,
b.tool_type_code,
b.tool_descr,
--i.VMID, 
@PartName part_name,
--'Thermostat Cover - DZ107549' part_name,
b.part_no,
b.assembly_no,
b.assy_descr
--select *
from 
(
	select  
	CASE 
	when CHARINDEX('R', b.tool_no) != 0 then cast(cast(replace(b.tool_no,'R','') as int) as varchar(50)) + 'R' 
	else cast(cast(b.tool_no as int) as varchar(50))  
	end trm_toolno, b.part_operation_key ,
	b.tool_no,b.part_no,b.operation_no,b.operation_code,
	b.assembly_no,b.assy_descr,b.tool_type_code, b.tool_descr,b.storage_location 
	from Plex.part_tool_BOM b
	where b.part_operation_key = @OperationKey
--	where b.part_operation_key = 7895835 --DZ107549
--	where b.part_operation_key = 7873443 -- 7873443	31X Bracket RH - 2017707
--	where b.part_operation_key = 7873452 -- 31X Bracket LH - 2017710
--	where b.part_operation_key = 7868688  -- JD Oil Filter Manifold
--	where b.part_operation_key = 7873079	 --'7873079	Drive Support - HXE66422	HXE66422
--	where b.part_operation_key = 7884545 --'51210T6N A000'  -- 35
	and b.storage_location = 'Tool Boss'
	and b.PCN = @PCN
--	AND b.tool_no like '%17137%'
) b 
left outer join 
(
 select distinct i.itemnumber from MSC.ItemSummary i 
 where i.pcn = @PCN

) i
--select * from AlbSPS.ItemSummary i where i.itemnumber='2021' --_tvmid = 5
on b.trm_toolno = i.ITEMNUMBER 
--where vmid = 5
left outer join Plex.purchasing_item_summary s 
--select * from Plex.purchasing_item_summary s where item_no like '%16007%'
on b.tool_no = s.item_no --48
where i.ITEMNUMBER is null
and s.pcn = @PCN

end

-- MissingMSCItems-Thermostat-Cover-DZ107549
select 
b.trm_toolno MSC#,
'''' + b.tool_no + ''''  item_no,
s.active,
b.tool_type_code,
b.tool_descr,
--i.VMID, 
--@PartName part_name,
'Sleeve - R568546 OP 20 Lathe' part_name,
b.part_no,
b.assembly_no,
b.assy_descr
--select *
from 
(
	select  
	CASE 
	when CHARINDEX('R', b.tool_no) != 0 then cast(cast(replace(b.tool_no,'R','') as int) as varchar(50)) + 'R' 
	else cast(cast(b.tool_no as int) as varchar(50))  
	end trm_toolno, b.part_operation_key ,
	b.tool_no,b.part_no,b.operation_no,b.operation_code,
	b.assembly_no,b.assy_descr,b.tool_type_code, b.tool_descr,b.storage_location 
	from Plex.part_tool_BOM b
	where b.part_operation_key = 7933024  -- JD Sleeve R568546 op 20
--	where b.part_operation_key = 7933023  -- JD Sleeve R568546 op 10
--	where b.part_operation_key = 7895835 --DZ107549
--	where b.part_operation_key = 7873443 -- 7873443	31X Bracket RH - 2017707
--	where b.part_operation_key = 7873452 -- 31X Bracket LH - 2017710
--	where b.part_operation_key = 7868688  -- JD Oil Filter Manifold
--	where b.part_operation_key = 7873079	 --'7873079	Drive Support - HXE66422	HXE66422
--	where b.part_operation_key = 7884545 --'51210T6N A000'  -- 35
	and b.storage_location = 'Tool Boss'
--	AND b.tool_no like '%17137%'
) b 
left outer join 
(
 select distinct i.itemnumber from MSC.ItemSummary i

) i
--select * from AlbSPS.ItemSummary i where i.itemnumber='2021' --_tvmid = 5
on b.trm_toolno = i.ITEMNUMBER 
--where vmid = 5
left outer join Plex.purchasing_item_summary s 
--select * from Plex.purchasing_item_summary s where item_no like '%6730%'
on b.tool_no = s.item_no --48
where i.ITEMNUMBER is null

 select i.itemnumber from MSC.ItemSummary i where i.ITEMNUMBER like '%673%'
/*
select * from Plex.part_tool_BOM
select i.itemnumber from AlbSPS.ItemSummary i where itemnumber like '%1651%'  -- '16516'
select * 
from AlbSPS.ItemSummary i 
--where i.ITEMNUMBER = '10111'
where i.ITEMNUMBER in ('16845','17292','17137')
and i.VMID = 5
*/
/*
select cast(cast(replace(b.tool_no,'R','') as int) as varchar(50)) trm_toolno, replace(b.tool_no,'R','') no_r_tool_no,b.tool_no,b.part_no,b.operation_no,b.operation_code,
b.assembly_no,b.assy_descr,b.tool_type_code, b.tool_descr,b.storage_location 
from Plex.part_tool_BOM b
where b.part_no = 'R568616'
--and b.tool_no in ('16845','17292','17137')
*/

