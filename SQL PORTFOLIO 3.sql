/*2


Cleaning Data in SQL Quereies 

*/ 

Select*
From Project_Housing.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

--Standardardize Date Format 

Select SaleDate , CONVERT(Date, SaleDate)
From Project_Housing.dbo.NashvilleHousing


Update NashvilleHousing 
SET SaleDate = CONVERT(DATE, SaleDate)  

----------------------------------------------------------------------------------------------------------

--Populate Property Address Data 

Select *
From Project_Housing.dbo.NashvilleHousing 
--Where PropertyAddress is null 
order by ParcelID 


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project_Housing.dbo.NashvilleHousing a 
JOIN NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null 


Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing a 
JOIN NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null 


----------------------------------------------------------------------------------------------------------

--Breaking Out Address into Individdual columns (Address, City, State)



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress NVARCHAR(255); 

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing 
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) 


Select * 
From NashvilleHousing




Select OwnerAddress 
From NashvilleHousing 


Select 
PARSENAME(REPLACE(OwnerAddress ,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress ,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress ,',','.'), 1)
From Project_Housing.dbo.NashvilleHousing 

ALTER TABLE Project_Housing.dbo.NashvilleHousing 
Add OwnerSplitAddress NVARCHAR(255); 

Update Project_Housing.dbo.NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress ,',','.'), 3)

ALTER TABLE Project_Housing.dbo.NashvilleHousing 
Add OwnerSplitCity Nvarchar(255); 

Update Project_Housing.dbo.NashvilleHousing 
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress ,',','.'), 2)

ALTER TABLE Project_Housing.dbo.NashvilleHousing 
Add OwnerSplitState Nvarchar(255); 

Update Project_Housing.dbo.NashvilleHousing 
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress ,',','.'), 1)

ALTER TABLE Project_Housing.dbo.NashvilleHousing 
DROP COLUMN OwnerPropertySplitCity

Select * 
From Project_Housing.dbo.NashvilleHousing

                          
-----------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field. 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
FROM Project_Housing.dbo.NashvilleHousing
Group by SoldAsVacant 
Order by 2




Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' Then 'YES' 
       When SoldAsVacant = 'N' Then 'No' 
	   Else SoldAsVacant 
	   End
FROM Project_Housing.dbo.NashvilleHousing 

Update Project_Housing.dbo.NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'YES' 
    When SoldAsVacant = 'N' Then 'No' 
	Else SoldAsVacant 
	End

------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 


WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference 
				 ORDER BY 
					UniqueID
					) row_num 

FROM Project_Housing.dbo.NashvilleHousing  
--order by ParcelID
)
SELECT *
FROM RowNumCTE 
Where row_num > 1 
--Order by PropertyAddress

-------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns 

Select * 
From Project_Housing.dbo.NashvilleHousing 


ALTER TABLE Project_Housing.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 


ALTER TABLE Project_Housing.dbo.NashvilleHousing 
DROP COLUMN SaleDate
