/*
CREATE TABLE myDW.[Map].Part (
	PCN int NOT NULL,
	original_process_id int NOT NULL,
	accounting_job_key int NOT NULL,
	part_key int NOT NULL
);
*/

-- Detail Query
select j.JOBNUMBER, j.descr, tl.* 
from MSC.Job j
inner join [Map].Part mp 
on j.JOBNUMBER = mp.original_process_id 
inner join MSC.TransactionLog tl 
on j.jobnumber=tl.JOBNUMBER 
where j.JOBNUMBER <> 'MARKER'
order by j.JOBNUMBER 

-- Group by job
select j.PCN,j.JOBNUMBER, j.descr,count(*) withdrawals,sum(tl.qty) total_quantity 
from MSC.Job j
inner join [Map].Part mp 
on j.JOBNUMBER = mp.original_process_id 
inner join MSC.TransactionLog tl 
on j.jobnumber=tl.JOBNUMBER 
group by j.PCN,j.JOBNUMBER, j.descr
having j.JOBNUMBER <> 'MARKER'
order by j.JOBNUMBER 


where j.DESCR like '%10103351%'