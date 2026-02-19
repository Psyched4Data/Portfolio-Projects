# COVID-19 Data Cleaning and Visualization
## Project Overview
In this project, I take a data set from "Our World in Data" that describes global COVID-19 figures. 
I take the raw CSV file, clean the date entries, use formulas to create a rolling count of people vaccinated over time, 
and lastly I use Tableau to create visualizations based on the SQL queries. Unfortunately, not all of the data was 
uploaded onto MySQL and so this led to limitations on the data that could be displayed in Tableau.
### The goal of the two SQL files was to:
- Clean and format the raw COVID-19 dataset
- Compute meaningful metrics (death %, infection %, vaccination %)
- Aggregate global and country-level statistics
- Demonstrate SQL techniques like joins, CTEs, and window functions

## Step 1: Data Cleaning (COVID SQL Cleaning)
```sql
-- View raw data
SELECT *
FROM portfolio.dirty_covid_data;

-- Add columns to extract Year, Month, Day
ALTER TABLE portfolio.dirty_covid_data ADD year VARCHAR(5);
ALTER TABLE portfolio.dirty_covid_data ADD month VARCHAR(3);
ALTER TABLE portfolio.dirty_covid_data ADD day VARCHAR(3);

-- Update year from last 2 digits of date
UPDATE portfolio.dirty_covid_data
SET year = RIGHT(date, 2) + 2000;

-- Update month with proper 2-digit formatting
UPDATE portfolio.dirty_covid_data
SET month = CASE
    WHEN SUBSTRING_INDEX(date,'/',1) = '1' THEN '01'
    WHEN SUBSTRING_INDEX(date,'/',1) = '2' THEN '02'
    -- ... additional months up to 12
    ELSE SUBSTRING_INDEX(date,'/',1)
END;

-- Update day with proper 2-digit formatting
UPDATE portfolio.dirty_covid_data
SET day = CASE
    WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '1' THEN '01'
    WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '2' THEN '02'
    -- ... additional days up to 31
    ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1)
END;

-- Combine into formatted date
ALTER TABLE portfolio.dirty_covid_data ADD formatted_date DATE;
UPDATE portfolio.dirty_covid_data
SET formatted_date = CONCAT(year, '-', month, '-', day);
```
### What I Did
- Cleaned inconsistent date formats in the raw COVID dataset.
- Split the date column into year, month, day.
- Combined these into a new formatted_date column.

### How I Did It
- Used ALTER TABLE to add temporary columns.
- Used SUBSTRING_INDEX and CASE statements to standardize months/days.
- Concatenated cleaned columns into YYYY-MM-DD format.

### Why I Did It
Standardized dates are necessary for accurate joins, filtering, and time-series analysis in SQL.

## Step 2: Data Exploration (COVID SQL Exploration)
```sql
-- View datasets to verify import
SELECT * FROM Portfolio.covid_deaths ORDER BY location, date;
SELECT * FROM Portfolio.covid_vaccinations ORDER BY location, date;
SELECT * FROM Portfolio.covid_data ORDER BY location, date;

-- Compute % deaths for a country (Armenia example)
SELECT location, date, total_cases, total_deaths,
       (total_deaths/total_cases)*100 AS total_death_percentage
FROM Portfolio.covid_data
WHERE location = 'Armenia' AND continent IS NOT NULL
ORDER BY location, date;

-- Compute % infected of population
SELECT location, date, total_cases, population,
       (total_cases/population)*100 AS total_infection_percentage
FROM Portfolio.covid_data
WHERE location = 'Armenia' AND continent IS NOT NULL
ORDER BY location, date;

-- Top countries by infection %
SELECT location, MAX(total_cases) AS max_case_count,
       population, (MAX(total_cases)/population)*100 AS max_infection_percentage
FROM Portfolio.covid_data
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_infection_percentage DESC;

-- Top countries by death %
SELECT location, MAX(total_deaths) AS max_death_count,
       population, (MAX(total_deaths)/population)*100 AS max_death_percentage
FROM Portfolio.covid_data
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_death_percentage DESC;

-- Global totals
SELECT SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM Portfolio.covid_deaths
WHERE continent IS NOT NULL;
```

### What I Did
- Explored COVID metrics such as infection rates, death rates, and total cases.
- Compared countries and examined global totals.

### How I Did It
- Used SELECT statements with calculations for percentages.
- Aggregated data with MAX(), SUM(), and GROUP BY.
- Filtered out rows with missing continent data.

### Why I Did It
Provides insights into relative impacts of COVID by country and globally.

## Step 3: Joining Vaccinations & Deaths
```sql
-- Join deaths and vaccinations on location and date
SELECT *
FROM Portfolio.covid_deaths
JOIN Portfolio.covid_vaccinations
ON Portfolio.covid_deaths.location = Portfolio.covid_vaccinations.location
AND Portfolio.covid_deaths.date = Portfolio.covid_vaccinations.date;

-- Use CTE to compute rolling vaccination count & percentage
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS (
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
           SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_people_vaccinated
    FROM Portfolio.covid_deaths d
    JOIN Portfolio.covid_vaccinations v
      ON d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_percent_vaccinated
FROM PopvsVac;
```
### What I Did
- Combined COVID deaths and vaccination datasets.
- Calculated rolling vaccination counts and percentages.

### How I Did It
- Used JOIN on location and date.
- Implemented a CTE with SUM() OVER() for rolling totals.

### Why I Did It
Allows analysis of vaccination progress over time alongside deaths and cases.

## Skills Demonstrated
- SQL Data Cleaning (dates, missing values)
- Aggregation & Percent Calculations
- Joining Multiple Tables
- Window Functions & CTEs for Rolling Totals
- Country-Level & Global Analysis
