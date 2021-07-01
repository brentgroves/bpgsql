-- myDW.AlbSPS.Import definition

-- Drop table

-- DROP TABLE myDW.Cubes.Import;
-- truncate TABLE myDW.Cubes.Import;
CREATE TABLE myDW.Cubes.Import (
	id int NOT NULL,
	description varchar(100) NULL,
	last_success datetime NULL,
	PRIMARY KEY (id)
);
declare @last_success datetime
set @last_success = '2021-06-29 00:00:00'
insert into myDW.Cubes.Import (id,description,last_success)
values (1,'tooling_cube',@last_success)
select * from myDW.Cubes.Import