
--DATA CLEANING PROJECT FOR HOUSING DATASET
--- Standardize Date Format
select*from [Data Cleaning Project].dbo.housing

alter table dbo.housing
add saledateconverted date;

update [Data Cleaning Project].dbo.housing
set saledateconverted = SaleDate; 

-----------------------------------------------------------------------------------------------------------------------------------------
---Populate Property Address data

select *
from [Data Cleaning Project].dbo.housing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
from [Data Cleaning Project].dbo.housing a
join [Data Cleaning Project].dbo.housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress=ISNULL(a.propertyaddress,b.PropertyAddress)
from [Data Cleaning Project].dbo.housing a
join [Data Cleaning Project].dbo.housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------------------------
---Breaking out address into Individual columns( Address, City, States)

select PropertyAddress
from [Data Cleaning Project].dbo.housing

select
PARSENAME(replace(PropertyAddress,',','.'),1) as City
,PARSENAME(replace(PropertyAddress,',','.'),2) as Address
from [Data Cleaning Project].dbo.housing
where PropertyAddress is not null

alter table [Data Cleaning Project].dbo.housing
add PropertySplitAddress varchar(300);

update [Data Cleaning Project].dbo.housing
set PropertySplitAddress = PARSENAME(replace(PropertyAddress,',','.'),2)

alter table [Data Cleaning Project].dbo.housing
add PropertySplitCity varchar(150);

update [Data Cleaning Project].dbo.housing
set PropertySplitCity =PARSENAME(replace(PropertyAddress,',','.'),1) 

select OwnerAddress
from [Data Cleaning Project].dbo.housing

select
PARSENAME(replace(owneraddress,',','.'),3) as Adress
,PARSENAME(replace(owneraddress,',','.'),2) as City
,PARSENAME(replace(owneraddress,',','.'),1) as State
from [Data Cleaning Project].dbo.housing
where OwnerAddress is not null


alter table [Data Cleaning Project].dbo.housing
add OwnerSplitAddress varchar(300);

update [Data Cleaning Project].dbo.housing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3); 

alter table dbo.housing
add OwnerSplitCity varchar(150);

update [Data Cleaning Project].dbo.housing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2); 


alter table [Data Cleaning Project].dbo.housing
add OwnerSplitState varchar(300);

update [Data Cleaning Project].dbo.housing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1); 

---------------------------------------------------------------------------------------------------------------
---Change Y and N to Yes and No in "Sold as vacant" Field

select distinct(soldasvacant),count(soldasvacant)
from [Data Cleaning Project].dbo.housing
group by SoldAsVacant
order by 2

select Soldasvacant,
case When SoldAsVacant='Y' then 'Yes'
	 When SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 END
from [Data Cleaning Project].dbo.housing

update [Data Cleaning Project].dbo.housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 END

-------------------------------------------------------------------------------------------------------------------------------
---- Remove Duplicate

select*from [Data Cleaning Project].dbo.housing


with RowNumCTE as(
select*,ROW_NUMBER() Over(
		Partition by ParcelID,
			propertyaddress,
			saleprice,
			saledate,legalreference
		order by
			uniqueID
		)row_num

		from [Data Cleaning Project].dbo.housing
		)
Delete
	from RowNumCTE
	where row_num>1
	
-------------------------------------------------------------------------------------------------------------------------------
---- Delete Unused Columns

select*
from [Data Cleaning Project].dbo.housing

alter table [Data Cleaning Project].dbo.housing
drop column Propertyaddress, owneraddress,taxDistrict,saledate

-------------------------------------------------------------------------------------------------------------------------------
----- Deleting Null values

select*from [Data Cleaning Project].dbo.housing
where ownername is null

DELETE
from [Data Cleaning Project].dbo.housing
where OwnerName is null