
# Exercise 2 --------------------------------------------------------------

#Load packages 

library(dplyr)
library(tidyr)
library(ggplot2)

# Exercise 3 --------------------------------------------------------------

#mtcars2 is new version of mtcars with column for car model 

mtcars2 <- tibble::rownames_to_column(mtcars, "car") |> as_tibble()
mtcars2


# Exercise 4 --------------------------------------------------------------

#Adding column to mtcars2, true if mpg > 20, else False

mtcars2 <- mtcars2 |> 
  mutate(mpg_over_20 = mpg > 20) 

select(mtcars2, mpg, mpg_over_20)

#Average mpg for each combination of cyl and gear 

cyl_gear_grouped <- mtcars2 |> 
  group_by(cyl, gear) |> 
  summarise(avg_mpg = mean(mpg), .groups = 'drop')

cyl_gear_grouped

#Average mpg for each combination of cyl and gear for each car make

car_make <- mtcars2 |> 
  separate(car, c("make", "model"))

cyl_gear_make_grouped <- car_make |> 
  group_by(cyl, gear, make) |> 
  summarise(avg_mpg = mean(mpg), .groups = 'drop')

cyl_gear_make_grouped

# Exercise 5 --------------------------------------------------------------

#Scatter graph of mpg against weight

ggplot(mtcars2) +
  geom_point(aes(x = mpg, y = wt)) + 
  labs(
    x = "Miles per gallon", 
    y = "Weight"
    )

#Scatter graph of mpg against weight grouped by cyl

ggplot(mtcars2) +
  geom_point(aes(x = mpg, y = wt, colour = factor(cyl))) + 
  labs(
    x = "Miles per gallon", 
    y = "Weight", 
    colour = "Number of cylinders"
    )

#Mark points that do over 20 mpg

ggplot(mtcars2) +
  geom_point(
    aes(x = mpg, y = wt, colour = factor(cyl), shape = mpg_over_20)
    ) + 
  labs(
    x = "Miles per gallon", 
    y = "Weight", 
    colour = "Number of cylinders", 
    shape = "More then 20 mpg"
    )

#Labelled graph and fitted line    

ggplot(mtcars2, aes(x = mpg, y = wt)) +
  geom_point(aes(colour = factor(cyl), shape = mpg_over_20)) + 
  geom_smooth(se = FALSE, show.legend = FALSE) +
  labs(
    title = "Impact of car weight on miles/gallon performance", 
    subtitle = "Weight of different cars plotting against 
    their miles/gallon performance and grouped by their number of cylinders", 
    x = "Miles/gallon", 
    y = "Weight (1000 lbs)", 
    colour = "Number of cylinders", 
    shape = "More then 20 mpg"
    ) +
  theme(plot.subtitle = element_text(size=6.5))

