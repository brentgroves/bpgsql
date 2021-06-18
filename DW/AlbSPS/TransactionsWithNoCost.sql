		select tl.pcn,tl.JOBNUMBER,tl.UNITCOST,tl.qty,(tl.UNITCOST*tl.qty) totalcost 
		from AlbSPS.TransactionLog tl
		inner join AlbSPS.Jobs j 
		on tl.PCN = j.PCN 
		and tl.JOBNUMBER = j.JOBNUMBER 
		where tl.VMID = 4
