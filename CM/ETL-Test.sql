CREATE TABLE plx_Detailed_Production_History (
	PCN int NULL,
	Production_No int NULL,
	Workcenter_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Key int NULL,
	Revision varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Serial_No varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Record_Date datetime2 NULL,
	Quantity decimal(19,5) NULL,
	Shift varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Workcenter_Type varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Standard_Production_Rate decimal(18,0) NULL,
	Operation_Code varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Note varchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Job_No varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Tracking_No varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Master_Unit_No varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Location varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Add_By varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);
--TRUNCATE table plx_Detailed_Production_History
select * from plx_Detailed_Production_History