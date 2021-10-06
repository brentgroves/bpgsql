-- truncate table Kors.recipient
select * 
--into Kors.recipientXXXX  --  37
from Kors.recipient
--from Kors.recipient0921
-- truncate table Kors.recipient
select * from Kors.recipient 
--where pcn = 297638
-- delete from Kors.recipient where pcn = 297638
select * from Kors.recipient0921


--truncate table Kors.notification
-- drop table Kors.notification
select * from Kors.notification  -- 50


// BACKUP
select * 
--into Kors.notification_09_30
from Kors.notification

--select * from Kors.notification_09_30

DECLARE @R INT
declare @cur_time time
declare @dbg_time time
declare @Dest varchar(1000)
declare @Lvl integer
set @Lvl = 3
declare @PCN integer
set @PCN = 295932
set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'

--select getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
exec @R=Kors.notifications_get_rs @PCN,@Level=@Lvl
--exec @R=Kors.notifications_get_rs @PCN,@Level=@Lvl,@dbg_time=@cur_time; --, @cur_time
select @R,@Dest,@dbg_time;
-- 2604380796@vtext.com
SELECT * FROM Kors.notification -- 50
select * from Kors.recipient -- 35
where customer_employee_no = 054109


-- truncate table Plex.PRP_Screen
select count(*) from Plex.PRP_Screen -- 46,133
select * from Plex.PRP_Screen 
--where pcn = 300758  -- Albion 1639
--where pcn = 310507  -- Avilla 1291
where pcn = 306766 -- Edon 1818

--truncate table Plex.purchasing_item_summary
select count(*) from Plex.purchasing_item_summary  -- 975,1865,2174
--where pcn = 300758  -- Albion 1639
--where pcn = 310507  -- Avilla 1291
--where pcn = 306766 -- Edon 1818

--truncate table Plex.part_tool_BOM
select count(*) from Plex.part_tool_BOM  -- 1639, 1548
--select count(distinct tool_no) from Plex.part_tool_BOM  -- 779
--where pcn = 300758  -- Albion 1639
--where pcn = 310507  -- Avilla 1291
--where pcn = 306766 -- Edon 1818

select * from SSIS.ScriptComplete
--update SSIS.ScriptComplete set Done = 0

--select * from SSIS.ScriptComplete where ID in (13,14,3,7,24,25,9,26,27)
--update SSIS.ScriptComplete set Done = 0 where ID in (13,14,3,7,24,25,9,26,27)
-- select * from SSIS.ScriptComplete where ID in (1,2,6,8) -- Albion MSC
--update SSIS.ScriptComplete set Done = 0 where ID in (1,2,6,8)  -- Albion MSC
-- select * from SSIS.ScriptComplete where ID in (16,17,18,19) -- Avilla MSC
-- update SSIS.ScriptComplete set Done = 0 where ID in (16,17,18,19) -- Avilla MSC
-- select * from SSIS.ScriptComplete where ID in (20,21,22,23) -- Edon MSC
-- -- update SSIS.ScriptComplete set Done = 0 where ID in (20,21,22,23) -- Edon MSC
/*
INSERT into ssis.ScriptComplete (ID,Description,Done)
values
(1,'Albion MSCJobs',0),
(2,'Albion MSCTransactionLog',0),
(3,'PRP Screen',0),
(4,'part_op_with_tool_list',0),
(5,'part_tool_assembly',0),
(6,'Albion MSCItemSummary',0),
(7,'Albion part_tool_BOM',0),
(8,'Albion MSC Restrictions2',0),
(9,'purchasing_item_summary',0),
(10,'Albion purchasing_item_usage',0),
(11,'purchasing_item_inventory',0),
(12,'purchasing_item_inv_cube',0),
(13,'kors_recipient',0),
(14,'kors_notification',0),
(15,'Edon part_tool_BOM',0),
(16,'Avilla MSCJobs',0),
(17,'Avilla MSCTransactionLog',0),
(18,'Avilla MSCItemSummary',0),
(19,'Avilla MSC Restrictions2',0),
(20,'Edon MSCJobs',0),
(21,'Edon MSCTransactionLog',0),
(22,'Edon MSCItemSummary',0),
(23,'Edon MSC Restrictions2',0),
(24,'Avilla part_tool_BOM',0),
(25,'Edon part_tool_BOM',0),
(26,'Avilla purchasing_item_summary',0),
(27,'Edon purchasing_item_summary',0)


*/
