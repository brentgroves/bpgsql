-- Drop table

-- drop TABLE Kors.dbo.HourlyOEEValues
CREATE TABLE Kors.dbo.HourlyOEEValues (
	ID int IDENTITY (1,1) NOT NULL,
	Workcenter_Code varchar(50),
	Job_number varchar(20),
	Part_number varchar(60),
	Data_hour INT,
	Hourly_planned_production_count INT,
	Hourly_actual_production_count INT,
	Cumulative_planned_production_count INT,
	Cumulative_actual_production_count INT,
	scrap_count INT,
	Downtime_minutes float,
	Date_time_stamp DATETIME
) 


select 
--top(100)
*
--into hourlyoeevalues0213 
from hourlyoeevalues
select 
top(100) *
--count(*) cnt --14808
from hourlyoeevalues0213

declare @dt datetime;
set @dt = '2014-07-02 14:29';
INSERT INTO Kors.dbo.HourlyOEEValues
(Workcenter_Code, Job_number, Part_number, Workcenter_status, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp, Transaction_number)
VALUES(' VSC_4', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0);
drop procedure InsertHourlyOEEValues
CREATE PROCEDURE InsertHourlyOEEValues
	@Workcenter_Code varchar(50),
	@Job_number varchar(20),
	@Part_number varchar(60),
	@Data_hour INT,
	@Hourly_planned_production_count INT,
	@Hourly_actual_production_count INT,
	@Cumulative_planned_production_count INT,
	@Cumulative_actual_production_count INT,
	@scrap_count INT,
	@Downtime_minutes float,
	@Date_time_stamp DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
   
-- Table variable   
DECLARE @MyTableVar table( ID int,
                           Workcenter_Code varchar(50));
--https://www.sqlservercentral.com/articles/the-output-clause-for-insert-and-delete-statements
-- We use the OUTPUT INTO syntax to store the results in a table variable. With this approach, 
-- we have access to the set of rows that were inserted during the execution of the query that can be used later for the next steps with in the same execution.   
INSERT INTO Kors.dbo.HourlyOEEValues
(Workcenter_Code, Job_number, Part_number, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp)
OUTPUT INSERTED.ID, INSERTED.Workcenter_Code
into @MyTableVar
VALUES(@Workcenter_Code, @Job_number, @Part_number, @Data_hour, @Hourly_planned_production_count, @Hourly_actual_production_count, @Cumulative_planned_production_count, @Cumulative_actual_production_count, @scrap_count, @Downtime_minutes, @Date_time_stamp);
--values (' VSC_5', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0)

--Display the result set of the table variable.
SELECT ID, Workcenter_Code FROM @MyTableVar;
--Display the result set of the table.
--select * from HourlyOEEValues h

END;
exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 7, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 7, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 7, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 7, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 8, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 8, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 8, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 8, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 9, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 9, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 9, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 9, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 10, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 10, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 10, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 10, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 11, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 11, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 11, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 12, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 12, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 12, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 12, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 13, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 13, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 13, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 13, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 14, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 14, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 14, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 14, 41, 38, 834,582, 0, 0,'2020-04-01 14:29'


select * from HourlyOEEValues h
--1011
delete from HourlyOEEValu
select * from users
select * from messages
--delete from messages
--drop table messages
--drop table users



-- Drop table

-- DROP TABLE Kors.dbo.messages GO

/*
--Moved all Feathers services to mysql including authentication
-- Drop table

-- DROP TABLE Kors.dbo.users GO

MySQL
show variables like 'sql_mode' ; 
The problem is because of sql_modes. Please check your current sql_modes by command:
show variables like 'sql_mode' ; 
And remove the sql_mode "NO_ZERO_IN_DATE,NO_ZERO_DATE" to make it work. This is the default sql_mode in mysql new versions.
You can set sql_mode globally as root by command:
set global sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';


CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `userName` varchar(255) DEFAULT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `isAdmin` tinyint(1) DEFAULT NULL,
  `roles` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

select * from users
 */


