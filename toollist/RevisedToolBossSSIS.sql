/*
 * All ToolBoss Jobs in Plant 9B toolboss
 */

select * from dbo.btJobNumbersIn9B -- 111

/*
 * Import these into SPS jobs table
 */
select JobNumber,Descr,alias,112 as Plant, CreatedBy,DATECREATED,DATELASTMODIFIED,LASTMODIFIEDBY,JOBENABLE,DATERANGEENABLE 
from btJobsIn9B  -- 111
where jobNumber in (43114,9323)

/*
 * Copy restrictions into Plant 9B ToolBoss
 */
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, 112 as plant 
into btToolBoss9BRestrictions
from bvToolBossItemsInPlants
where job in 
(
select * from btJobNumbersIn9B
)
group by [User], Job, Machine, D_Consumer, item, D_Item

select [User], Job, Machine, D_Consumer, item, D_Item, plant 
from btToolBoss9BRestrictions
-- 2274

select count(*) cnt from ( 
select distinct job,item
-- * 
from btToolBoss9BRestrictions
)s1 -- 2274

SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(112) AS bfToolBossItemsInPlant_1

