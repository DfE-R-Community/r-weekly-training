#Loading in packages
install.packages('dplyr', dependencies=TRUE, repos='http://cran.rstudio.com/')

library(dplyr)
library(tidyr)
library(ggplot2)


#loading the data
mtcars2 = mtcars

#Making the row names into a column and naming it car
mtcars2 <- tibble::rownames_to_column(mtcars2, "car")

####TASK 4

#adding column of true or false as to whether it can do 20mph
mtcars3 <- mtcars2 %>%
  mutate(morethan_20_mpg = mpg > 20) 

#average
mtcars4 <- mtcars2 %>%
  select(cyl, gear, mpg) %>%
  group_by(cyl, gear) %>%
  summarise(meanMPG = mean(mpg, na.rm = TRUE), .groups = 'drop') 


#also grouping by make
mtcars5 = separate(mtcars3, col=car, into =c('make', 'type'), sep = ' ')

mtcars6 =   mtcars5 %>%
  select(cyl, gear, mpg, make) %>%
  group_by(cyl, gear, make) %>%
  summarise(meanMPG = mean(mpg, na.rm = TRUE), .groups = 'drop')  


####TASK 5

#Making a scatter plot
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt))

#Colouring by number of cylinders
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, color = cyl))

#Different shapes to show if a car does over 20mph
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, colour = cyl, shape = mpg > 20))

#Improving appearance of graph and adding a smooth line
ggplot(data = mtcars2) +
  geom_point(mapping = aes(x = mpg, y = wt, colour = cyl, shape = mpg > 20))+
  geom_smooth(mapping = aes(x = mpg, y = wt, colour =cyl))+
  ggtitle('Relationship Between Weight and Miles per Gallon', subtitle = 'The greater the weight of the car, the less fuel effiecient it is. 
          The number of cylinders increases with increased weight. ')





