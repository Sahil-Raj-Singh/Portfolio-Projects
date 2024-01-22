-- Looking at the data
Select * 
From PortfolioProject.dbo.NashVilleHousing

-- Standardize the format of Data
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashVilleHousing

Update NashVilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

Alter Table NashVilleHousing 
ALter Column SaleDate Date

-- Populate Property Address data
Select *
From PortfolioProject.dbo.NashVilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
     on a.ParcelID = b.ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashVilleHousing a
JOIN PortfolioProject.dbo.NashVilleHousing b
     on a.ParcelID = b.ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns(Address, City,State)

Select PropertyAddress
From PortfolioProject.dbo.NashVilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashVilleHousing
Add PropertyAddressSplit Nvarchar(255)

Update NashVilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

Alter Table NashVilleHousing
Add PropertyCitySplit Nvarchar(255)

Update NashVilleHousing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashVilleHousing




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing


-- Changes in 'Sold as Vacant' Column 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashVilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case when SoldAsVacant='Y' Then 'Yes'
     when SoldAsVacant='N' Then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject.dbo.NashVilleHousing


Update NashVilleHousing
SET SoldAsVacant=Case when SoldAsVacant='Y' Then 'Yes'
     when SoldAsVacant='N' Then 'No'
	 Else SoldAsVacant
	 END


-- Removing Duplicates

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

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing


-- Delete Unused Columns


Select * 
from PortfolioProject.dbo.NashVilleHousing


Alter Table PortfolioProject.dbo.NashVilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table PortfolioProject.dbo.NashVilleHousing
Drop Column SaleDate