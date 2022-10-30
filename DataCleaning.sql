select * 
from PortfolioProject.dbo.NashvilleHousing

--stardardize data format

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing


--populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.propertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.propertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--breaking out  address into individual columns(address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);
update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);
update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


--change Y and N to Yes and No in SoldAsVacant

select distinct SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
	end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
	end



-- remove duplicates

With RowNumCTE as(
select *,
	ROW_NUMBER() over(partition by
		ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
		order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing)

delete
from RowNumCTE
where row_num > 1


--delete unused columns

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, OwnerAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
select *
from PortfolioProject.dbo.NashvilleHousing