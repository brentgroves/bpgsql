-- mgdw.Plex.Cost_Gross_Margin_Get definition

-- Drop table
-- mgdw.Plex.Cost_Gross_Margin_Daily definition

-- Drop table

-- DROP TABLE mgdw.Plex.Cost_Gross_Margin_Daily;

-- use our part numbers 
price from shipper. 

CREATE TABLE mgdw.Plex.Cost_Gross_Margin_Daily (
	PCN int NOT NULL,
	Plexus_Customer_Code varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Report_Date datetime NULL,
	Customer_Code varchar(35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Salesperson varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Order_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PO_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Product_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Description varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Sales_Qty decimal(19,5) NULL,
	Sales_Unit varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Quantity decimal(19,5) NULL,
	Quantity_Unit varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Unit_Price decimal(19,7) NULL,
	Revenue decimal(19,7) NULL,
	Invoice_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Group varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PO_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Net_Weight decimal(19,5) NULL,
	Total decimal(19,7) NULL,
	Customer_Abbreviated_Name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Currency_Code varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Gross_Margin_Key int NULL,
	Customer_Category varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Source varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Production_Qty decimal(19,5) NULL,
	Part_Revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Part_Revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Sequence_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Master_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Cost_Model_Key int NULL
);
 CREATE CLUSTERED INDEX IX_Plex_Cost_Gross_Margin_Daily ON Plex.Cost_Gross_Margin_Daily (  PCN ASC  , Report_Date ASC  , Gross_Margin_Key ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

select distinct pcn,Report_Date  from Plex.Cost_Gross_Margin_Daily order by pcn,Report_Date 
select * from Plex.Cost_Gross_Margin_Daily 
select * from Plex.Cost_Gross_Margin_Daily_View  order by pcn,Report_Date 
select * from Plex.Cost_Gross_Margin_Get
create view Plex.Cost_Gross_Margin_Daily_View
as
select 
	PCN,
	Plexus_Customer_Code,
	DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
	Customer_Code,
	Salesperson,
	Order_No,
	PO_No,
	Part_No,
	Product_Type,
	Part_Description,
	Sales_Qty,
	Sales_Unit,
	Quantity,
	Quantity_Unit,
	Unit_Price,
	Revenue,
	Invoice_No,
	Part_Type,
	Part_Group,
	PO_Type,
	Net_Weight,
	Total,
	Customer_Abbreviated_Name,
	Customer_Currency_Code,
	Gross_Margin_Key,
	Customer_Category,
	Customer_Type,
	Part_Source,
	Production_Qty,
	case 
	when part_revision is null then ''
	else part_revision 
	end revision,
	Customer_Part_No,
	Customer_Part_Revision,
	Sequence_No,
	Master_No,
	Cost_Model_Key
	from Plex.Cost_Gross_Margin_Daily  
