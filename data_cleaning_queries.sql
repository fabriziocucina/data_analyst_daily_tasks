/* 
Cleaning Data In Postgresql Queries
*/

/*
1.Visualize All The Data
*/

select * 
from nashville_housing_data


/*
2.Populate Property Address Data
*/

select a.parcel_id,a.property_address, b.parcel_id, b.property_address, coalesce(a.property_address,b.property_address)
from nashville_housing_data as a
join nashville_housing_data as b
on a.parcel_id = b.parcel_id 
and a.id_number <> b.id_number
where a.property_address is null

update nashville_housing_data tgt
set property_address = src.property_address
from nashville_housing_data src
where src.parcel_id = tgt.parcel_id 
  and src.id_number != tgt.id_number
  and src.property_address is not null
  and tgt.property_address is null

/* 
3.Breaking Out Address Into Individuals Columns (Address, City, State)
*/

select 
substring(property_address,1,strpos(property_address,',')-1) as address,
substring(property_address,strpos(property_address,',')+1, length(property_address)) as address
from nashville_housing_data

alter table nashville_housing_data
add property_split_address varchar(255)

update nashville_housing_data
set property_split_address = substring(property_address,1,strpos(property_address,',')-1)

alter table nashville_housing_data
add property_split_city varchar(255)

update nashville_housing_data
set property_split_city = substring(property_address,strpos(property_address,',')+1, length(property_address))

select *
from nashville_housing_data

select 
split_part(owner_address,',',1),
split_part(owner_address,',',2),
split_part(owner_address,',',3)
from nashville_housing_data

alter table nashville_housing_data
add owner_split_address varchar(255)

update nashville_housing_data
set owner_split_address = split_part(owner_address,',',1)

alter table nashville_housing_data
add owner_split_city varchar(255)

update nashville_housing_data
set owner_split_city = split_part(owner_address,',',2)

alter table nashville_housing_data
add owner_split_state varchar(50)

update nashville_housing_data
set owner_split_state = split_part(owner_address,',',3)

select *
from nashville_housing_data

/*
4.Change false And true to Yes And No In 'sold_as_vacant' Field
*/

select distinct(sold_as_vacant),
count(sold_as_vacant)
from nashville_housing_data
group by sold_as_vacant

select sold_as_vacant, 
case 
when sold_as_vacant = 'false'
then 'no'
when sold_as_vacant = 'true'
then 'yes'
else sold_as_vacant
end 
from nashville_housing_data

update nashville_housing_data
set sold_as_vacant =
case
when sold_as_vacant = 'false'
then 'no'
when sold_as_vacant = 'true'
then 'yes'
else sold_as_vacant
end 

select sold_as_vacant
from nashville_housing_data

/*
5. Remove Duplicates
*/

select * from nashville_housing_data

select * 
from (select *, row_number() over(partition by parcel_id,property_address,sale_price,sale_date,legal_reference) row_num
from nashville_housing_data) as dp
where row_num >1

delete from nashville_housing_data
where id_number in(
select id_number 
	from (select id_number,row_number() over(partition by parcel_id,property_address,sale_price,sale_date,legal_reference) row_num
		  from nashville_housing_data) as s
	where row_num >1
	)









 