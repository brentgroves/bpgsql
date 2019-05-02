--Upload the item_location table into Cribmaster.PlxItemLocation table. 
select item_no,location,quantity
from
(
  select 
  --count(*)
  ROW_NUMBER() over(order by pi.item_no asc) as row#,
  pi.item_no,
  il.location,
  --pi.description,
  --il.quantity,
  CAST(il.quantity AS int) AS quantity
  from 
  purchasing_v_item_location il
  left outer join purchasing_v_item pi
  on il.item_key=pi.item_key
  --13591
  left outer join common_v_location cl
  on il.location=cl.Location
  --13591
  left outer join common_v_building cb
  on cl.building_key = cb.building_key
  --13591
  left outer join common_v_location_type lt
  on cl.location_type=lt.location_type
  --13591
  left outer join common_v_location_group lg
  on cl.location_group_key=lg.location_group_key
  --13591
  where
  --Building_code and location_group uniquely identify the locations as being for
  --the MRO.  Location_group of Maintenance Crib are messed up Maintenance locations
  --that should be excluded.
  cb.building_code = 'BPG Central Stores' --12700
  --lt.location_type='Supply Crib' --13525
  and --12700
  lg.location_group = 'MRO Crib' --12700
  --il.location ='' --66
  --or 
  --il.location = '09-01-01' --825
  --order by pi.item_no
)lv1
where row# > 12500  
--where row# > 10000 and row# <= 12500 
--where row# > 7500 and row# <= 10000 
--where row# > 5000 and row# <= 7500 
--where row# > 2500 and row# <= 5000 
--where row# <= 2500 --2500

CREATE PROCEDURE [dbo].[Purchasing_Item_Location_Get]
(
  @Start_Row INT,
  @End_Row INT
)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 04/30/19 bg: Created for CM Item_Location upload process.
SELECT Iem_No,Location,Quantity
FROM
(
  SELECT 
  ROW_NUMBER() OVER(ORDER BY PI.Item_No asc) as Row#,
  PI.Item_No,
  IL.Location,
  CAST(IL.Quantity AS INT) AS Quantity
  FROM Purchasing.dbo.Item_Location AS IL
  LEFT OUTER JOIN Purchasing.dbo.Item AS I
  ON IL.Item_Key=I.Item_Key
  LEFT OUTER JOIN Common.dbo.Location CL
  ON I.Location=CL.Location
  LEFT OUTER JOIN Common.dbo.Building CB
  ON CL.Building_Key = CB.Building_Key
  LEFT OUTER JOIN Common.dbo.Location_Type LT
  ON CL.Location_Type=LT.Location_Type
  LEFT OUTER JOIN Common.dbo.Location_Group LG
  ON CL.Location_Group_Key=LG.Location_Group_Key
  WHERE CB.Building_Code = 'BPG Central Stores' 
  AND LG.Location_Group = 'MRO Crib' 
)lv1
WHERE Row# > @Start_Row 
AND Row# <= @End_Row

RETURN;


