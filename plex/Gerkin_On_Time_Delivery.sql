/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681
2	295932 Fruit Port
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
	*/
	
DECLARE @Planning_Group_Mode TINYINT
DECLARE @Planning_Group_Group_Key INT = 1

exec Plexus_Control_p_Customer_Setting_Get2 @PCN, 'Part', 'Planning Group Groups Use', @Planning_Group_Mode OUTPUT
select @Planning_Group_Mode
IF @Planning_Group_Mode = 1 AND @Planning_Group_Key IS NOT NULL
BEGIN
  SET @Planning_Group_Group_Key = CAST(ISNULL(@Planning_Group_Key,0) AS INT)
END
select @Planning_Group_Mode,@Planning_Group_Group_Key


select top 10 
    R.PCN,
    R.PO_Line_Key,
    R.Release_Key,
    R.Release_No,
    R.Release_Status_Key,
    R.Due_Date,
    R.Ship_Date,
    R.Quantity,
    R.Add_Date,
    RC.Due_Date AS Original_Due_Date,
    RC.Ship_Date AS Original_Ship_Date
into #Original_Release_Dates_CTE    
  FROM sales_v_Release AS R
  JOIN sales_v_Release_Change AS RC
    ON RC.PCN = R.PCN
    AND RC.Release_Key = R.Release_Key
  JOIN sales_v_Release_Type AS RT
    ON RT.PCN = R.PCN
    AND RT.Release_Type_Key = R.Release_Type_Key
  WHERE R.PCN = @PCN
    AND RC.Previous_Change_Key_d IS NULL
    AND R.Ship_Date >= @Ship_Date_Start 
    AND R.Ship_Date < @Ship_Date_End 
    AND @On_Time_To_Request = 0
    AND RT.Allow_Ship = 1

-- select * from #Original_Release_Dates_CTE
  SELECT
    SC.PCN,
    SC.Release_Key,
    S.Ship_Date AS Actual_Ship_Date,
    SC.Quantity AS Quantity_Shipped
into #Release_Quantity_Shipped_CTE
FROM sales_v_Shipper_Container AS SC
  JOIN sales_v_Shipper_Line AS SL
    ON SL.PCN = SC.PCN
    AND SL.Shipper_Line_Key = SC.Shipper_Line_Key
  JOIN sales_v_Shipper AS S 
    ON S.PCN = SL.PCN
    AND S.Shipper_Key = SL.Shipper_Key
  WHERE SC.PCN = @PCN
--  select top 10 * from #Release_Quantity_Shipped_CTE

  SELECT
    ORD.PCN,
    ORD.PO_Line_Key,
    ORD.Release_Key,
    ORD.Release_No,
    ORD.Add_Date,
    RS.Release_Status,
    ORD.Due_Date,
    ORD.Ship_Date,
    ORD.Original_Due_Date,
    ORD.Original_Ship_Date,
    MAX(RQS.Actual_Ship_Date) AS Actual_Ship_Date,
    ORD.Quantity AS Release_Quantity,
    SUM(RQS.Quantity_Shipped) AS Quantity_Shipped,
    SUM(CASE
      WHEN @On_Time_To_Request=0 AND RQS.Actual_Ship_Date < ORD.Ship_Date THEN RQS.Quantity_Shipped
      WHEN @On_Time_To_Request=1 AND RQS.Actual_Ship_Date < ORD.Original_Ship_Date THEN RQS.Quantity_Shipped
      ELSE 0
    END) AS Early_Deliveries,
    SUM(CASE
      WHEN @On_Time_To_Request=0 AND RQS.Actual_Ship_Date >= ORD.Ship_Date AND RQS.Actual_Ship_Date < DATEADD(D,1,ORD.Ship_Date) THEN RQS.Quantity_Shipped
      WHEN @On_Time_To_Request=1 AND RQS.Actual_Ship_Date >= ORD.Original_Ship_Date AND RQS.Actual_Ship_Date < DATEADD(D,1,ORD.Original_Ship_Date) THEN RQS.Quantity_Shipped 
      ELSE 0
    END) AS On_Time_Deliveries,
    SUM(CASE
      WHEN @On_Time_To_Request=0 AND RQS.Actual_Ship_Date > DATEADD(D,1,ORD.Ship_Date) THEN RQS.Quantity_Shipped
      WHEN @On_Time_To_Request=1 AND RQS.Actual_Ship_Date > DATEADD(D,1,ORD.Original_Ship_Date) THEN RQS.Quantity_Shipped
      ELSE 0
    END) AS Late_Deliveries
into #Releases_CTE
  FROM #Original_Release_Dates_CTE AS ORD
  LEFT OUTER JOIN #Release_Quantity_Shipped_CTE AS RQS
    ON RQS.PCN = ORD.PCN
    AND RQS.Release_Key = ORD.Release_Key
  JOIN sales_v_Release_Status AS RS
    ON RS.PCN = ORD.PCN
    AND RS.Release_Status_Key = ORD.Release_Status_Key
  WHERE ORD.PCN = @PCN
    AND 
    (
      RS.Shipped_Status = 1 
      OR RS.Active = 1
      OR (RS.Closed_Status = 1 AND RQS.Quantity_Shipped > 0)
    )
  GROUP BY
    ORD.PCN,
    ORD.PO_Line_Key,
    ORD.Release_Key,
    ORD.Release_No,
    ORD.Add_Date,
    RS.Release_Status,
    ORD.Due_Date,
    ORD.Ship_Date,
    ORD.Original_Due_Date,
    ORD.Original_Ship_Date,
    ORD.Quantity
-- select * from #Releases_CTE
SELECT
  RCTE.PCN,
  PO.PO_Key,
  POL.PO_Line_Key,
  RCTE.Release_Key,
  RCTE.Release_No,
  C.Customer_No,
  C.Name AS Customer_Name,
  PO.PO_No,
  PT.PO_Type,
  RCTE.Due_Date,
  RCTE.Ship_Date,
  RCTE.Original_Due_Date,
  RCTE.Original_Ship_Date,
  P.Part_Key,
  P.Part_No,
  P.Revision,
  PG.Part_Group,
  PPT.Product_Type,
  RCTE.Release_Status,
  RCTE.Actual_Ship_Date,
  RCTE.Release_Quantity,
  RCTE.Quantity_Shipped,
  RCTE.Early_Deliveries,
  RCTE.On_Time_Deliveries,
  RCTE.Late_Deliveries,
  POL.Line_No,
  P.Planner,
  PU.Last_Name AS Planner_Last_Name,
  PU.First_Name AS Planner_First_Name,
  CASE WHEN @Planning_Group_Mode = 1 THEN GT.Group_Name ELSE PPP.Planning_Group END AS Planning_Group,
  P.Lead_Time,
  RCTE.Add_Date
FROM #Releases_CTE AS RCTE
JOIN sales_v_PO_Line AS POL
  ON POL.PCN = RCTE.PCN
  AND POL.PO_Line_Key = RCTE.PO_Line_Key
JOIN part_v_Part AS P
  ON P.Plexus_Customer_No = POL.PCN
  AND P.Part_Key = POL.Part_Key
LEFT OUTER JOIN part_v_Part_Planning_Parameters AS PPP
  ON PPP.PCN = P.Plexus_Customer_No
  AND PPP.Part_Key = P.Part_Key
LEFT OUTER JOIN Communication_v_Group_Table AS GT
  ON GT.Plexus_Customer_No = PPP.PCN
  AND GT.Group_Key = PPP.Planning_Group_Key
LEFT OUTER JOIN Plexus_Control_v_Plexus_User AS PU 
  ON PU.Plexus_Customer_No = P.Plexus_Customer_No
  AND PU.Plexus_User_No = P.Planner
LEFT OUTER JOIN Part_v_Part_Group AS PG
  ON PG.Plexus_Customer_No = P.Plexus_Customer_No
  AND PG.Part_Group_Key = P.Part_Group_Key
LEFT OUTER JOIN Part_v_Part_Product_Type AS PPT
  ON PPT.PCN = P.Plexus_Customer_No
  AND PPT.Product_Type_Key = P.Product_Type_Key
JOIN sales_v_PO AS PO
  ON PO.PCN = POL.PCN
  AND PO.PO_Key = POL.PO_Key
LEFT OUTER JOIN sales_v_PO_Type AS PT
  ON PT.PCN = PO.PCN 
  AND PT.PO_Type_Key = PO.PO_Type_Key
JOIN Common_v_Customer AS C
  ON C.Plexus_Customer_No = PO.PCN
  AND C.Customer_No = PO.Customer_No
WHERE RCTE.PCN = @PCN
/*
  AND (@Customer_No = ',' OR CHARINDEX (',' + CAST(C.Customer_No AS VARCHAR(20)), @Customer_No) > 0)
  AND (PT.PO_Type_Key = @PO_Type_Key OR @PO_Type_Key IS NULL)
  AND (PG.Part_Group_Key = @Part_Group_Key OR @Part_Group_Key IS NULL)
  AND (PPT.Product_Type_Key = @Product_Type_Key OR @Product_Type_Key IS NULL)
  AND (@Planner = -1 OR P.Planner = @Planner)
  AND (
    (@Planning_Group_Mode = 1 
    AND (@Planning_Group_Group_Key = 0 OR @Planning_Group_Group_Key = PPP.Planning_Group_Key))
    OR  
    (@Planning_Group_Mode = 0 
      AND (@Planning_Group_Key = '' OR @Planning_Group_Key = PPP.Planning_Group)))
-- OPTION (FORCE ORDER, RECOMPILE);
*/
