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
