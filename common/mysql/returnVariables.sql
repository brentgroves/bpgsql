CREATE DEFINER=`brent`@`%` PROCEDURE CompareContainerFetch (
	pStartDate DATETIME,
	pEndDate DATETIME,
	pLimit int,
	pSkip int,
	OUT pRecordCount INT 
)
BEGIN

	DECLARE startDate,endDate DATETIME;
	DECLARE startWeek,endWeek INT;

	set startDate =pStartDate;
	set endDate =pEndDate;

	select * from CompareContainer where transDate between pStartDate and pEndDate ORDER BY CompareContainer_Key LIMIT pLimit OFFSET pSkip;  
	-- select @pRecordCount := count(*) from CompareContainer where transDate between pStartDate and pEndDate;
	-- set pRecordCount = @pRecordCount;
	select count(*) 
	into pRecordCount
	from CompareContainer 
	where transDate between pStartDate and pEndDate;	

   	-- SELECT ROW_COUNT(); -- 0
   	-- set pRecordCount = FOUND_ROWS();
end;