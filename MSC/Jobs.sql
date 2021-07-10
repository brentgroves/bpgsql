select j.* 
from jobs j 
inner join Jobs_VendingMachineAssignment a 
on j.JOBNUMBER = a.JOBNUMBER 

and a.VMID = 5

select 
--  ROW_NUMBER() OVER(PARTITION BY recovery_model_desc ORDER BY name ASC) 
ROW_NUMBER () over (partition by j.JOBNUMBER order by r.R_ITEM) row#,
j.JOBNUMBER,j.DESCR,j.ALIAS,j.JOBENABLE,a.VMID,r.R_ITEM 
from jobs j 
inner join Jobs_VendingMachineAssignment a 
on j.JOBNUMBER = a.JOBNUMBER 
INNER join Restrictions2 r 
on j.JOBNUMBER = r.R_JOB 
and a.VMID = 5


where JOBNUMBER IN ('2684942',  '2684943' )
select * from Jobs_VendingMachineAssignment 
--where JOBNUMBER IN ('2684942', '2684943')  
where vmid = 5 
SELECT * 
FROM Restrictions2 r 
INNER
WHERE r_JOB IN ('2684942', '2684943','2803944')

SELECT count(*) FROM Restrictions2 r WHERE r_JOB IN ('2684942', '2684943')  -- 26
jobnumber=partkey nvarchar(32)
descr = nvarchar(50) part_no plus an optional op# or hone,horz,vert,
alias = part_no nvarchar(50)
select * from items where descr like '%5%MM%'
select * from JobGroups jg 
select * from ItemGroups ig 
select * from items where ItemGroup in ('12345','223456')
--tool_assy_key,T01-1ST OP HORIZONTAL MILL
/*
select 
cast(ROW_NUMBER() OVER(ORDER BY J.JOBNUMBER) as int) ID,
'300758' PCN,
vm.VMID, 
j.JOBENABLE,
j.JOBNUMBER,
j.DESCR 
--select count(*)
from jobs j -- 38
inner join  Jobs_VendingMachineAssignment vm -- 149
on j.JOBNUMBER = vm.JOBNUMBER 
where vm.VMID in (4) -- (vmid 4 / plant 6 / 37 jobs),
*/
/*
CREATE TABLE myDW.AlbSPS.Jobs (
	ID int not null,
	PCN int NOT NULL,
	VMID int NOT NULL,
	JOBENABLE int NOT NULL,
	JOBNUMBER nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	DESCR nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);
*/
/*
It looks like the same jobs are in all the vending machines by looking at
the VMID in the Jobs_VendingMachineAssignment vm table.  I believe there are 
3 vmid assigned to the glove machines and 1 that is for the plant 6 VM.
After looking at the transaction log it seems the VMID for plant 6 is 4.
select 
vm.VMID, 
j.* 
--select count(*)
from jobs j -- 38
left outer join 
(
	select * from Jobs_VendingMachineAssignment vm -- 149
	where vm.VMID = 4
) vm
on j.JOBNUMBER = vm.JOBNUMBER -- 149
where (vm.VMID is null)

where vm.JOBNUMBER is NULL 
where vm.VMID = 4  -- 37
where jobnumber in ('28079')
*/
/*
select 
--j.jobnumber
j.jobnumber,j.descr,r.*
from jobs j 
inner join Restrictions2 r 
on j.JOBNUMBER = r.R_JOB 
where j.JOBNUMBER in ('12888','12916')
*/

