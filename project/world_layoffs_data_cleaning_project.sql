-- Data Cleaning 
# importing the schemas first to do the further process
# create new schema, in schemas tab right click it and click the table import wizard and import the dataset

SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data (capitalize, spell check, etc...)
-- 3. Null Values or Blank values
-- 4. Removing unnecessary columns in dataset

-- create a table similar to the raw dataset
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- to obtain the duplicate rows we use the window function partition by and over with the analytical function ROW_NUMBER() in the CTE
-- What is the ROW_NUMBER sequence in SQL?
-- ROW_NUMBER numbers all rows sequentially (for example 1, 2, 3, 4, 5). RANK provides the same numeric value for ties (for example 1, 2, 2, 4, 5).
--  ROW_NUMBER is a temporary value calculated when the query is run. To persist numbers in a table, see IDENTITY Property and SEQUENCE.

-- In MySQL, a Common Table Expression (CTE) is a temporary named result set that's defined within a WITH clause and used within a single SQL statement.
-- It's essentially a named subquery that can be referenced multiple times within the same statement, improving readability and making complex queries easier to manage

-- In MySQL, the OVER clause is used with window functions to define the scope of calculations performed on rows. It enables window functions to calculate values
-- (like aggregates or ranks)
-- based on a group of rows, instead of just the current row. This allows for calculations relative to other rows within a defined window

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(                       
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1 ;

SELECT *
FROM layoffs_staging
WHERE company = 'yahoo';

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(                       
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num >1 ;           -- CANNOT BE DELETED AS UPDATABLE IN CTE



CREATE TABLE `layoffs_staging2` (                       -- CREATING A NEW TABLE FOR DELETING THE DATA AND FOR THE USE OF FURTHER PROCESSING
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(                       
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE company = 'yahoo' or 'casper';

DELETE FROM layoffs_staging2
WHERE row_num > 1;                             -- all the duplicated rows are deleted


-- Standardizing data
-- Starting from the company column , we check for anamolies
SELECT * 
FROM layoffs_staging2;

SELECT company , TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Industry field is been checked next

SELECT DISTINCT( industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Country field is checked for standardization

SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;
-- or it can be done by
SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Date field is setted in appropriate format and data type

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY 	COLUMN `date` DATE; 

-- total_laid_off and the percentage_laid_off field are checked for valid data thats been usable for future process


-- industry field is checked for blank or null values to be filled
-- using references of the same company and location
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- UPDATE layoffs_staging2
-- SET industry = 'Travel'
-- WHERE company = 'Airbnb' AND industry = '';  -- is a lame work to do , it can be effectively done by join

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
OR t1.industry = ''
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2
WHERE company = 'Bally''s Interactive';

-- total_laid_off and the percentage_laid_off field are checked for valid data thats been usable for future process
-- and deleting the unusable data thats not needed anymore
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT * 
FROM layoffs_staging2;

-- Droping the unwanted rows or columns from table

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs;             -- raw dataset
SELECT *
FROM layoffs_staging;     -- copied data set
SELECT *
FROM layoffs_staging2;    -- cleaned data set