Create a Power BI report from Plex 
1. Create a Plex Stored Procedure or identify a Plex web service with the data you need.
2. Create a Azure automation ETL script or SSIS ETL script to transfer the date from Plex to the data warehouse. Can ask Sam or Brent to do this.
3. Create a sql view in the data warehouse.
4. Create a Power BI report using the data warehouse sql view.
5. Publish the Power BI report to the Power BI test or live workspace. Can ask Sam or Brent to do this.
6. Add the report to a Microsoft teams tab. Can ask Sam or Brent to do this.

All you need to do is.
1. Install Power BI desktop on your laptop.
2. Create the Plex stored procedure or identify a web service with the data you need.
3. Create a sql view in the data warehouse.
4. Create a Power BI report using the data warehouse sql view.

Added benefit of Power BI reporting language.
You can set filters on specific columns.

Yes, Go to https://test.plexonline.com, You have to go Directly to this site. You can't switch databases from production. And you must have the Cumulus extension installed. 

Yes, Go to https://test.plexonline.com, You have to go Directly to this site. You can't switch databases from production. And you must have the Cumulus extension installed. 
Data warehouse connection string
mgsqlmi.public.48d444e7f69b.database.windows.net,3342
mgadmin
WeDontSharePasswords1!

Need access to All Reports

create procedure Plex.accounting_account_sproc
as 

create view Plex.accounting_account_view 
as 
