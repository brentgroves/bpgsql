-- update ssis.ScriptComplete set done=1 where id=1
-- update ssis.ScriptComplete set done=0
-- create schema ssis;
select * from ssis.ScriptComplete


-- drop TABLE myDW.SSIS.ScriptComplete
 
-- truncate TABLE mgdw.SSIS.ScriptComplete;
/*
CREATE TABLE mgdw.SSIS.ScriptComplete (
	ID int NOT NULL,
	Description varchar(100) NOT NULL,
	Done bit NOT NULL,
	PRIMARY KEY (ID)
);
*/
select * from ssis.ScriptComplete
/*
INSERT into ssis.ScriptComplete (ID,Description,Done)
values
(1,'MSC Jobs Import',0),
(2,'MSC TransactionLog Import',0),
(3,'customer_release_due_WIP_ready_loaded',0),
(4,'part_op_with_tool_list',0),
(5,'part_tool_assembly',0),
(6,'MSCItemSummary',0),
(7,'part_tool_BOM',0),
(8,'MSC Restrictions2',0),
(9,'purchasing_item_summary',0),
(10,'purchasing_item_usage',0),
(11,'purchasing_item_inventory',0),
(12,'purchasing_item_inv_cube',0),
(13,'kors_recipient',0),
(14,'kors_notification',0),
(15,'Edon part_tool_BOM',0)

*/