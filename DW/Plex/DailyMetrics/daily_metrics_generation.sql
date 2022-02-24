-- daily_metrics_generation process

Use an ETL script to transfer the data from daily_shift_report_get Plex web service to the Plex.Daily_Shift_Report table in the DW. 
Resource: Sam.

Run DailyShiftReportDownload ETL script to import the daily shift report csv file that 
can be generated from Plex report download button. Import this data set into the mgdw.Plex.daily_shift_report_download
DW table to validate the Plex daily_shift_report_get web service.

Use an ETL script to transfer the data from Plex cost_gross_margin_get web service to the Plex.Cost_Gross_Margin_Daily table in the DW. 
Resource: Sam.



Definitions
Plex.Daily_Shift_Report -- The ETL script copies the Plex daily_shift_report_get web service data into this table.
Plex.Cost_Gross_Margin_Daily -- The ETL script copies the Plex cost_gross_margin_get web service data into this table.
Plex.Cost_Sub_Type_Breakdown_Matrix -- The ETL script copies the Plex cost_sub_type_breakdown_matrix web service data into this table.

Testing Only:
Plex.gross_margin_report -- The ETL script copies the Plex cost_gross_margin_get web service data into this table.
Plex.daily_shift_report_get -- The ETL script copies the Plex daily_shift_report_get web service data into this table.
Plex.daily_shift_report_get_view: replaces null values found in the Plex.daily_shift_report_get table.
Plex.cost_type_breakdown_matrix_download
Plex Mobex authored procedure: part_cost_model
Plex.daily_shift_report_get_aggregate_pcn_view: calculates values and assigns each an ID. The ID are listed
in the Updated_Daily Metrics 12.1.20211 spreadsheet on the Daily Metrics tab.