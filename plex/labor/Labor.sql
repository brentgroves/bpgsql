--select count(*) from common_v_Cost_Sub_Type 
--select * from common_v_Cost_Sub_Type 

-- Labor records screen
select
s1.part_key,
s1.part_no,
s1.hours,
cast((s1.runninTotal / 50) as int) as period
from
(
select
p.part_key,
p.part_no,
cc.quantity hours,
sum(cc.quantity) over (partition by p.part_key order by cc.cost_date) as runninTotal
from part_v_part p
inner join common_v_cost cc
on p.part_key=cc.part_key
inner join common_v_cost_sub_type cst
on cc.cost_sub_type_key = cst.cost_sub_type_key
where p.part_no = '18190-RNO-A012-S10'
and cc.cost_date >= '2020-07-01 00:00:00'
and cst.cost_sub_type = 'Production'
)s1

/*
select 
top(10) 
p.part_key,
p.part_no,
cc.job_key,
cc.quantity,
cc.cost_date
from part_v_part p
inner join common_v_cost cc
on p.part_key=cc.part_key
inner join common_v_cost_sub_type cst
on cc.cost_sub_type_key = cst.cost_sub_type_key
where p.part_no = '18190-RNO-A012-S10'
and cc.cost_date >= '2020-07-01 00:00:00'
and cst.cost_sub_type = 'Production'
ORDER by cc.cost_date
*/


/*
SELECT
  CustomerID,
  TransactionDate,
  Price,
  SUM(Price) OVER (PARTITION BY CustomerID ORDER BY TransactionDate) AS RunningTotal
FROM
  dbo.Purchases
*/