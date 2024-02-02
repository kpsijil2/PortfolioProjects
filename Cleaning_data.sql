-- Cleaning Data in SQL Queries

SELECT*
FROM PortfoliProject.dbo.NationalHousing


-- 1.Standardize date format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfoliProject.dbo.NationalHousing

UPDATE PortfoliProject.dbo.NationalHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE PortfoliProject.dbo.NationalHousing
Add SaleDateConverted date;

UPDATE PortfoliProject.dbo.NationalHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- 2. Populate Property address data

SELECT *
FROM PortfoliProject.dbo.NationalHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfoliProject.dbo.NationalHousing a
JOIN PortfoliProject.dbo.NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfoliProject.dbo.NationalHousing a
JOIN PortfoliProject.dbo.NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- 3. Breaking out Address into Individual Columns(Address, City, State)


SELECT PropertyAddress
FROM PortfoliProject.dbo.NationalHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfoliProject.dbo.NationalHousing

ALTER TABLE PortfoliProject.dbo.NationalHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfoliProject.dbo.NationalHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfoliProject.dbo.NationalHousing
Add PropertySplitCity nvarchar(255);

UPDATE PortfoliProject.dbo.NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfoliProject.dbo.NationalHousing


SELECT OwnerAddress
FROM PortfoliProject.dbo.NationalHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfoliProject.dbo.NationalHousing

ALTER TABLE PortfoliProject.dbo.NationalHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfoliProject.dbo.NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfoliProject.dbo.NationalHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfoliProject.dbo.NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfoliProject.dbo.NationalHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfoliProject.dbo.NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- 4. Change Y and N to YES and NO in "Sold as Vacant" field.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfoliProject.DBO.NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfoliProject.dbo.NationalHousing

UPDATE PortfoliProject.dbo.NationalHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- 5. Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfoliProject.dbo.NationalHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- 6. Delete Unused Columns

SELECT *
FROM PortfoliProject.dbo.NationalHousing

ALTER TABLE PortfoliProject.dbo.NationalHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress