/*

CLEANING DATA IN SQL QUERIES

*/

Select *
From PortfolioProject.dbo.[Nashville Housing]

---------------------------------
--Selecting SaleDate

Select SaleDate
From PortfolioProject.dbo.[Nashville Housing]

--------------------------------
-- Populate Property Address Data

Select *
From PortfolioProject.dbo.[Nashville Housing]
--Where PropertyAddress is null
Order By ParcelID

-- To collect only unique ID and remove duplication
Select *
From PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
   on a.ParcelID = b.ParcelID
    And a.[uniqueID] <> b.[uniqueID]

Select *
From PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
   on a.ParcelID = b.ParcelID
    And a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null


Select a. ParcelID, a.PropertyAddress, b.ParcelID, b. PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
   on a.ParcelID = b.ParcelID
    And a.[uniqueID] <> b.[uniqueID]
where a.ParcelID is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
   on a.ParcelID = b.ParcelID
    And a.[uniqueID] <> b.[uniqueID]

-----------------------------------------------------------------------------------
--Breaking out individuals Colunms (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.[Nashville Housing]
--Using the substring func to separate the address from the delimiter
-- Char index is the position, '-1' means one position before the comma,+1 to remove  ',' before the address

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX ( ',',PropertyAddress) -1) As Address
  , SUBSTRING (PropertyAddress, CHARINDEX ( ',',PropertyAddress) +1, LEN (PropertyAddress)) As City
From PortfolioProject.dbo.[Nashville Housing]

-- Adding Splitted Property address to Table
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX ( ',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar (255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX ( ',',PropertyAddress) +1, LEN (PropertyAddress))

select *
From PortfolioProject.dbo.[Nashville Housing]

-------------------------------------------------------------------------------------------------------------
--Splitting the Owner address using PARSENAME Function

select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing] 

Select 
PARSENAME(REPLACE (OwnerAddress,',','.') , 3)
, PARSENAME(REPLACE (OwnerAddress,',','.') , 2)
, PARSENAME(REPLACE (OwnerAddress,',','.') , 1)
From PortfolioProject.dbo.[Nashville Housing]

--Adding the Splitted the rows to the table
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar (255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar (255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress,',','.') , 3)

select OwnerAddress
From PortfolioProject.dbo.[Nashville Housing] 

------------------------------------------------------------------------------------------------------------
--COUNTING  SOLDASVACANT RESPONSE

select Distinct SoldAsVacant, Count(SoldAsVacant) as NumberOfOccurrence 
From PortfolioProject.dbo.[Nashville Housing]
Group By SoldAsVacant

------------------------------------------------------------------------------------------------
--Removing Duplicates

WITH RowNumCTE AS(
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

From PortfolioProject.dbo.[Nashville Housing]
)
DELETE
From RowNumCTE
Where Row_num > 1

-- To cross check the query for duplicates, implement the statement below with the RowNumCTE Statement above
select *
From RowNumCTE
Where Row_num > 1

--------------------------------------------------------------------------------------------------------
--DELETE Unused Columns 
-- Note: best used for deleting unsed views, deleting raw data is unadvisable unless very necessary.

select *
From PortfolioProject.dbo.[Nashville Housing]


ALTER PortfolioProject.dbo.[Nashville Housing]
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict 

ALTER PortfolioProject.dbo.[Nashville Housing]
DROP COLUMN SaleDate