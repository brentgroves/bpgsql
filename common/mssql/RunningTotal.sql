
SELECT
  CustomerID,
  TransactionDate,
  Price,
  SUM(Price) OVER (PARTITION BY CustomerID ORDER BY TransactionDate) AS RunningTotal
FROM
  dbo.Purchases
