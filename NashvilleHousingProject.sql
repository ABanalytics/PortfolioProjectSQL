SELECT  * FROM PortfolioProject..['NashvilleHousing$']

--Standardize Date Format

SELECT SaleDateConverted , CONVERT(Date,SaleDate)
FROM PortfolioProject..['NashvilleHousing$']

Update ['NashvilleHousing$']
SET SaleDate = SaleDateConverted

ALTER TABLE ['NashvilleHousing$']
ADD SaleDateConverted Date;
Update ['NashvilleHousing$']
SET SaleDateConverted = Convert(Date, SaleDate)

--Populate Property Address data

SELECT *
FROM PortfolioProject..['NashvilleHousing$']
--WHERE PropertyAddress is null
order by ParcelID


--PARCELid ahave a property address but   are not populating, get property address for parcel id and populate on null
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..['NashvilleHousing$'] a
JOIN PortfolioProject..['NashvilleHousing$'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

--use isnull to create new rows then update table 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..['NashvilleHousing$'] a
JOIN PortfolioProject..['NashvilleHousing$'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..['NashvilleHousing$'] a
JOIN PortfolioProject..['NashvilleHousing$'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

--Breaking out Address into individual Columns (address, city, state)
SELECT PropertyAddress
FROM PortfolioProject..['NashvilleHousing$']

--using substring to split address from city and end before comma, start city +1 after comma

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

FROM PortfolioProject..['NashvilleHousing$']


--Create and populate new rows PropertySplitAddress and PropertySplitCity
ALTER TABLE ['NashvilleHousing$']
ADD PropertySplitAddress Nvarchar(255);

Update ['NashvilleHousing$']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE ['NashvilleHousing$']
ADD PropertySplitCity Nvarchar(255);

Update ['NashvilleHousing$']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Split Owner address using PARSENAME, replacing , with period

SELECT OwnerAddress FROM PortfolioProject..['NashvilleHousing$']

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)

FROM PortfolioProject..['NashvilleHousing$']

--Create and populate new rows OwnerSplitAddress and OwnerSplitCity OwnerSplitState

ALTER TABLE ['NashvilleHousing$']
 ADD OwnerSplitAddress Nvarchar(255);

Update ['NashvilleHousing$']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE ['NashvilleHousing$']
ADD OwnerSplitCity Nvarchar(255);

Update ['NashvilleHousing$']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE ['NashvilleHousing$']
ADD OwnerSplitState Nvarchar(255);

Update ['NashvilleHousing$']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)

SELECT * FROM PortfolioProject..['NashvilleHousing$']

--Change 'Y' & 'N' to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVAcant)
FROM PortfolioProject..['NashvilleHousing$']
GROUP by SoldAsVacant
ORDER BY 2
--52 Y and 399 N

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
FROM PortfolioProject..['NashvilleHousing$']

Update ['NashvilleHousing$']
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

--Remove duplicates (can use Rank, Order rank, Row num)
-- Creates Row_num column to label as duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM PortfolioProject..['NashvilleHousing$']
--ORDER by ParcelID
)
SELECT * FROM ROWNumCTE
WHERE row_num >1
Order by PropertyAddress

--Deletes Duplicate rows
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM PortfolioProject..['NashvilleHousing$']
)
DELETE ROWNumCTE
WHERE row_num >1

--DELETE UNUSED COLUMNS, Never delete from raw data

SELECT * FROM PortfolioProject..['NashvilleHousing$']

ALTER TABLE PortfolioProject..['NashvilleHousing$']
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
