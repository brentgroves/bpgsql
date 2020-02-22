--Query 1 - Direct Database Access (Server Level)
select 
--top 10 
name,isntname ,password,sysadmin
from sys.syslogins 
where sysadmin = 1 and hasaccess=1
union all 
select 
--top 10 
name,isntname ,password,sysadmin
from sys.syslogins 
where securityadmin = 1 and hasaccess=1

--Query 2 - Direct Database Access (Database level)
--drop table btRoleMember
CREATE TABLE btRoleMember (
	DbRole sysname NOT NULL,
	MemberName sysname NOT NULL,
	MemberSID varbinary(170)
);
select * from dbo.btRoleMember 
insert into dbo.btRoleMember (DbRole,MemberName,MemberSID )
--exec sp_helprolemember 'db_owner'
--exec sp_helprolemember 'db_datawriter'
--exec sp_helprolemember 'db_securityadmin'
--exec sp_helprolemember 'db_accessadmin'
exec sp_helprolemember 'db_ddladmin'