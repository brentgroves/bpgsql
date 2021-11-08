--select * from part_v_part


CREATE TABLE #ctePart
(
  PCN INT,
  Invoice_Link INT,
  Shipper_Line_Key INT,
  Customer_No INT,
  Part_No VARCHAR(100),
  Part_Key INT,
  Part_Operation_Key INT,
  Quantity DECIMAL(18,5),
  Part_Total_Revenue DECIMAL(18,2),
  Part_Name VARCHAR(100),
  Product_Type VARCHAR(50)
);

DECLARE
  @Today DATETIME = GETDATE(),
  @Grand_Total DECIMAL(18,2),
  @Cost_Type_Valuation_Columns VARCHAR(800);

SELECT @Cost_Type_Valuation_Columns =
  LEFT(F.OrdIDList, LEN(F.OrdIDList) - 1)
  FROM
  (
    SELECT
      T.Cost_Type + ','
    FROM
    (
      SELECT DISTINCT
        Sort_Order,
        ISNULL(NULLIF(CONVERT(VARCHAR(50), CT.Abbreviated_Cost_Type), ''), CT.Cost_Type) AS Cost_Type
      -- select * from common_v_cost_type_e where pcn= 300758  
      FROM Common_v_Cost_Type_e AS CT
      WHERE CT.PCN = @Plexus_Customer_No
        AND CT.Valuation_Column = 1
    ) AS T
    ORDER BY
      T.Sort_Order,
      T.Cost_Type
    FOR XML PATH('')
  ) AS F(OrdIdList);

--0select @Cost_Type_Valuation_Columns
-- Safety net: This should only happen when the PIT screen accessed from Plexus when the user chooses the customer
IF @Cost_Model_Key = -1
BEGIN
  SELECT TOP (1)
    @Cost_Model_Key = Cost_Model_Key
  FROM Part_v_Cost_Model_e
  WHERE PCN = @Plexus_Customer_No
    AND Primary_Model = 1;
END;
/*

SELECT TOP (1)
  Cost_Model_Key
FROM Part_v_Cost_Model_e
WHERE PCN = @Plexus_Customer_No
  AND Primary_Model = 1;
*/
IF @Date_Start IS NOT NULL OR @Date_End IS NOT NULL
BEGIN
  DECLARE
    @Current_Date DATETIME;
      SELECT
    @Current_Date = CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 101));
  

  SELECT
    @Period_Start = 0,
    @Period_End = 0,
    @Date_Start = ISNULL(@Date_Start, ISNULL(DATEADD(D, -1, DATEADD(M, -1, @Date_End)), @Current_Date)),
    @Date_End = ISNULL(@Date_End, ISNULL(DATEADD(D, -1, DATEADD(M, 1, @Date_Start)), DATEADD(D, -1, DATEADD(M, 1, @Current_Date))));
END;
--select @Current_Date,@Date_Start,@Date_End
--select count(*)  -- 364682,270425
--select    AID.Plexus_Customer_No AS PCN,AID.Account_No, A.Account_Name,i.invoice_no,i.invoice_link,p.part_no,q.quantity,aid.Unit_Price,
--aid.currency_amount,aid.quantity,aid.currency_amount/aid.quantity amount_div_quantity,DT_Container.part_operation_key,aid.*
select   I.Invoice_Link,
  AID.Shipper_Line_Key,
  I.Customer_No,
  P.Part_No,
  P.Part_Key,
  DT_Container.Part_Operation_Key,
  P.Name,
  PPT.Product_Type,
 -- sum(q.quantity) quantity
FROM accounting_v_AR_Invoice_e AS I
JOIN accounting_v_AR_Invoice_Dist_e AS AID
  ON AID.Plexus_Customer_No = I.Plexus_Customer_No
  AND AID.Invoice_Link = I.Invoice_Link
/*
The CROSS APPLY operator returns only those rows from the left table expression (in its final output) 
if it matches with the right table expression. In other words, the right table expression returns rows for the left table expression match only.
Same as inner join but in some cases the use of the APPLY operator boosts performance of your query. 
-- https://www.mssqltips.com/sqlservertip/1958/sql-server-cross-apply-and-outer-apply/
*/
CROSS APPLY
(
  SELECT
    A1.Plexus_Customer_No AS PCN,
    A1.Account_No,
    A1.Account_Name
  FROM accounting_v_Account_e AS A1
  WHERE A1.Plexus_Customer_No = AID.Plexus_Customer_No
    AND A1.Account_No = AID.Account_No
    AND A1.Category_Type = 'Revenue'
) AS A
LEFT OUTER JOIN Part_v_Part_e AS P
  ON P.Plexus_Customer_No = AID.Plexus_Customer_No
  AND P.Part_Key = AID.Part_Key
LEFT OUTER JOIN Part_v_Part_Product_Type_e AS PPT
  ON PPT.PCN = P.Plexus_Customer_No
  AND PPT.Product_Type_Key = P.Product_Type_Key 
LEFT OUTER JOIN Common_v_Building_e AS B
  ON B.Plexus_Customer_No = P.Plexus_Customer_No
  AND B.Building_Key = P.Building_Key   
-- Find the max part operation, why?
CROSS APPLY
(
  SELECT
    MAX(C.Part_Operation_Key) AS Part_Operation_Key
  FROM Sales_v_Shipper_Container AS SC WITH (INDEX(IX_Shipper_Line_Key))
  -- https://stackoverflow.com/questions/6529053/when-should-i-use-an-inner-loop-join-instead-of-an-inner-join
  -- There were certain cases where the optimizer wanted to select
  -- from Container before Shipper_Container.  
  -- Example: exec dbo.Customer_Revenue_By_Part_Get 162263,-1,201604,201604,NULL,NULL,-1,-1,0,0,0
  -- Adding this index hint helps fix this join order without forcing the order in the entire query.
  INNER LOOP JOIN Part_v_Container AS C WITH (INDEX(IX_Container_PT_Cost_History))
    ON C.Plexus_Customer_No = SC.PCN
    AND C.Serial_No = SC.Serial_No
  WHERE SC.PCN = AID.Plexus_Customer_No
    AND SC.Shipper_Line_Key = AID.Shipper_Line_Key
    -- Added Part_Key to where clause which helps prevent SQL Server from 
    -- thinking a spool is useful.  This extra equality is implied anyway 
    -- since the Part_Operation_Key returned in the result set is assumed to 
    -- be for the Part_Key.
    AND C.Part_Key = P.Part_Key
) AS DT_Container  

-- sum the quantities for the part_key of the ar_invoice_dist record
-- there may be multiple ar_invoice_dist records with the same invoice_link,shipper_line, and part_key
OUTER APPLY
(
  SELECT
    ISNULL(CASE WHEN SUM(D1.Unit_Price) = 0 THEN SUM(D1.Quantity) ELSE SUM(D1.Currency_Amount) / SUM(D1.Unit_Price) END, AID.Quantity) AS Quantity
  FROM accounting_v_AR_Invoice_Dist AS D1 WITH (INDEX(IX_Part_Key_Shipper_Line_Key))
  WHERE D1.Plexus_Customer_No = I.Plexus_Customer_No
    AND D1.Invoice_Link = I.Invoice_Link
    AND D1.Shipper_Line_Key = AID.Shipper_Line_Key
    AND D1.Part_Key = AID.Part_Key
) AS Q
WHERE I.Plexus_Customer_No = @Plexus_Customer_No
  AND (@Period_Start = 0 OR I.Period >= @Period_Start)
  AND (@Period_End = 0 OR I.Period <= @Period_End)
  AND (@Date_Start IS NULL OR I.Invoice_Date >= @Date_Start)
  AND (@Date_End IS NULL OR I.Invoice_Date <= @Date_End)
  AND I.Void = 0
  AND (@Customer_No = -1 OR I.Customer_No = @Customer_No)
  AND (@Exclude_No_Part = 0 OR P.Part_No IS NOT NULL)
  AND (@Part_Key = -1 OR AID.Part_Key = @Part_Key)
GROUP BY
  I.Invoice_Link,
  AID.Shipper_Line_Key,
  I.Customer_No,
  P.Part_No,
  P.Part_Key,
  DT_Container.Part_Operation_Key,
  P.Name,
  PPT.Product_Type
OPTION (RECOMPILE);
/*
where i.plexus_customer_no = @Plexus_Customer_No 
and i.period=202111
--and i.invoice_no = 'AB19852'
and aid.shipper_line_key = 30195993
and aid.invoice_link = 16844546
*/
/*

select * from Part_v_Container c
select * from sales_v_shipper_line where shipper_line_key =30195993
select c.part_key,p.part_no,c.part_operation_key,sc.* 
from sales_v_shipper_container sc
join part_v_container c 
on sc.serial_no=c.serial_no
join part_v_part p
on c.part_key=p.part_key
where shipper_line_key =30195993
--select * from common_v_building_e
select p.part_no,po.* from part_v_part p
join part_v_part_operation po
on p.part_key=po.part_key
where p.part_no in ('10103353','10103355')  -- 7874377,	8369213
order by part_no
*/
/*
INSERT dbo.#ctePart
(
  PCN,
  Invoice_Link,
  Shipper_Line_Key,
  Customer_No,
  Part_No ,
  Part_Key,
  Part_Operation_Key ,
  Quantity ,
  Part_Total_Revenue,
  Part_Name,
  Product_Type
)
SELECT
  @Plexus_Customer_No,
  I.Invoice_Link,
  AID.Shipper_Line_Key,
  I.Customer_No,
  P.Part_No,
  P.Part_Key,
  CASE WHEN P.Part_Key IS NULL THEN NULL ELSE DT_Container.Part_Operation_Key END,
  CASE 
    WHEN 
      EXISTS
      (  SELECT TOP(1)
           DCIU.Invoice_Link
         FROM dbo.AR_Invoice_Dist_Customer_Inventory_Usage AS DCIU
         WHERE  DCIU.PCN = MAX(I.Plexus_Customer_No)
           AND DCIU.Invoice_Link = I.Invoice_Link
           AND DCIU.Line_Item_No = MAX(AID.Line_Item_No)
      ) THEN
      SUM(Q.Quantity * CASE WHEN I.Credit_Memo = 1 THEN -1 ELSE 1 END) 
    ELSE 
      MAX(Q.Quantity)
  END,
  ISNULL(SUM(AID.Credit - AID.Debit),0),
  P.Name AS Part_Name,
  PPT.Product_Type
FROM accounting_v_AR_Invoice_e AS I
JOIN accounting_v_AR_Invoice_Dist_e AS AID
  ON AID.Plexus_Customer_No = I.Plexus_Customer_No
  AND AID.Invoice_Link = I.Invoice_Link
CROSS APPLY
(
  SELECT
    A1.Plexus_Customer_No AS PCN,
    A1.Account_No,
    A1.Account_Name
  FROM accounting_v_Account_e AS A1
  WHERE A1.Plexus_Customer_No = AID.Plexus_Customer_No
    AND A1.Account_No = AID.Account_No
    AND A1.Category_Type = 'Revenue'
) AS A
LEFT OUTER JOIN Part_v_Part_e AS P
  ON P.Plexus_Customer_No = AID.Plexus_Customer_No
  AND P.Part_Key = AID.Part_Key
LEFT OUTER JOIN Part_v_Part_Product_Type_e AS PPT
  ON PPT.PCN = P.Plexus_Customer_No
  AND PPT.Product_Type_Key = P.Product_Type_Key 
LEFT OUTER JOIN Common_v_Building_e AS B
  ON B.Plexus_Customer_No = P.Plexus_Customer_No
  AND B.Building_Key = P.Building_Key   
CROSS APPLY
(
  SELECT
    MAX(C.Part_Operation_Key) AS Part_Operation_Key
  FROM Sales_v_Shipper_Container AS SC WITH (INDEX(IX_Shipper_Line_Key))
  
  -- There were certain cases where the optimizer wanted to select
  -- from Container before Shipper_Container.  
  -- Example: exec dbo.Customer_Revenue_By_Part_Get 162263,-1,201604,201604,NULL,NULL,-1,-1,0,0,0
  -- Adding this index hint helps fix this join order without forcing the order in the entire query.
  INNER LOOP JOIN Part_v_Container AS C WITH (INDEX(IX_Container_PT_Cost_History))
    ON C.Plexus_Customer_No = SC.PCN
    AND C.Serial_No = SC.Serial_No
  WHERE SC.PCN = AID.Plexus_Customer_No
    AND SC.Shipper_Line_Key = AID.Shipper_Line_Key
    
    -- Added Part_Key to where clause which helps prevent SQL Server from 
    -- thinking a spool is useful.  This extra equality is implied anyway 
    -- since the Part_Operation_Key returned in the result set is assumed to 
    -- be for the Part_Key.
    AND C.Part_Key = P.Part_Key
) AS DT_Container
OUTER APPLY
(
  SELECT
    ISNULL(CASE WHEN SUM(D1.Unit_Price) = 0 THEN SUM(D1.Quantity) ELSE SUM(D1.Currency_Amount) / SUM(D1.Unit_Price) END, AID.Quantity) AS Quantity
  FROM accounting_v_AR_Invoice_Dist AS D1 WITH (INDEX(IX_Part_Key_Shipper_Line_Key))
  WHERE D1.Plexus_Customer_No = I.Plexus_Customer_No
    AND D1.Invoice_Link = I.Invoice_Link
    AND D1.Shipper_Line_Key = AID.Shipper_Line_Key
    AND D1.Part_Key = AID.Part_Key
) AS Q

WHERE I.Plexus_Customer_No = @Plexus_Customer_No
  AND (@Period_Start = 0 OR I.Period >= @Period_Start)
  AND (@Period_End = 0 OR I.Period <= @Period_End)
  AND (@Date_Start IS NULL OR I.Invoice_Date >= @Date_Start)
  AND (@Date_End IS NULL OR I.Invoice_Date <= @Date_End)
  AND I.Void = 0
  AND (@Customer_No = -1 OR I.Customer_No = @Customer_No)
  AND (@Exclude_No_Part = 0 OR P.Part_No IS NOT NULL)
  AND (@Part_Key = -1 OR AID.Part_Key = @Part_Key)
GROUP BY
  I.Invoice_Link,
  AID.Shipper_Line_Key,
  I.Customer_No,
  P.Part_No,
  P.Part_Key,
  DT_Container.Part_Operation_Key,
  P.Name,
  PPT.Product_Type
OPTION (RECOMPILE);
*/
