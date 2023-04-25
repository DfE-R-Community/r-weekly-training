
# install packages --------------------------------------------------------


install.packages(c("tidyr", "dplyr", "ggplot2"))
library(tidyr)
library(dplyr)
library(ggplot2)
install.packages("tidyverse")
library(tibble)


# exercise 3 --------------------------------------------------------------


mtcars2 <-
  mtcars %>% rownames_to_column(var = "cars") #because it is a dataframe the first column is like a row so need to convert the row to a column
as_tibble(mtcars2) #now convert to a tibble


# exercise 4 --------------------------------------------------------------


mtcars2 <-
  mtcars2 %>%
  mutate(mpg_rate = ifelse(mpg > 20, 'TRUE', 'FALSE'),
         cyl = factor(cyl)) #true false column added and converted cyl column to discrete 

mtcars3 <- mtcars2 %>%
  group_by(cyl, gear) %>%
  summarise(average_miles = mean(mpg)) #average miles calc 

mtcars3 <- mtcars2 %>%
  group_by(cyl, gear) %>%
  summarise(average_miles = mean(mpg), .groups = 'drop') 


# exercise 5 --------------------------------------------------------------


mtcars2_plot = ggplot(data = mtcars2) + 
  geom_point(mapping = aes(x = mpg, y = wt))

mtcars2_plot_2 = ggplot(data = mtcars2) + 
  geom_point(mapping = aes(x = mpg, y = wt, colour = cyl))

mtcars2_plot_3 = ggplot(data = mtcars2) + 
  geom_point(mapping = aes(x = mpg, y = wt, shape = mpg_rate))

mtcars2_plot_4 = ggplot(data = mtcars2) + 
  geom_point(mapping = aes(x = mpg, y = wt, shape = mpg_rate)) +
ggtitle("Scatter plot to show relationship between average miles by weight of cars", subtitle = "the heavier the cars, the more fuel they use")


# ctrl shift r to create sections 

mtcars2_plot_5 = ggplot(data = mtcars2,mapping = aes(x = mpg, y = wt)) + # if the mapping and aesthetics are defined here, they don't need to be defined as arguments in geom point and smooth
  geom_point(aes(shape = mpg_rate)) +
  geom_smooth(method = 'lm', se = FALSE) + # se is standard error, false removes this from the plot
  ggtitle("Scatter plot to show relationship between average miles by weight of cars", subtitle = "the heavier the cars, the more fuel they use") 







