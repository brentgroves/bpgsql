-- mgdw.Plex.accounting_period definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_period;
declare @dt datetime= '1900-01-01';
CREATE TABLE mgdw.Plex.accounting_period (
	pcn int NOT NULL,
	period_key int NOT NULL,
	period int NULL,
	fiscal_order int NULL,
	begin_date datetime NULL,
	end_date datetime NULL,
	period_display varchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	quarter_group tinyint NULL,
	period_status int null,
	add_date datetime null,
	update_date datetime null,
	CONSTRAINT PK__accounting_period PRIMARY KEY (pcn,period_key)
);
select *
from Plex.accounting_period ap 
where ROWNUM < 5
select *
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Plex.accounting_period ap -- 1,418
where period_key = 45758
drop procedure Report.accounting_period
insert into Scratch.t1
exec Report.accounting_period 202201,202203
create procedure Report.accounting_period
@start_period int,
@end_period int
as 
select 
period,
period_display,
begin_date,
end_date,
case 
	when period_status = 1 then 'Active'
	else 'Closed'
end status,
update_date updated 
from Plex.accounting_period
where period between @start_period and @end_period
and pcn = 123681
order by pcn,period desc 



-- DROP TABLE Scratch.accounting_period

CREATE TABLE Scratch.accounting_period (
	period int NULL,
	period_display varchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	begin_date datetime NULL,
	end_date datetime NULL,
	status varchar(10) null,
	updated datetime null,
);
insert into Scratch.accounting_period
exec Report.accounting_period 202201,202203

insert into Scratch.accounting_period
exec Report.accounting_period 202201,202203
