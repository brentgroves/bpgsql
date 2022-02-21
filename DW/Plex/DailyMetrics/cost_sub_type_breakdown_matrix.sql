-- DROP TABLE Plex.cost_sub_type_breakdown_matrix;
-- TRUNCATE TABLE mgdw.Plex.cost_sub_type_breakdown_matrix;
CREATE TABLE Plex.cost_sub_type_breakdown_matrix(
	pcn int null,
	cost decimal(18,6) null,
	part_key int null,
	part_description varchar(100) null,  -- only a guess. map this to a plex column
	line_type varchar(100) null,-- only a guess. map this to a plex column
	cost_breakdown decimal(18,6) null,
	cost_type varchar(50) null,
	cost_model_key int null,
	cost_type_sort_order int null,
	revision varchar(8) null
	
)
select * from Plex.cost_sub_type_breakdown_matrix m

-- select distinct m.cost_type from Plex.cost_sub_type_breakdown_matrix m  -- 1559  --join part_description 
/*
cost_type  
-----------
Material   
Overhead   
Subcontract
Labor      
Total       
*/
 */
-- does cost always equal cost_breakdown? yes
select count(*) from Plex.cost_sub_type_breakdown_matrix_view -- 534
select * from Plex.cost_sub_type_breakdown_matrix_view -- 534
 /*
  * To compare these sets rearrange Plex.cost_sub_type_breakdown_matrix to have the same columns as the other 2 sets.
  */
 -- drop view Plex.cost_sub_type_breakdown_matrix_view 
create view Plex.cost_sub_type_breakdown_matrix_view 
as
select 
pcn,
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
	--pcn_part_revision,
	REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(replace(pcn_part_revision,'.','+')),'|','.'),1)),'+','.') pcn,
	REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(replace(pcn_part_revision,'.','+')),'|','.'),2)),'+','.') part_no,
	REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(replace(pcn_part_revision,'.','+')),'|','.'),3)),'+','.') revision,
--	REVERSE(PARSENAME(REPLACE(REVERSE(pcn_part_revision), '|', '.'), 1)) AS pcn,
--	REVERSE(PARSENAME(REPLACE(REVERSE(pcn_part_revision), '|', '.'), 2)) AS part_no,
--	REVERSE(PARSENAME(REPLACE(REVERSE(pcn_part_revision), '|', '.'), 3)) AS revision, 
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
) r 

-- are there the same number of parts in all sets? yes
select count(*) from Plex.cost_sub_type_breakdown_matrix_download;  -- 534
select count(*) from Plex.cost_type_breakdown_matrix_download d -- 534
select count(*) cnt from Plex.cost_sub_type_breakdown_matrix_view -- 534
where part_no is NULL 
where pcn is NULL 
where revision is NULL 
select * from Plex.cost_sub_type_breakdown_matrix_download;  -- 534  -- join part_description 
select * from Plex.cost_type_breakdown_matrix_download d -- 534 -- join part_description
select * from Plex.cost_sub_type_breakdown_matrix_view -- 534

-- Does all 3 data sources show the same material cost?       
select v.*
select count(*) cnt 
--into Scratch.missing_parts
from Plex.cost_sub_type_breakdown_matrix_view v -- no pcn info since pivot removed it.
inner join Plex.cost_sub_type_breakdown_matrix_download_view d 
on v.pcn = d.pcn
and v.part_no = d.part_description 
and v.revision = d.revision -- 534
inner join Plex.cost_type_breakdown_matrix_download t 
on v.pcn = t.pcn 
and v.part_no = t.part_description 
and v.revision = t.revision 
where d.pcn = 300758  -- 534
--and d.overhead = t.overhead  -- 534
--and v.overhead = t.overhead  -- 534
--and v.overhead = d.overhead  -- 534
--and d.total = t.total  -- 534
--and v.total = t.total  -- 534
--and v.total = d.total  -- 534
--and d.subcontract = t.subcontract  -- 534
--and v.subcontract = t.subcontract  -- 534
--and v.subcontract = d.subcontract  -- 534
--and d.labor = t.labor  -- 534
--and v.labor = t.labor  -- 534
--and v.labor = d.labor  -- 534
--and d.material = t.material  -- 534
--and v.material = t.material  -- 534
and v.material = d.material  -- 534


select count(*) cnt  
from Plex.cost_sub_type_breakdown_matrix m
where m.cost_type = 'Material'  -- 403

Part Description	Revision	Line Type	Material	Labor		Overhead	Total
001-0408-04W		28			Part		130.360000	27.090000	65.310000	222.760000   PASS

Part Description	Revision	Line Type	Material	Labor		Overhead	Total
10035417			A						8.793240	17.199790	184.191840	210.184870

Part Description	Revision	Line Type	Material	Labor	Overhead	Total
10035423			A			Part		8.793240	8.629790	29.321840	46.744870

Part Description	Revision	Line Type	Labor		Overhead	Total
10103344			A			Part		3.700000	12.882670	16.582670

Part Description	Revision	Line Type	Material	Labor		Overhead	Total
19X354217			A			Part		116.920000	18.679740	63.150330	198.750070

Part Description	Revision	Line Type	Labor		Overhead	Subcontract	Total
A82832RH			D			Part		1.026420	1.689020	2.230000	4.945440

A82832RH       |D       |  0.000000|  1.689020|   2.230000| 1.026420|  4.945440


