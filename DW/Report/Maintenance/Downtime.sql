This seems like it would be a good Intelliplex report, since it is based on one plex table.
Jake Kunkel is the customer, but Holy Baxter is the contact for any questions.
Worked with Brad to look at the Plex tables and a few web service data sources.
Thank you Brad for finding the Plex table that has the information we need to summarize.

Plex Downtime Analysis report
This is what the customer currently uses and can be used for validation purposes.

What it does not include


Plan:
Get familiar with the data sources used to generate the Plex Downtime Analysis Report.

select * from Plex.Detailed_Production_History dph 
Production Status screen
workcenter production status report
Plex SPROC
part.dbo.Workcenter_Status_Get_All
Web service
Workcenter_Status_Get	16511	Workcenter Tracking	Stored Procedure	 	Glen Tillman
Workcenter_Status_Get_All	6265	Workcenter List	Stored Procedure	 	Glen Tillman
Workcenter_Status_Key_Get	8339	Workcenter List	Stored Procedure	 	Thomas Schulte
Workcenter_Status_Summary	6674	Workcenter List	Stored Procedure	 	Barrie Vince
Workcenter_Status_Summary_Report_Get

select count(*) 
select *
from part_v_workcenter_status 

select *
from part_v_workcenter_log wl
where workcenter_key = 58322
order by wl.log_date desc