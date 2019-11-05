DROP TABLE if EXISTS Facility;
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

DROP TABLE IF EXISTS Plant;
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

DROP TABLE IF EXISTS CNC;
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

DROP TABLE IF EXISTS PlexJob;
CREATE TABLE mach2.PlexJob (
	PlexJobKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name varchar(50) NULL,
    PRIMARY KEY (PlexJobKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex Job info';

DROP TABLE IF EXISTS PlexPart;
CREATE TABLE mach2.PlexPart (
	PlexPartKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name varchar(50) NULL,
    PRIMARY KEY (PlexPartKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex Part info';

DROP TABLE IF EXISTS PlexJobParts;
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

DROP TABLE IF EXISTS PlexWorkCenterGroup;
CREATE TABLE mach2.PlexWorkCenterGroup (
	PlexWorkCenterGroupKey MEDIUMINT NOT NULL AUTO_INCREMENT,
	Name varchar(50) NULL,
    PRIMARY KEY (PlexWorkCenterGroupKey)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci
COMMENT='Plex workcenter group info';

DROP TABLE IF EXISTS PlexWorkCenter;
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

DROP TABLE IF EXISTS PlexWorkCenterGroupWorkCenters;
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

DROP TABLE IF EXISTS Mach2WorkCenter;
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

DROP TABLE IF EXISTS Mach2WorkCenterGroup;
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

DROP TABLE IF EXISTS Mach2WorkCenterGroupWorkCenters;
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

DROP TABLE IF EXISTS Control_Panel_Setup_Containers_Get;
CREATE TABLE Control_Panel_Setup_Containers_Get(
  Control_Panel_Setup_Containers_Get_Key INT NOT NULL AUTO_INCREMENT,
  TransDate datetime DEFAULT NULL,
  ProdServer bool NULL,
  Part_No varchar(50) NULL,
  Name varchar(50) NULL,
  Multiple bool NULL,
  Container_Note varchar(50) NULL,
  Cavity_Status_Key INT NULL,
  Container_Status varchar(50) NULL,
  Defect_Type varchar(50) NULL,
  Serial_No varchar(50) NULL,
  Setup_Container_Key INT NULL,
  Count MEDIUMINT NULL,
  Part_Count MEDIUMINT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Standard_Container_Type varchar(50) NULL,
  Container_Type_Key INT NULL,
  Parent_Part varchar(50) NULL,
  Parent varchar(50) NULL,
  Cavity_No varchar(50) NULL,
  Master_Unit_Key INT NULL DEFAULT 0,
  Workcenter_Printer_Key INT NULL,
  Master_Unit_No varchar(50) NULL,
  Physical_Printer_Name varchar(50) NULL,
  Container_Count MEDIUMINT NULL,
  Container_Quantity MEDIUMINT NULL,
  Default_Printer varchar(50) NULL,
  Default_Printer_Key INT NULL,
  Class_Key INT NULL,
  Quantity INT NULL,
  Companion bool NULL,	 
  Container_Type varchar(50) NULL,
  Container_Type_Description varchar(100) NULL,
  Sort_Order MEDIUMINT NULL,
  PRIMARY KEY (Control_Panel_Setup_Containers_Get_Key)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Control_Panel_Setup_Containers_Get_Key historian';


//delete from Control_Panel_Setup_Containers_Get
select * from Control_Panel_Setup_Containers_Get
DROP TABLE IF EXISTS ProdVrsTest;
CREATE TABLE ProdVrsTest (
  ProdVrsTestKey MEDIUMINT NOT NULL AUTO_INCREMENT,
  Mach2WorkCenterKey varchar(10) NULL,
  TransDate datetime DEFAULT NULL,
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
