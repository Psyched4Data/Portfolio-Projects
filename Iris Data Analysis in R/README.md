# Iris Flower Statistical Analysis in R
## Project Overview
This project explores the classic Iris dataset using R to understand differences in species characteristics through:
- Descriptive statistics
- Visualizations
- Statistical testing
- Regression modeling
The goal is to perform a full exploratory data analysis (EDA) and assess relationships between flower features.

All work is contained in an [R file](https://github.com/Psyched4Data/Portfolio-Projects/blob/main/Iris%20Data%20Analysis%20in%20R/Iris%20Data%20Exploration.R).

## Step 1: Load Data & Packages
```r
library(datasets)
data("iris")
View(iris)

install.packages("skimr")
library(skimr)
```
### What I Did
- Imported the Iris dataset.
- Loaded necessary packages for analysis (datasets, skimr).

### How I Did It
- Used View() to inspect the data interactively.
- Used summary() and skim() for descriptive statistics.

## Step 2: Check for Null Values
```r
sum(is.na(iris))
```
### What I Did
Verified that there are no missing values in the dataset.

### How I Did It
Counted NA entries with sum(is.na(iris)).

### Why I Did It
Ensures data cleaning is unnecessary for missing values, simplifying analysis.

## Step 3: Exploratory Data Analysis by Species
```r
iris %>%
  dplyr::group_by(Species) %>%
  skim()
```
### What I Did
Compared distributions of measurements by species.

### How I Did It
Used dplyr::group_by() with skim() to get summary statistics for each species.

### Why I Did It
Helps identify species-level differences in sepal and petal dimensions.

## Step 4: Visualizations
```r
# Scatter Plot of Sepal Width vs Sepal Length
plot(iris$Sepal.Width, iris$Sepal.Length, col="blue",
     xlab = "Sepal Width", ylab = "Sepal Length")

Histograms
hist(iris$Sepal.Width, col = "blue")
hist(iris$Sepal.Length, col = "blue")

Boxplot by Species
boxplot(Sepal.Length ~ Species, data = iris,
        main = "Boxplot of Sepal Length by Species",
        xlab = "Species",
        ylab = "Sepal Length",
        col = c("lightblue", "lightgreen", "lightpink"))
legend("topright", legend = levels(iris$Species), 
       fill = c("lightblue", "lightgreen", "lightpink"))

Feature Plots with caret
install.packages("caret")
library(caret)
featurePlot(x = iris[,1:4],
            y = iris$Species,
            plot = "box",
            strip=strip.custom(par.strip.text=list(cex=0.7)),
            scales = list(x = list(relation="free"),
                          y = list(relation= "free")))
```
### What I Did
- Visualized distributions and relationships of iris measurements.

### How I Did It
- Used base R plots (plot(), hist(), boxplot()).
- Used featurePlot from caret for multi-feature visualization.

### Why I Did It
- Helps detect patterns, outliers, and species-specific characteristics.

## Step 5: Statistical Testing
```r
# T-Test: Sepal Length (Setosa vs Versicolor)
df1 <- iris %>% 
  select(Sepal.Length, Species) %>% 
  filter(Species == "setosa" | Species == "versicolor")

t.test(data = df1, Sepal.Length ~ Species)
```
### What I Did
Tested whether the mean sepal length differs significantly between Setosa and Versicolor.

### How I Did It
- Filtered dataset to only two species.
- Ran t.test() comparing sepal lengths.

### Why I Did It
Provides statistical evidence of differences between species.

## Step 6: Regression Analysis
```r
# Linear Regression: Sepal Width vs Sepal Length
summary(lm(Sepal.Width ~ Sepal.Length, data=iris))

library(ggplot2)
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, col = "red") +
  labs(x = "Sepal Length", y = "Sepal Width", title = "Regression Model") +
  geom_segment(aes(x = 6.5, y = 4.0, xend = 5.5, yend = 3.1), 
               arrow = arrow(length = unit(0.2, "inches")), color = "black") +
  annotate("text", x = 6.5, y = 4.1, label = "Regression Line", color = "black", hjust = 0)
```
### What I Did
Built a linear regression model to examine the relationship between sepal length and width.

### How I Did It
- Used lm() for modeling.
- Visualized regression line with ggplot2.

### Why I Did It
Evaluates predictive relationships between features and highlights trends visually.

## Skills Demonstrated
- Data Exploration in R
- Data Cleaning & Validation
- Grouped Descriptive Statistics
- Multiple Plotting Techniques (base R, ggplot2, caret)
- Statistical Testing (t-test)
- Linear Regression Modeling
