-- DROP TABLE mgdw.Plex.gross_margin_report;
-- TRUNCATE TABLE mgdw.Plex.gross_margin_report;
-- drop table Plex.gross_margin_report
CREATE TABLE Plex.gross_margin_report (
	customer_code varchar(35) null,
	salesperson varchar(100) null,
	order_no varchar(100) null,
	po_no varchar(100) null,
	part_no varchar(100) null,
	product_type varchar(100) null,
	part_description varchar(100) null,
	sales_qty numeric null,
	sales_unit varchar(100) null,
	quantity numeric null,
	quantity_unit varchar(100) null,
	unit_price numeric(18,5) null,
--	unit_price numeric null,
	revenue numeric(18,5) null,
	invoice_no varchar(100) null,
	part_type varchar(100) null,
	part_group varchar(100) null,
	po_type varchar(100) null,
	net_weight numeric(18,5) null,
	total numeric(18,5) null, -- not there
	
	
	/* skipped
	cost_type varchar(100) null,
	cost_sub_type varchar(100) null,
	shipper_line_key numeric null,
	total numeric null,
	SGA_percent numeric null,
	SGA_cost numeric null,
	scrap_percent numeric null,
	scrap_cost numeric null,
	total_cost numeric null,
	cost_per_sales numeric null,
	markup numeric null,
	margin numeric null,
*/
	customer_abbreviated_name varchar(50) null,
	customer_currency_code varchar(50) null,
	/* skipped
	cost_column varchar(100) null,
	part_key numeric null,
	line_item_no numeric null,
	*/
	gross_margin_key numeric null,
	customer_category varchar(100) null,
	customer_type varchar(100) null,
	part_source varchar(100) null,
	production_qty numeric null,
	part_revision varchar(100) null,
	customer_part_no varchar(100) null,
	customer_part_revision varchar(100) null,
	sequence_no varchar(100) null,
	master_no varchar(100) null
	/* skipped
	cost numeric null,
	ext_cost numeric null,
	cost_type_order numeric null
	*/
);
--truncate table Plex.gross_margin_report 
select * from Plex.gross_margin_report
where invoice_no = 'AB20537'
--where invoice_no = 'AB20524'
--where master_no is not null
--where po_type is not null
--where part_type is not null
--where part_no = '51393TJB A040M1'
where part_no = '51394TJB A040M1'
and order_no = 'FD001212'
and invoice_no = 'AB20530'
'

