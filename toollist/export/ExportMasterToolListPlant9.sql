select * 
--into dbo.btJobsIn9BBAK 
from dbo.btJobsIn9B 
--truncate table dbo.btJobsIn9BBAK
select * from dbo.btJobsIn9BBAK
/*
 * Find originalprocessid, processid
 */
select * from [ToolList PartNumbers] m where PartNumbers like '%51393%'
select *
from bvToolListsInPlants tl
where plant = 8
--and tl.Originalprocessid = 40750
and partnumber like '%51393TJB%'

select * from [ToolList Toolboss Stock Items] tbs
--create view [dbo].[bvToolBossItemsInPlants] 
--as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

--	select '$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
select '(''' + itemnumber + '''),' 
	from
	(
	
	create procedure Kors.destinations_get(
 @PCN int,
 @Level int,
 @Destinations varchar(1000) OUTPUT
)
as
begin
	
declare @x xml;

select @x=(
select
--',' +
/* Debug section
n.notify_level,
--n.email_check,
case 
when n.email_check = 0 then cast (r.shift_std as varchar) 
else 'N/A'
end shift,
r.[position],r.dept_name,r.last_name,
*/ 
CASE 
when n.email_check = 0 then ' Lv' + cast(n.notify_level as varchar) + '-Shift' + cast(r.shift_std as varchar) + '-' + left(r.first_name,1) + r.last_name + '-2604380796@vtext.com' + CHAR(13) + CHAR(10) -- r.SMS
else ' Lv' + cast(n.notify_level as varchar) + '-' + left(r.first_name,1) + r.last_name + '-' + '2604380796@vtext.com,' + r.email + CHAR(13) + CHAR(10)
end --notify
from Kors.notification n
--from Kors.notification_test1 n
inner join Kors.recipient r 
on n.pcn=r.pcn
and n.customer_employee_no=r.customer_employee_no
where n.notify_level = @Level
and 
(
	n.pcn = @PCN
	or r.last_name = 'Kenrick'
)
order by n.notify_level,n.email_check,r.shift_std,r.[position],r.dept_name, r.last_name 

for xml path(''),type);
select @Destinations=(@x.value('(./text())[1]','nvarchar(max)'));
--select len(@x.value('(./text())[1]','nvarchar(max)')) j  -- 834
--   SET @Destinations='SOME VALUE';
   RETURN 0;
end;

			select originalprocessid,processid,descript,partNumber,plant,
			itemNumber,lv1.itemClass,UDFGLOBALTOOL,toolbossStock  
			from
			(
			/* Used for generating tool list item list */
				select '(''' + itemNumber + '''),' 
				from bvToolListItemsInPlants
				where processid =  62158
				and toolbossstock=0 and UDFGLOBALTOOL <> 'YES'-- 40
				--and itemNumber like '%17292%'
			/* Used for generating tool boss item list */
				select '(''' + itemNumber + '''),' -- 14
				from bvToolListItemsInPlants i
				inner join
				[ToolList Toolboss Stock Items] tbs
				on i.itemClass=tbs.ItemClass
				where processid =  62158 -- 33 --62372 -- 26
				and toolbossstock=0 and UDFGLOBALTOOL <> 'YES'-- 40
			/* Used for generating toolbossstock item list */
				select '(''' + itemNumber + '''),' -- 14
				from bvToolListItemsInPlants i
				where processid =  62158 
				and toolbossstock=1

				/* This is the actual sql for the original query. */
				-- select itemNumber from bvToolListItemsInPlants
				--where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
				-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA
			) lv1
			inner join
			[ToolList Toolboss Stock Items] tbs
			on lv1.itemClass=tbs.ItemClass
			-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA -- 19
			--14347
		union
			-- stocked in toolboss no matter the item
			-- class
			SELECT *
			from
			bvToolListItemsInPlants
			where toolbossstock=1 and UDFGLOBALTOOL <> 'YES'
			and processid = 40750  -- 0
		-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA			
			--17
		/* These are already in the Plex master tool list			
		union
			-- add these global items to all tool lists 
			select *
			from
			bvToolListItemsInPlants
			where UDFGLOBALTOOL = 'YES'
			*/
) lv2;

-- dbo.bvToolListItemsInPlants source

--///////////////////////////////////////////////////////////////////////////////
-- This view does not take into consideration the [ToolList Toolboss Stock Items]
-- table which lists the item classes to be stocked in the toolbosses. See
-- bvToolBossItemsInPlants to determine items to be stocked in the ToolBosses.
-- This list would be appropriate to list restrictions for the Cribmaster if you
-- grouped the recordset on all fields except plant.
--///////////////////////////////////////////////////////////////////////////////
--create view [dbo].[bvToolListItemsInPlants]
as
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'
--27838
union
	-- 796 select count(*) from bvToolListsInPlants
	select tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant
	,ti.itemNumber, ti.itemclass, ti.UDFGLOBALTOOL, 0 as toolbossStock 
	FROM  toolitems ti
	CROSS JOIN
	bvToolListsInPlants tl
	WHERE (ti.UDFGLOBALTOOL = 'YES');

select * from toolitems

select count(*)
FROM 
(
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(8) AS bfToolBossItemsInPlant_1
where job IN (63810)
-- 14218|    14218 NEXTEER |26088054 ALUMINUM ASSEMBLY  -- No tool boss items
-- 40750|    61622--H2GC-5K651-AB RH CD4.2 RLCA
--185
)s1

select * from bvToolListItemsInPlants
where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
and processid = 14218

SELECT * FROM bvToolBossItemsInPlants
