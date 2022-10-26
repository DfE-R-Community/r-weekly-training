# Week 1: Introduction to R

# Load the required packages
library(dplyr)
library(tidyr)
library(ggplot2)


#---------- Question 4 ---------------
# Label the first column of mtcars and save as a new tibble
mtcars2 <- tibble::rownames_to_column(mtcars, var='cars')

# Define a column which states if the car does more than 20mpg
mtcars2 <- transform(mtcars2, gt20mpg=ifelse(mpg>20, TRUE, FALSE))

# Create a new dataset giving the average mpg for each cyl and gear
mtcars3 <- mtcars2 %>% 
            group_by(cyl, gear) %>%
            summarise(avg_mpg = mean(mpg))

# Now include each make of car in the output. Lets create a new dataset. 
# First split the car name into (make, model). Omit model.
mtcars4 <- mtcars2 %>% 
            separate(cars, c("make", NA), sep=" ")

# Repeat filter in last question now grouping by make as well
mtcars4 <- mtcars4 %>% 
            group_by(make, cyl, gear) %>%
            summarise(avg_mpg = mean(mpg)) 


#---------- Question 5 ------------------

# Create plot of mpg against weight
plot(x = mtcars2$wt, 
     y = mtcars2$mpg,
     xlab = "Weight\n", 
     ylab = "Miles per Gallon",
     col = mtcars2$cyl, # label colour
     pch = as.numeric(mtcars2$gt20mpg), # label shape
     cex = 1.2, # label size
     lwd = 1.5, # label border thickness
     main = "MPG by Weight and Number of Cylinders \nfor Cars in the mtcars Dataset",
     sub = "Heavier vehicles have lower miles to the gallon, \nvehicles with more cylinders are attributed to heavier cars")

# Set up the legend
legend(x = "topright",  
       title= "Number of cylinders", 
       legend = c(4,6,8),  # legend labels  
       col = c(4,6,8), # label colour
       pch = 16) # shape: filled in circle

            
