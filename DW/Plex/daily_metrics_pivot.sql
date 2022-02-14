	SELECT 
	--m.pcn,m.cost_model_key, m.part_key,m.part_description,m.revision,m.line_type,m.cost_type_sort_order [Oranges] AS Oranges, [Pickles] AS Pickles
	pcn_part_revision,[Material] as material,[Overhead] overhead,[Subcontract] subcontract,[Labor] labor,[Total] total 
	--part_description,revision,[Material] as material,[Overhead] overhead,[Subcontract] subcontract,[Labor] labor,[Total] total 
	FROM 
	   ( 
	   		select 
	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
	--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
	--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
	   		from Plex.cost_sub_type_breakdown_matrix m
	 --  		where part_description = '5234R'
	--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
	--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
	   ) m
	PIVOT
	   ( SUM (cost)
	--     FOR cost_type IN ( [Material])
	     FOR cost_type IN ( [Material],[Overhead],[Subcontract],[Labor],[Total])
	   ) AS pvt
	) s

	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	
	SELECT 
	--m.pcn,m.cost_model_key, m.part_key,m.part_description,m.revision,m.line_type,m.cost_type_sort_order [Oranges] AS Oranges, [Pickles] AS Pickles
	[H2GC 5K652 AB] ,[H2GC 5K651 AB] ,[TR121895],[10103355],[10115487] 
--	pcn_part_revision,[Material] as material,[Overhead] overhead,[Subcontract] subcontract,[Labor] labor,[Total] total 
	--part_description,revision,[Material] as material,[Overhead] overhead,[Subcontract] subcontract,[Labor] labor,[Total] total 
	FROM 
	   ( 
	   		select 
	   		part_no,m.material  
--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
	--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
	--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
	   		from Report.daily_metrics m
	 --  		where part_description = '5234R'
	--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
	--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
	   ) m
	PIVOT
	   ( sum(material) 
	--     FOR cost_type IN ( [Material])
	     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
	   ) AS pvt
--	) s
		
//////////////////////////
// TEST PIVOT https://www.sqlservertutorial.net/sql-server-basics/sql-server-pivot/
/////////////////
select * 
-- drop table Report.daily_metrics_pivot
--into Report.daily_metrics_pivot
from Report.daily_metrics_pivot_view
order by id 
select * from Report.daily_metrics_pivot
--select * from Plex.enterprise_pcns_get
create table 
( 
)

exec Report.daily_metrics_pivot_ordered
create procedure Report.daily_metrics_pivot_ordered
as 
select * from Report.daily_metrics_pivot_view
order by id

--drop view Report.daily_metrics_pivot_view
select * from Report.daily_metrics
select * from Report.daily_metrics_pivot_view
create view Report.daily_metrics_pivot_view
as 
	with part_pivot
	as 
	(
		select 5 id, 'Gross Volume Produced' name,*
		FROM 
		   ( 
		   		select 
		   		part_no,m.parts_produced  
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(parts_produced) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt
		union 
		select 10 id, 'Parts Scrapped' name,*
		FROM 
		   ( 
		   		select 
		   		part_no,m.parts_scrapped  
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(parts_scrapped) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt			
		union 
		select 15 id, 'Quantity_Produced' name,*
		FROM 
		   ( 
		   		select 
		   		part_no,m.produced_minus_scrapped 
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(produced_minus_scrapped) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt	
		union 
		select 40 id, 'Labor_Hours_Earned' name,*
		FROM 
		   ( 
		   		select 
		   		part_no,m.labor_hours_earned 
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(labor_hours_earned) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt	
		union 
		select 45 id, 'Labor_Hours_Actual' name,*
		FROM 
		   ( 
		   		select 
		   		part_no,m.labor_hours_actual 
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(labor_hours_actual) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt	
		union 
		select 65 id,'Material Standard' name,*
		FROM 
		   ( 
		   		select 
		   		
		   		part_no,m.material_standard  
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(material_standard) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt
		union 
		select 70 id,'Material' name ,*
		FROM 
		   ( 
		   		select 
		   		
		   		part_no,m.material_standard*m.parts_produced material 
	--	   		CONCAT(m.pcn,'|',m.part_description,'|',m.revision) pcn_part_revision,m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		   		from Report.daily_metrics m
		 --  		where part_description = '5234R'
		--select distinct m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		--select m.part_description from Plex.cost_sub_type_breakdown_matrix m  order by part_description     		
		   ) m
		PIVOT
		   ( sum(material) 
		--     FOR cost_type IN ( [Material])
		     FOR part_no IN ( [H2GC 5K652 AB],[H2GC 5K651 AB],[TR121895],[10103355],[10115487])
		   ) AS pvt
	),
	add_total 
	as 
	(
		select p.*,
		case 
		when p.id =5 and a.total is null then 0 
		when p.id =5 and a.total is not null then a.total 
		when p.id =10 and a.total is null then 0 
		when p.id =10 and a.total is not null then a.total
		when p.id =15 and a.total is null then 0 
		when p.id =15 and a.total is not null then a.total
		when p.id =40 and a.total is null then 0 
		when p.id =40 and a.total is not null then a.total
		when p.id =45 and a.total is null then 0 
		when p.id =45 and a.total is not null then a.total
		end total
		from part_pivot p 
		left outer join Plex.daily_shift_report_get_aggregate_view a 
		on p.id = a.id 
	)
	select * from add_total  
	
	/*
You can absolutely utilize your SQL views in Power BI.


Try to connect to it by entering your server and database name as you normally would, but then expand the "Advanced Options", and drop in a query to call upon that view 
    SELECT [Field List]
    FROM dbo_viewname
	 */
	
	select * from Report.daily_metrics_pivot_view p
	order by id asc
	
	
	