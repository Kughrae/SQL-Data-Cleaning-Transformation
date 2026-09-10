-- DATA CLEANING WITH SQL | PROJECT #1

-- =================================================================================================================================
-- [1] Table Setup & Staging 
-- =================================================================================================================================

-- 1. Clean 'NULL' text from the date column
UPDATE world_layoffs
SET [date] = NULL
WHERE LTRIM(RTRIM([date])) IN ('NULL', '');

-- 2. Safely parse and convert dates
UPDATE world_layoffs
SET [date] = TRY_CONVERT(DATE, [date])
WHERE [date] IS NOT NULL;

-- 3. Alter the date column to proper DATE type
ALTER TABLE world_layoffs ALTER COLUMN [date] DATE;
GO

SELECT * 
FROM world_layoffs;

-- =================================================================================================================================
-- [2] Removing Duplicates	   
-- =================================================================================================================================

-- 1. Creating a staging table
SELECT * 
INTO layoffs_staging 
FROM world_layoffs;

-- 2. Generating row numbers to identify duplicates
SELECT 
	company, 
	industry, 
	total_laid_off,
	date,
	ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,date ORDER BY company) AS row_num
FROM layoffs_staging;

-- 3.Previewing the duplicates
SELECT *
FROM (
	SELECT 
		company, 
		industry, 
		total_laid_off,
		date,
		ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,date ORDER BY company) AS row_num
	FROM layoffs_staging
) AS duplicates
WHERE row_num > 1

-- 4. Transforming the preview into a CTE
WITH DuplicateCTE AS (
	SELECT 
		company, 
		industry, 
		total_laid_off,
		date,
		ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,date ORDER BY company) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM DuplicateCTE
WHERE row_num > 1;

-- 5. Deleting the duplicates directtly once verified
WITH DuplicateCTE AS (
	SELECT 
		company, 
		industry, 
		total_laid_off,
		date,
		ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,date ORDER BY company) AS row_num
	FROM layoffs_staging
)
DELETE FROM DuplicateCTE
WHERE row_num > 1;

-- =================================================================================================================================
-- [3] Standardizing data	   
-- =================================================================================================================================

-- 1. Checking industry column inconsistencies
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry;

-- 2. Isolating rows with missing industry data
SELECT *
FROM layoffs_staging
WHERE industry IS NULL OR industry = ''
ORDER BY industry;

-- 3. Standardizing empty strings to NULL
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '' OR LTRIM(RTRIM(industry)) = '';

-- 4. Previewing missing industry rows
SELECT 
	company, 
	location, 
	industry
FROM layoffs_staging
WHERE industry IS NULL;

-- 5. Populating NULL industries using a Self-Join
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging AS t1
INNER JOIN layoffs_staging AS t2 
    ON t1.company = t2.company
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;

-- 6. Verifying the self-join results
SELECT *
FROM layoffs_staging
WHERE industry IS NULL
OR industry = '';

-- 7. Checking current industry variation
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry;

-- 8. Standardizing all variations to 'Crypto'
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 9. Verifying the industry fix
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry;

-- 10. Checking distinct country names
SELECT DISTINCT country
FROM layoffs_staging
ORDER BY country;

-- 11. Standardizing country names (removing trailing periods)
UPDATE layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%';

-- 12. Verifying the country fix
SELECT DISTINCT country
FROM layoffs_staging
ORDER BY country;

-- 13. Converting text dates to proper DATE type
UPDATE layoffs_staging
SET [date] = CONVERT(DATE, [date], 101)  -- Style 101 corresponds to mm/dd/yyyy
WHERE [date] IS NOT NULL 
AND [date] != '';

-- 14. Altering the column data type permanently
ALTER TABLE layoffs_staging
ALTER COLUMN [date] DATE;

-- =================================================================================================================================
-- [4] Final Cleanup & Filtering	   
-- =================================================================================================================================

-- 1. Inspecting rows with no layoff data
SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- 2. Deleting rows with no layoff data
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- 3. Final sanity check on the clean dataset
SELECT * 
FROM layoffs_staging;