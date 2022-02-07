select * from part_v_cost_model_e m 
where m.primary_model = 1
--where m.cost_model_key = 116
--where m.cost_model like '%2022%'
--where m.pcn = 300758
--and m.primary =
--and m.cost_model like '%2022%'

/*
select * from part_v_part
where name like '%RDX%'
select * from common_v_period
select * from accounting_v_AR_Invoice
where invoice_no = 'AB20583'

  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Material') AS Material_Cost,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor') AS Direct_Labor_Cost,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Variable', 'Variable Overhead')) AS Variable_Overhead_Cost,
  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Fixed', 'Fixed Overhead')) AS Fixed_Overhead_Cost

select * FROM Accelerated_Standard_Cost_Part_v_e 
where pcn = 300758
and cost_type = 'Material'

select distinct cost_type FROM Accelerated_Standard_Cost_Part_v_e 
where cost_type = 'BOM'

select * FROM Accelerated_Standard_Cost_Part_v_e 
where part_key = 2960018
auto it.
select * from part_v_part where part_no = '51393TJB A040M1'
*/