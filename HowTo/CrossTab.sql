USE tempdb;
CREATE TABLE ProductSales
( SalesPerson varchar(20),
  Product varchar(20),
  SalesAmount money )


INSERT INTO ProductSales
SELECT 'Bob','Pickles',100.00
UNION
SELECT 'Sue','Oranges',50.00
UNION
SELECT 'Bob','Pickles',25.00
UNION
SELECT 'Bob','Oranges',300.00
UNION
SELECT 'Sue','Oranges',500.00  

SELECT SalesPerson, [Oranges] AS Oranges, [Pickles] AS Pickles
FROM 
   ( SELECT SalesPerson, Product, SalesAmount
     FROM ProductSales 
   ) ps
PIVOT
   ( SUM (SalesAmount)
     FOR Product IN ( [Oranges], [Pickles])
   ) AS pvt
   

-- Dynamic CrossTab

USE tempdb;
CREATE TABLE dbo.Products
(
  ProductID INT PRIMARY KEY,
  Name      NVARCHAR(255) NOT NULL UNIQUE
  /* other columns */
);
INSERT dbo.Products VALUES
(1, N'foo'),
(2, N'bar'),
(3, N'kin');
CREATE TABLE dbo.OrderDetails
(
  OrderID INT,
  ProductID INT NOT NULL
    FOREIGN KEY REFERENCES dbo.Products(ProductID),
  Quantity INT
  /* other columns */
);
INSERT dbo.OrderDetails VALUES
(1, 1, 1),
(1, 2, 2),
(2, 1, 1),
(3, 3, 1);   

--/* HARD CODED
SELECT p.[foo], p.[bar], p.[kin]
FROM
(
  SELECT p.Name, o.Quantity
   FROM dbo.Products AS p
   INNER JOIN dbo.OrderDetails AS o
   ON p.ProductID = o.ProductID
) AS j
PIVOT
(
  SUM(Quantity) FOR Name IN ([foo],[bar],[kin])
) AS p;
--*/
DECLARE @columns as NVARCHAR(MAX), @sql as NVARCHAR(MAX)
SET @columns=N''
SELECT @columns += N', ' + QUOTENAME(p.Name) 
FROM dbo.Products p 
INNER JOIN dbo.OrderDetails AS o 
ON p.ProductID = o.ProductID
GROUP BY p.Name
SET @columns  = STUFF(@columns, 1, 2, '')
--select @columns
--SELECT STUFF(@columns, 1, 2, '')


SET @sql = N'
SELECT ' + @columns + '
FROM
(
	SELECT p.Name,o.Quantity 
    FROM dbo.Products p
	INNER JOIN dbo.OrderDetails o
 	ON p.ProductID = o.ProductID
) AS stg
PIVOT
(
 	SUM(stg.Quantity)
 	FOR stg.Name IN (' + @columns + ')
) AS pvt;'
--SELECT @sql

EXEC sp_executesql @sql;


