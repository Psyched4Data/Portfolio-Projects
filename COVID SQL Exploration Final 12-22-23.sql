## After importing the CSV into MySQL, I just want to view the data to be sure that it imported correctly
## I also wanted to be sure that the I cleaned the data properly in Excel and set the dates in the right format
SELECT*
FROM Portfolio.covid_deaths
ORDER BY location, date;

SELECT*
FROM Portfolio.covid_vaccinations
ORDER BY location, date;

SELECT*
FROM Portfolio.covid_data
ORDER BY location, date;

## I noticed one problem while examining the data. Sometimes the continent is listed under 'location' rather than 'continent' when this is 
## the case, the 'continent' column is NULL. To fix this I just add WHERE continent is not NULL to the queries
## Since all of the data looks good to go, I will now begin exploring the death rate and other values
## First I will examine the total cases vs total deaths in Armenia
## by using the formula (total_deaths/total_cases)*100 I can get the % of those who contracted covid died
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS total_death_percentage
FROM Portfolio.covid_data
WHERE location = 'Armenia' AND continent is not NULL
ORDER BY location, date;

## Next I will do a similar process but for looking at the % of the population that contracted covid for Armenia
SELECT location, date, total_cases, population, (total_cases/population)*100 AS total_infection_percentage
FROM Portfolio.covid_data
WHERE location = 'Armenia' AND continent is not NULL
ORDER BY location, date;

## Now I will run a query that will give me the countries with the highest % of the population that contracted covid
SELECT location, MAX(total_cases) AS max_case_count, population, (MAX(total_cases)/population)*100 AS max_infection_percentage
FROM Portfolio.covid_data
WHERE continent is not NULL
GROUP BY location, population
ORDER BY max_infection_percentage DESC;

## I will do the same thing as above but with death count so that I get the countries that have the largest % of their population that died
SELECT location, MAX(total_deaths) AS max_death_count, population, (MAX(total_deaths)/population)*100 AS max_death_percentage
FROM Portfolio.covid_data
WHERE continent is not NULL
GROUP BY location, population
ORDER BY max_death_percentage DESC;

## I can also just get most deaths per a country regardless of population size
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_death_count
FROM Portfolio.covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC;

## I can even look at the total number of global cases, deaths, and the global death percentage
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM Portfolio.covid_deaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date DESC;

## I can also get total global cases, deaths, and death percentage for the entire pandemic
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM Portfolio.covid_deaths
WHERE continent is not NULL;

## Now I am going to join the 'covid_deaths' with the 'covid_vaccinations' table using location and date since both tables share that data
SELECT *
FROM Portfolio.covid_deaths
JOIN Portfolio.covid_vaccinations
ON Portfolio.covid_deaths.location = Portfolio.covid_vaccinations.location
AND Portfolio.covid_deaths.date = Portfolio.covid_vaccinations.date;

## The join syntax is correct so now I can be picky about what I include in the SELECT statement 
## Next, just to show off, I will create a Common Table Expression (CTE). This is sometimes called a WITH query.
## I will use the CTE and create a rolling count of the people vaccinated. This will track how many total people become vaccinated over time. 
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
    Portfolio.covid_deaths.continent, 
    Portfolio.covid_deaths.location, 
    Portfolio.covid_deaths.date, 
    Portfolio.covid_deaths.population, 
    Portfolio.covid_vaccinations.new_vaccinations, 
    SUM(Portfolio.covid_vaccinations.new_vaccinations) OVER (
        PARTITION BY Portfolio.covid_deaths.location
        ORDER BY Portfolio.covid_deaths.location, Portfolio.covid_deaths.date
    ) AS rolling_people_vaccinated
FROM Portfolio.covid_deaths
JOIN Portfolio.covid_vaccinations
    ON Portfolio.covid_deaths.location = Portfolio.covid_vaccinations.location
    AND Portfolio.covid_deaths.date = Portfolio.covid_vaccinations.date
WHERE Portfolio.covid_deaths.continent IS NOT NULL
ORDER BY location, date
)
## Above is the CTE and below is the query that creates the rolling percentage of the people vaccinated
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_percent_vaccinated
FROM PopvsVac;