--Populate property Address data
--Deleting NULL values

SELECT * FROM nashville_housing_upd
--WHERE propertyaddress is null
ORDER BY parcelid;

-----------
SELECT 
    a.parcelid, 
    a.propertyaddress, 
    b.parcelid, 
    b.propertyaddress,
	ISNULL(a.propertyaddress,b.propertyaddress)
FROM nashville_housing_upd AS a
JOIN nashville_housing_upd AS b 
    ON a.parcelid = b.parcelid
   AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE nashville_housing_upd AS a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing_upd AS b
WHERE a.parcelid = b.parcelid
  AND a.uniqueid <> b.uniqueid
  AND a.propertyaddress IS NULL;
  
---------------------------------

--Breaking out address into individual columns (Address, City, State)
-- Extract Address (before first comma)
SELECT 
    SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1) AS address,
    SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1) AS city
FROM nashville_housing_upd;

-- Add new split columns
ALTER TABLE nashville_housing_upd
ADD COLUMN propertysplitaddress VARCHAR(255);

ALTER TABLE nashville_housing_upd
ADD COLUMN propertysplitcity VARCHAR(255);
-- Update the new columns with split values
UPDATE nashville_housing_upd
SET propertysplitaddress = SUBSTRING(propertyaddress FROM 1 FOR POSITION(',' IN propertyaddress) - 1),
    propertysplitcity = SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1);

SELECT * FROM nashville_housing_upd;
------
-- SPLITING OWNER ADDRESS INFO
SELECT 
    SPLIT_PART(owneraddress, ',', 1) AS address,   -- "123 Main St"
    SPLIT_PART(owneraddress, ',', 2) AS city,      -- "Nashville"
    SPLIT_PART(owneraddress, ',', 3) AS state      -- "TN"
FROM nashville_housing_upd;

ALTER TABLE nashville_housing_upd
ADD COLUMN ownersplitaddress VARCHAR(255),
ADD COLUMN ownersplitcity VARCHAR(255),
ADD COLUMN ownersplitstate VARCHAR(255);

UPDATE nashville_housing_upd
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1),
    ownersplitcity = SPLIT_PART(owneraddress, ',', 2),
    ownersplitstate = SPLIT_PART(owneraddress, ',', 3);

SELECT * FROM nashville_housing_upd;
-----------------------------


---CHANGES Y AND N to YES And NO in "Sold as Vacant Field"

SELECT soldasvacant, COUNT(*) AS record_count
FROM nashville_housing_upd
GROUP BY soldasvacant
ORDER BY soldasvacant;

SELECT 
    soldasvacant,
    CASE 
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END AS soldasvacant_clean
FROM nashville_housing_upd;

--UPDATING THE TABLE WITH NEW VALUES
UPDATE nashville_housing_upd
SET soldasvacant = CASE 
    WHEN soldasvacant = 'Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END;

---------------------------

---REMOVE DUPLICATES 
SELECT * FROM nashville_housing_upd;

WITH RowNumCTE AS (
    SELECT uniqueid,
           ROW_NUMBER() OVER (
               PARTITION BY parcelid,
                            propertyaddress,
                            saleprice,
                            saledate,
                            legalreference
               ORDER BY uniqueid
           ) AS row_num
    FROM nashville_housing_upd
)
DELETE FROM nashville_housing_upd
USING RowNumCTE
WHERE nashville_housing_upd.uniqueid = RowNumCTE.uniqueid
  AND RowNumCTE.row_num > 1;

-----------------------

--DELETE UNUSED COLUMS
SELECT * FROM nashville_housing_upd;

ALTER TABLE nashville_housing_upd
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;
