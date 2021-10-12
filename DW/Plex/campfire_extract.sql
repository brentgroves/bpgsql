/*
 * -- create schema Plex
-- drop table Plex.campfire_extract
--truncate table Plex.campfire_extract
CREATE TABLE Plex.campfire_extract 
(
id int, -- row_number() over( order by pcn,part_key,ship_to) id,
pcn int,
plexus_customer_code varchar(50), -- Plexus_Control_v_Customer_Group_Member.plexus_customer_code 
company varchar(50),  -- Plexus_Control_v_Customer_Group_Member.AD_Company_Code
part_key int,  -- added this for joins
part_number varchar(50), -- part_v_part.part_no
Destination_Code int, -- release.ship_to
Currency varchar(5),  -- Accounting_v_AR_Invoice_e.currency_code
Period int, -- Accounting_v_Period_e.Period  
Actual_Units float, -- --   SUM(Accounting_v_AR_Invoice_Dist_e.Quantity),
Actual_Local_Rev float, --SUM((SUM(Accounting_v_AR_Invoice_Dist_e.Quantity)*(Accounting_v_AR_Invoice_Dist_e.unit_price * Accounting_v_AR_Invoice_e.exchange_rate)) + (Accounting_v_AR_Invoice_Dist_e.taxable_amount * Accounting_v_AR_Invoice_e.exchange_rate))) AS Foreign_Price_Plus_Tax
Actual_USD_Rev float, --SUM(((Accounting_v_AR_Invoice_Dist_e.Unit_Price * SUM(Accounting_v_AR_Invoice_Dist_e.Quantity)) + Accounting_v_AR_Invoice_Dist_e.Taxable_Amount)) 
Actual_Local_Material_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) *  (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Material') )),0) AS Local_Material_Cost,
Actual_Local_Direct_Labor_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor'))),0)
Actual_Variable_Local_Overhead_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Variable', 'Variable Overhead')))),0) AS Local_Variable_Overhead_Cost,
Actuals_Local_Fixed_Cost float,--ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Fixed', 'Fixed Overhead')))),0) AS Local_Fixed_Overhead_Cost,
Actual_USD_Material_Cost float,-- ISNULL(SUM((SUM(Sales_v_Release_e.Quantity) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor'))),0) AS Foreign_Material_Cost,
Actual_USD_Direct_Labor_Cost float, --ISNULL(SUM((SUM(Sales_v_Release_e) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Type = 'Labor')) * RWC.Exchange_Rate),0) AS Foreign_Direct_Labor_Cost,
Actual_Variable_USD_Overhead_Cost float,-- ISNULL(SUM((SUM(Sales_v_Release_e) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Variable', 'Variable Overhead'))) * RWC.Exchange_Rate),0) AS Foreign_Variable_Overhead_Cost,
Actuals_USD_Fixed_Cost float, -- ISNULL(SUM((SUM(Sales_v_Release_e) * (SELECT SUM(SCP.Cost) FROM Accelerated_Standard_Cost_Part_v_e AS SCP WHERE SCP.PCN = R.PCN AND SCP.Part_Key = R.Part_Key AND SCP.Cost_Sub_Type IN ('Fixed', 'Fixed Overhead'))) * RWC.Exchange_Rate),0) AS Foreign_Fixed_Overhead_Cost,
CurrBacklogUnits int, -- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 0 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits1 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 1 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits2 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 2 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits3 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 3 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits4 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 4 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits5 int,-- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 5 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
BacklogUnits6 int, -- ISNULL((SELECT SUM(SUM(Sales_v_Release_e.Quantity)) FROM CTE_Summarized_Releases_By_Month AS CSRBM WHERE CSRBM.PCN = CDLI.PCN AND CSRBM.Month_Sequence = 6 AND CSRBM.Part_Key = CDLI.Part_Key AND CSRBM.Ship_To = CDLI.Ship_To),0) AS CurrBacklogUnits,
PRIMARY KEY (id)
);

*/
-- delete from Plex.campfire_extract where pcn in (300758)
select * from Plex.campfire_extract 
where pcn in (300758)
select count(*) from Plex.campfire_extract  -- 1639, 2930
where pcn = 300758 
--select count(distinct tool_no) from Plex.part_tool_BOM  -- 779
where pcn = 300758  -- Albion 1639
--where pcn = 310507  -- Avilla 1291
--where pcn = 306766 -- Edon 1818

select * from SSIS.ScriptComplete
--update SSIS.ScriptComplete set Done = 0
--select id,pcn from Plex.part_tool_BOM where pcn != 300758  -- 779


