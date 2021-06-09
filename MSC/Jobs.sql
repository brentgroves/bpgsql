select * from jobs
where jobnumber in ('28079')

select JOBNUMBER,DESCR from Jobs
select 
j.*
--j.JOBNUMBER,j.DESCR 
from Jobs j  -- 37
where j.descr like '%2009828%'
-- 1 job is Marker

select 
--j.jobnumber
j.jobnumber,j.descr,r.*
from jobs j 
inner join Restrictions2 r 
on j.JOBNUMBER = r.R_JOB 
where j.JOBNUMBER in ('12888','12916')


select * 
from Jobs_VendingMachineAssignment jvma  