# Web Scraping Wikipedia and Books to Scrape.com with Beautiful Soup
In this project I scraped two different sites using Beautiful Soup, turned the results into csv files, and created a visualization of the results. In WikiWebScrapping.ipynb, I collected data on the largest companies by revenue according to Wikipedia and created a graph to visualize which industries were the most profitable. In BookWebScrapping.ipynb, I pulled data from the website books.toscrape.com to collect details on all of the books listed. I then created visuals to show the average price and number of books based on the rating of the book. Visualizations were created with matplotlib.

## Books to Scrape
This project demonstrates end-to-end data collection, cleaning, storage, and visualization using Python.

I scraped book data from BooksToScrape.com, extracted structured information (title, price, and rating), stored the data in a CSV file, and performed exploratory analysis to uncover pricing patterns across star ratings.

This project highlights skills in:
-Web scraping with requests and BeautifulSoup
-Data wrangling with pandas
-Data visualization with matplotlib
-Automation across multiple pages
-Converting unstructured HTML into structured datasets

###Step 1 Pull the HTML
```python
import requests
from bs4 import BeautifulSoup

url = "https://books.toscrape.com/"
response = requests.get(url)
response = response.content
soup = BeautifulSoup(response, 'html.parser')
soup
```
####What I Did

Sent an HTTP request to the website using requests

Retrieved the raw HTML content

Parsed the HTML using BeautifulSoup

Converted the webpage into a searchable object (soup)

####Why This Matters

Web pages are unstructured HTML.
To extract meaningful data, we must first convert that HTML into a structured format that Python can navigate.

This step establishes the foundation for automated scraping.

###Step 2 Scrape the Key Data
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
####What I Did
-Automated scraping across all 50 pages using a loop
-Located each book container using HTML tags
-Extracted:
    Book title
    Star rating (converted from text to numeric)
    Price (cleaned and converted to float)
    Stored results in a Python list

####Why This Matters
This demonstrates:
-Web automation
-Data cleaning during extraction
-Transforming messy HTML attributes into usable structured data

###Step 3 Creating a Structured Dataset
####What I did
-Converted the raw list into a structured pandas DataFrame
-Assigned meaningful column names
-Exported the dataset to CSV for future use
####Why This Matters
-Raw scraped data is not useful until structured properly.
-This step transforms collected data into an analysis-ready dataset.

###Step 4 Make Visuals
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
####What I Did
-Grouped books by star rating
-Calculated average price for each rating
-Visualized the relationship using a line chart
-Added data labels for clarity

####Analytical Insight
Do higher-rated books cost more on average?
!(Average Book Price by Star Rating.png)

Next Visual
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
####What I Did
-Counted number of books per star rating
-Visualized the frequency distribution
-Added annotations for interpretability

####Analytical Insight
-Are certain ratings more common than others?

## Scraping the largest companies from Wikipedia

