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
	
	
	select * from Report.daily_metrics p
	
	
	