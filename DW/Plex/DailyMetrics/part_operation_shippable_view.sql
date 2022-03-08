-- mgdw.Plex.Part_Operation definition

-- Drop table

-- DROP TABLE mgdw.Plex.Part_Operation;

CREATE TABLE mgdw.Plex.Part_Operation (
	PCN int NOT NULL,
	Part_Operation_Key int NOT NULL,
	Part_Key int NOT NULL,
	Part_No nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Revision nvarchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Part_No_Revision nvarchar(118) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Part_Description nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Operation_No int NOT NULL,
	Description nvarchar(1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Operation_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Net_Weight decimal(19,5) NOT NULL,
	Standard_Container_Type nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Note nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Suboperation int NOT NULL,
	Standard_Quantity decimal(19,5) NOT NULL,
	Part_Op_Type nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Standard int NOT NULL,
	Grade nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Shippable int NOT NULL,
	Minimum_Quantity decimal(19,5) NOT NULL
);
 CREATE CLUSTERED INDEX IX_Part_Operation ON Plex.Part_Operation (  PCN ASC  , Part_Operation_Key ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
	
/*
123681 Southfield
295932 FruitPort
300757 Alabama
300758 Albion
306766 Edon
310507 Avilla
	*/
/*
 * Do we need a view to clean up null values
 */	
SELECT * from Plex.Part_Operation po 	
WHERE revision IS NULL -- 0

select count(*) cnt 
from 
(
	select distinct part_key from Plex.Part_Operation po 
) c  -- 1,663 

select count(*) from part_v_part_e p
where part_status in ('Production')  -- 1169
--where part_status in ('Service')  -- 363

select *
--select count(*) 
from Plex.Part_Operation po 
where po.PCN = 123681  -- 232 --Southfield
--where po.PCN = 295932 -- 1,828 -- FruitPort
--where po.PCN = 300757 -- 318 -- Alabama
--where po.PCN = 300758 -- 1,212 -- Albion
--where po.PCN = 306766 -- 453 -- Edon
where po.PCN = 310507 -- 105 -- Avilla

/*
What is the primary key? any of these 4 should be ok:
-- 	group by pcn,part_operation_key -- 4,148
--	group by pcn,part_key,operation_no -- 4,148
--	group by pcn,part_no_revision,operation_no  -- 4,148
--	group by pcn,part_no,revision,operation_no  -- 4,148

*/
select count(*)
from 
(
	select count(*) cnt 
	from Plex.Part_Operation po -- 4,148
--	group by pcn,part_operation_key -- 4,148
--	group by pcn,part_key,operation_no -- 4,148
--	group by pcn,part_no_revision,operation_no  -- 4,148
--	group by pcn,part_no,revision,operation_no  -- 4,148
) r 	
	
--drop view Plex.part_operation_shippable_view 
create view Plex.part_operation_shippable_view 
as 
with shippable_ops
as 
(
	select *
	--select count(*) 
	from Plex.Part_Operation po 
	--where po.PCN = 123681  -- 232 --Southfield
	where po.Shippable = 1
)
select * from shippable_ops 

select * 
--select count(*)
from Plex.part_operation_shippable_view -- 1,662

/*
 * Is there just one distinct shippable part operation for each part.
 * Or is there more than one?
 * Remember our primary key has changed to part selling price.
 */

select count(*)
from 
(
	select distinct pcn,part_operation_key 
	from Plex.part_operation_shippable_view 
) s  -- 1,662

select count(*)
from 
(
	select distinct pcn,part_no,revision,operation_no 
	from Plex.part_operation_shippable_view 
) s  -- 1,662

select count(*)
from 
(
	select distinct pcn,part_no,revision 
	from Plex.part_operation_shippable_view 
) s  -- 1,662

select count(*)
from 
(
	select distinct pcn,part_key 
	from Plex.part_operation_shippable_view 
) s  -- 1,662



 * 
/* old wrong. look at shippable instead.
create view Plex.part_final_production_operation_view 
as 
with all_ops
as 
(
	select *
	--select count(*) 
	from Plex.Part_Operation po 
	--where po.PCN = 123681  -- 232 --Southfield
	where po.Part_Op_Type =  'Production'
), 
final_ops 
as 
( 
	select pcn,part_key,part_no,Revision,max(Operation_No) final_op 
	from all_ops 
	group by pcn,part_key,part_no,Revision  
)
select * from final_ops 
*/

