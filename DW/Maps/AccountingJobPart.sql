/*
 * Plex Accounting job key to part_key 
 */
CREATE table Maps.AccountingJobPart
(
	PCN int not null,
	accounting_job_key int not null,
	accounting_job_no varchar(25) not null,
	part_key int not null
)
insert into Maps.AccountingJobPart(PCN,accounting_job_key,accounting_job_no,part_key)
values 
(300758,105727,'TLG00000000089',2794731), -- '10103353'
(300758,105728,'TLG00000000090',2794706) -- '10103355'

select * from Maps.AccountingJobPart