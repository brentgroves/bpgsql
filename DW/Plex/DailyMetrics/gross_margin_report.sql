-- mgdw.Plex.gross_margin_report definition

-- Drop table

-- DROP TABLE mgdw.Plex.gross_margin_report;

CREATE TABLE mgdw.Plex.gross_margin_report (
	customer_code varchar(35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	salesperson varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	order_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	po_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	product_type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_description varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	sales_qty numeric(18,0) NULL,
	sales_unit varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	quantity numeric(18,0) NULL,
	quantity_unit varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	unit_price numeric(18,5) NULL,
	revenue numeric(18,5) NULL,
	invoice_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_group varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	po_type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	net_weight numeric(18,5) NULL,
	total numeric(18,5) NULL,
	customer_abbreviated_name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	customer_currency_code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	gross_margin_key numeric(18,0) NULL,
	customer_category varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	customer_type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	part_source varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	production_qty numeric(18,0) NULL,
	part_revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	customer_part_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	customer_part_revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	sequence_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	master_no varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);u

select * from Plex.gross_margin_report 
where part_no = '10103355'

