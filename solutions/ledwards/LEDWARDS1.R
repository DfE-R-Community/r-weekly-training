#---- Week 1 ----

library(ggplot2)
library(dplyr)
library(tidyr)


#---- 3 ----
#Change row/car names into new column "car"
mtcars2 <- mtcars
mtcars2 <- tibble::rownames_to_column(mtcars2, "car")
as_tibble(mtcars2)


#---- 4 ----
# Boolean for if car does more than 20 mpg
mtcars4_1 <- mtcars2 |>
  mutate(over_twenty_mpg = mpg > 20)
mtcars4_1

# Mean mpg for each combination of cyl and gear
mtcars4_2 <- mtcars2 |>
  select(cyl, gear, mpg) |>
  group_by(cyl, gear) |>
  summarise(mean_mpg = mean(mpg, na.rm = TRUE))
mtcars4_2

# Drop all grouping from previous answer
mtcars4_3 <- mtcars2 |>
  select(cyl, gear, mpg) |>
  group_by(cyl, gear) |>
  summarise(mean_mpg = mean(mpg, na.rm = TRUE), .groups = "drop")
#  group_vars()
mtcars4_3

# Just want the first word which it the brand
mtcars4_4a <- mtcars2 |>
  separate(car, into = c("company", "make"), sep = " ", extra = "merge", fill = "right")
# Mean mpg for each combination of brand, cyl and gear
mtcars4_4b <- mtcars4_4a |>
  select(company, cyl, gear, mpg) |>
  group_by(company, cyl, gear) |>
  summarise(mean_mpg = mean(mpg, na.rm = TRUE), .groups = "drop")
mtcars4_4b


#---- 5 ----
# Scatter plot mpg against weight
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt))

# Use colour to indicate number of cylinders
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, color = factor(cyl)))

# Use shapes to indicate cars over 20mpg
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, colour = factor(cyl), shape = mpg > 20))

# Add a title and brief subtitle
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, colour = factor(cyl), shape = mpg > 20)) +
  labs(title = "Effect of Weight of Car on Miles/Gallon",
       subtitle = "The lighter in weight of the car, the lower the number of cylinders and higher the mpg")

# Fitting a smooth line
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, colour = factor(cyl), shape = mpg > 20)) +
  geom_smooth(mapping = aes(x = mpg, y = wt)) +
  labs(title = "Effect of Weight of Car on Miles/Gallon",
       subtitle = "The lighter in weight of the car, the lower the number of cylinders and higher the mpg")

