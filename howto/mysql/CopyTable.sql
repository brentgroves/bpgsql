/*
If you don't want to list the fields, and the structure of the tables is the same, you can do:

INSERT INTO `table2` SELECT * FROM `table1`;
or if you want to create a new table with the same structure:

CREATE TABLE new_tbl [AS] SELECT * FROM orig_tbl;
*/