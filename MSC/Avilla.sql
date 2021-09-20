-- 172.20.90.51 sa/sps12345
select * from jobs
select * from items

select JOBNUMBER,* from TransactionLog tl 
where JOBNUMBER = '50424'
where JOBNUMBER != ''
where JOBNUMBER is not NULL and JOBNUMBER != ''

where tl.JOBNUMBER = '12627' order by TRANSTARTDATETIME DESC 
JOBNUMBER is not NULL and JOBNUMBER != ''
where JOBNUMBER != ''
and JOBNUMBER is not null


select a.*,j.* 
from jobs j 
inner join Jobs_VendingMachineAssignment a 
on j.JOBNUMBER = a.JOBNUMBER 
where a.VMID = 6
