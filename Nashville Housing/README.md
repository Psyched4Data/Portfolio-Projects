# Nashville Housing Data (SQL and Power BI)
## Project Overview
This project focuses on cleaning and transforming a real-world housing dataset for the city of Nashville using SQL. After the CSV is created, it is imported into Power BI to generate a visual for communicating key insights.

### The raw dataset contained:
- NULL values
- Combined address fields
- Inconsistent categorical values
- Duplicate records
- Redundant columns

The goal was to transform the dataset into a clean, analysis-ready format using structured SQL operations.

## Step 1: Data Exploration
```SQL
SELECT *
FROM Portfolio.nashville_housing_data;
```
### What I Did
- Queried the full dataset to understand structure and data quality.

### How I Did It
Used a full table select to inspect:
- Column types
- NULL values
- Address formatting
 -Duplicate risk

## Step 2: Filling Null Property Addresses
Using a self-join, I copied non-null addresses from matching ParcelIDs:
```python
UPDATE Portfolio.nashville_housing_data AS a
JOIN Portfolio.nashville_housing_data AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL 
  AND b.PropertyAddress IS NOT NULL;
```
### What I Did
Populated missing PropertyAddress values.

### How I Did It
Each ParcelID corresponds to a unique property address.
Using a self-join, I copied non-null addresses from matching ParcelIDs.

### Why I Did It
Instead of deleting incomplete rows, I preserved data integrity by leveraging relational consistency within the dataset.

## Step 3: Splitting Address into Separate Columns
The original PropertyAddress column contained Street Address and City.

### What I Did
Split combined address data into:
- property_address
- property_city

### How I Did It
Used SUBSTRING() and LOCATE() to split based on the comma delimiter:
```sql
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1)
```

Then created new columns and populated them:
```sql
ALTER TABLE portfolio.nashville_housing_data
ADD property_address NVARCHAR(255);

UPDATE portfolio.nashville_housing_data
SET property_address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);
```
Repeated the process for property_city.

## Step 4: Extracting State Information
### What I Did
Extracted state abbreviation into its own column.

### How I Did It
Used string length logic on the OwnerAddress column:
```sql
ALTER TABLE portfolio.nashville_housing_data
ADD property_state NVARCHAR(10);

UPDATE portfolio.nashville_housing_data
SET property_state = SUBSTRING(OwnerAddress, LENGTH(OwnerAddress) - 1);
```
This standardized location data for easier grouping and filtering.

## Step 5: Standardizing Categorical Values
The SoldAsVacant column contained:
- 'Y'
- 'N'
- 'Yes'
- 'No'

### What I Did
Standardized all values to only "Yes" and "No".

### How I Did It
Used a CASE statement:
```sql
UPDATE portfolio.nashville_housing_data
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
```
### Why I Did It
Inconsistent categorical values cause issues in:
- Aggregations
- BI dashboards
- Filtering logic
Standardization ensures clean grouping behavior.

## Step 6: Removing Duplicate Records
### What I Did
Identified and removed duplicate rows.

### How I Did It
Used a Common Table Expression (CTE) with ROW_NUMBER():
```sql
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
```
Then deleted rows where row_num > 1.

### Why I Did It
Using ROW_NUMBER() ensures:
- Controlled duplicate detection
- Only secondary duplicates are removed
- Primary records remain intact

Step 7: Dropping Redundant Columns
After splitting address fields, the original columns were no longer necessary.
```sql
ALTER TABLE portfolio.nashville_housing_data
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress;
```
### What I Did
Removed redundant columns to normalize schema.

### How I Did It
Used ALTER TABLE DROP COLUMN.

### This improves:
- Schema clarity
- Query performance
- Downstream usability

## Skills Demonstrated
- Data Cleaning
- Handling NULL values
- String parsing and transformation
- Categorical normalization
- Joins
- Common Table Expressions (CTEs)
- Duplicate detection
- Controlled deletion
- Schema normalization
- ALTER TABLE operations
- Column creation and removal

<img src="Visuals/BI Dashboard.png" width="500">
