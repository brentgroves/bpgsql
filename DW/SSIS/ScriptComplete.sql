-- update ssis.ScriptComplete set done=1 where id=1
-- update ssis.ScriptComplete set done=0

select * from ssis.ScriptComplete


-- drop TABLE myDW.SSIS.ScriptComplete
 
-- truncate TABLE myDW.SSIS.ScriptComplete;
/*
CREATE TABLE myDW.SSIS.ScriptComplete (
	ID int NOT NULL,
	Description varchar(100) NOT NULL,
	Done bit NOT NULL,
	PRIMARY KEY (ID)
);
*/
/*
INSERT into ssis.ScriptComplete (ID,Description,Done)
values
(1,'Albion MSC Jobs Import',0),
(2,'Albion MSC TransactionLog Import',0),
(3,'customer_release_due_WIP_ready_loaded',0),
(4,'part_op_with_tool_list',0),
(5,'part_tool_assembly',0)
*/