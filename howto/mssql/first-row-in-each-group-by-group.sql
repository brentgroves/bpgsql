--first-row-in-each-group-by-group
WITH added_row_number AS (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY year ORDER BY result DESC) AS row_number
  FROM exam_results
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;