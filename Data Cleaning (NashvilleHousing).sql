/*

Cleaning Data 

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing





/* Standardize Date Format */

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)





/* Populate Property Address data */

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




/* Breaking out Address into individual columns (Address, City, State) */


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing



-- Pulling results without the comma (,) 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)








/* Change Y and N to Yes and No in "Sold as Vacant" field   */

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END




/* Remove Duplicates  */

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
Where row_num > 1






/* DELETE UNUSED COLUMNS */

Select *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

