create table Plex.part_container
(
Serial_No varchar(25)
)

-- mgdw.Plex.account_balance definition

-- Drop table

-- DROP TABLE mgdw.Plex.part_container;
-- TRUNCATE TABLE mgdw.Plex.part_container;
-- drop table Plex.part_container
CREATE TABLE mgdw.Plex.part_container (
	Serial_No varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_key int NULL
);
select * from Plex.part_container
/*
CREATE TABLE mgdw.Plex.part_container (
	name varchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	value varchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
);
*/



