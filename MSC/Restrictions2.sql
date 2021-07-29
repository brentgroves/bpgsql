select count(*) cnt from Restrictions2 r -- 798
select  * 
from Restrictions2 r 
--WHERE r_job = '12876'
where r_job in ('7884545') 
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



