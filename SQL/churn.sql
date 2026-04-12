## Initialize the project workspace
## Switches the session to the dedicated churn database for analysis.
use churn_analysis_db;
## Audit existing data structures
##Lists all available tables to confirm the database schema is correctly initialized.
show tables;
## Data Integrity & Schema Validation
## Checks the column names, data types, and null constraints for the staging table.
## This ensures the 'stg_churn' table aligns with the source CSV before data ingestion.
describe stg_churn;
## Execute Bulk Data Load (LOAD DATA INFILE) once schema is validated.
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer_Data.csv"
INTO TABLE stg_churn
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM stg_churn;
SELECT * FROM stg_churn LIMIT 5;


SET SQL_SAFE_UPDATES = 0;

UPDATE churn_prod 
SET Tenure_Group = CASE  
    WHEN Tenure_in_Months <= 6 THEN '0-6 Months' 
    WHEN Tenure_in_Months <= 12 THEN '6-12 Months' 
    WHEN Tenure_in_Months <= 24 THEN '1-2 Years' 
    ELSE 'Over 2 Years' 
END;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE churn_prod ADD COLUMN Age_Group VARCHAR(20);

-- 1. Turn off Safe Updates
SET SQL_SAFE_UPDATES = 0;

-- 2. Run the Update
UPDATE churn_prod 
SET Age_Group = CASE  
    WHEN Age >= 65 THEN 'Senior' 
    WHEN Age >= 30 THEN 'Adult' 
    ELSE 'Youth' 
END;

-- 3. Turn Safe Updates back on (Good practice!)
SET SQL_SAFE_UPDATES = 1;

SELECT 
    Customer_ID, 
    Age, 
    Age_Group, 
    Tenure_in_Months, 
    Tenure_Group,
    Monthly_Charge,
    Total_Revenue
FROM churn_prod 
LIMIT 10;

-- Disable safe mode
SET SQL_SAFE_UPDATES = 0;

-- Update Age Groups
UPDATE churn_prod 
SET Age_Group = CASE  
    WHEN Age >= 65 THEN 'Senior' 
    WHEN Age >= 30 THEN 'Adult' 
    ELSE 'Youth' 
END
WHERE Customer_ID IS NOT NULL; -- This helps bypass safe mode

-- Update Tenure Groups
UPDATE churn_prod 
SET Tenure_Group = CASE  
    WHEN Tenure_in_Months <= 6 THEN '0-6 Months' 
    WHEN Tenure_in_Months <= 12 THEN '6-12 Months' 
    WHEN Tenure_in_Months <= 24 THEN '1-2 Years' 
    ELSE 'Over 2 Years' 
END
WHERE Customer_ID IS NOT NULL;

-- Re-enable safe mode
SET SQL_SAFE_UPDATES = 1;

-- Check the results
SELECT Customer_ID, Age, Age_Group, Tenure_in_Months, Tenure_Group 
FROM churn_prod 
LIMIT 10;

-- Delete the old, broken table
DROP TABLE IF EXISTS churn_prod;

-- Create the table and CALCULATE the groups immediately
CREATE TABLE churn_prod AS
SELECT 
    *,
    CASE 
        WHEN Age >= 65 THEN 'Senior' 
        WHEN Age >= 30 THEN 'Adult' 
        ELSE 'Youth' 
    END AS Age_Group,
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '0-6 Months' 
        WHEN Tenure_in_Months <= 12 THEN '6-12 Months' 
        WHEN Tenure_in_Months <= 24 THEN '1-2 Years' 
        ELSE 'Over 2 Years' 
    END AS Tenure_Group
FROM stg_churn;

--  Check the results
SELECT Customer_ID, Age, Age_Group, Tenure_in_Months, Tenure_Group 
FROM churn_prod 
LIMIT 10;
-- Create the table and CALCULATE the groups immediately
CREATE TABLE churn_prod AS
SELECT 
    *,
    CASE 
        WHEN Age >= 65 THEN 'Senior' 
        WHEN Age >= 30 THEN 'Adult' 
        ELSE 'Youth' 
    END AS Age_Group,
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '0-6 Months' 
        WHEN Tenure_in_Months <= 12 THEN '6-12 Months' 
        WHEN Tenure_in_Months <= 24 THEN '1-2 Years' 
        ELSE 'Over 2 Years' 
    END AS Tenure_Group
FROM stg_churn;
  
--- Check the results
SELECT Customer_ID, Age, Age_Group, Tenure_in_Months, Tenure_Group 
FROM churn_prod 
LIMIT 10;

SELECT * FROM churn_prod;
SELECT Customer_Status, Churn_Category FROM stg_churn LIMIT 10;
SET SQL_SAFE_UPDATES = 0;


SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) 
FROM churn_prod 
WHERE Customer_Status = '' OR Customer_Status IS NULL;

SELECT 
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Customer_Status IS NULL OR Customer_Status = '' THEN 1 ELSE 0 END) AS Missing_Status,
    SUM(CASE WHEN Churn_Category IS NULL OR Churn_Category = '' THEN 1 ELSE 0 END) AS Missing_Category,
    SUM(CASE WHEN Age_Group IS NULL THEN 1 ELSE 0 END) AS Missing_Age_Groups
FROM churn_prod;

SELECT Customer_Status, Churn_Category, COUNT(*) as Count
FROM churn_prod
GROUP BY Customer_Status, Churn_Category
ORDER BY Customer_Status;

Select Count(*) as total_records from churn_prod;
Select * from churn_prod;
