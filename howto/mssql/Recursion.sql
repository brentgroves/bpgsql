WITH expression_name (column_list)
AS
(
    -- Anchor member
    initial_query  
    UNION ALL
    -- Recursive member that references expression_name.
    recursive_query  
)
-- references expression name
SELECT *
FROM   expression_name
/*
In general, a recursive CTE has three parts:

1. An initial query that returns the base result set of the CTE. The initial query is called an anchor member.
2. A recursive query that references the common table expression, therefore, it is called the recursive member. 
The recursive member is union-ed with the anchor member using the UNION ALL operator.
3. A termination condition specified in the recursive member that terminates the execution of the recursive member.
*/

WITH cte_numbers(n, weekday) 
AS (
	-- initial/anchor set
    SELECT 
        0, 
        DATENAME(DW, 0)
    UNION ALL
    -- Keep calling this until n = 6
    SELECT    
        n + 1, 
        DATENAME(DW, n + 1)
    FROM    
        cte_numbers
    WHERE n < 6
)
SELECT 
    weekday
FROM 
    cte_numbers;
--create schema Tutorial
DECLARE @employee TABLE
(
 	id int identity(1,1),
 	first_name varchar(10),
 	last_name varchar(10),
 	manager_id int
);
INSERT INTO @employee
VALUES 
('Maisy','Bloom',null),
('Caine','Farrow',1),
('Waqar','Jarvis',2),
('Lacey-Mai','Rahman',2),
('Merryn','French',3);
--select * from @employee

/*
In general, a recursive CTE has three parts:

1. An initial query that returns the base result set of the CTE. The initial query is called an anchor member.
2. A recursive query that references the common table expression, therefore, it is called the recursive member. 
The recursive member is union-ed with the anchor member using the UNION ALL operator.
3. A termination condition specified in the recursive member that terminates the execution of the recursive member.
*/
/*
How does this query work? 
It starts by running the first part (before the UNION ALL) and selects an employee without a manager (i.e. Maisy Bloom). 
Then the part beneath the UNION ALL selects the employee(s) directly managed by Maisy (Caine Farrow). 
Since the query is calling itself, it then runs the same part again and selects all the employees managed by Caine (Waqar Jarvis and Lacey-Mai Rahman). 
It repeats this operation as long as it has rows to join. After traversing the whole management chain, the query halts.
 */

WITH employee_chain (id,first_name,last_name,manager_id,chain2) AS 
(
-- anchor member: An initial query that returns the base result set of the CTE.
-- It starts by running the first part (before the UNION ALL) and selects an employee without a manager (i.e. Maisy Bloom). 
-- initial set is Maisy
  SELECT
    id,
    first_name,
    last_name,
    manager_id,
    cast(first_name + ' ' + last_name as varchar(255)) AS chain2
  FROM @employee e
  WHERE manager_id IS NULL
  -- recursive member
  -- Then the part beneath the UNION ALL selects the employee(s) directly managed by Maisy (Caine Farrow). 
  UNION ALL
  SELECT
    e.id,
    e.first_name,
    e.last_name,
    e.manager_id,
    cast(c.chain2 + '->' + e.first_name + ' ' + e.last_name as varchar(255)) -- chain keeps growing 
    
  FROM employee_chain c  -- is this a set that keeps growing
  JOIN @employee e
    ON e.manager_id = c.id
    -- Since the query is calling itself, it then runs the same part again and selects all the employees managed by Caine (Waqar Jarvis and Lacey-Mai Rahman). 
    -- run it again for wagar and add 2 more employees
    -- then run it for each one of those employees and so on.

)
 
SELECT
  id,
  first_name,
  last_name,
  manager_id,
  chain2
FROM employee_chain;

/*
A huge advantage of CTEs is that they can be used multiple times in a query. You don’t have to copy the whole CTE code – you simply put the CTE name.

Using the data from the previous section, we’d like to 
1) filter out the employees who don’t have a manager and then 
2) show each employee with their manager – but only if they have a manager. The result will look like this:
*/
DECLARE @employee TABLE
(
 	id int identity(1,1),
 	first_name varchar(10),
 	last_name varchar(10),
 	manager_id int
);
INSERT INTO @employee
VALUES 
('Maisy','Bloom',null),
('Caine','Farrow',1),
('Waqar','Jarvis',2),
('Lacey-Mai','Rahman',2),
('Merryn','French',3);
--select * from @employee

WITH not_null_manager AS (
  SELECT
    *
  FROM @employee
  WHERE manager_id IS NOT NULL
)
 
SELECT
  nnm1.first_name,
  nnm1.last_name,
  nnm2.first_name,
  nnm2.last_name
FROM not_null_manager AS nnm1
JOIN not_null_manager AS nnm2
  ON nnm1.manager_id = nnm2.id;

DECLARE @employee TABLE
(
 	id int identity(1,1),
 	first_name varchar(10),
 	last_name varchar(10),
 	manager_id int
);
INSERT INTO @employee
VALUES 
('Maisy','Bloom',null),
('Caine','Farrow',1),
('Waqar','Jarvis',2),
('Lacey-Mai','Rahman',2),
('Merryn','French',3);
--select * from @employee

SELECT
  nnm1.first_name,
  nnm1.last_name,
  nnm2.first_name,
  nnm2.last_name
FROM (
  SELECT
    *
  FROM @employee
  WHERE manager_id IS NOT NULL
) AS nnm1
JOIN (
  SELECT
    *
  FROM @employee
  WHERE manager_id IS NOT NULL
) AS nnm2
  ON nnm1.manager_id = nnm2.id;
  
 