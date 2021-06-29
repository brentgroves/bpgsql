
/*
CREATE TABLE myDW.[Map].Part (
	PCN int NOT NULL,
	original_process_id int NOT NULL,
	accounting_job_key int NOT NULL,
	part_key int NOT NULL
);
*/

-- Facts table
/*
 * Add Busche managed tool cost and inventory adjustment stats
 */
select j.JOBNUMBER, j.descr, tl.* 
from AlbSPS.Jobs j
inner join AlbSPS.TransactionLog tl 
on j.jobnumber=tl.JOBNUMBER 
where j.JOBNUMBER <> 'MARKER'
and j.JOBNUMBER='54485'
and tl.UNITCOST = 0
order by j.JOBNUMBER 

/*

truncate table Plex.purchasing_item_usage
create table Plex.purchasing_item_usage
(
  id int,
  pcn int,
  item_key int,
  item_no varchar(50),
  trim varchar(50),
  accounting_job_key int,
  accounting_no varchar(20),
  location varchar(50),
  quantity int,
  usage_date datetime,
  total_cost decimal(19,4),
  transaction_type_key int,
  transaction_type varchar(50)	  
)
*/

/*
 * Plex item usage fact table
 */
select iu.pcn,iu.usage_date,m.part_key,iu.item_key,iu.quantity,iu.total_cost 
from Plex.purchasing_item_usage iu
inner join Maps.AccountingJobPart m 
on iu.pcn = m.pcn
and iu.accounting_job_key = m.accounting_job_key
where m.part_key in (2794731,2794706) ---- '10103353', '10103355'

/*
 * SPS item usage fact table
 * IDENTIFY THE JOB TRANSACTION AGAINST WRONG JOBS AND A VISUAL TO SHOW THE ISSUE
 * 
 */

select tl.pcn,tl.itemnumber,tl.transtartdatetime usage_date,
--m.part_key,
--i.item_key,
tl.qty quantity,tl.UNITCOST,tl.qty*tl.UNITCOST total_cost
-- select count(*)
from AlbSPS.TransactionLogNO tl -- 1863
-- left outer join Maps.Tool_Part_Op m 
-- on tl.PCN = m.PCN 
--and tl.JOBNUMBER = m.original_process_id -- 946
-- WHERE M.PCN IS NULL  -- ADD A VISUAL FOR THIS ISSUE
LEFT OUTER join Plex.purchasing_item_summary i -- NOT TOO MANY OF THESE
on tl.PCN =i.pcn
and tl.ITEMNUMBER = i.trim -- 803
WHERE I.PCN IS NULL  -- ADD A VISUAL FOR THIS ISSUE




-- Group by job
select j.PCN,j.JOBNUMBER, j.descr,count(*) withdrawals,sum(tl.qty) total_quantity 
from AlbSPS.JobsWithNumbersOnly j
inner join AlbSPS.TransactionLog tl 
on j.jobnumber=tl.JOBNUMBER 
group by j.PCN,j.JOBNUMBER, j.descr
having j.JOBNUMBER <> 'MARKER'
and j.JOBNUMBER in ('54485','54479'
order by j.JOBNUMBER 


where j.DESCR like '%10103351%'