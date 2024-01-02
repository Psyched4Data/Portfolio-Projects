# First I will load the needed packages and ensure that the data set was
# imported properly with the View function.
library(datasets)
data("iris")
View(iris)
# This data set contains measurements of iris flowers.
# To help me get a better idea of each variable in the data frame, I can use
# summary(_) and skim(_)to view general descriptive statistics
summary(iris)
install.packages("skimr")
library(skimr)
skim(iris)
# I will also check for null values. 
sum(is.na(iris))
# Since there are no null values, I can proceed without needing to clean
# the data.

# The first thing that I will want to investigate are the differences between 
# the three different species of iris flower. To begin this process, I will 
# create a pipeline to group the different species of flower before I skim()
iris %>%
  dplyr::group_by(Species) %>%
  skim() 
# Since the output is a bit cluttered, I will filter down the results a bit
iris %>%
  select(Sepal.Length, Sepal.Width, Species) %>% 
  dplyr::group_by(Species) %>%
  skim()
# To get a deeper understanding of the data I can create a basic scatter plot
plot(iris$Sepal.Width, iris$Sepal.Length, col="blue",
     xlab = "Sepal Width", ylab = "Sepal Lenght")
# I can also create a histogram
hist(iris$Sepal.Width, col = "blue")
hist(iris$Sepal.Length, col = "blue")
# or even a box plot of sepal lengths for each species
boxplot(Sepal.Length ~ Species, data = iris,
        main = "Boxplot of Sepal Length by Species",
        xlab = "Species",
        ylab = "Sepal Length",
        col = c("lightblue", "lightgreen", "lightpink"))
legend("topright", legend = levels(iris$Species), 
       fill = c("lightblue", "lightgreen", "lightpink"))
# because of the numerous packages available for R there are even more ways 
# to create similar plots
install.packages("caret")
library(caret)
featurePlot(x = iris[,1:4],
            y = iris$Species,
            plot = "box",
            strip=strip.custom(par.strip.text=list(cex=0.7)),
            scales = list(x = list(relation="free"),
                          y = list(relation= "free")))
# After all of these descriptive statistics and visualizations it is time
# to run some statistical tests! I'll start by determining if there is a
# statistically significant difference in the Sepal Length between 
# the setosa and versicolor species. To start, I'll create a new data frame
# that only contains the sepal lengths of setosa and versicolor.
df1 <- iris %>% 
  select(Sepal.Length, Species) %>% 
  filter(Species == "setosa" |
          Species == "versicolor")
# Having this new data frame will make running the t-test easier.
t.test(data = df1, Sepal.Length ~ Species)
# The output shows that the p-value is < 2.2e-16, far less than 0.05. 
# This indicates that the difference in sepal length is significantly
# different between the two groups. Lastly, I will create a linear regression 
# model examining the relationship between sepal length and sepal width.
summary(lm(Sepal.Width ~ Sepal.Length, data=iris))
# In the above model the response variable is sepal width and the predictor
# variable is sepal length. The p-value of 0.152 indicates that 
# there is not enough evidence to conclude a significant linear relationship 
# between Sepal.Width and Sepal.Length.
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, col = "red") +
  labs(x = "Sepal Length", 
       y = "Sepal Width", 
       title = "Regression Model")+
  geom_segment(aes(x = 6.5, y = 4.0, xend = 5.5, yend = 3.1), 
               arrow = arrow(length = unit(0.2, "inches")),
               color = "black") +
  annotate("text", x = 6.5, y = 4.1, label = "Regression Line", 
           color = "black", hjust = 0)