/*
There is a 1 to many relation between release_no and release_key.
Why:
I looked at release_no 644.
select * from sales_v_release where release_no = '644'
There were 4 release_keys with status of open, forecast.
There were 5 release keys with status of closed.
The add_date spanned a long period of time.
*/

select -- 143
distinct sr.release_no,
(
    SELECT SUBSTRING(
    (
        SELECT ',' + cast(Release_key as varchar(20))
        FROM sales_v_release sr2
        WHERE sr2.release_no = sr.release_no FOR XML PATH('')), 2, 200000)
)
from sales_v_release sr
where sr.release_no in 
(
  -- only multiple release_keys, 85 recs
  select release_no 
  from 
  (
    -- only active (open,staged,scheduled, open-scheduled) releases
    select release_no from sales_v_release sr
    inner join sales_v_release_status rs 
    on sr.release_status_key = rs.release_status_key
    where rs.active = 1
  ) ar
  group by release_no
  having count(*) > 1 
)
order by release_no desc


select count(*) from (
select distinct release_key from sales_v_release
 )sa --214949

select count(*) from (
select distinct release_key,release_no from sales_v_release
 )sa --214949

select count(*) from (
select distinct release_no from sales_v_release
 )sa --172887

select sr.*
from sales_v_release sr
where sr.release_no in 
(
select release_no from sales_v_release
group by release_no
having count(*) > 1
)
order by ship_date desc