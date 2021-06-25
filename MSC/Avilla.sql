-- 172.20.90.51 sa/sps12345
select * from jobs

select JOBNUMBER,* from TransactionLog tl 
where JOBNUMBER != ''
and JOBNUMBER is not null
