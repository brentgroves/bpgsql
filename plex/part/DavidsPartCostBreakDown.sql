 SELECT T1."Plexus_Customer_No",T1."Part_Key",T1."Part_No",
 T1."Name",T1."Part_Status",T1."Part_Source_Key",
 T2."Plexus_Customer_Code",T3."PCN",T3."Cost_Model_Key",
 T3."Part_Key",T3."Cost",T3."Recalc_Date",T4."Cost",T6."PCN",
 T6."PO_Line_Key",T6."Active",T7."Price_Key",T7."Effective_Date",
 T7."Price",T7."Active",T7."Expiration_Date" FROM ( ( ( ( (
 Plex.Part_v_Part_e T1 LEFT OUTER JOIN
 Plex.Plexus_Control_v_Customer_Group_Member T2 ON
 T2."Plexus_Customer_No" = T1."Plexus_Customer_No" ) LEFT OUTER
 JOIN Plex.Part_v_Part_Cost_e T3 ON T3."PCN" =
 T1."Plexus_Customer_No" AND T3."Part_Key" = T1."Part_Key" )
 LEFT OUTER JOIN Plex.Part_v_Cost_Component_e T4 ON T4."PCN" =
 T3."PCN" AND T4."Cost_Model_Key" = T3."Cost_Model_Key" AND
 T4."Part_Key" = T3."Part_Key" ) LEFT OUTER JOIN
 Plex.Sales_v_PO_Line_e T6 ON T6."PCN" = T1."Plexus_Customer_No"
 AND T6."Part_Key" = T1."Part_Key" ) LEFT OUTER JOIN
 Plex.Sales_v_Price_e T7 ON T7."PCN" = T6."PCN" AND
 T7."PO_Line_Key" = T6."PO_Line_Key" ) WHERE
 (T1."Part_Source_Key" IN(373, 788)) AND (T1."Part_Status"
 IN('Pre-Production', 'Preproduction', 'Production', 'Service'))
 AND (T6."Active" = 1) AND (T7."Active" = 1);