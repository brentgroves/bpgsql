-- Kors.dbo.HourlyOEEValues definition

-- Drop table

-- DROP TABLE Kors.dbo.HourlyOEEValues GO

CREATE TABLE HourlyOEEValues (
	ID int NOT NULL AUTO_INCREMENT,
	Workcenter_Code varchar(50),
	Job_number varchar(20),
	Part_number varchar(60),
	Data_hour int,
	Hourly_planned_production_count int,
	Hourly_actual_production_count int,
	Cumulative_planned_production_count int,
	Cumulative_actual_production_count int,
	scrap_count int,
	Downtime_minutes float,
	Date_time_stamp datetime,
  	CONSTRAINT HOV_pk PRIMARY KEY (ID)
)

DELIMITER //
--drop procedure country_hos
CREATE PROCEDURE country_hos
(IN _con CHAR(20))
BEGIN
  SELECT Name, HeadOfState FROM Country
  WHERE Continent = @con;
  SELECT Name, HeadOfState FROM Country
  WHERE Continent = @con;
 
END //
DELIMITER ;


CREATE PROCEDURE check_table_exists(table_name VARCHAR(100)) 
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02' SET @err = 1;
    SET @err = 0;
    SET @table_name = table_name;
    SET @sql_query = CONCAT('SELECT 1 FROM ',@table_name);
    PREPARE stmt1 FROM @sql_query;
    IF (@err = 1) THEN
        SET @table_exists = 0;
    ELSE
        SET @table_exists = 1;
        DEALLOCATE PREPARE stmt1;
    END IF;
   select 1 from HourlyOEEValues ho 
END 

call check_table_exists('HourlyOEEValues');

CALL Kors.InsertHourlyOEEValues(:_Workcenter_Code,:_Job_number,:_Part_number,:_Data_hour,:_Hourly_planned_production_count,:_Hourly_actual_production_count,:_Cumulative_planned_production_count,:_Cumulative_actual_production_count,:_scrap_count,:_Downtime_minutes,:_Date_time_stamp) 

call InsertHourlyOEEValues(' VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-19 14:29')
select * from HourlyOEEValues ho
--drop procedure InsertHourlyOEEValues
DELIMITER //
CREATE PROCEDURE InsertHourlyOEEValues(
	_Workcenter_Code varchar(50),
	_Job_number varchar(20),
	_Part_number varchar(60),
	_Data_hour INT,
	_Hourly_planned_production_count INT,
	_Hourly_actual_production_count INT,
	_Cumulative_planned_production_count INT,
	_Cumulative_actual_production_count INT,
	_scrap_count INT,
	_Downtime_minutes float,
	_Date_time_stamp DATETIME
	)
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements. MSSQL
    -- SET NOCOUNT ON; -- There is no MySQL equivalent to this.
                     
INSERT INTO HourlyOEEValues
(Workcenter_Code, Job_number, Part_number, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp)
VALUES(_Workcenter_Code, _Job_number, _Part_number, _Data_hour, _Hourly_planned_production_count, _Hourly_actual_production_count, _Cumulative_planned_production_count, _Cumulative_actual_production_count, _scrap_count, _Downtime_minutes, _Date_time_stamp);

-- Display the last inserted row.
select ID, Workcenter_Code from HourlyOEEValues where ID=(SELECT LAST_INSERT_ID());


END //
DELIMITER ;


--select * from HourlyOEEValues h
