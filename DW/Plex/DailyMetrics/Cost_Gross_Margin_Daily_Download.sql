-- CSV file headings
Customer,Salesperson,Order No,Cust PO,Invoice No,Part No,Part Revision,Customer Part No,Customer Part Revision,Description,Mfg Qty,Sales Qty,
Unit Price,Revenue,Part_Type,PO_Type,Net_Weight,Customer_Abbreviated_Name,Customer_Currency_Code,Part_Revision,Customer_Part_No,Customer_Part_Revision,
Master_No,Material Material,Labor Production,Overhead Variable,Gross Margin,Percent of Revenue

drop table Plex.cost_gross_margin_daily_download
CREATE TABLE mgdw.Plex.cost_gross_margin_daily_download (
	PCN int NOT NULL,
	Report_Date datetime NULL,
	Customer_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Salesperson varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Order_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PO_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  -- labeled as Cust PO
	Invoice_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Part_Revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Description varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, -- labeled as description	
	Production_Qty decimal(19,5) NULL,  -- labled as Mfg Qty
	Sales_Qty decimal(19,5) NULL,
	Unit_Price decimal(19,7) NULL,
	Revenue decimal(19,7) NULL,
	Part_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PO_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Net_Weight decimal(19,5) NULL,
	Customer_Abbreviated_Name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Currency_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Revision_2 varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, -- Labeled as Part Revision, 2 columns have the same name.
	Customer_Part_No_2 varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, -- Labeled as Customer_Part_No, 2 columns have the same name,
	Customer_Part_Revision_2 varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, -- Labeled as Customer_Part_Revision, 2 columns have the same name,
	Master_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	material decimal(19,7) NULL,
	labor decimal(19,7) NULL,
	overhead decimal(19,7) NULL,
	gross_margin decimal(19,7) null,
	percent_of_revenue decimal(19,7) null 
);

select * from Plex.cost_gross_margin_daily_download 
