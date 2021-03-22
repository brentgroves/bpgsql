SELECT DISTINCT [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         bvToolBossRestrictions2
where job in (43114,9323)
-- where job in (43114) --40
--where job in (9323) --42
and item not in 
(
'0000466',
'0002005',
'0002008',
'0002022',
'0002144',
'0003087',
'0003224',
'0003417',
'0003611',
'0004082',
'0004556',
'0000466',
'0002005',
'0002008',
'0002022',
'0002144',
'0003087',
'0003224',
'0003417',
'0003611',
'0004082'
)
WHERE     (processid IN (63269,63270))


select * from bvToolBossJobList
where descr like '%TRX%CARRIER%'

originalprocessid|ProcessID|PartFamily            |OperationNumber|OperationDescription|Obsolete|Customer  
-----------------|---------|----------------------|---------------|--------------------|--------|----------
            43114|    49995|R559432 SCAVENGER PUMP|             60|MILL COMPLETE       |       0|JOHN DEERE

originalprocessid|ProcessID|PartFamily            |OperationNumber|OperationDescription|Obsolete|Customer  
-----------------|---------|----------------------|---------------|--------------------|--------|----------
             9323|    49716|R218919 SCAVENGER PUMP|             60|MILL COMPLETE       |       0|JOHN DEERE


SELECT     JobNumber, Descr, alias, Plant, CreatedBy, DATECREATED, DATELASTMODIFIED, LASTMODIFIEDBY, JOBENABLE, DATERANGEENABLE
FROM         dbo.bfGetToolBossJobList(112)
-- where descr like '%TRX%CARRIER%'
-- WHERE     (JobNumber IN (61866,61868))

/*
 * Only the OriginalProcessID get put in tool list.
 */
select * from bvToolBossJobList
where jobNumber in (43114,9323)


where plant = 112
and jobNumber in (49995,49716)

select * from bfGetToolBossJobList(112)

select * from bvToolBossJobList

where plant = @plant;


select * from bvToolListsInPlants
where processid in (49995,49716)
where partfamily like '%TRX%CARRIER%'

select * from bvToolListsAssignedPN
where processid in (49995,49716)
where partfamily like '%TRX%CARRIER%'

select * from bvListOfActiveApprovedToolLists
where processid in (49995,49716)
where partfamily like '%TRX%CARRIER%'

select  *
FROM   [ToolList PartNumbers]
where processid in (49995,49716)
--(
--select processid from bvListOfActiveApprovedToolLists
--where partfamily like '%TRX%CARRIER%'
--)
10115487
select  *
FROM   [ToolList PartNumbers]

/*
 * The 	[ToolList Plant] uses the toollist processid 
 */
 -- 
-- select * from
-- update 
[ToolList Plant] 
-- where plant = 112
-- set plant = 112
where processid in 
(49995,49716)

select distinct plant from [ToolList Plant]

/* 
 * The processid gets put in the [ToolList PartNumbers] table
 */
-- insert into [ToolList PartNumbers]
(ProcessID,PartNumbers)
values 
(63269,'10115487'),
(63270,'10115487')
select * from 
[ToolList PartNumbers]
where processid in 
(63269,63270)
()
select top 10 * from 
[ToolList PartNumbers]

/*
 * The originalprocessid gets put into the tool list
 */

select originalprocessid,processid,partfamily,operationnumber from [ToolList Master]
select * from [ToolList PartNumbers]
-- where originalprocessid in (
where processid in (
13886,
13887,
14197,
14199,
14201,
14578,
14985,
14989,
14990,
153,
15368,
15369,
15424
)
where partfamily like '%TRX%CARRIER%'

originalprocessid|processid|partfamily |operationnumber
-----------------|---------|-----------|---------------
            61866|    63269|TRX CARRIER|             60
            61868|    63270|TRX CARRIER|             70



-- dbo.bvToolListsAssignedPN source

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

-- dbo.bvToolListsInPlants source

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



exec bpDistinctToolLists
--///////////////////////////////////////////////////////////////////////////////////
-- Generate Distinct ToolList table
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpDistinctToolLists] 
AS
BEGIN
	IF
	OBJECT_ID('btDistinctToolLists') IS NOT NULL
		DROP TABLE btDistinctToolLists
	select * 
	into btDistinctToolLists
	from bvDistinctToollists
end;

select * from bvToolBossJobList
where plant = 9;

select * from bfGetToolBossJobList(9)
order by Descr

create PROCEDURE [dbo].[bpGetToolBossJobList] 
	-- Add the parameters for the stored procedure here
	@plant int
AS
BEGIN
select * from bfGetToolBossJobList(@plant)
order by Descr
END;

select * from bfGetToolBossJobList(112)

create FUNCTION [dbo].[bfGetToolBossJobList]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select * from bvToolBossJobList
where plant = @plant;

SELECT     JobNumber, Descr, alias, Plant, CreatedBy, DATECREATED, DATELASTMODIFIED, LASTMODIFIEDBY, JOBENABLE, DATERANGEENABLE
FROM         dbo.bfGetToolBossJobList(11-2)
order by descr
WHERE     (JobNumber IN (49396, 49265))


-- dbo.bvToolBossJobList source

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
		

-- dbo.bvToolListsInPlants source

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

select * from bvToolListsAssignedPN LV1
INNER JOIN
[ToolList Plant] AS tp 
ON lv1.ProcessID = tp.ProcessID		
where LV1.originalprocessid in (41365,41364)

where partNumber like '%R558149%'

Originalprocessid|processid
-----------------|---------
            41365|    63731
            41364|    62435
            
41365,41364 
63731,62435

SELECT     JobNumber, Descr, alias, Plant, CreatedBy, DATECREATED, DATELASTMODIFIED, LASTMODIFIEDBY, JOBENABLE, DATERANGEENABLE
FROM         dbo.bfGetToolBossJobList(8)
WHERE     (JobNumber IN (41365,41364))


SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(112) AS bfToolBossItemsInPlant_1


		