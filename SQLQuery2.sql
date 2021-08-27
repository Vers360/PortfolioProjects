/*
Cleaning Data in SQL Queries
*/


Select *
From Project_3.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From Project_3.dbo.NashvilleHousing


-- If it doesn't Update properly

Select SaleDate2, CONVERT(Date, SaleDate)
From Project_3.dbo.NashvilleHousing

Update  NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing 
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(Date, SaleDate)

 ------------------------------------------------------------- Populate Property Address data---------------------------------------------------------------

Select *
From Project_3.dbo.NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project_3.dbo.NashvilleHousing a
JOIN Project_3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project_3.dbo.NashvilleHousing a
JOIN Project_3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 




------------------------------------------------------------------- Breaking out Address into Individual Columns (Address, City, State)--------------------------------------------------------

Select PropertyAddress
From Project_3.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Project_3.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing 
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing 
Add PropertySplitCity NVARCHAR(255);;

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From Project_3.dbo.NashvilleHousing


Select OwnerAddress
From Project_3.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
From Project_3.dbo.NashvilleHousing

--Owner address

ALTER TABLE NashvilleHousing 
Add OwnerSpitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSpitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

--Owner City 

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2)


--Owner state 

ALTER TABLE NashvilleHousing 
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1)



-------------------------------------------------- Change Y and N to Yes and No in "Sold as Vacant" field--------------------------------------------------------------------------

Select  DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project_3.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Project_3.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


------------------------------------------------------------------------ Remove Duplicates-------------------------------------------------------------------------------------


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

From Project_3.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
 
--Order by PropertyAddress

Select *
From Project_3.dbo.NashvilleHousing

ALTER TABLE Project_3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project_3.dbo.NashvilleHousing
DROP COLUMN SaleDate