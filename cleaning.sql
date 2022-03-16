--Preview the data 
SELECT * FROM Nashvile.dbo.nashvilleHousing


-- Checking the data types 
exec sp_help 'dbo.nashvilleHousing'

--Converting datetime into date */
ALTER TABLE Nashvile.dbo.nashvilleHousing
ADD SaleDateC date

UPDATE Nashvile.dbo.nashvilleHousing
SET SaleDateC=CONVERT(date,SaleDate)

SELECT * FROM Nashvile.dbo.nashvilleHousing

-- cleaning property address column 
SELECT PropertyAddress FROM Nashvile.dbo.nashvilleHousing

SELECT * FROM Nashvile.dbo.nashvilleHousing
WHERE PropertyAddress IS NULl


-- Populate the missing addresses
SELECT * FROM Nashvile.dbo.nashvilleHousing
ORDER BY ParcelID

SELECT * FROM Nashvile.dbo.nashvilleHousing a
JOIN Nashvile.dbo.nashvilleHousing b
ON a.ParcelID=b.ParcelID 
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULl

UPDATE a
SET a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashvile.dbo.nashvilleHousing a
JOIN Nashvile.dbo.nashvilleHousing b
ON a.ParcelID=b.ParcelID 
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULl

SELECT * FROM Nashvile.dbo.nashvilleHousing 


-- Breaking down the owner address (address, City, State)
SELECT SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) AS Address,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)) AS city, 
SUBSTRING(SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)),
CHARINDEX(',',SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)))+1,LEN(OwnerAddress)) AS STATE  
FROM Nashvile.dbo.nashvilleHousing


ALTER TABLE Nashvile.dbo.nashvilleHousing
ADD owner_Address nvarchar(255), OwnerCity nvarchar(255) ,OwnerState nvarchar(255)

UPDATE Nashvile.dbo.nashvilleHousing
SET owner_Address = SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1),
OwnerCity=SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)),
OwnerState=SUBSTRING(SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)),
CHARINDEX(',',SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)))+1,LEN(OwnerAddress))

SELECT * FROM Nashvile.dbo.nashvilleHousing


-- Breaking down the property address (address, City)
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM Nashvile.dbo.nashvilleHousing

ALTER TABLE Nashvile.dbo.nashvilleHousing
ADD prop_Address nvarchar(255), prop_City nvarchar(255)

UPDATE Nashvile.dbo.nashvilleHousing
SET prop_Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
prop_City= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM Nashvile.dbo.nashvilleHousing

-- adjusting the binary column SoldAsVacant
SELECT DISTINCT SoldAsVacant,COUNT(SoldAsVacant) 
FROM Nashvile.dbo.nashvilleHousing
GROUP BY SoldAsVacant

UPDATE Nashvile.dbo.nashvilleHousing
SET SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END


SELECT DISTINCT SoldAsVacant,COUNT(SoldAsVacant) 
FROM Nashvile.dbo.nashvilleHousing
GROUP BY SoldAsVacant


--Removing duplicates
WITH rowNumCTE AS(
SELECT *,ROW_NUMBER() OVER(PARTITION BY
                                       ParcelID,PropertyAddress,SaleDate,OwnerName,LegalReference ORDER BY OwnerName)row_num
FROM Nashvile.dbo.nashvilleHousing
)
DELETE
FROM rowNumCTE
WHERE row_num >1

SELECT*FROM Nashvile.dbo.nashvilleHousing

--Drop unused column 
ALTER TABLE Nashvile.dbo.nashvilleHousing
DROP COLUMN SaleDate,PropertyAddress,OwnerAddress

SELECT*FROM Nashvile.dbo.nashvilleHousing


