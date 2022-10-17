/*
Cleaning Data in SQL



*/

select *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------
--Standardize Data Format
--This converts the date format in SaleDate from a date/time format to date format


ALTER TABLE portfolioproject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDate,SaleDateConverted
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------
--Populate Property Address data
SELECT *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--It can be noticed that every Propertyaddress has a parcelID unique to it which would suggest that if there is a NULL address,
--with a ParcelID one can find the propertyaddress that perhaps share the same ParcelID with a known address. 

SELECT *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

 update a
 set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]

 
----------------------------------------------------------------------------------------------------

--Breaking out Address into Individual COlumns (Address,City, State)

SELECT PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER TABLE portfolioproject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE portfolioproject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
from PortfolioProject..NashvilleHousing


---For OwnerAddress

SELECT OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
from PortfolioProject..NashvilleHousing

ALTER TABLE portfolioproject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)


ALTER TABLE portfolioproject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2)


ALTER TABLE portfolioproject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1)


SELECT *
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field 

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
CASE
	when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
end
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant=
CASE
	when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
end


----------------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE as (
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------

--Delete Unused columns

SELECT *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate