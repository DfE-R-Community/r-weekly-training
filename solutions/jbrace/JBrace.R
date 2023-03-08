# Question 2 --------------------------------------------------------------

# Load in packages
library(dplyr)
library(tidyr)
library(ggplot2)

# Question 3 --------------------------------------------------------------

# Create a copy of mtcars
mtcars2 <- mtcars  

# Create a new column that is just the row names
mtcars2$car <- mtcars |>
  row.names()

# Question 4 --------------------------------------------------------------

# a)
# Create a column that shows what cars have mpg > 20
mtcars2$mpg_over20 <- mtcars2$mpg>20

# b,c)
# Prepare combinations of cylinders and number of gears and then find mean
# mpg for each combination
cyl_gear_mpg <- mtcars2 |>
  group_by(cyl, gear) |>  
  summarise(mean_mpg = mean(mpg), .groups = "drop")

# d)
# Separate out the make and model of the cars
cyl_gear_make_mpg <- mtcars2 |>
  separate(car,c("make","model"),
           sep = " ",
           extra = "merge",
           fill = "right") |>
  group_by(cyl, gear, make) |>
  summarise(mean_mpg = mean(mpg), .groups = "drop")

# Question 5 --------------------------------------------------------------

# Use geom_smooth to add smooth line (linear model)
p1 <- mtcars2 |> 
  ggplot(aes(wt, mpg)) +
  geom_point(aes(colour = factor(cyl), shape = mpg_over20)) +
  geom_smooth() +  
  labs(title = "Miles/Gallon by weight by cyclinder count",
       subtitle = "All cars with 4 cylinders have a mpg > 20",
       x = "Weight",
       y = "Miles per Gallon")
print(p1)
