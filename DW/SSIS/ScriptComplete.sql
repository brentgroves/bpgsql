-- update ssis.ScriptComplete set done=1 where id=1
-- update ssis.ScriptComplete set done=1 where id in (7,24,25)
--update ssis.ScriptComplete set done=0 where id in (7,24,25)

-- update ssis.ScriptComplete set done=0
-- create schema ssis;
select * from ssis.ScriptComplete


-- drop TABLE myDW.SSIS.ScriptComplete
 
-- truncate TABLE SSIS.ScriptComplete;
/*
CREATE TABLE mgdw.SSIS.ScriptComplete (
	ID int NOT NULL,
	Description varchar(100) NOT NULL,
	Done bit NOT NULL,
	PRIMARY KEY (ID)
);
*/
select * from ssis.ScriptComplete
172.20.90.51
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
2	295932 Fruit Port

/*
 * select * from ssis.ScriptComplete
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
(33,'Southfield CampfireExtract',0),
(34,'Albion CampfireExtract',0),
(35,'Avilla CampfireExtract',0),
(36,'Edon CampfireExtract',0),
(37,'Alabama CampfireExtract',0),
(38,'Fruitport CampfireExtract',0),
(39,'Southfield GLAccountActivitySummary',0),
(40,'Albion GLAccountActivitySummary',0),
(41,'Southfield AccountBalanceByPeriod',0),
(42,'Albion AccountBalanceByPeriod',0),
(43,'Albion Account',0),
(44,'Avilla Account',0),
(45,'Edon Account',0),
(46,'Alabama Account',0),
(47,'Southfield Account',0)


MSC pipelines

Plex pipelines
update SSIS.ScriptComplete set Done = 0 where ID in (3,28,29,30,7,24,25,31,9,26,27,32)
(3,28,29,30) -- PRP screen
(7,24,25,31) -- Tool_BOM
(9,26,27,32) -- PurchasingItemSummary
(13,14)
*/

/*
select * from SSIS.ScriptComplete where ID in (1,2,6,8) -- Albion MSC to DW Script ID  
select * from SSIS.ScriptComplete where ID in (16,17,18,19) -- Avilla MSC to DW Script ID  
select * from SSIS.ScriptComplete where ID in (20,21,22,23) -- Edon MSC to DW Script ID  

update SSIS.ScriptComplete set Done = 0 where ID in (1,2,6,8)
(1,'Albion MSCJobs',0),
(2,'Albion MSCTransactionLog',0),
(6,'Albion MSCItemSummary',0),
(8,'Albion MSC Restrictions2',0),

*/