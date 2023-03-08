
# ---- Question 1 ----
#Created R script and named it MAITCHISON 

# ---- Question 2 ----
#Load selected packages 

library(dplyr) #packages loaded using library function
library(tidyr)
library(ggplot2)

# ---- Question 3 ---- 
#run mtcars in console, and then create new data set turning row names into a column 

mtcars2 <- tibble::rownames_to_column(mtcars, "Car") #Found on stackexchange, converts row names to column

#---- Question 4 ----

#Question 4a
#Add new column giving TRUE/FALSE dependent on if a car does more than 20 miles/gallon

mtcars3 <- mtcars2 |> #Create new data set for this question
  mutate(Efficient = ifelse(mpg > 20, TRUE, FALSE)) #Use mutate to add column, and ifelse to wrtie a condition

#Question 4b
#Create new data set giving mean miles/gallon for each combination of cyl and gear

mtcars4 <- mtcars3 |> #Create new data set
  group_by(cyl, gear) |> # use group_by to group by the two specified attributes
  summarise(avg_mpg = mean(mpg)) #use mean function to calculate average

#Question 4c
#Ensure the output to 4b is not grouped by reading documentation of 'summarise'

#by default, summerise eliminates the last stated group used in group_by, this can be overidden using .groups
mtcars4 <- mtcars3 |> #Create new data set 
  group_by(cyl, gear,) |>
  summarise(avg_mpg = mean(mpg), .groups = 'drop') #eliminates all grouping

#Question 4d
#Bonus: Do the same, but include each make of car in the output using 'separate'

mtcars5 <- mtcars2 |> #Create new data set
  separate(col = Car, into = c('Make','Model'), sep = ' ', extra = "drop", fill = "right") |> #separate column at the point of space between two words
  group_by(Make, cyl, gear) |>
  summarise(avg_mpg = mean(mpg), .groups = 'drop')

#Note- some null values are given when the 'Car' category only has one word, this means entries in the new 'Model' column
#can be null. But since we only want 'Make' we can move past this error

# ---- Question 5 ---- 

#Question 5a - scatter plot of miles/gallon against weight

ggplot(data = mtcars) + 
  geom_point(mapping = aes(x = mpg, y = wt)) #use geom_plot to create scatter graph

#Question 5b
#Colour the points to indicate the number of cylinders

ggplot(data = mtcars) + 
  geom_point(mapping = aes(x = mpg, y = wt, color = cyl)) #use the colour aesthetic to indicate points based on cyl

#Question 5c -
#give the points a different shape if the car does more than 20 miles/gallon

#This first attempt works but includes a overly large key
#ggplot(data = mtcars) + 
 # geom_point(mapping = aes(x = mpg, y = wt, color = ifelse(mpg > 20, 'red', 'blue')))

ggplot(data = mtcars) + 
  geom_point(mapping = aes(x = mpg, y = wt, color = mpg > 20)) + #use this condition 
  scale_colour_manual(name = 'mpg > 20', values = setNames(c('green','red'),c(T, F))) #manually change colour based on above condition

#Question 5d
#Give the plot a title and subtitle
ggplot(data = mtcars) + 
  geom_point(mapping = aes(x = mpg, y = wt, color = mpg > 20)) +
  scale_colour_manual(name = 'mpg > 20', values = setNames(c('green','red'),c(T, F))) +
  labs(title = "Weight Against Miles/Gallon", #use labs fucntion to add title and subtitle
     subtitle = "Negative Relationship")

#Question 5e
#Fit a smooth plot
ggplot(data = mtcars) + 
  geom_point(mapping = aes(x = mpg, y = wt, color = mpg > 20)) +
  scale_colour_manual(name = 'mpg > 20', values = setNames(c('green','red'),c(T, F))) +
  labs(title = "Weight Against Miles/Gallon",
       subtitle = "Negative Relationship") +
  geom_smooth(mapping = aes(x = mpg, y = wt)) #use geom_smooth to add smooth plot

#Question 6
#Ensure script is commented
