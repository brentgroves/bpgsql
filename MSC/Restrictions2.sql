/* 
 * Export 'TOOL SETTER' restrictions to pass on to MSC so they can create the SOT restrictions.
 */
select  'SOT' group_id, 'SOT_CERTIFIED' group_description, '7873079' job_number,'Drive Support - HXE66422' job_description, R_ITEM as item_number 
--select *  
from Restrictions2 r 
--WHERE r_job = '12876'
where r_job in ('7884545')
and r_item in ('16845','17137','17292')

select * from items where ITEMNUMBER like '%7982%'

select * from Jobs j where ltrim(rtrim(DESCR)) ='Support Front Control-R568616 Horz' like '%Support Front Control%' -- R568616 Horz'



select * from jobs j WHERE descr like  '%NSX%'
select count(*) cnt from Restrictions2 r -- 798
select  * 
from Restrictions2 r 
WHERE r_job = '7950328'
where r_job in ('7950328','7950317') and r_item in ('16845','17137','17292')
order by R_JOB 
--where r_item = '13753'
-- where r_job = '28078'
select * from UserGroups ug 
select * from Users u where 
descr like '%Domingo%'

select 
cast(ROW_NUMBER() over(order by R_JOB,R_ITEM) as int) id,
'300758' pcn,
R_JOB,
R_ITEM 
from Restrictions2 r 

select * 
from Jobs_VendingMachineAssignment v
where v.VMID = 4

select * from UserGroups ug 
select  * 
SELECT COUNT(*)
from Restrictions2 r 
where r_user = 'TOOL SETTER'  -- 1019



