 /* 
 Problem Reporting Open Master
 SELECT DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) AS StartOfMonth,
 DATEADD(year,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) startOfMonthLastYear,
 getdate() today,
 
 
 */
-- select o.Plexus_Customer_Code, o.building_code, o.year, o.month,o.month_name
select *
from
(
 select 
 case 
 when o.Plexus_Customer_Code is null then c.Plexus_Customer_Code
 else o.Plexus_Customer_Code
 end Plexus_Customer_Code,
 case 
 when o.building_code is null then c.building_code
 else o.building_code
 end building_code, 
 case 
 when o.year is null then c.year
 else o.year
 end year,
 case
 when o.month is null then c.month
 else o.month
 end month,
 case
 when o.month_name is null then c.month_name
 else o.month_name
 end month_name,
 isnull(o.opened,0) opened,
 isnull(o.formal_opened,0) formal_opened,
 isnull(o.informal_opened,0) informal_opened,
 isnull(c.closed,0) closed,
 isnull(C.formal_closed,0) formal_closed,
 isnull(C.informal_closed,0) informal_closed
from
(
  select gr.Plexus_Customer_Code, b.building_code, year(problem_date) year, month(problem_date) month,DateName( month , DateAdd( month , month(problem_date) , 0 ) - 1 ) month_name, count(*) opened,
  COUNT(CASE WHEN problem_category = 'Customer - Formal' THEN 1 END) formal_opened,
  COUNT(CASE WHEN problem_category = 'Customer - Informal' THEN 1 END) informal_opened

  -- select p2.plexus_customer_no,gr.Plexus_Customer_Code, b.building_code, p2.building_key, year(problem_date) year, month(problem_date) month
  -- select distinct p2.plexus_customer_no,gr.Plexus_Customer_Code, b.building_code, p2.building_key, year(problem_date) year, month(problem_date) month
  -- select count(*)
  from quality_v_problem_2_e as p2
  inner join  Plexus_Control_v_Customer_Group_Member gr
  on p2.Plexus_Customer_No = gr.Plexus_Customer_No -- 154
  inner join common_v_building_e b -- 140 dropped 14 but those are not in our filter
  -- left outer join common_v_building_e b 
  on p2.Plexus_Customer_No = b.Plexus_Customer_No 
  and p2.building_key=b.building_key  -- 154
  where problem_category in ('Customer - Formal', 'Customer - Informal')  -- 93
  and problem_status not in ( 'Cancelled', 'Closed')  -- 41
  -- DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
  and problem_date between DATEADD(year,-1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) AND GETDATE()
--  and problem_date between DATEADD(year,-1,GETDATE()) AND GETDATE()
  -- and b.building_key is null  -- 0 that match our filter
  group by gr.Plexus_Customer_Code, b.building_code, year(problem_date), month(problem_date)  -- 20
) o
full outer join 
(
 /* 
 Problem Reporting Closed Master
select DATEADD(year,-1,GETDATE()) AND GETDATE();
HDATE ( QUALITY_V_PROBLEM_2_E.QUALITY_V_PROBLEM_2_E.CLOSED_DATE , 'YYMD' ) 
 */
  select gr.Plexus_Customer_Code, b.building_code, year(closed_date) year, month(closed_date) month,DateName( month , DateAdd( month , month(closed_date) , 0 ) - 1 ) month_name, count(*) closed,
  COUNT(CASE WHEN problem_category = 'Customer - Formal' THEN 1 END) formal_closed,
  COUNT(CASE WHEN problem_category = 'Customer - Informal' THEN 1 END) informal_closed
  -- select p2.plexus_customer_no,gr.Plexus_Customer_Code, b.building_code, p2.building_key, year(problem_date) year, month(problem_date) month
  -- select distinct p2.plexus_customer_no,gr.Plexus_Customer_Code, b.building_code, p2.building_key, year(problem_date) year, month(problem_date) month
  -- select count(*)
  from quality_v_problem_2_e as p2
  inner join  Plexus_Control_v_Customer_Group_Member gr
  on p2.Plexus_Customer_No = gr.Plexus_Customer_No -- 154
  inner join common_v_building_e b -- 140 dropped 14 but those are not in our filter
  -- left outer join common_v_building_e b 
  on p2.Plexus_Customer_No = b.Plexus_Customer_No 
  and p2.building_key=b.building_key  -- 154
  where problem_category in ('Customer - Formal', 'Customer - Informal')  -- 93
  and problem_status ='Closed'  -- 46
  and closed_date between DATEADD(year,-1,GETDATE()) AND GETDATE()
  group by gr.Plexus_Customer_Code, b.building_code, year(closed_date), month(closed_date)  -- 21
) c
on o.Plexus_Customer_Code=c.Plexus_Customer_Code 
and o.building_code=c.building_code
and o.year=c.year
and o.month=c.month
)r order by r.Plexus_Customer_Code, r.building_code, r.year, r.month


