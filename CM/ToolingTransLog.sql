-- m2mdata01.dbo.ToolingTransLog definition

-- Drop table

-- DROP TABLE m2mdata01.dbo.ToolingTransLog GO

CREATE TABLE m2mdata01.dbo.ToolingTransLog (
	JobNumber nvarchar(32),
	PartNumber nvarchar(25),
	Rev nvarchar(3),
	ItemNumber nvarchar(32),
	Qty int,
	UNITCOST money,
	TranStartDateTime smalldatetime NOT NULL,
	UserNumber nvarchar(32),
	UserName nvarchar(50),
	Plant nvarchar(3)
) GO
CREATE INDEX TranStartDateTimeIndex ON m2mdata01.dbo.ToolingTransLog (TranStartDateTime) GO;

declare @start datetime
set @start = '2020-01-01'
/*
primary_key: Determine primary key of result set.
*/
create table #primary_key
(
  	primary_key int,
  	plant nvarchar(3),
	ItemNumber nvarchar(32)
  
  year_week int,
  year_week_fmt varchar(10),
  start_week datetime,
  end_week datetime,
  customer_no int,
  part_key int
)

select 
top(100)
* 
from btItemQtyIssuedMonth


declare @start datetime
set @start = '2020-01-01'

select 
--transtartdatetime
count(*) 
from dbo.ToolingTransLog
where transtartdatetime >= @start
and Plant = 3  --5769



Declare @startDateParam DATETIME
Declare @endDateParam DATETIME
set @startDateParam = DATEADD (month ,-1, GETDATE())
set @endDateParam = GETDATE()
select itemNumber,qty from toolingtranslog
where transtartdatetime >= @startDateParam
and transtartdatetime <= @endDateParam
and plant = '3'
--and itemNumber like '%R'
--and itemNumber not like '%R'
and itemNumber <> ''