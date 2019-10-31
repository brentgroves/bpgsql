DROP TABLE Facility;
CREATE TABLE mach2.Facility (
	FacilityKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name VARCHAR(50) NULL,
	City varchar(50) NULL,
	State varchar(50) NULL,
	Country varchar(50) NULL,
   PRIMARY KEY (FacilityKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Facility info';

DROP TABLE Plant;
CREATE TABLE mach2.Plant (
	PlantKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	FacilityKey MEDIUMINT NULL,
	Name varchar(50) NULL,
	Address VARCHAR(50) NULL,
    PRIMARY KEY (PlantKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plant info';

DROP TABLE CNC;
CREATE TABLE mach2.CNC (
	CNCKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	PlantKey MEDIUMINT NULL,
	PlexWorkCenterKey MEDIUMINT,
	Name varchar(50) NULL,
    PRIMARY KEY (CNCKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='CNC info';

DROP TABLE PlexJob;
CREATE TABLE mach2.PlexJob (
	PlexJobKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name varchar(50) NULL,
    PRIMARY KEY (PlexJobKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex Job info';

DROP TABLE PlexPart;
CREATE TABLE mach2.PlexPart (
	PlexPartKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name varchar(50) NULL,
    PRIMARY KEY (PlexPartKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex Part info';

DROP TABLE PlexJobParts;
CREATE TABLE mach2.PlexJobParts (
	PlexJobPartsKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	PlexJobKey MEDIUMINT,
	PlexPartKey MEDIUMINT,
	QuantityNeeded INT,
	QuantityProduced INT,
    PRIMARY KEY (PlexJobPartsKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex Job Parts';

DROP TABLE PlexWorkCenterGroup;
CREATE TABLE mach2.PlexWorkCenterGroup (
	PlexWorkCenterGroupKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name varchar(50) NULL,
    PRIMARY KEY (PlexWorkCenterGroupKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex workcenter group info';

DROP TABLE PlexWorkCenter;
CREATE TABLE mach2.PlexWorkCenter (
	PlexWorkCenterKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	PlexWorkCenterGroupKey MEDIUMINT,
	PlexJobKey MEDIUMINT,
	Name varchar(50) NULL,
	PlexPLCName varchar(50) NULL,
    PRIMARY KEY (PlexWorkCenterKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex workcenter info';

DROP TABLE PlexWorkCenterGroupWorkCenters;
CREATE TABLE mach2.PlexWorkCenterGroupWorkCenters (
	PlexWorkCenterGroupWorkCentersKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	PlexWorkCenterGroupKey MEDIUMINT,
	PlexWorkCenterKey MEDIUMINT,
    PRIMARY KEY (PlexWorkCenterGroupWorkCentersKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex workcenter group workcenters';

DROP TABLE Mach2WorkCenter;
CREATE TABLE mach2.Mach2WorkCenter (
	Mach2WorkCenterKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Mach2WorkCenterGroupKey MEDIUMINT,
	PlexWorkCenterKey MEDIUMINT,
	Name varchar(50) NULL,
	KEPServerChannel varchar(50) NULL,
	KEPServerTag varchar(50) NULL,
	KEPServerAddress varchar(50) NULL,
    PRIMARY KEY (Mach2WorkCenterKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Mach2 workcenter info';

DROP TABLE Mach2WorkCenterGroup;
CREATE TABLE mach2.Mach2WorkCenterGroup (
	Mach2WorkCenterGroupKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	PlexWorkCenterGroupKey MEDIUMINT,
	Name varchar(50) NULL,
    PRIMARY KEY (Mach2WorkCenterGroupKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Mach2 workcenter group info';

DROP TABLE Mach2WorkCenterGroupWorkCenters;
CREATE TABLE mach2.Mach2WorkCenterGroupWorkCenters (
	Mach2WorkCenterGroupWorkCentersKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Mach2WorkCenterGroupKey MEDIUMINT,
	Mach2WorkCenterKey MEDIUMINT,
    PRIMARY KEY (Mach2WorkCenterGroupWorkCentersKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Mach2 workcenter group workcenters';

DROP TABLE ProdVrsTest;
CREATE TABLE ProdVrsTest (
  ProdVrsTestKey MEDIUMINT NOT NULL AUTO_INCREMENT,
  Mach2WorkCenterKey varchar(10) NULL,
  DateTime datetime DEFAULT NULL,
  P1PartKey MEDIUMINT,
  P1ProdQuantity INT DEFAULT NULL,
  P1TestQuantity INT DEFAULT NULL,
  P2PartKey MEDIUMINT,
  P2ProdQuantity INT DEFAULT NULL,
  P2TestQuantity INT DEFAULT NULL,
  PRIMARY KEY (ProdVrsTestKey)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Compare test to production server container values';
select * from ProdVrsTest
--insert into ProdVrsTest (CNC, DateTime,P1ProdQuantity,P1TestQuantity,P2ProdQuantity,P2TestQuantity) values (422,"2019-10-31 13:14:7",12,12,14,14)
