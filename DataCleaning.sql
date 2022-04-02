/*

Cleaning data in SQL queries

*/

SELECT * 
FROM project.dbo.NashvilleHousing


------------------------------------------------------------------------------

/* Standartize Date Format */ 

SELECT SaleDate, CONVERT(date, SaleDate)
FROM project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

-- If it doesn't work

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;


------------------------------------------------------------------------------

/* Populate Property Address data */

SELECT PropertyAddress
FROM project.dbo.NashvilleHousing
WHERE PropertyAddress is null

-- There are 29 rows with no value in PropertyAddress, so we need to fill them

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM project.dbo.NashvilleHousing as a
JOIN project.dbo.NashvilleHousing as b
	 on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM project.dbo.NashvilleHousing as a
JOIN project.dbo.NashvilleHousing as b
	 on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


------------------------------------------------------------------------------

/* Breaking out Address into Individual Columns (Address, City, State) */

SELECT PropertyAddress
FROM project.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address_1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address_2
FROM project.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD Property_Address nvarchar(255);
UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD Property_City nvarchar(255);
UPDATE NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress;



SELECT OwnerAddress
FROM project.dbo.NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM project.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD Owner_Address nvarchar(255);
UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD Owner_City nvarchar(255);
UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD Owner_State nvarchar(255);
UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress;


------------------------------------------------------------------------------

/* Change Y and N to Yes and No in "Sold as Vacant" field */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as total
FROM project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY total;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

