SELECT *
FROM Housing.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date format

SELECT SaleDate, CONVERT(date,SaleDate), SaleDateConverted
FROM Housing.dbo.NashvilleHousing

ALTER TABLE Housing.dbo.NashvilleHousing
ADD SaleDateConverted date

UPDATE Housing.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM Housing.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Housing.dbo.NashvilleHousing a
JOIN Housing.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID]											-- Same parcel id but different row
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)			-- Filling property address from table b to table a 
FROM Housing.dbo.NashvilleHousing a
JOIN Housing.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[Unique ID]


SELECT PropertyAddress 
FROM Housing.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Feature	Engineering >> Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM Housing.dbo.NashvilleHousing


SELECT CHARINDEX(',' , PropertyAddress)  
FROM Housing.dbo.NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) - 1) AS PropertySplitAddress, 
SUBSTRING(PropertyAddress, (CHARINDEX(',' , PropertyAddress) + 1), LEN(PropertyAddress)) AS PropertySplitCity 
FROM Housing.dbo.NashvilleHousing

ALTER TABLE Housing.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE Housing.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) - 1)

ALTER TABLE Housing.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE Housing.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',' , PropertyAddress) + 1), LEN(PropertyAddress))


SELECT PropertySplitAddress, PropertySplitCity
FROM Housing.dbo.NashvilleHousing



SELECT PARSENAME(OwnerAddress, 1)								-- Default, checks for period(.) sign 
FROM Housing.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM Housing.dbo.NashvilleHousing


ALTER TABLE Housing.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE Housing.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE Housing.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE Housing.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE Housing.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE Housing.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM Housing.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Converting Y and N to Yes and No in "Sold as Vacant" Field


SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM Housing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant
		END
FROM Housing.dbo.NashvilleHousing

UPDATE Housing.dbo.NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant
		END 


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,										--	Partition by Columns with duplicate data 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing.dbo.NashvilleHousing
--order by ParcelID
)

DELETE
From RowNumCTE
WHERE row_num >1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Deleting Columns

SELECT *
FROM Housing.dbo.NashvilleHousing

ALTER TABLE Housing.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

