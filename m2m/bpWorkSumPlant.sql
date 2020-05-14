create procedure [dbo].[bpWorkSumPlant]
@startDateParam DATETIME,
@endDateParam DATETIME
AS
select * from  bfWorkSumLv6IJ(@startDateParam,@endDateParam)
order by fdept,partNumber;

--/////////////////////////////////////////////////////////////////////////
-- Use this query on the main report which will drop jobs with no tool cost
--////////////////////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv6IJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- summing the tool costs
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	EngToolAllowance,
	engToolCost, 
	ConsToolAllowance,
	ConsToolCost, 
	ActualToolAllowance, 
	actualToolCost, 
	case 
	when (actualToolCost = 0) then 0.0
	else ((ConsToolCost / actualToolCost) * 100)  
	end 
	as consumableVrsActualPct, 
	case 
	when (EngToolCost = 0) then 0.0
	else ((ConsToolCost / EngToolCost) * 100)  
	end 
	as actualVrsBudgetedPct, 
	case 
	when (valueAddedSales = 0) then 0.0
	else ((actualToolCost / totalValueAdd) * 100)  
	end 
	as actualVrsVaSalesPct 
	from
	(
		select * from  bfWorkSumLv5IJ(@startDateParam,@endDateParam)
		--12223
	) as lv5;

--/////////////////////////////////////////////////////////////////////
-- Sum of partNumber / itemNumber tool costs
-- Part/Item total cost has been calculated
-- BudgetPartItemTotCost has also been calculated for
-- consumable items
-- and part item records have been marked as consumable or not
-- partItemTotCost can be compared to BudgetPartItemTotCost
--/////////////////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv5IJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- Use this query on the main report which will drop jobs with no tool cost
	-- summing the tool costs
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript, 
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	case 
	when (pcsProduced = 0) then 0.0
	else sum(budgetPartItemTotCost) / pcsProduced
	end
	as EngToolAllowance,
	sum(budgetPartItemTotCost) as engToolCost, 

	case 
	when (pcsProduced = 0) then 0.0
	else sum(ConsPartItemTotCost) / pcsProduced
	end
	as ConsToolAllowance,
	sum(ConsPartItemTotCost) as ConsToolCost, 

	case
	when (pcsProduced = 0) then 0.0
	else sum(partItemTotCost) / pcsProduced
	end
	as ActualToolAllowance,
	sum(partItemTotCost) as actualToolCost 
	from
	(
		select * from  bfWorkSumLv4IJC(@startDateParam,@endDateParam)
	) as lv5
	GROUP BY 
	partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster
	
	--/////////////////////////////////////////////////////////////////////
-- Sum of partNumber / itemNumber tool costs
-- Part/Item total cost has been calculated
-- BudgetPartItemTotCost has also been calculated for
-- consumable items
-- and part item records have been marked as consumable or not
-- ConsPartItemTotCost is a sum of all consumable toollog entries
-- ConsPartItemTotCost can be compared to BudgetPartItemTotCost
-- and PartItemTotCost is the total actual toolcost
--/////////////////////////////////////////////////////////////////////
create FUNCTION [dbo].[bfWorkSumLv4IJC] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN

select lv4ijc.*, 
	case 
	when (ConsPartItemTotCost = 0) then 0.0
	else ((BudgetPartItemTotCost / ConsPartItemTotCost) * 100)  
	end budgetedVrsActualCost,
	case 
	when (BudgetPartItemTotCost = 0) then 0.0
	else ((ConsPartItemTotCost / BudgetPartItemTotCost ) * 100)  
	end ActualVrsBudgetedCost
from
(
	-- Use this query on the main report which will drop jobs with no tool cost
	select lv4ij.partNumber,lv4ij.itemNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,unitcost, 
	pcsProduced,
	valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	partItemTotQty, partItemTotCost, 
	-- identify items as consumable or not
	case 
		when itemsPerPart is null then 0 
		-- The toollist probably needs updated on these parts
		when itemsPerPart = 0 then 0 
		else 1 
	end
	as consumable,
	case 
		when toolDescript is null then 'No Desciption' 
		else toolDescript 
	end
	as toolDescript,
	case 
		when itemsPerPart is null then 0.0 
		else itemsPerPart 
	end
	as itemsPerPart,
	case 
		when toolOps is null then 'Not Found' 
		else toolOps 
	end
	as toolOps,
	case 
		when itemsPerPart is null then 0 
		else pcsProduced*itemsPerPart 
	end
	as bdgItemCnt,
	case
		when itemsPerPart is null then 0.0
		else (pcsProduced*itemsPerPart * unitCost)
	end
	as BudgetPartItemTotCost,
	case 
		-- if it is not consumable then
		-- we want to set this partItem 
		-- to $0
		when itemsPerPart is null then 0.0 
		when itemsPerPart = 0 then 0.0 
		else partItemTotQty 
	end
	as ConsPartItemTotQty,
	case 
		-- if it is not consumable then
		-- we want to set this partItem 
		-- to $0
		when itemsPerPart is null then 0.0 
		when itemsPerPart = 0 then 0.0 
		else partItemTotCost 
	end
	as ConsPartItemTotCost
	from 
	(
		select partNumber,lv4.itemNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
		m2mDescription,descript,unitCost,description1 toolDescript,
		pcsProduced,
		valueAddedSales,totalValueAdd,budgetedToolAllowance, 
		budgetedToolCost,NTLFlag,PartRevInItemMaster,
		partItemTotQty,
		partItemTotCost 
		from
		(
			select partNumber,itemNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
			m2mDescription,descript,unitCost,
			pcsProduced,
			valueAddedSales,totalValueAdd,budgetedToolAllowance, 
			budgetedToolCost,NTLFlag,PartRevInItemMaster,
			sum(toolItemIssueQty) partItemTotQty,
			sum(toolItemIssueTotCost) partItemTotCost 
			from bfWorkSumLv4IJ(@startDateParam,@endDateParam) 
			group by 
				partNumber, itemNumber,partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
				m2mDescription,descript,unitCost, 
				pcsProduced,
				valueAddedSales,totalValueAdd,budgetedToolAllowance, 
				budgetedToolCost,NTLFlag,PartRevInItemMaster
				--2379
		)lv4
		inner join
		toolitems ti
		on lv4.itemnumber= ti.itemnumber
		--2379
	)lv4IJ
	left outer join
	(
		-- All these items are marked as consumable on ToolList
		select partNumber,ipp.itemNumber,
		itemsPerPart,toolOps
		from btToolListPartItems ipp
		--7076
	)ip
	on lv4IJ.partNumber=ip.partNumber
	and lv4IJ.itemNumber=ip.itemNumber
	--2194
)lv4IJC;

	--231;
create FUNCTION [dbo].[bfWorkSumLv4IJ] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
m2mDescription,descript, 
pcsProduced,
valueAddedSales,totalValueAdd,budgetedToolAllowance, 
budgetedToolCost,NTLFlag,PartRevInItemMaster,
Plant,username,transTime,itemNumber,toolItemIssueQty,unitCost, 
cast(toolItemIssueQty*unitCost as decimal(18,2)) as toolItemIssueTotCost  
from
(
	select lv3.partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,descript,
	pcsProduced,valueAddedSales,totalValueAdd,budgetedToolAllowance, 
	budgetedToolCost,NTLFlag,PartRevInItemMaster,
	Plant,username,TranStartDateTime as transTime,
	itemNumber,
	case 
		when ToolLog.qty is null then cast(0.0 as decimal(18,2)) 
		else ToolLog.qty
	end 
	as toolItemIssueQty, 
	case 
		when ToolLog.unitCost is null then cast(0.0 as decimal(18,2)) 
		else ToolLog.unitCost
	end 
	as unitCost 
	from bfWorkSumLv3(@startDateParam,@endDateParam) lv3
	inner join			
	(
		select * from dbo.ToolingTransLog
		where dbo.ToolingTransLog.[TranStartDateTime] >= @startDateParam 
		and dbo.ToolingTransLog.[TranStartDateTime] <= @endDateParam 
	) ToolLog
	on lv3.partNumber = ToolLog.partNumber
) lv4
--12765;

create FUNCTION [dbo].[bfWorkSumLv3] (@startDateParam DATETIME,@endDateParam DATETIME) 
  RETURNS Table 
AS 
RETURN
	-- add totalValueAdd and budgetedToolCost
	select partNumber, partRev, maxJobNumber,maxOperNo, fpro_id, fdept,
	m2mDescription,	descript, pcsProduced,  
	valueAddedSales,
	cast(pcsProduced*valueAddedSales as decimal(18,2)) as totalValueAdd,
	budgetedToolAllowance, 
	cast(pcsProduced*budgetedToolAllowance as decimal(18,2)) as budgetedToolCost, 
	NTLFlag, 
	PartRevInItemMaster
	from
	(

		select * from  bfWorkSumLv2(@startDateParam,@endDateParam)
	)lv3
	--283;

create FUNCTION [dbo].[bfWorkSumLv2]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
-- use this function to sum all parts made in a specified time period
select partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription, tlDescription as descript, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,
sum(fcompqty) as pcsProduced  
from bfWorkSumLv1(@startDateParam,@endDateParam)
group by partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
	m2mDescription,tldescription,valueAddedSales,budgetedToolAllowance,NTLFlag, 
	PartRevInItemMaster;

create FUNCTION [dbo].[bfWorkSumLv1]
(  
@startDateParam DATETIME,
@endDateParam DATETIME
)
RETURNS TABLE 
AS
RETURN
select 
partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription,tlDescription, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 
from 
(
	select 
	p.partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
	m2mDescription,
	case
		when q.maxPartFamily is not null then q.maxPartFamily
		else p.m2mDescription 
	end
	as tlDescription, 
	valueAddedSales,budgetedToolAllowance,
	NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 
	from 
	(
		select 
		c.partNumber, mpi.partRev, mpi.maxJobNumber,mpi.maxOperNo,mpi.fpro_id,mpi.fdept,
		mpi.description as m2mDescription,
		valueAddedSales,budgetedToolAllowance,NTLFlag, 
		PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,c.fstatus  
		from
		(
			-- switch to part number because we will determine what job number to use later
			-- and never will want to use the one straight from the ladetail records
			select b.fpartno partNumber,a.fdate,a.fedatetime,a.fempno,a.fcompqty,a.fstatus
			from 
			(
				select lv3.fjobno,lv3.foperno,lv4.fdate,lv4.fedatetime,
					lv4.fempno,lv4.fcompqty,lv4.fstatus
				from
				(
					--> This is a list of job/operation numbers which we need to tally 
					--> pieces produced. If a labor detail has an operation besides these
					--> ones that means it was for a secondary operation.  We should only 
					--> total the max operation quantities to arrive at the pieces produced.
					--> It has been verified that lower operation ladetail records can have
					--> fcompqty > 0 so this step is needed.
					-->Get rid of lower operation numbers
					select fjobno, max(foperno) as foperno 
					from jodrtg 
					group by fjobno
					having fjobno <> ''
					-- 19792
				) lv3
				inner join
				(
					select fjobno,foperno,DATEADD(dd, 0 , DATEDIFF(DD, 0,  fedatetime)) as fdate,fedatetime,
					fempno,fcompqty,fstatus
					from ladetail 
					-- status = P is posted H is Hold
					where fstatus = 'P' 
					and fedatetime >= @startDateParam and fedatetime <= @endDateParam 
					and fcompqty <> 0.0
					-- 15951
				) lv4
				on lv3.fjobno = lv4.fjobno 
				and lv3.foperno = lv4.foperno
				--162328
				--15100
			) a
			inner join
			jomast b
			on a.fjobno = b.fjobno
			-- 15100
			--162328
		) c
		-- drop some tool grinding ladetail records
		inner join (
			select * from btM2mPartJobInfo
			--988
			where NTLFlag <> 999 
			--875
		) mpi
		on c.partNumber=mpi.partNumber
		-- we don't want labor details that do not have a dept attached to the max job op
		--159340 --dropped 3000 records 1 month because of found no max job op with a dept with that job.
		--14928  --dropped 180 records 1 month because of found no max job op with a dept with that job.  
	) p
	inner join 
	(
		select partNumber,max(custPartFamily) maxPartFamily from btDistinctToolLists
		group by partNumber
		--529
	) q
	on p.partNumber=q.partNumber
	-- we don't want labor details for part numbers with no tool list.
	--125483
	--14928
) r
--> delete duplicate records. Don't know why there are a few duplicates, but there are
group by 
partNumber, partRev, maxJobNumber,maxOperNo,fpro_id,fdept,
m2mDescription,tlDescription, valueAddedSales,budgetedToolAllowance,
NTLFlag,PartRevInItemMaster,fdate,fedatetime,fempno,fcompqty,fstatus 
--125427 
--14925;


-- m2mdata01.dbo.btM2mPartJobInfo definition

-- Drop table

-- DROP TABLE m2mdata01.dbo.btM2mPartJobInfo GO

CREATE TABLE m2mdata01.dbo.btM2mPartJobInfo (
	partNumber char(25) NOT NULL,
	partRev char(3),
	maxJobNumber char(10),
	maxOperNo int,
	fpro_id char(7) NOT NULL,
	fdept char(2) NOT NULL,
	description varchar(40),
	valueAddedSales numeric(18,2),
	budgetedToolAllowance numeric(18,2),
	NTLFlag numeric(15,5),
	PartRevInItemMaster int NOT NULL,
	fstatus char(10) NOT NULL
) GO;
