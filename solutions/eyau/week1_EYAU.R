# Week 01 Introduction
# Emily Yau

#---- Load Packages ----
library('dplyr')
library('tidyr')
library('ggplot2')
library('tidyverse')

#---- Exercise 3 ----
# Add a new row for the car names
car <- rownames(mtcars)

# Add the car vector as a column to original dataset and then stores it as a tibble called mtcars2
mtcars2 <- as_tibble(cbind(mtcars, car))

#---- Exercise 4 part a ----
#Adding a TRUE/FALSE column for cars with over 20mpg
#TRUE if over and FALSE if under
#Creates an empty vector for the TRUE/FALSE values
# over20mpg <- vector()
# #A loop to go through all of the rows
# for(i in 1:length(mtcars2$mpg)){
#   #Checks that for each row to see if the mpg is equal to or over 20
#   if (mtcars2$mpg[i] >= 20){
#     #If is is equal to or over 20, store that value in over20mpg as TRUE
#     over20mpg[i] <- TRUE
#   }else{
#     #If is is less than 20, then store that value in over20mpg as FALSE
#     over20mpg[i] <- FALSE
#   }
# }
# #Adds this TRUE/FALSE column as a new column in mtcars2
# mtcars2 <- cbind(mtcars2,over20mpg)

mtcars2 <- mtcars2 %>% 
  mutate(over20mpg = mpg >= 20)

#---- Exercise 4 part b ----
cyl_gear <- mtcars2 %>%
  #group the data by cylinder number and gear
  group_by(cyl,gear) %>%
  # then summarise the data by finding the mean mpg for each combination of cyl and gear
  summarise(avempg = mean(mpg))

#---- Exercise 4 part c ----
# To ensure that the answer in part b is not 'grouped',
# We can use .groups= "drop". This drops all levels of grouping
cyl_gear <- mtcars2 %>%
  group_by(cyl,gear) %>%
  #same process as part b but drop all levels of grouping
  summarise(avempg = mean(mpg), .groups = "drop")

#---- Exercise 4 part d ----
make_model <- mtcars2 %>%
  group_by(cyl,gear) %>%
  separate(car, c("Make","Model"), extra="merge", fill="left")

make_cyl_gear <- make_model %>%
  group_by(cyl, gear, Make) %>%
  summarise(avempg = mean(mpg), .groups = "drop")

#---- Exercise 5 part a ----
#Creates a basic scatter plot with mpg against weight
plot1 <- ggplot(data = mtcars2, aes(x=wt,y=mpg))+
  geom_point()+
  # relabels the axis
  labs(x="Weight", y="Miles Per Gallon")
plot1

#---- Exercise 5 part b ----
# plotting a scatter plot with mpg against weight
plot2 <- ggplot(data=mtcars2, aes(x=wt,y=mpg))+
  # uses Cylinder as a factor to group the data and give points different colours per group
  geom_point(aes(colour=as.factor(cyl)))+
  # relabels axis and legend title
  labs(x="Weight", y="Miles Per Gallon", colour="Cylinder")
plot2

#---- Exercise 5 part c ----
plot3 <- ggplot(data=mtcars2, aes(x=wt, y=mpg))+
  #This gives points different colours for each cyl group and gives different shapes for points
  #whether they are 20mpg or not 
  geom_point(aes(colour=as.factor(cyl),shape=as.factor(over20mpg)))+
  labs(x="Weight", y="Miles Per Gallon", colour="Cylinder", shape="Over 20mpg")
plot3

#---- Exercise 5 part d ----
plot4 <- plot3 +
  #Uses the previous and builds on it by adding a title and a subtitle
  labs(title ="Miles Per Gallon Against Weight, \nseparated by cylinder number and whether the car does more than 20mpg",
       subtitle = "Mpg and Weight have a negative correlation - as the weight increases the mpg decreases.")
plot4

#---- Exercise 5 part e ----
plot5 <- plot4 +
  #builds on the previous title and plots a smooth line between the points
  geom_smooth(se=FALSE, method='gam')
plot5
