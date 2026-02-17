# Web Scraping Wikipedia and Books to Scrape.com with Beautiful Soup
In this project I scraped two different sites using Beautiful Soup, turned the results into csv files, and created a visualization of the results. In WikiWebScrapping.ipynb, I collected data on the largest companies by revenue according to Wikipedia and created a graph to visualize which industries were the most profitable. In BookWebScrapping.ipynb, I pulled data from the website books.toscrape.com to collect details on all of the books listed. I then created visuals to show the average price and number of books based on the rating of the book. Visualizations were created with matplotlib.

## Books to Scrape
This project demonstrates end-to-end data collection, cleaning, storage, and visualization using Python.

I scraped book data from BooksToScrape.com, extracted structured information (title, price, and rating), stored the data in a CSV file, and performed exploratory analysis to uncover pricing patterns across star ratings.

This project highlights skills in:
- Web scraping with requests and BeautifulSoup
- Data wrangling with pandas
- Data visualization with matplotlib
- Automation across multiple pages
- Converting unstructured HTML into structured datasets

### Step 1 Pull the HTML
```python
import requests
from bs4 import BeautifulSoup

url = "https://books.toscrape.com/"
response = requests.get(url)
response = response.content
soup = BeautifulSoup(response, 'html.parser')
soup
```
#### What I Did
- Sent an HTTP request to the website using requests
- Retrieved the raw HTML content
- Parsed the HTML using BeautifulSoup
- Converted the webpage into a searchable object (soup)

#### Why This Matters
Web pages are unstructured HTML.
To extract meaningful data, we must first convert that HTML into a structured format that Python can navigate.

This step establishes the foundation for automated scraping.

### Step 2 Scrape the Key Data
```python
import requests
from bs4 import BeautifulSoup
import pandas as pd

books = []

for i in range(1,51):
    url = f"https://books.toscrape.com/catalogue/page-{i}.html"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, "html.parser")
    ol = soup.find("ol")
    articles = ol.find_all('article', class_='product_pod')

    for article in articles:
    
        # Title
        image = article.find("img")
        title = image["alt"]
    
        # Star rating
        star_tag = article.find("p", class_="star-rating")
        star_text = star_tag["class"][1]
        star_map = {
            "One": 1,
            "Two": 2,
            "Three": 3,
            "Four": 4,
            "Five": 5
        }
        stars = star_map[star_text]
    
        # Price
        price = article.find("p", class_="price_color").text
        price = float(price.replace("£", ""))
    
        books.append([title, price, stars])
```
#### What I Did
- Automated scraping across all 50 pages using a loop
- Located each book container using HTML tags
- Extracted:
    * Book title
    * Star rating (converted from text to numeric)
    * Price (cleaned and converted to float)
    * Stored results in a Python list

#### Why This Matters
This demonstrates:
- Web automation
- Data cleaning during extraction
- Transforming messy HTML attributes into usable structured data

### Step 3 Creating a Structured Dataset
#### What I did
- Converted the raw list into a structured pandas DataFrame
- Assigned meaningful column names
- Exported the dataset to CSV for future use
#### Why This Matters
- Raw scraped data is not useful until structured properly.
- This step transforms collected data into an analysis-ready dataset.

### Step 4 Make Visuals
```python
import matplotlib.pyplot as plt

df["Star Rating"] = df["Star Rating"].astype(int)

avg_price = df.groupby("Star Rating")["Price"].mean().reindex([1,2,3,4,5])

plt.figure()
plt.plot(
    avg_price.index, 
    avg_price.values, 
    marker='o',
    linewidth=3,
    markersize=8,
    color='teal'
)

for x, y in zip(avg_price.index, avg_price.values):
    plt.text(x, y + 0.2, f"{y:,.2f}", ha='center')

plt.xlabel("Star Rating")
plt.ylabel("Average Price (£)")
plt.title("Average Book Price by Star Rating")
plt.xticks([1, 2, 3, 4, 5])
plt.ylim(34, 37)
plt.grid(alpha=0.3)

plt.show()
```
#### What I Did
- Grouped books by star rating
- Calculated average price for each rating
- Visualized the relationship using a line chart
- Added data labels for clarity

#### Analytical Insight
Do higher-rated books cost more on average?
<img src="Visuals/Average Book Price by Star Rating.png" width="600">

### Next Visual
```python
rating_counts = df["Star Rating"].value_counts().reindex([1,2,3,4,5])

plt.figure()
plt.plot(
    rating_counts.index, 
    rating_counts.values, 
    marker='o', 
    linewidth=3, 
    markersize=8,
    color='orange'
)

for x, y in zip(rating_counts.index, rating_counts.values):
    plt.text(x, y + 2, f"{y}", ha='center')

plt.xlabel("Star Rating")
plt.ylabel("Number of Titles")
plt.title("Number of Books by Star Rating")
plt.xticks([1,2,3,4,5])
plt.ylim(175, 230)
plt.grid(alpha=0.3)

plt.show()
```
#### What I Did
- Counted number of books per star rating
- Visualized the frequency distribution
- Added annotations for interpretability

#### Analytical Insight
Are certain ratings more common than others?
<img src="Visuals/Count of Books by Rating.png" width="600">

## Scraping the largest companies from Wikipedia
This project demonstrates advanced web scraping, complex table parsing, data cleaning, and industry-level revenue analysis using Python.
I scraped the Wikipedia page listing the largest companies by revenue and built a complete data pipeline to:
- Extract structured company-level financial data
- Handle complex HTML tables with rowspan
- Clean and transform revenue values
- Expand multi-industry classifications
- Compute and visualize average revenue by industry

This project highlights deeper scraping logic beyond simple tag extraction.

### Step 1 Connecting to Wikipedia
```python
from bs4 import BeautifulSoup
import requests
import time
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

headers = {
    'User-Agent': 'WikiScraper/1.0 (https://github.com/Psyched4Data/Portfolio-Projects/tree/main/Web%20Scraping%20With%20Python; haydongonzalezdyer@gmail.com)'
}

url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_by_revenue'
page = requests.get(url, headers=headers)
soup = BeautifulSoup(page.text, 'html.parser')
print(soup)
```
#### What I Did
- Sent a request with a custom User-Agent header
- Retrieved the HTML content
- Parsed the webpage into a searchable object

##### Why This Matters
Using a custom header:
- Demonstrates responsible scraping practices
- Identifies the script to the server
- Reduces the risk of being blocked

### Step 2 Extracting Table Headers
```python
table = soup.find('table', class_='wikitable')
header_row = table.find('tr')
headers_list = [th.get_text(strip=True) for th in header_row.find_all('th')]
headers_list = [h.split('[')[0] if '[' in h else h for h in headers_list]

df = pd.DataFrame(columns=headers_list)
```
#### What I Did
- Located the main revenue table
- Extracted column headers dynamically
- Removed reference footnotes (e.g., “[1]”)
 -Created an empty structured DataFrame

#### Why This Matters
Wikipedia tables often include:
- Footnote markers
- Inconsistent formatting

### Step 3 Handling Complex Tables with rowspan
```python
rows = table.find_all("tr")[1:]
all_rows_data = []
active_rowspans = {}

for row in rows:
    ...
```
#### What I Did
Wikipedia’s table includes rowspan attributes, meaning:
- Some cells span multiple rows instead of repeating their value.
- To correctly extract the table:
    * Tracked active rowspans in a dictionary
    * Carried values forward when rows were merged
    * Managed column alignment manually
    * Added safety padding for missing cells

#### Why This Matters
- Most beginner scrapers fail when encountering rowspan.
- This section demonstrates:
    * Advanced HTML structure handling
    * Defensive programming
    * Data integrity validation

### Step 4 Converting to a Clean Dataset
```python
df = pd.DataFrame(all_rows_data, columns=headers_list)
df = df.drop(columns=["Ref."])
df.to_csv("fortune_companies.csv", index=False, encoding="utf-8")
```
#### What I Did
- Converted extracted rows into a structured DataFrame
- Removed unnecessary reference columns
- Exported the cleaned dataset to CSV

#### Why This Matters
- Unstructured HTML → Clean structured dataset

### Step 5 Revenue Cleaning & Industry Analysis
```python
df["Revenue_clean"] = (
    df["Revenue"]
    .str.replace("$", "", regex=False)
    .str.replace(",", "", regex=False)
    .astype(float)
)
```
#### What I Did
- Removed currency symbols
- Removed commas
- Converted revenue to numeric format
#### Why This Matters
- Financial data must be numeric to:
    * Aggregate
    * Compare
    * Visualize

### Step 6 Handling Multi-Industry Companies
```python
def split_industries(industry_str):
    if industry_str == "Retail Information technology":
        return ["Retail", "Information technology"]
    else:
        return [industry_str]

df["Industry_list"] = df["Industry"].apply(split_industries)
df_exploded = df.explode("Industry_list")
```
#### What I Did
- Identified companies classified under multiple industries
- Split industry labels into lists
- Used .explode() to allow companies to contribute to multiple industry averages

#### Why This Matters
- Without exploding:
    * Multi-industry companies would distort results
    * Revenue would only be counted once

### Step 7 Visualizing Average Revenue by Industry
```python
industry_avg = (
    df_exploded.groupby("Industry_list")["Revenue_clean"]
    .mean()
    .sort_values(ascending=False)
)
# Then visualize using Seaborn
sns.barplot(...)
```
#### What I Did
- Calculated mean revenue by industry
- Sorted industries by average revenue
- Created a formatted bar chart
- Added value labels for clarity

#### Analytical Insight
Are certain ratings more common than others?

<img src="Visuals/Revenue by Industry.png" width="600">
