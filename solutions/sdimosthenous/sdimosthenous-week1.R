#### Load libraries ####
# Part 1 and Part 2
# Create R script and load necessary libraries
install.packages("dplyr")
install.packages("tidyverse")
library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)

#### DATASET MANIPULATION ####
# Parts 3 and 4
# Turn row names into a column named "cars"
mtcars2 <- tibble::rownames_to_column(mtcars, "cars")
# Convert to tibble and add conditional column
mtcars2 <- as_tibble(mtcars2)
mtcars2 <- mutate(mtcars2, over_20 = mpg > 20)
typeof(mtcars2) # Not certain as_tibble conversion is strictly necessary
# Group by cylinder and gear and summarise combinations by the mean of miles per gallon
mtcars2 |> 
  group_by(cyl, gear) |>
  summarise(mean(mpg), .groups = "drop")
# Split car column into columns make and model
# Group by car make, cylinder and gear and summarise combinations by the mean of miles per gallon
mtcars2 |> 
  separate(cars, c("make", "model"),  sep = " ", extra = "merge", fill = "right") |> 
  group_by(make, cyl, gear) |> 
  summarise(mean(mpg), .groups = "keep")

#### PLOT DATA ####
# Part 5
ggplot(data = mtcars2, mapping = aes(x = wt, y = mpg)) +
  geom_smooth(mapping = aes(x = wt, y = mpg), method = 'loess', span = 0.8, 
              formula = y ~ x, level = 0.95, colour = "black", size = 0.75)

