select 
st.Crib, 
st.CribBin,
SUBSTRING(st.CribBin,1,2) pre,
st.item
from STATION st 
where SUBSTRING(st.CribBin,1,2) = '12' 
/*
 * 
 * 
 * 
 * PLEX LOCATION UPLOAD
 * 
 * 
 * 
 * 
 * 
 * 
 */
select * 
from plxTestSetLocation

select
top 10
Location,
building_code,
location_type,  
note,
location_group
--into plxTestSetLocation
from
(
/*
 * Plex Location Upload
 */
	--select count(*) cnt from (
	select 
	ROW_NUMBER() over(order by location asc) as row#,
	Location,
	building_code,
	'Maintenance' as location_type,  
	'' as note,
	'Maintenance Crib' as location_group
	from
	(
		/*
		 * Drop the itemnumber from this set.  Since there are many parts that share
		 * locations the set count will drop significantly at this point. 
		 */
		--select count(*) cnt from (
		select DISTINCT location,building_code 
		from dbo.plxItemLocationSub il
		--)tst --3309 Dropped itemnumber from set
	)set1
	--)tst --3309 Dropped itemnumber from set
)set2
--)tst  --3309 
where SUBSTRING(location,1,3)='MPB'
--where SUBSTRING(location,1,2)='MD'
order by location