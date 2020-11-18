DECLARE 
  @Workcenter_code VARCHAR(50),
  @Workcenter_Key INT = 61324, --CNC103  
  @PCN INT = 	310507  --Avilla

set @Workcenter_code = 'CNC103'


-- Get the current workcenter setup
SELECT
  S.Setup_Key,
  SC.Serial_No,
  S.Part_Key,
  S.Part_Operation_Key,
  S.Job_Op_Key,
  SC.Setup_Container_Key,
  c.*,
  C.Quantity --Current Container Quantity
FROM part_v_Setup AS S
LEFT OUTER JOIN part_v_Setup_Container AS SC  
  ON SC.PCN = S.Plexus_Customer_No 
  AND SC.Workcenter_Key = S.Workcenter_Key
  AND SC.Setup_Key = S.Setup_Key
LEFT OUTER JOIN part_v_Container AS C
  ON C.Plexus_Customer_No = SC.PCN
  AND C.Serial_No = SC.Serial_No
WHERE S.Plexus_Customer_No = @PCN
  AND S.Workcenter_Key = @Workcenter_Key
