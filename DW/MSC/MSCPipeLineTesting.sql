
*/
--truncate table MSC.ItemSummary;
select * from MSC.ItemSummary
where pcn = 300758 and vmid = 4 -- plant 6
select * from MSC.ItemSummary
where pcn = 300758 and vmid = 5 -- plant 8
select * from MSC.ItemSummary
where pcn = 300758 and vmid = 6 -- plant 9 
select * from MSC.ItemSummary
where pcn = 310507 and vmid = 3
select * from MSC.ItemSummary
where pcn = 306766 and vmid = 3

-- truncate table mgdw.MSC.Jobs 
select * from mgdw.MSC.Jobs 
where pcn = 300758 and vmid = 4 -- plant 6
select * from mgdw.MSC.Jobs 
where pcn = 300758 and vmid = 5 -- plant 8
select * from mgdw.MSC.Jobs 
where pcn = 300758 and vmid = 6 -- plant 9 
select * from mgdw.MSC.Jobs 
where pcn = 310507 and vmid = 3
select * from mgdw.MSC.Jobs 
where pcn = 306766 and vmid = 3

--truncate table MSC.Restrictions2;
select * from MSC.Restrictions2
where pcn = 300758
select * from MSC.Restrictions2
where pcn = 310507
select * from MSC.Restrictions2
where pcn = 306766

-- delete from MSC.TransactionLog where pcn = 300758
select tl.* from MSC.TransactionLog tl 
where pcn = 300758 and vmid = 4 
order by tl.transtartdatetime desc
select tl.* from MSC.TransactionLog tl 
where pcn = 300758 and vmid = 5 
order by tl.transtartdatetime desc
select tl.* from MSC.TransactionLog tl 
where pcn = 300758 and vmid = 6 -- none
order by tl.transtartdatetime desc
select tl.* from MSC.TransactionLog tl 
where pcn = 310507 and vmid = 3
order by tl.transtartdatetime desc
select tl.* from MSC.TransactionLog tl 
where pcn = 306766 and vmid = 3
order by tl.transtartdatetime desc
select tl.* from MSC.TransactionLog tl 
where pcn = 306766 and vmid = 4
order by tl.transtartdatetime desc

select * from MSC.import

/*
MSC pipelines
select * from SSIS.ScriptComplete where ID in (6,1,8,2)  -- albion
select * from SSIS.ScriptComplete where ID in (18,16,19,17) -- avilla
select * from SSIS.ScriptComplete where ID in (22,20,23,21)  -- edon

update SSIS.ScriptComplete set Done = 0 where ID in (6,1,8,2)  -- albion
update SSIS.ScriptComplete set Done = 0 where ID in (18,16,19,17) -- avilla
update SSIS.ScriptComplete set Done = 0 where ID in (22,20,23,21)  -- edon
(6,18,22) -- Item summary
(1,16,20)  -- Jobs
(8,19,23)  -- Restrictions2
(2,17,21) -- TransactionLog
Plex pipelines
select * from SSIS.ScriptComplete where ID in (3,28,29,30,7,24,25,31,9,26,27,32)
update SSIS.ScriptComplete set Done = 0 where ID in (3,28,29,30,7,24,25,31,9,26,27,32)
(3,28,29,30) -- PRP screen
(7,24,25,31) -- Tool_BOM
(9,26,27,32) -- PurchasingItemSummary
(13,14)
*/
/*
truncate table ssis.ScriptComplete
INSERT into ssis.ScriptComplete (ID,Description,Done)
values
(1,'Albion MSCJobs',0),
(2,'Albion MSCTransactionLog',0),
(3,'Albion PRP Screen',0),
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
(27,'Edon purchasing_item_summary',0),
(28,'Avilla PRP Screen',0),
(29,'Edon PRP Screen',0),
(30,'Alabama PRP Screen',0),
(31,'Alabama part_tool_BOM',0),
(32,'Alabama purchasing_item_summary',0),

*/