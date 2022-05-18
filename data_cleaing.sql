SELECT * FROM NashHouse;

-- ***stardardize date format
-- add new col
alter table NashHouse
add SaleDateConverted Date
-- add data to new col
update NashHouse
set SaleDateConverted = CONVERT(varchar, SaleDate,23) 



-- populate Propertyaddress by finding the same ParcellID
update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashHouse a
join NashHouse b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


--breaking out address into columns(address, city, state) 
select 
SUBSTRING ( PropertyAddress ,1 , CHARINDEX(',' ,PropertyAddress )-1 ), 
SUBSTRING ( PropertyAddress ,CHARINDEX(',' ,PropertyAddress )+1, LEN(PropertyAddress) )
from NashHouse 


alter table NashHouse
add PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255)

update NashHouse 
set PropertySplitAddress = SUBSTRING ( PropertyAddress ,1 , CHARINDEX(',' ,PropertyAddress )-1 )


update NashHouse 
set PropertySplitCity = SUBSTRING ( PropertyAddress ,CHARINDEX(',' ,PropertyAddress )+1, LEN(PropertyAddress) )

--breaking down OwnerAddress
select * from NashHouse

select 
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
from NashHouse 

alter table NashHouse
add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255),  OwnerSplitState nvarchar(255)

update NashHouse
set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

update NashHouse
set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

update NashHouse
set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)

-- change Y and N to yes and no
select distinct(SoldAsVacant), count(SoldAsVacant) from NashHouse
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case 
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
End
from NashHouse

update NashHouse
set SoldAsVacant = 
	Case
		when SoldAsVacant = 'N' then 'No'
		when SoldAsVacant = 'Y' then 'Yes'
		else SoldAsVacant
	End

-- remove duplicates: we find out the total uniqueID is less than count of row, it means 
-- there're duplicate rows
select * from NashHouse
order by [UniqueID ]

with CTE as(
select * ,ROW_NUMBER() over (partition by ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference 
order by uniqueID) as row_num
from NashHouse
)

DELETE FROM CTE
where row_num > 1


-- delete unused col
select * from NashHouse

alter table NashHouse
drop column Propertyaddress, OwnerAddress, TaxDistrict, Saledate
