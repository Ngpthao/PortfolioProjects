select * 
from PortfolioProject..NashvilleHousing

--1. Populate Property Address data
select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress--, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a join PortfolioProject..NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a join PortfolioProject..NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
--2. Breaking Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress + ',') -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress + ',') -1)

ALTER TABLE NashvilleHousing
ADD PropertySlpitCity NVARCHAR(255) 

UPDATE NashvilleHousing
SET PropertySlpitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
from PortfolioProject..NashvilleHousing

-- Breaking OwnerAddress into 3 seperate columns. 
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject..NashvilleHousing

--3. Change Y and N to Yes and No in "Sold as Vacant" field
select distinct (SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
where SoldAsVacant = 'Yes' or SoldAsVacant = 'No'
group by SoldAsVacant



select SoldAsVacant, 
   case when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
        end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
        end

--4. Remove Duplicates
with rowNumCTE as (
select *, 
     ROW_NUMBER() OVER(
        PARTITION BY ParcelID, 
                     PropertyAddress, 
                     SalePrice, 
                     SaleDate,
                     LegalReference
                     ORDER BY UniqueID
     ) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
delete
from rowNumCTE
where row_num > 1

--5. Delete Unused Columns
select *
from PortfolioProject..NashvilleHousing
 
alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress