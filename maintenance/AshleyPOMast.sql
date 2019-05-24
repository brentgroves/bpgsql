create procedure [dbo].[bpPORT] 
	@currentPO as char(6)
AS
BEGIN
SET NOCOUNT ON
insert into btpomast
(
fpono,cribpo,fcompany,fcshipto, forddate,fstatus,fvendno,fbuyer,
fchangeby,fshipvia, fcngdate, fcreate, ffob, fmethod, foldstatus, fordrevdt, 
fordtot,fpayterm,fpaytype,fporev,fprint,freqdate,freqsdt,freqsno, frevtot, 
fsalestax, ftax, fcsnaddrke, fnnextitem, fautoclose,fnusrqty1,fnusrcur1, fdusrdate1,fcfactor,
fdcurdate, fdeurodate, feurofctr, fctype, fmsnstreet, fpoclosing,fndbrmod, 
fcsncity, fcsnstate, fcsnzip, fcsncountr, fcsnphone,fcsnfax,fcshcompan,fcshcity,
fcshstate,fcshzip,fcshcountr,fcshphone,fcshfax,fmshstreet,
flpdate,fconfirm,fcontact,fcfname,fcshkey,fcshaddrke,fcusrchr1,fcusrchr2,fcusrchr3,
fccurid,fmpaytype,fmusrmemo1,freasoncng
)
select @currentPO -1 + row_number() over (order by PONumber)as fpono,PONumber cribpo,fccompany fcompany,
'SELF' fcshipto, PODate forddate,'OPEN' fstatus,UDFM2MVENDORNUMBER fvendno,'CM' fbuyer,
'CM' fchangeby,'UPS-OURS' fshipvia, PODate fcngdate,PODate fcreate,
'OUR PLANT' ffob,'1' fmethod,'STARTED' foldstatus,'1900-01-01 00:00:00.000' fordrevdt, 
0 fordtot,fcterms fpayterm,'3' fpaytype, '00' fporev,'N' fprint,'1900-01-01 00:00:00.000' freqdate,
PODate freqsdt,'' freqsno, 0 frevtot, 0 fsalestax, 'N' ftax, '0001' fcsnaddrke, 1 fnnextitem,
'Y' fautoclose,0 fnusrqty1,0 fnusrcur1,'1900-01-01 00:00:00.000' fdusrdate1,0 fcfactor,
'1900-01-01 00:00:00.000' fdcurdate,'1900-01-01 00:00:00.000' fdeurodate,0 feurofctr,'O' fctype,
fmstreet fmsnstreet,
'Please reference our purchase order number on all correspondence.  ' +
'Notification of changes regarding quantities to be shipped and changes in the delivery schedule are required.' + 
CHAR(13) + CHAR(13) + 
'PO APPROVALS:' + CHAR(13) + CHAR(13) +
'Requr. _______________________________________________' + CHAR(13) + 
'Dept. Head ___________________________________________' + CHAR(13) + CHAR(13) + 
'G.M. or Exec. Asst.: For All P.O.''s Over $500.00' + CHAR(13) + 
'G.M. or E.A.: ________________________________________' + CHAR(13) + 
'Plant Controller Only: All Assests/CER and ER Over $10,000.00' + CHAR(13) + 
'Plant Controller______________________________________' + CHAR(13) + 
'Pres. Only: All Assets/CER/ER and/or PO''s Over $10,000.00' + CHAR(13) + 
'President ____________________________________________' fpoclosing,0 fndbrmod,
fccity fcsncity,fcstate fcsnstate,fczip fcsnzip, fccountry fcsncountr,fcphone fcsnphone,fcfax fcsnfax,
'BUSCHE INDIANA' fcshcompan,'ALBION' fcshcity,'IN' fcshstate,'46701' fcshzip,'USA' fcshcountr,
'2606367030' fcshphone, '2606367031' fcshfax,'1563 E. State Road 8' fmshstreet,
'1900-01-01 00:00:00.000' flpdate,'' fconfirm,'' fcontact,'' fcfname,'' fcshkey,'' fcshaddrke,
'' fcusrchr1,'' fcusrchr2,'' fcusrchr3,'' fccurid,'' fmpaytype,'' fmusrmemo1,'Automatic closure.' freasoncng 
from 
(
	SELECT PONumber,Vendor,PODate 
	FROM [PO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)
)po1
inner join 
(
	select VendorNumber,UDFM2MVENDORNUMBER from vendor 
)vn1
on po1.Vendor = vn1.VendorNumber
inner join
(
	SELECT fvendno,fcterms,fccompany,fccity,fcstate,fczip,fccountry,fcphone,fcfax,fmstreet FROM btapvend  
)av1
on vn1.UDFM2MVENDORNUMBER=av1.fvendno

update PO
set PO.VendorPO = pom.fpono
--select po.ponumber,pom.cribpo,pom.fpono,po.vendorpo
from [PO] po 
inner join
btpomast pom
on 
po.PONumber=pom.cribPO
WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

insert into btpoitem
(
fpono, cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
)
SELECT 
po.VendorPO fpono, po.PONumber cribPO, fpartno,frev,fmeasure,fitemno,frelsno,
fcategory,fjoopno,flstcost,fstdcost,fleadtime,forgpdate,flstpdate,
fmultirls,fnextrels,fnqtydm,freqdate,fretqty,fordqty,fqtyutol,fqtyltol,
fbkordqty,flstsdate,frcpdate,frcpqty,fshpqty,finvqty,fdiscount,fstandard,
ftax,fsalestax,flcost,fucost,fprintmemo,fvlstcost,fvleadtime,fvmeasure,
fvptdes,fvordqty,fvconvfact,fvucost,fqtyshipr,fdateship,fnorgucost,
fnorgeurcost,fnorgtxncost,futxncost,fvueurocost,fvutxncost,fljrdif,
fucostonly,futxncston,fueurcston,fcomments,fdescript,fac,fndbrmod,
SchedDate,fsokey,fsoitm,fsorls,fjokey,fjoitm,frework,finspect,fvpartno,
fparentpo,frmano,fdebitmemo,finspcode,freceiver,fcorgcateg,fparentitm,fparentrls,frecvitm,
fueurocost,FCBIN,FCLOC,fcudrev,blanketPO,PlaceDate,DockTime,PurchBuf,Final,AvailDate
FROM 
(
	SELECT PONumber,vendorPO
	FROM [PO]  
	WHERE POSTATUSNO = 3 and SITEID <> '90' and (BLANKETPO = '' or BLANKETPO is null)

)po
inner join
(
	select
	'' fsokey,'' fsoitm,'' fsorls,'' fjokey,'' fjoitm,'' frework,'' finspect,'' fvpartno,'' fparentpo, 
	'' frmano,'' fdebitmemo,'' finspcode,'' freceiver,'' fcorgcateg,'' fparentitm,'' fparentrls,'' frecvitm,
	0.000 fueurocost,'' FCBIN,'' FCLOC,'' fcudrev,0 blanketPO,
	'1900-01-01 00:00:00.000' PlaceDate,0 DockTime,0 PurchBuf,0 Final,
	'1900-01-01 00:00:00.000' AvailDate,
	'1900-01-01 00:00:00.000' SchedDate,
	PONumber,left(ItemDescription,25) fpartno,'NS' frev, 'EA' fmeasure, 
	case 
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 99 then cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	when (row_number() over (PARTITION BY PONumber order by ItemDescription )) > 9 then ' ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	else '  ' + cast((row_number() over (PARTITION BY PONumber order by ItemDescription )) as char(3))
	end	as fitemno, '  0' frelsno,
	UDF_POCATEGORY fcategory,
	0 fjoopno,
	Cost flstcost,
	cost fstdcost,
	0 fleadtime,
	case
		when RequiredDate is null then GETDATE()
		else RequiredDate
	end as forgpdate,
	case
	when RequiredDate is null then GETDATE()
	else RequiredDate
	end as flstpdate,
	'N' fmultirls,
	0 fnextrels,
	0 fnqtydm,
	'1900-01-01 00:00:00.000' freqdate,
	0 fretqty,
	quantity fordqty,
	0 fqtyutol,
	0 fqtyltol,
	0 fbkordqty,
	'1900-01-01 00:00:00.000' flstsdate,
	'1900-01-01 00:00:00.000' frcpdate,
	0 frcpqty,
	0 fshpqty,
	0 finvqty,
	0 fdiscount,
	0 fstandard,
	'N' ftax,
	0 fsalestax,
	cost flcost,
	cost fucost,
	'Y' fprintmemo,
	cost fvlstcost,
	0 fvleadtime,
	'EA' fvmeasure,
	case
		when ITEM is null then ' '
		else ITEM
	end as fvptdes,
	Quantity fvordqty,
	1 fvconvfact,
	cost fvucost,
	0 fqtyshipr,
	'1900-01-01 00:00:00.000' fdateship,
	0 fnorgucost,
	0 fnorgeurcost,
	0 fnorgtxncost,
	0 futxncost,
	0 fvueurocost,
	0 fvutxncost,
	0 fljrdif,
	cost fucostonly,
	0 futxncston,
	0 fueurcston,
	case
		when Comments is null then ' '
		else Comments 
	end fcomments,
	case
		when Description2 is null then ' ' 
		else Description2
	end fdescript,
	'Default' fac,
	0 fndbrmod
	from PODETAIL
) pod
on po.PONumber = pod.PONumber

update PODetail
set vendorPONumber = po.VendorPO
from
PODetail pod
inner join
[PO]  po
on
pod.ponumber=po.PONumber
WHERE POSTATUSNO = 3 and SITEID <> '90' and (po.BLANKETPO = '' or po.BLANKETPO is null)


end;
