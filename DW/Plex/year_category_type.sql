--drop table Plex.account_year_category_type 
create table Plex.account_year_category_type 
(
	pcn int,
	account_no varchar(20),
	[year] int,
	category_type varchar(10),
	revenue_or_expense bit
)

select * from Plex.account_year_category_type 