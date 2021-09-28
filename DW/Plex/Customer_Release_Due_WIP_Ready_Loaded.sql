OBSELETE *** RENAMED TO PRP_Screen
-- mgdw.Plex.Customer_Release_Due_WIP_Ready_Loaded definition

-- Drop table

-- DROP TABLE mgdw.Plex.Customer_Release_Due_WIP_Ready_Loaded;

/*
create table mgdw.Plex.Customer_Release_Due_WIP_Ready_Loaded
(
ID int,
pcn int,
building_key int,
building_code varchar(50),
part_key int,
part_no varchar(100),
name varchar(100),
qty_rel int,
qty_shipped int,
qty_due int,
past_due int,
qty_wip int,
qty_ready int,
qty_loaded int,
qty_ready_or_loaded int
)
*/
select * 
from Plex.Customer_Release_Due_WIP_Ready_Loaded  