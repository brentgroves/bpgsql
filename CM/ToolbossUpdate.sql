DECLARE	@return_value int
DECLARE @plant INT
set @plant = 11
select * from bfGetToolBossJobList(@plant)
where alias like '001-0408%'
or alias like '001-0518%'
order by Descr

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
			
