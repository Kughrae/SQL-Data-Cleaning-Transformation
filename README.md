# SQL Data Cleaning & Transformation

## Project Overview

For this project, I worked with a global layoffs dataset sourced from Kaggle. The original dataset was provided as an Excel file, which I imported into Microsoft SQL Server for cleaning and transformation.

My goal was to take the raw dataset and make it cleaner, more consistent, and ready for further analysis. I used SQL to identify duplicate records, standardize inconsistent values, handle missing information, convert data types, and remove records that did not contain sufficient layoff information.

## Dataset

The dataset I used is a global layoffs dataset sourced from Kaggle.

The original raw Excel file is included in the `data` folder of this repository.

**Raw Dataset:** `data/layoffs_raw.xlsx`

The dataset contains information about company layoffs, including:

* Company
* Location
* Industry
* Total employees laid off
* Percentage of workforce laid off
* Date
* Country
* Funds raised

## Tools Used

* **Microsoft SQL Server**
* **Microsoft Excel** for the original dataset

## Data Cleaning Process

### 1. Table Setup & Staging

I started by preparing the original table and checking the `date` column for values that could cause problems during conversion.

I cleaned text values such as `'NULL'` and empty strings by converting them into actual `NULL` values. I then used `TRY_CONVERT()` to safely convert the dates into the proper `DATE` format.

After preparing the original table, I created a staging table called `layoffs_staging`. I used the staging table for the main cleaning process so that the original data remained separate from the cleaned version.

### 2. Removing Duplicates

Next, I checked the staging table for duplicate records.

I used the `ROW_NUMBER()` window function to identify records with matching values for:

* Company
* Industry
* Total laid off
* Date

I first previewed the records identified as duplicates by filtering for `row_num > 1`. After checking the results, I used a Common Table Expression (CTE) to remove the duplicate records from the staging table.

### 3. Standardizing Data

After removing duplicates, I reviewed the dataset for inconsistent and missing values.

#### Industry

For the `industry` column, I:

* Checked the distinct industry values
* Converted empty strings into `NULL`
* Identified records with missing industry information
* Used a self-join to fill missing industry values when another record for the same company had an industry value
* Standardized industry values beginning with `Crypto` to `Crypto`

#### Country

I reviewed the distinct country values and identified inconsistencies in country names.

I then standardized variations of `United States` so that they used a consistent value.

#### Date

I also converted the date values in the staging table into the proper `DATE` data type and altered the column so that the cleaned table stored the dates correctly.

### 4. Final Cleanup & Filtering

For the final cleanup, I looked for records that did not contain any layoff information.

I identified and removed rows where both:

* `total_laid_off` was `NULL`
* `percentage_laid_off` was `NULL`

After making the final changes, I ran a query to review the cleaned dataset.

## SQL Concepts Used

Throughout this project, I used several SQL concepts for data cleaning and transformation, including:

* `SELECT`
* `UPDATE`
* `DELETE`
* `WHERE`
* `ORDER BY`
* `DISTINCT`
* `LIKE`
* `INNER JOIN`
* Self-joins
* `ROW_NUMBER()`
* Window functions
* Common Table Expressions (CTEs)
* `NULL` handling
* `LTRIM()` and `RTRIM()`
* `TRY_CONVERT()`
* `CONVERT()`
* `ALTER TABLE`
* Data type conversion
* Staging tables

## Project Structure

```text
SQL-Data-Cleaning-Transformation/
│
├── README.md
├── layoffs_data_cleaning.sql
│
└── data/
    └── layoffs_raw.xlsx
```

## Project Outcome

After completing the cleaning process, I was able to transform the raw layoffs dataset into a cleaner and more consistent dataset.

The process removed duplicate records, standardized inconsistent values, filled missing industry information where possible, converted data into appropriate formats, and removed records without sufficient layoff information.

The cleaned dataset is now better prepared for further exploratory analysis and other data analytics work.

## Project Author
Carrey Nadine S. Magante
