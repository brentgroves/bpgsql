CREATE TABLE mgdw.Plex.cost_component_workcenter_get (
	pcn int NULL,
	operation_no int null,
	operation_code varchar(30) null,
	wc_sort int null,
	workcenter_code varchar(50) null,
	department_code varchar(60) null,
	cost_type varchar(50) null,
	cost_sub_type varchar(50) null,
	cost decimal(18,5) null,
	calc_note varchar(500) null,
	op_count int null,
	wc_count int null,
	part_operation_key int null,
	operation_key int null,
	workcenter_key int null,
	department_no int null
);
select * from Plex.cost_component_workcenter_get
Maybe this is for the cost overrides values
