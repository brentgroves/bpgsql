Create schema btl
-- mgdw.btl.btJobsIn9B definition

-- Drop table

-- DROP TABLE mgdw.btl..btJobsIn9B;
/*
CREATE TABLE mgdw.btl.btJobsIn9BBak (
	JobNumber int NULL,
	Descr nvarchar(50) NULL,
	alias nvarchar(50) NULL,
	Plant int NOT NULL,
	CreatedBy varchar(4) NOT NULL,
	DATECREATED varchar(8) NOT NULL,
	DATELASTMODIFIED varchar(8) NOT NULL,
	LASTMODIFIEDBY varchar(4) NOT NULL,
	JOBENABLE int NOT NULL,
	DATERANGEENABLE int NOT NULL
);
*/
--TRUNCATE table btl.btJobsIn9B
select * from btl.btJobsIn9BBak
