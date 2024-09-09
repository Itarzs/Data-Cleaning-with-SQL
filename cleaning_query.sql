--Create and use database--

create database Nashville_Housing;
use Nashville_Housing;

--Sample Table--
select * from housing;

--create a new table from original table to clean while keeping original table is usually a good practise

SELECT *
INTO housing2
FROM housing;

-- using new table for cleaning--

select * 
from housing2

select count(*) no_count
from housing2

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'housing2';

--Finding duplicate--

with duplicate as (
    select *,
    row_number() over (partition by UniqueID order by UniqueID desc ) as row_number
    from housing2
)
select distinct * 
from duplicate
where row_number > 1   --> no duplicate found in all column

--Standardizing data --> checking columns for errors

SELECT *
FROM housing
WHERE UniqueID is null or ParcelID IS NULL or LandUse is null or PropertyAddress is null
      or SaleDate is null or SalePrice is null or LegalReference is null or SoldAsVacant is null 
      or OwnerAddress is null or Acreage is null or TaxDistrict is null or LandValue is null 
      or BuildingValue is null or TotalValue is null or YearBuilt is null or Bedrooms is null
      or fullbath is null or halfbath is null;  --> checking columns with null values

select SoldAsVacant 
from housing2 --> error found in the coulumn , instead of 'NO' 
/* Fixing this error  we need to update the row with N to No and Y to Yes*/

update housing2
set SoldAsVacant = 'No'
where SoldAsVacant = 'N'

update housing2
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

--Changing Datatype and filling null value

UPDATE housing2
SET SaleDate = CAST(SaleDate AS DATE) --> changing SaleDate column Data type from varchar to date

select OwnerName, OwnerAddress, Acreage
from housing2
where OwnerName is null or OwnerAddress is null or Acreage is null 

-- replacing null with place holder for columnn with varchar data type

UPDATE housing2
SET PropertyAddress = coalesce(PropertyAddress, 'Unknown PropertyAddress'),
    OwnerName =  coalesce(OwnerName, 'Unknown OwnerName'),
    OwnerAddress =  coalesce(OwnerAddress, 'Unknown OwnerAddress'),
    TaxDistrict = coalesce (TaxDistrict,'Unknown TaxDistrict')
where PropertyAddress is null or OwnerName is null or OwnerAddress is null or TaxDistrict is null


/* Finding the average for column with null values for numerical data type  and replacing the null with thir average */

-- Calculate averages using a CTE
WITH AvgValues AS (
    SELECT 
        AVG(Bedrooms) AS AvgBedrooms,
        AVG(FullBath) AS AvgFullBath,
        AVG(HalfBath) AS AvgHalfBath
    FROM housing2
)
-- Update the table using the CTE
UPDATE housing2
SET 
    Bedrooms = COALESCE(Bedrooms, AvgValues.AvgBedrooms),
    FullBath = COALESCE(FullBath, AvgValues.AvgFullBath),
    HalfBath = COALESCE(HalfBath, AvgValues.AvgHalfBath)
FROM AvgValues
WHERE 
    Bedrooms IS NULL OR
    FullBath IS NULL OR
    HalfBath IS NULL;


with Cte as (
    select round(avg(Acreage), 2) avgAcreage
    from housing2 
    where Acreage is not null
)
update housing2
set LandValue = coalesce(Acreage, Cte.avgAcreage)from Cte
where Acreage is null

select * 
from housing2


with Cte as (
    select round(avg(LandValue), 2) avgLandValue
    from housing2 
    where LandValue is not null
)
update housing2
set LandValue = coalesce(LandValue, Cte.avgLandValue)
from Cte
where LandValue is null
