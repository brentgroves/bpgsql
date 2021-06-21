select count(*) cnt from Restrictions2 r -- 798
select top 10 * 
from Restrictions2 r 
where r_item = '13753'
-- where r_job = '28078'


select 
cast(ROW_NUMBER() over(order by R_JOB,R_ITEM) as int) id,
'300758' pcn,
R_JOB,
R_ITEM 
from Restrictions2 r 
