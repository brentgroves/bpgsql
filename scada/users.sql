-- don't create a user here. use bpg-services because of encryption.
select * from users
delete from users where email = 'bgroves@buschegroup.com'