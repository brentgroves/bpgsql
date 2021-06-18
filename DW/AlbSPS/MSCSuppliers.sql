select SUPPLIERNUMBER, count(*) item_cnt 
from items i
group by SUPPLIERNUMBER 
-- filter by vmid