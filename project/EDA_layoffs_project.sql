-- Exploratory Data Analysis
-- using the previously cleaned dataset
SELECT *
FROM layoffs_staging2;

-- finding the max and min of total laid off that is 12000
SELECT MAX(total_laid_off), MAX(percentage_laid_off), MIN(total_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2;

-- funds_raised_millions topper is british volt has 2400 millions who had laid off 1% (100/100 total employees)
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- this explains the company wise laid off toppers by amazon 18150, google 12000, meta 11000, salesforce 10090, microsoft 10000
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- the min date is 2020-03-11 and max date is 2023-03-06
SELECT MIN(`date`), MAX(`date`)  -- 3 years from 2020 to 20223
FROM layoffs_staging2;

-- the industry wise toppers are consumer 45182, retail 43613, other 36289, transportation 33748, finance 28344
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- country wise 	United States	256559, 	India	35993,	Netherlands	17220,	Sweden	11264,	Brazil	10391
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- by the date and year wise 	2023	125677,	2022	160661,	2021	15823,	2020	80998
SELECT Year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY Year(`date`)
ORDER BY 1 DESC;

-- stages wise 	Post-IPO	204132,	Unknown	40716,	Acquired	27576,	Series C	20017,	Series D	19225
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- company wise 
SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- 
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- with rolling total of 	2023-03	4470	383159
WITH Rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) Total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC)
SELECT `MONTH`, Total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_total
FROM Rolling_total;

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL               #
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;



WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE total_laid_off IS NOT NULL AND years IS NOT NULL
ORDER BY Ranking ASC;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE total_laid_off IS NOT NULL AND years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;


WITH Company_Year (company, country, years, total_laid_off) AS
(
SELECT company, country, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, country, YEAR(`date`)
), Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE total_laid_off IS NOT NULL AND years IS NOT NULL
AND country = 'India'
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;


































