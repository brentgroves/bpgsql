/*
-- mgdw.Plex.PRP_Screen definition

-- Drop table

-- DROP TABLE mgdw.Plex.PRP_Screen;

CREATE TABLE mgdw.Plex.PRP_Screen (
	ID int NOT NULL,
	pcn int NOT NULL,
	building_key int NOT NULL,
	building_code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_key int NULL,
	part_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	qty_rel int NULL,
	qty_shipped int NULL,
	qty_due int NULL,
	past_due int NULL,
	qty_wip int NULL,
	qty_ready int NULL,
	qty_loaded int NULL,
	qty_ready_or_loaded int NULL,
	CONSTRAINT PK__PRP_Scre__78E3E6BB6F87CA47 PRIMARY KEY (ID,pcn,building_key)
);
*/
select * from Plex.PRP_Screen