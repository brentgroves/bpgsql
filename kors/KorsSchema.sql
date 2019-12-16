-- Drop table

-- DROP TABLE master.dbo.CommandLog GO

CREATE TABLE Kors.dbo.HourlyOEEValues (
	ID int IDENTITY (1,1) NOT NULL,
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
) GO

select * from hourlyoeevalues
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
	@Workcenter_status varchar(50),
	@Data_hour INT,
	@Hourly_planned_production_count INT,
	@Hourly_actual_production_count INT,
	@Cumulative_planned_production_count INT,
	@Cumulative_actual_production_count INT,
	@scrap_count INT,
	@Downtime_minutes INT,
	@Date_time_stamp DATETIME,
	@Transaction_number BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
   
-- Table variable   
DECLARE @MyTableVar table( ID int,
                           Workcenter_Code varchar(50));
   
INSERT INTO Kors.dbo.HourlyOEEValues
(Workcenter_Code, Job_number, Part_number, Workcenter_status, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp, Transaction_number)
OUTPUT INSERTED.ID, INSERTED.Workcenter_Code
into @MyTableVar
VALUES(@Workcenter_Code, @Job_number, @Part_number, @Workcenter_status, @Data_hour, @Hourly_planned_production_count, @Hourly_actual_production_count, @Cumulative_planned_production_count, @Cumulative_actual_production_count, @scrap_count, @Downtime_minutes, @Date_time_stamp, @Transaction_number);
--values (' VSC_5', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0)

--Display the result set of the table variable.
SELECT ID, Workcenter_Code FROM @MyTableVar;
--Display the result set of the table.
--select * from HourlyOEEValues h

END;

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0
select * from HourlyOEEValues h
--1011
delete from HourlyOEEValues h

1010	 VSC_5	1210	4140	Production	10	41	38	834	582	0	0	2014-07-02 14:29:00	0

     OUTPUT INSERTED.Name, INSERTED.Identifier