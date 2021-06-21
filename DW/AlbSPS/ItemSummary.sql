select * from AlbSPS.ItemSummary

/*
 * Import all Busche Managed item numbers with unit cost 
 */
select * 
from AlbSPS.ItemSummary
where SUPPLIERNUMBER = 'BUSCHE'

/*
 * Can't find 8035 CPMT 21.52 MQ AP25N
 */
