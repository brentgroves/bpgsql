/*
 * Test 1 text and email testing with the minimum users.  1 recipient per shift and level for SMS only recipients and 1 recipient per level for email/SMS recipients.
 */
/*
 * Make sure the following two sets have the SMS field filled in with the test phone #
 * list of email_check users to test
 */
--select * from Kors.notification_subset
select n.pcn,n.position,n.dept_name,n.last_name,n.first_name,n.email,n.SMS,n.customer_employee_no
--into Kors.notification_subset
from
(
	select n.pcn,1 shift,1 email_check,n.position,n.dept_name,n.last_name,n.first_name,n.email,n.SMS,n.customer_employee_no 
	from
	(
		select n.pcn,n.notify_level,r.shift_std, r.position,r.dept_name,r.last_name,r.first_name,r.email,r.SMS,n.customer_employee_no 
		from 
		(
			select n.pcn,n.notify_level,max(customer_employee_no) customer_employee_no
			from 
			(
				select n.pcn,n.notify_level,n.customer_employee_no 
				from Kors.notification n
				where n.email_check = 1
			) n 
			group by n.pcn,n.notify_level
		) n 
		inner join 
		(
				select r.pcn, r.shift_std, r.position,r.dept_name,r.last_name,r.first_name,r.email,r.SMS,r.customer_employee_no 
				from Kors.recipient r -- 36
		) r 
		on n.pcn=r.pcn 
		and n.customer_employee_no= r.customer_employee_no
	) n 
	group by n.pcn,n.position,n.dept_name,n.last_name,n.first_name,n.email,n.SMS,n.customer_employee_no 
UNION 
	/* list of NON email_check users to test */
	--select shift, position,dept_name,last_name,email 
	select n.pcn,n.shift_std shift,0 email_check, n.position,n.dept_name,n.last_name,n.first_name,n.email,n.SMS,n.customer_employee_no 
	from 
	(
		select n.pcn,n.notify_level,n.shift_std,r.position,r.dept_name,r.last_name,r.first_name,r.email,r.SMS,n.customer_employee_no 
		from
		(
			select n.pcn,n.notify_level,n.shift_std,max(customer_employee_no) customer_employee_no 
			from 
			( 
				select n.pcn,n.notify_level,r.shift_std,n.customer_employee_no 
				from Kors.notification n
				inner join Kors.recipient r
				on n.pcn = r.pcn
				and n.customer_employee_no=r.customer_employee_no
				where n.email_check = 0
			) n 
			group by n.pcn,notify_level,shift_std 
		) n -- no email check list
		inner join 
		(
				select r.pcn, r.position,r.dept_name,r.last_name,r.first_name,r.email,r.SMS,r.customer_employee_no 
				from Kors.recipient r -- 36
		) r 
		on n.pcn=r.pcn 
		and n.customer_employee_no= r.customer_employee_no
	) n 
	group by n.pcn,n.shift_std, n.position,n.dept_name,n.last_name,n.first_name,n.email,n.SMS,n.customer_employee_no 
) n order by n.pcn,n.email_check,n.shift,n.last_name



