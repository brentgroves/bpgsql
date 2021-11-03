select distinct period,pcn from Plex.campfire_extract
order by period,pcn


/*
 * Accounts in campfire_extract 
 */

select c.pcn,c.period,c.part_number,a.part,c.actual_units,a.quantity 
select count(*)
from Plex.campfire_extract c
where 
--pcn=123681
pcn=300758
and period = 202110

/*
 * It was decided to group parts instead of having individual records for each customer
 */
/*
select a.pcn,a.period,a.part,sum(a.revenue) revenue,sum(a.quantity) quantity,max(a.total_percent) total_percent,
sum(a.material) material,sum(a.labor) labor,sum(a.overhead) overhead,sum(a.subcontract) subcontract, 
sum(a.total) total,sum(a.net_margin) net_margin
into Plex.revenue_analysis_by_part_grouped 
from Plex.revenue_analysis_by_part a
group by a.pcn,period,part
*/
select * from Plex.revenue_analysis_by_part_grouped
/*
 * Accounts in Revenue Analysis by Part report
 */
select count(*)
from Plex.revenue_analysis_by_part_grouped a
where 
--pcn=300758
pcn=123681
and period = 202110

/*
 * Accounts in campfire_extract but not in Plex Revenue Analysis by Part report
 */
select c.* 
--select count(*)
from Plex.campfire_extract c
left outer join Plex.revenue_analysis_by_part_grouped a 
on c.pcn=a.pcn
and c.part_number=a.part
and c.period=a.period
where 
--c.pcn = 300758
c.pcn = 123681
and c.period = 202110
and a.pcn is null
-- R104756
select a.*
from Plex.revenue_analysis_by_part a 
where a.part like '%472%'

/*
 * Accounts in Revenue Analysis by Part but not in campfire_extract
 */
select a.* 
--select count(*)
from Plex.revenue_analysis_by_part_grouped a 
left outer join Plex.campfire_extract c
on a.pcn=c.pcn
and a.part=c.part_number
and a.period=c.period
where 
--a.pcn = 300758
a.pcn = 123681
and a.period = 202110
and c.pcn is null
-- R104756
select c.*
from Plex.campfire_extract c 
where c.part_number like '%6059%'  --358-6059V

/*
 * Accounts in both campfire_extract and revenue by analysis report
 */
select a.* 
--select count(*)
from Plex.revenue_analysis_by_part_grouped a 
join Plex.campfire_extract c
on a.pcn=c.pcn
and a.part=c.part_number
and a.period=c.period
where 
--a.pcn = 300758
a.pcn = 123681
and a.period = 202110

select c.*
from Plex.campfire_extract c 
where c.part_number like '%6059%'  --358-6059V


/*
 * Revenue Analysis by Part and campfire_extract quantity differences
 */
select a.pcn,a.period,a.part,a.quantity rev_anal_quantity,c.actual_units campfire_quantity, a.quantity-c.actual_units quantity_diff 
--select count(*)
--into Plex.quantity_diff
from Plex.revenue_analysis_by_part_grouped a 
join Plex.campfire_extract c
on a.pcn=c.pcn
and a.part=c.part_number
and a.period=c.period
where 
--a.pcn = 300758
--a.pcn = 123681
--and a.period = 202101
--and a.quantity=c.actual_units  
--and a.quantity!=c.actual_units  
a.quantity!=c.actual_units  

select a.*
from Plex.revenue_analysis_by_part a 
where a.part like '%472%'

select c.*
from Plex.campfire_extract c 
where c.part_number like '%6059%'  --358-6059V


/*
 * Revenue Analysis by Part and campfire_extract revenue differences
 */
select a.pcn,a.part,a.revenue rev_anal_revenue,round(c.actual_local_rev,2) campfire_revenue_rounded, a.revenue - round(c.actual_local_rev,2) revenue_diff
--select count(*)
--select * 
-- into Plex.revenue_diff
from Plex.revenue_analysis_by_part_grouped a 
join Plex.campfire_extract c
on a.pcn=c.pcn
and a.part=c.part_number
and a.period=c.period
where 
--a.pcn = 300758
--a.pcn = 123681
--and a.period = 202110
--and a.revenue=round(c.actual_local_rev,2)  
--and a.revenue!=round(c.actual_local_rev,2)  
a.revenue!=round(c.actual_local_rev,2)  

select a.*
from Plex.revenue_analysis_by_part a 
where a.part like '%472%'

select c.*
from Plex.campfire_extract c 
where c.part_number like '%6059%'  --358-6059V

select c.pcn,c.period,c.part_number,a.part,c.actual_units,a.quantity 
from Plex.campfire_extract c
join Plex.revenue_analysis_by_part a 
on c.pcn=a.pcn
and c.part_number=a.part
and c.period=a.period
where 
pcn=123681
--and period=202101
--and period=202109
--and period=202110

select * from Plex.campfire_extract 
where 
pcn=300758
--and period=202101
--and period=202109
and period=202110

/*
create table Plex.campfire_validation
(
	pcn int not null,
	period int not null,
	part_key int not null,
	part_no varchar(50), 
	name varchar(100),
	quantity int,
	primary key (pcn,period,part_key)
)
*/
select 
v.pcn,
v.period,
v.part_key,
v.part_no,
v.name,
v.quantity
--select count(*)
from Plex.campfire_validation v  -- 211
where v.part_no = 'L1MW 4A028 GA'
