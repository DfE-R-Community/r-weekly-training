#Loaded packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(tidyverse)

#--------Exercise 3---------

#Assigning the value of mtcars into mtcars2 creating a new data set
#with the same values
mtcars2 <- mtcars

#This finds the element named car within mtcars which will be
#the car names (as each row is called a car name) and will 
#create a new row with the cars and cars as its column name.
#the initial car names are then deleted as it now at the end
mtcars2$car <- row.names(mtcars)
row.names(mtcars2) <- NULL
mtcars2 <- as_tibble(mtcars2)


#-------Exercise 4)A-----------------

#This creates a new column and adds it to the end 
#of the data frame. This Calls the column Over20mpg and creates a Boolean
#it then puts this within mtcars2

mtcars2 <- mtcars2 |>
  mutate(Over20mpg = mpg >= 20)

#-------Exercise 4 B -------------

#A new data set has been created with the same values as mtcars2
#from this data set it it groups cyl and gear into its own table
#a new data frame is created from the group variables
#within this data from a new column called mean_mpg 
#a mean of the mpg values is given here
gear_cyl <- mtcars2 |>
  group_by(cyl, gear) |>
  summarize(mean_mpg = mean(mpg, na.rm = TRUE))

#-------Exercise 4 C -------------

#to un groups everything using .group, I have made it equal drop
#as this un groups everything
gear_cyl <- mtcars2 |>
  group_by(cyl, gear) |>
  summarize(mean_mpg = mean(mpg, na.rm = TRUE), .groups = "drop")


#------Exercise 5)a-----------

#A simple plot of mpg (y axis) against weight (x axis)
plot(data = mtcars2, mpg ~ wt)


#------Exercise 5)b, c & d -----------

# using a qplot to change the colour it is equivalent to cyl and to change the shape
# shape equates to the column Over20mpg. I have added labels for X and Y axis and
# a title. (The subtitle I cannot get to appear)
qplot(wt, mpg, data = mtcars2, shape = Over20mpg, colour = cyl,
      ylab="Miles Per Gallon", xlab="Car Weight", main="Mpg against Car weight", 
      sub = "Higher the mpg, lower the car weight")

#-------Exercise 5)e ---------------

#to get a smooth line I have used geom = smooth, line and point.
qplot(wt, mpg, data = mtcars2, shape = Over20mpg, colour = cyl, 
      ylab="Miles Per Gallon", xlab="Car Weight", 
      main="Mpg against Car weight", sub = "Higher the mpg, lower the car weight", geom =c("smooth","line", "point"))
