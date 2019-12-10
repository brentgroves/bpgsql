-- DROP TABLE master.dbo.CommandLog GO

CREATE TABLE PlxLastUsed (
	ID int IDENTITY (1,1) NOT NULL,
	item_no varchar(50),
	Description varchar(800),
	
	Job_number varchar(20),
	Part_number varchar(60),
	Workcenter_status varchar(50),
	Data_hour INT,
	Hourly_planned_production_count INT,
	Hourly_actual_production_count INT,
	Cumulative_planned_production_count INT,
	Cumulative_actual_production_count INT,
	scrap_count INT,
	Downtime_minutes INT,
	Date_time_stamp DATETIME,
	Transaction_number BIGINT
)
select 
top 10
itemNumber,Description1 from dbo.INVENTRY

CREATE TABLE CMLastUsed (
	ID int IDENTITY (1,1) NOT NULL,
	itemNumber varchar(12),
	Description1 varchar(50),
	
	Workcenter_Code varchar(50),
	Job_number varchar(20),
	Part_number varchar(60),
	Workcenter_status varchar(50),
	Data_hour INT,
	Hourly_planned_production_count INT,
	Hourly_actual_production_count INT,
	Cumulative_planned_production_count INT,
	Cumulative_actual_production_count INT,
	scrap_count INT,
	Downtime_minutes INT,
	Date_time_stamp DATETIME,
	Transaction_number BIGINT
)