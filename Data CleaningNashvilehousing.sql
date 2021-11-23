/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[SaleDateConverted]
  FROM [PortfolioProject].[dbo].[NashvileHousing]

  
/* 
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.NashvileHousing

--Standardize Date

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvileHousing


UPDATE NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvileHousing
ADD SaleDateConverted Date;

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate property address data

SELECT *
FROM PortfolioProject.dbo.NashvileHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress  = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

--Breaking Out  Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvileHousing
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAddress  Nvarchar(255);

UPDATE NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) 

SELECT *
FROM PortfolioProject.dbo.NashvileHousing


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvileHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.NashvileHousing


ALTER TABLE NashvileHousing
ADD OwnerSplitAddress  Nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvileHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


SELECT *
FROM PortfolioProject.dbo.NashvileHousing

-- Change yes and no to Y and N "Sold as vacant" field.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant ='N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvileHousing

UPDATE NashvileHousing
 SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant ='N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvileHousing

-------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate, LegalReference
				 ORDER BY
				 UniqueID) row_num

FROM PortfolioProject.dbo.NashvileHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns


SELECT *
FROM PortfolioProject.dbo.NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate







