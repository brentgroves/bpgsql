
/*
 * All of the Plex.Part.Tool_Assembly_Part records Tool_BOMs will have restrictions 
 * under the MSC job with this description.
 */
-- drop table Maps.Tool_Part_Op
CREATE TABLE Maps.Tool_Part_Op (
	PCN int NOT NULL,
	original_process_id int NOT NULL,
	process_id int NOT NULL,
	part_operation_key int NOT NULL,  -- This is what should be in the MSC vending machine
	accounting_job_key int NOT NULL,
	accounting_job_no varchar(25) not null,
	partfamily varchar(50) not null,
	part_key int,
	part_no varchar(100) not null,
	operation_code varchar(30) not null
);
--select * from [Map].Part

select * from Maps.Tool_Part_Op po
where po.process_id= 54479


-- TRUNCATE table  myDW.Map.Tool_Part_Op
INSERT INTO Maps.Tool_Part_Op
(PCN, original_process_id,process_id,part_operation_key,accounting_job_key,accounting_job_no,partfamily,part_key,part_no,operation_code)
VALUES
(300758,0,0,7883645,105686,'TLG00000000048','',2802671,'2001268','Final'), -- 
(300758,0,0,7931266,0,'','',	2812246,'2001270','Final'), -- , 
(300758,0,0,7876436,0,'','',2794756,'2004917','Final'), -- , 
(300758,0,0,7876426,0,'','',2794756,'2004917','Machine A - WIP'), -- , 
(300758,0,0,7874348,0,'','',2794741,'2015898','Final'), -- , 
(300758,0,0,7874343,0,'','',2794741,'2015898','Machine A - WIP'), -- , 
(300758,0,0,7961936,0,'','',2820260,'10103358CD','Final'), -- , 
(300758,0,0,7961932,0,'','',2820260,'10103358CD','Machine A - WIP'), -- , 
(300758,0,0,7961929,0,'','',2820253,'10103357CD','Final'), -- , 
(300758,0,0,7961925,0,'','',2820253,'10103357CD','Machine A - WIP'), -- , 
(300758,0,0,7876294,105730,'TLG00000000092','',2794752,'10103358','Final'), -- , 
(300758,0,0,7876279,105730,'TLG00000000092','',2794752,'10103358','Machine A - WIP'), -- , 
(300758,0,0,7876272,105729,'TLG00000000091','',2794748,'10103357','Final'), --
(300758,0,0,7876263,105729,'TLG00000000091','',2794748,'10103357','Machine A - WIP'), --, 
(300758,0,0,7961801,0,'','',2820236,'10103353CX','Final'),-- ,
(300758,0,0,7961797,0,'','',2820236,'10103353CX','Machine A - WIP'), -- ,
(300758,0,0,7961915,0,'','',2820251,'10103355CX','Final'), --,
(300758,0,0,7961911,0,'','',2820251,'10103355CX','Machine A - WIP'), --,
(300758,54480,54480,7874377,105727,'TLG00000000089','10103353 DANA 6K RH VERT',2794731,'10103353','Final'),  -- no description on the process routing screen 
(300758,54484,61747,7874371,105727,'TLG00000000089','10103353H P558 6K RH',2794731,'10103353','Machine A - WIP'), -- OP 10/20 Horizontal Mill
(300758, 54479,54479,7874408,105728,'TLG00000000090','10103355 DANA 6K LH VERT',2794706,'10103355','Final'),  -- OP 30 Vertical Mill
(300758, 54485,61748,7874404,105728,'TLG00000000090','10103355H DANA P558 6K LH',2794706,'10103355','Machine A - WIP')  -- OP 10/20 Horizontal Mill,Machine A - WIP operation	

SELECT * FROM AlbSPS.jobs

select j.DESCR,tl.* 
from AlbSPS.TransactionLog tl 
inner join AlbSPS.Jobs j 
on tl.JOBNUMBER = j.JOBNUMBER 

select distinct j.DESCR,j 
from AlbSPS.TransactionLog tl 
inner join AlbSPS.Jobs j 
on tl.JOBNUMBER = j.JOBNUMBER 

10103351 - not in plex
10103353 - OK
10103355 - OK
10103355CX - not in VM
2004915 - not in plex
2004916 - not in plex
2009490 - not in plex
2009828 - not in plex
2015683 - not in plex
48439 - OK
51040 - not in plex
51355 - not in plex
53382 - not in plex
10013354 - not in plex
10037973 - not in plex
10037973 - not in plex
10103344 - not in ple 
















select * from AlbSPS.TransactionLogNO tl 

select * from AlbSPS.JobsNO jn -- 35
select * from AlbSPS.Jobs  -- 46

/*
Add 3 sets to DW
1. purchaseing_item_summary_DW
2. purchasing_item_usage_DW
3. purchasing_item_inventory_DW
*


select po.*,m.part_no, m.operation_code from [Map].Tool_Part_Op po 
inner join Plex.toolingModuleMetric m 
on po.part_operation_key = m.part_operation_key
where process_id = 54480


--Tool List, DANA 10013354 P558 6K RH KNUCKLE
-- Plex	10103353
(300758,23726,62576,2820292,51168,'DANA-10103344H P558 7K RH KNUCKLE')  -- uploaded
(300758,23564,54536,2820292,56035,'DANA-10103344 Vert P558 7K RH KNUCKLE') -- uploaded
(300758,28079,61763,2820294,56035,'DANA 10103351H P558 7K LH KNUCKLE')  -- uploaded
-- (300758,4912	54529,2820294,56035,'DANA 10103351 P558 7K LH KNUCKLE')  -- There is only one of these tool list in the Plex tooling module?
(300758,54484,61747, 2794731, 51168,'DANA - 10103353H P558 6K RH'),  -- uploaded
(300758,54480,54480, 2794731, 56035,'DANA - 10103353 DANA 6K RH VERT'),  -- uploaded 
(300758,54484,61747, 2820236, 51168,'DANA - 10103353H P558 6K RH'),  -- 10103353CX parts 
(300758,54480,54480, 2820236, 56035,'DANA - 10103353 DANA 6K RH VERT'),  -- 10103353CX parts



(300758, 54485, 105728, 2794706),  -- DANA - 10103355H DANA P558 6K LH
(300758, 54479, 105728, 2794706)  -- DANA - 10103355 DANA 6K LH VERT
-- (PCN, original_process_id, accounting_job_key, part_key)

(300758, 12876, , 2812248), --12876	DANA - 48439 SERVICE KNUCKLE, What tlg# for RH Service Knuckle pn#48439
(300758, 12883, 0, 0)
(300758, 28078, 105727, 2794731) --DANA 10013354 P558 6K RH KNUCKLE, Plex	10103353
(300758, 0, 0, 0)

--12876	DANA - 48439 SERVICE KNUCKLE
12883	DANA - 51355 SERVICE KNUCKLE
12887	DANA - 2009490H 6K KNUCKLE
12888	DANA - 2009828 6K KNUCKLE
12893	DANA - 2015683H 6K KNUCKLE
12916	DANA - 2009828 6K KNUCKLE
12932	DANA - 2004915H RH 7K KNUCKLE
12935	DANA - 2004915 7K KNUCKLE
13077	DANA - 2015685H 6K KNUCKLE
191	USM - 53379 GMT560 YOKE
23564	DANA-10103344 P558 7K RH KNUCKLE
23726	DANA-10103344H P558 7K RH KNUCKLE
24001	DANA 10037973H P558 6K LH KNUCKLE
26029	DANA 10037973 P558 6K LH KNUCKLE
28077	DANA 10013354H P558 6K RH KNUCKLE
28078	DANA 10013354 P558 6K RH KNUCKLE
28079	DANA 10103351H P558 7K LH KNUCKLE
28080	DANA 10103351 P558 7K LH KNUCKLE
4774	DANA - 2004916 7K KNUCKLE
4912	DANA - 10103351H LH 7K KNUCKLE
54479	DANA - 10103355 DANA 6K LH VERT
54480	DANA - 10103353 DANA 6K RH VERT
54484	DANA - 10103353H P558 6K RH
54485	DANA - 10103355H DANA P558 6K LH
MARKER	MARKER
/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681
2	295932 Fruit Port
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
*/
