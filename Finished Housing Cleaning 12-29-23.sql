## The set describes information about housing in the city of Nashville and it needs to be cleaned up a bit.  
SELECT*
FROM Portfolio.nashville_housing_data;
## The below statement helps me to make updates without using a WHERE clause.
SET SQL_SAFE_UPDATES = 0;
## Fist thing is to populate the property address entries that are NULL.
SELECT*
FROM Portfolio.nashville_housing_data
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
## I know that the ParcelID corresponds to the Address such that a particular ParcelID = a particular PropertyAddress.
## Because of this fact, I can make a statement such that if a PropertyAddress is NULL I can copy the Address from a row that
## does have an Address listed with the same ParcelID.
## Below is the query that will fix the NULLs for PropertyAddress
UPDATE Portfolio.nashville_housing_data AS a
JOIN Portfolio.nashville_housing_data AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL AND b.PropertyAddress IS NOT NULL;
## Now I'll verify that there are no NULL entries in PropertyAddress
SELECT*
FROM Portfolio.nashville_housing_data
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
## I next need to break apart the current address columns into Address, City, and State individual columns.
SELECT PropertyAddress
FROM Portfolio.nashville_housing_data; 
## Using the above query I can see that there is a delimiter separating the Address and the City. Using this delimiter I can divide the 
## address and the city using the below query.
SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM portfolio.nashville_housing_data;
## The way that this query works is that it uses the SUBSTRING and LOCATE statements to locate the first ',' in the PropertyAddress column 
## and then moves one character back to isolate the address. Next I use a similar statement but this time it moves one character 
## in front of the comma to produce the city. Now that I have the Address and City separated, I can create two new columns in the 
## table.
SET SQL_SAFE_UPDATES = 0;
## The above statement helps me to make updates without using a WHERE clause. Below are the updates.
ALTER TABLE portfolio.nashville_housing_data
ADD property_address NVARCHAR(255);

UPDATE portfolio.nashville_housing_data
SET property_address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE portfolio.nashville_housing_data
ADD property_city NVARCHAR(255);

UPDATE portfolio.nashville_housing_data
SET property_city = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);
## Now that the query has been executed I can check the table to see if the new columns were added correctly.
SELECT property_address, property_city
FROM portfolio.nashville_housing_data;
## Now what about getting the state? Well, I can use the OwnerAddress column to get the state.
ALTER TABLE portfolio.nashville_housing_data
ADD property_state NVARCHAR(10);
UPDATE portfolio.nashville_housing_data
SET property_state = SUBSTRING(OwnerAddress, LENGTH(OwnerAddress) - 1);
## Now I check it all again to be sure that everything is correct.
SELECT property_address, property_city, property_state
FROM Portfolio.nashville_housing_data;

## The next task is to update the SoldAsVacant column from containing 'Yes', 'No', 'Y', and 'N' to just contain 'Yes' and 'No'
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM portfolio.nashville_housing_data
GROUP BY SoldAsVacant
ORDER BY 2;
## To do this I will make a CASE statement such that if 'N' then it will become 'No' and if it is 'Y' then it will become 'Yes'
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM portfolio.nashville_housing_data;
## This case statement works so I'll update the table with the above CASE statement
UPDATE portfolio.nashville_housing_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END;
## Now, I will update the table to eliminate duplicates. To do this I need to start with finding duplicate rows.  
## Once I have isolated the duplicate rows, I can create a Common Table Expression (CTE) to query off of it. 
WITH duplicate_cte AS (
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
FROM portfolio.nashville_housing_data
)
SELECT *
FROM duplicate_cte
ORDER BY PropertyAddress;
## The CTE expression uses ROW_NUMBER to assign row number 2 to the duplicate rows. I use OVER and PARTITION BY to select the columns that should be
## unique. Now that I have isolated all of the duplicates, I can delete them. 
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM portfolio.nashville_housing_data
)

DELETE FROM portfolio.nashville_housing_data
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID) IN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID
    FROM duplicate_cte
    WHERE row_num > 1
);
## Now, I'll verify that the desired duplicate rows have been deleted.
WITH duplicate_cte AS (
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
FROM portfolio.nashville_housing_data
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
ORDER BY PropertyAddress;
## Lastly, I'll delete the useless columns.
## Now that I have the address, city, and state in their own columns, I no longer need 'PropertyAddress' and 'OwnerAddress' columns
ALTER TABLE portfolio.nashville_housing_data
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress;
## I'll check that the columns are gone
SELECT*
FROM portfolio.nashville_housing_data;
## Finally, to be safe, I'll turn the safe updates back on.
SET SQL_SAFE_UPDATES = 1;