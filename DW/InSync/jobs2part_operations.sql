/*
CREATE TABLE Map.Tool_Part_Op (
	PCN int NOT NULL,
	original_process_id int NOT NULL,
	process_id int NOT NULL,
	part_operation_key int NOT NULL,  -- This is what should be in the MSC vending machine
	accounting_job_key int NOT NULL,
	accounting_job_no varchar(25) not null,
	partfamily varchar(50) not null
);
--select * from [Map].Part
select * from albsps.jobs where 
SELECT CASE WHEN @Test NOT LIKE '%[^0-9]%' THEN CAST(@Test as int) ELSE 0 END 
*/

select 
j.jobnumber,
j.DESCR,
m.partfamily,
ta.assembly_no,
ta.description 
--j.*
from 
(
	select * from AlbSPS.Jobs j where j.JOBNUMBER NOT LIKE '%[^0-9]%'  -- filters MSC JOBNUMBER with non-numeric characters
) j
inner join [Map].Tool_Part_Op m 
on j.pcn=m.PCN 
and j.JOBNUMBER = m.original_process_id 
inner join Plex.part_tool_assembly ta 
on m.pcn= ta.pcn 
and m.part_operation_key = ta.part_operation_key 
where ta.part_no = '10103355'