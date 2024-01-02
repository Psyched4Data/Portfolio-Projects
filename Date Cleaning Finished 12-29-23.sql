SELECT*
FROM portfolio.dirty_covid_data;
## Dates are not formatted correctly in data source so I had to re-arrange the characters and specify that the new string is a date. 
## Dates in the original source are set as 'M-D-YY' or 'MM-D-YY' or 'M-DD-YY' or 'MM-DD-YY' and I need them all to be 'YYYY-MM-DD'
## To start this process, I am going to add a new column for 'year', 'month', and 'day'. 
ALTER TABLE portfolio.dirty_covid_data
ADD year VARCHAR(5);
ALTER TABLE portfolio.dirty_covid_data
ADD month VARCHAR(3);
ALTER TABLE portfolio.dirty_covid_data
ADD day VARCHAR(3);
## Now I just check that the new columns were created properly
SELECT year, month, day
FROM portfolio.dirty_covid_data;
## Now that the columns are there, I just need to fill them with the correct data formatted properly.
SET SQL_SAFE_UPDATES = 0;
## First, I need to turn off the Safe Updates option using the query above.
## Next, I update the tables
UPDATE portfolio.dirty_covid_data
SET year = RIGHT(date, 2) + 2000;
## year was easy as I just needed to isolate the last 2 characters and then add 2000 to get the correct year
UPDATE portfolio.dirty_covid_data
SET month =
CASE
	WHEN SUBSTRING_INDEX(date,'/',1) = '1' THEN '01'
    WHEN SUBSTRING_INDEX(date,'/',1) = '2' THEN '02'
    WHEN SUBSTRING_INDEX(date,'/',1) = '3' THEN '03'
    WHEN SUBSTRING_INDEX(date,'/',1) = '4' THEN '04'
	WHEN SUBSTRING_INDEX(date,'/',1) = '5' THEN '05'
	WHEN SUBSTRING_INDEX(date,'/',1) = '6' THEN '06'
	WHEN SUBSTRING_INDEX(date,'/',1) = '7' THEN '07'
	WHEN SUBSTRING_INDEX(date,'/',1) = '8' THEN '08'
	WHEN SUBSTRING_INDEX(date,'/',1) = '9' THEN '09'
    ELSE SUBSTRING_INDEX(date,'/',1)
END;
## month was a bit more complicated. I could use SUBSTRING_INDEX to get the number but since the original formatting could be 'M' or 'MM' I used CASE
## to ensure that all rows were 'MM"
UPDATE portfolio.dirty_covid_data
SET day = CASE
	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '1' THEN '01'
    WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '2' THEN '02'
    WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '3' THEN '03'
    WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '4' THEN '04'
	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '5' THEN '05'
	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '6' THEN '06'
	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '7' THEN '07'
	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '8' THEN '08'
	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1) = '9' THEN '09'
    ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(date,'/',2),'/',-1)
END;
## to format the day correctly I used the same process as for month. 
## Next, I just check that all the data is entered correctly
SELECT date, year, month, day
FROM portfolio.dirty_covid_data;
## Now I need to insert this new data into the table as the new column as 'formatted_date'
ALTER TABLE portfolio.dirty_covid_data
ADD formatted_date date;
UPDATE portfolio.dirty_covid_data
SET formatted_date = CONCAT(year, '-', month, '-', day);
## I'll again verify that everything looks good
SELECT date, year, month, day,formatted_date
FROM portfolio.dirty_covid_data;
## Now that the data has been cleaned, I can begin to explore it.
SET SQL_SAFE_UPDATES = 1