/*
Can we say that if a container is currently in a finished location that it is ready to ship?
If we can say it is ready to ship then when exactly was it ready?
Was it ready to ship when the container was last moved?
Can we conclude that we completed X amount of parts on the last moved date of this container?

*/


select
--top 10
c.serial_no,
c.container_key,
c.Tracking_No,
c.location,
c.Last_Action,
c.Container_Status,
c.quantity,
cc.last_action
from part_v_container c
inner join part_v_container_change2 cc 
on c.serial_no=cc.serial_no  --1 to many
where c.serial_no = 'BM505566'
and c.location like 'Finished%'