-- Plex.Cost_Sub_Type_Breakdown_Matrix

-- mgdw.Plex.Cost_Sub_Type_Breakdown_Matrix definition

-- Drop table

-- DROP TABLE mgdw.Plex.Cost_Sub_Type_Breakdown_Matrix;
/*
 * WRONG INDEX
 */
CREATE TABLE mgdw.Plex.Cost_Sub_Type_Breakdown_Matrix (
	PCN int NOT NULL,
	Plexus_Customer_Code varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Cost_Date datetime NULL,  -- This is now null 
	Cost decimal(19,5) NULL,
	Part_Key int NULL,
	Part_Description varchar(120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Line_Type varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, -- I think this corresponds to cost sub type on the Plex cost sub type breakdown matrix report.
	-- All 4,722 records have a line_type = 'Part'
	Cost_Breakdown decimal(19,5) NULL,
	Cost_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
	Cost_Model_Key int NULL,
	Cost_Type_Sort_Order int NULL,  -- I believe this is for the ordering of different cost types in Plex reports.
	Revision varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);
 CREATE CLUSTERED INDEX IX_Cost_Sub_Type_Breakdown_Matrix ON Plex.Cost_Sub_Type_Breakdown_Matrix (  PCN ASC  , Cost_Date ASC  , Revision ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
/*
 * Examine record set
 */
select *	
--select pcn,cost_model_key,part_key,cost_type,count(distinct cost_type_sort_order) 	
--select distinct cost_type_sort_order 	
--select distinct line_type 	
--select distinct cost_type 	
--select pcn,cost_date,part_key,cost_type,line_type 	
--select count(*)
from mgdw.Plex.Cost_Sub_Type_Breakdown_Matrix -- 4,722
where line_type = 'Part'  --4,722
where cost_type_sort_order !=1
and pcn = 300758
group by pcn,cost_model_key,part_key,cost_type  
having count(distinct cost_type_sort_order)  > 1  -- 0
cost_type_sort_order 
3
1
4
99999
2

Only has 1 Line_Type:Part
select distinct cost_type 	

Material
Overhead
Subcontract
Labor
Total

	
/*
 * What is the correct index/primary key for mgdw.Plex.Cost_Sub_Type_Breakdown_Matrix?
 */	
select pcn,cost_date,part_key,cost_type, count(*) cnt  	
--select count(*)
from mgdw.Plex.Cost_Sub_Type_Breakdown_Matrix -- 4,722
group by pcn,cost_model_key,cost_date,part_key,cost_type
having count(*) > 1 -- 0 records
/*
 * Do we need a view to replace null values?
 */
	select * 
	--select distinct pcn,plexus_customer_code
	-- select count(*)
	from Plex.Cost_Sub_Type_Breakdown_Matrix  -- 4,722
	--where Cost_Date is null -- 4,722
	where Revision IS null  -- 0
	where Revision != ''
	order by pcn,Plexus_Customer_Code 
	
/* 
 * Do we need a view to select a distinct pcn,part_key to be used.
 * The ETL script had multiple pcn,cost_model_key,part_key,cost_type records
 * so make a view that picks the one with the most recent one. 
 * I think the issue is fixed so the max_cost_date cte could be removed.
 */	
	/*
cost_type  
-----------
Material   
Overhead   
Subcontract
Labor      
Total       
*/
	
 /*
  * To compare these sets rearrange Plex.cost_sub_type_breakdown_matrix to have the same columns as the other 2 sets.
  */
 -- drop view Plex.cost_sub_type_breakdown_matrix_pivot_view 
create view Plex.cost_sub_type_breakdown_matrix_pivot_view 
as
select 
pcn,
cost_model_key,
--cost_date,
part_key,
part_no,
case 
when revision is null then ''
else revision 
end revision,
material,
overhead,
subcontract,
labor,
total
from 
(
	select 
--	pcn_part_revision,
	-- first replace is only needed if dots are in the original data.
	-- first set of 3 separated by | values
	reverse(parsename(REPLACE(REVERSE(replace(pcn_model_part_revision,'.','+')),'|','.'),1)) pcn,
--	reverse(parsename(REPLACE(REVERSE(replace(pcn_model_date_part_revision,'.','+')),'|','.'),2)) cost_date,
	reverse(parsename(REPLACE(REVERSE(replace(pcn_model_part_revision,'.','+')),'|','.'),2)) cost_model_key,
	reverse(parsename(REPLACE(REVERSE(replace(pcn_model_part_revision,'.','+')),'|','.'),3)) part_key,
--	reverse(parsename(REPLACE(REVERSE(replace(pcn_model_date_part_revision,'.','+')),'|','.'),4)) SecondHalf
--	replace(reverse(reverse(parsename(REPLACE(REVERSE(replace(pcn_model_date_part_revision,'.','+')),'|','.'),4))),'&','.') SecondHalf
	-- first replace is only needed if dots are in the original data.
	-- last replace is needed only because there are dots in the revision and maybe the part NO 
	replace(reverse(parsename(replace(reverse(reverse(parsename(REPLACE(REVERSE(replace(pcn_model_part_revision,'.','+')),'|','.'),4))),'&','.'),1)),'+','.') part_no,
	replace(reverse(parsename(replace(reverse(reverse(parsename(REPLACE(REVERSE(replace(pcn_model_part_revision,'.','+')),'|','.'),4))),'&','.'),2)),'+','.') revision,
--	replace(reverse(parsename(replace(reverse(reverse(parsename(REPLACE(REVERSE(replace(pcn_model_date_part_revision,'.','+')),'|','.'),4))),'&','.'),3)),'+','.') revision, 
	
	case 
	when material is null then 0
	else material
	end material,
	case 
	when overhead is null then 0
	else overhead
	end overhead,
	case 
	when subcontract is null then 0
	else subcontract
	end subcontract,
	case 
	when labor is null then 0
	else labor
	end labor,
	case 
	when total is null then 0
	else total
	end total
	from
	(
		SELECT 
		--m.pcn,m.cost_model_key, m.part_key,m.part_description,m.revision,m.line_type,m.cost_type_sort_order [Oranges] AS Oranges, [Pickles] AS Pickles
		pcn_model_part_revision,[Material] as material,[Overhead] overhead,[Subcontract] subcontract,[Labor] labor,[Total] total 
		--part_description,revision,[Material] as material,[Overhead] overhead,[Subcontract] subcontract,[Labor] labor,[Total] total 
		
		--select count(*) from (select distinct pcn_model_date_part_revision  -- 1573
		--select count(*) -- 1573
		FROM 
		   ( 
		   		select 
		   		-- only can use separator 3 times, If more than 3 item then you must use a different separator
		   		CONCAT(m.pcn,'|',m.cost_model_key,'|',m.part_key,'|',m.part_description,'&',m.revision) pcn_model_part_revision,  -- This will be the primary key
--		   		CONCAT(m.pcn,'|',m.cost_date,'|',m.cost_model_key,'|',m.part_key,'&',m.part_description,'&',m.revision) pcn_model_date_part_revision,  -- This will be the primary key
		   		m.cost_type,m.cost  
		--   		m.part_description+m.revision,m.cost_type,m.cost  -- strange results maybe trucation occurring
		--   		m.pcn,m.cost,m.part_key,m.part_description,m.line_type,m.cost_breakdown,m.cost_type,m.cost_model_key,m.cost_type_sort_order,m.revision  
		-- select *
		   		from Plex.Cost_Sub_Type_Breakdown_Matrix m
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
	
) r 
	where revision is not null 
	
	
select * 
from Plex.Cost_Sub_Type_Breakdown_Matrix

where Part_Description like '%RFA%'
select *
--select distinct pcn,cost_model_key,cost_date
from  Plex.Cost_Sub_Type_Breakdown_Matrix_Pivot_View m


select * 
--select count(*)
from Plex.daily_shift_report_get_view ds -- 3,336
left outer join  Plex.Cost_Sub_Type_Breakdown_Matrix_Pivot_View m
on ds.pcn = m.pcn 
and ds.part_key = m.part_key -- 3400

/*
 * Are there duplicate pcn,part_key in the breakdown matrix?
 */
select pcn,part_key,count(*) part_key_count 
from Plex.Cost_Sub_Type_Breakdown_Matrix_Pivot_View m
group by pcn,part_key 
having count(*) > 1

select *
from Plex.Cost_Sub_Type_Breakdown_Matrix_Pivot_View m
where part_key in 
(
select part_key 
from Plex.Cost_Sub_Type_Breakdown_Matrix_Pivot_View m
group by pcn,part_key 
having count(*) > 1
)
order by pcn,part_key



--where m.part_no = '%RFA%'
where m.cost_date = 'Feb 22 2022  4:17AM'

-- Do we have all the PCN in the Cost_Sub_Type_Breakdown_Matrix 
select *
--select distinct pcn, cost_model_key, cost_date 
--select count(*)
select distinct pcn, cost_model_key, cost_date
from  Plex.Cost_Sub_Type_Breakdown_Matrix m
order by m.pcn,Cost_Model_Key, Cost_Date 
select *
select distinct pcn
from Plex.cost_type_breakdown_matrix_download d -- 300758
-- are there the same number of parts in all sets? yes
select count(*) from Plex.cost_sub_type_breakdown_matrix_download;  -- 534
select count(*) cnt from Plex.cost_sub_type_breakdown_matrix_view -- 1,573
--where part_no is NULL 
--where pcn is NULL 
--where revision is NULL 

-- Does all 3 data sources show the same material cost?   
-- I downloaded inactive part numbers when I created the 2 download tables.
-- So disregard these part numbers. 
-- Does all 3 data sources show the same material cost?       
select *
--select count(*)
from Plex.cost_sub_type_breakdown_matrix_download_view d 
inner join  Plex.cost_type_breakdown_matrix_download t 
on d.pcn = t.pcn 
and d.part_description  = t.part_description 
and d.revision = t.revision -- 534
--left outer join Plex.cost_sub_type_breakdown_matrix_view v -- 
inner join Plex.cost_sub_type_breakdown_matrix_pivot_view v
on v.pcn = d.pcn
and v.part_no = d.part_description 
and v.revision = d.revision -- 534
where d.pcn = 300758  -- 534
and d.part_description not in ('A82833LH','10009044','A82832RH')  -- these are inactive part numbers 
--and d.overhead = t.overhead  -- 531
--and v.overhead = t.overhead  -- 531
--and v.overhead = d.overhead  -- 531
--and d.total = t.total  -- 531
--and v.total = t.total  -- 531
--and v.total = d.total  -- 531
--and d.subcontract = t.subcontract  -- 531
--and v.subcontract = t.subcontract  -- 531
--and v.subcontract = d.subcontract  -- 531
--and d.labor = t.labor  -- 531
--and v.labor = t.labor  -- 531
--and v.labor = d.labor  -- 531
--and d.material = t.material  -- 531
--and v.material = t.material  -- 531
--and v.material = d.material  -- 531
-- used in Plex to determine the currently active cost model.
select * from part_v_cost_model_e m 
where m.primary_model = 1


select * from Plex.cost_sub_type_breakdown_matrix_pivot_view 
where pcn = 123681
select * from Plex.cost_sub_type_breakdown_matrix_view v 
where part_no is NULL 
where pcn is NULL 
where revision is NULL 
	
	