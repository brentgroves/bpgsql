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
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Plex.accounting_period ap -- 1,418

