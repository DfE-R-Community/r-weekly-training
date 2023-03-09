library(tidyverse)
library(ggplot2)
library(scales)
library(viridis)
library(ggthemes)
library(geomtextpath)
library(ggpointdensity)
library(patchwork)

#==== Q1.1 - Create a subset of txhousing which only includes counties =========
# (hint: try looking at all the distinct values of city first)

distinct_cities <- txhousing %>% 
  distinct(city)

txhousing_counties <- txhousing %>%
  filter(grepl("County",city))


#==== Q1.2 - create a plot which shows how the median house price for each county changes over time. You should use geom_line() to do this, and counties should be differentiated using colour.====

ggplot(txhousing_counties, mapping = aes(x = date, y = median, colour = city)) +
  geom_line()


#==== Q1.3 - Now add lines for every city in the txhousing dataset to your plot. These should be coloured light grey and should not be included in the colour legend.====

ggplot(txhousing_counties, mapping = aes(x = date, y = median, colour = city)) +
  geom_line(txhousing, mapping = aes(group = city), colour = "grey") +
  geom_line()


#==== Q1.4 - Colour palette, labels on the y-axis - scales::label_dollar(), Changing the x, y, colour and title labels using labs(), Applying a nicer theme than the default theme_grey().====

ggplot(txhousing_counties, mapping = aes(x = date, y = median, colour = city)) +
  geom_line(txhousing, mapping = aes(group = city), colour = "grey") +
  geom_line() +
  scale_y_continuous(labels = label_dollar()) +
  scale_colour_viridis_d(option = "plasma") +
  labs(title = "Median prices over the years",
       x = "Years", 
       y = "Median (Dollars)", 
       colour = "County") +
  theme_dark()


#==== Q2.1 - Create a version of the economics dataset where pce, pop, psavert, uempmed and unemploy are rescaled to be between 0 and 1 ====

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

rescaled_economics <- economics %>%
  mutate(across(c(-1),rescale01)) # C can be names of columns

#==== Q2.2 - Now, create a plot of your rescaled dataset where the rescaled columns are all represented as different coloured lines ====

ggplot(rescaled_economics,aes (x = date)) +
  geom_line(aes(y = pce , colour ="pce")) +
  geom_line(aes(y = pop , colour ="pop")) +
  geom_line(aes(y = psavert , colour ="psavert")) +
  geom_line(aes(y = uempmed , colour ="uempmed")) +
  geom_line(aes(y = unemploy , colour ="unemploy")) +
  scale_colour_viridis_d(option = "plasma") +
  theme_dark()


#==== 2.3 Use pivot_longer() to pivot the columns pce, pop, psavert, uempmed and unemploy. Column names should end up in a single column variable and values should end up in a single column value ====
#Use group_by(), mutate() and rescale01() to create a rescaled version of the value column. Call this new column value01. Don't forget to ungroup()! ====

rescaled_economics_2 <- rescaled_economics %>%
  pivot_longer(c(-1), names_to = "variable", values_to = "value") %>%
  group_by(variable) %>%
  mutate(value01 = rescale01(value)) %>%
  ungroup()


#==== 2.4 creating plot from Q2.2 ====

ggplot(rescaled_economics_2) +
  geom_line(aes(x = date, y = value, colour = variable)) +  
  scale_colour_viridis_d(option = "plasma") +
  theme_dark()


#==== 3.1 Changing plot appearance =============================================
#FHARRIES Week 5.R - Liked the way each variable was labelled in the graph
ggplot(rescaled_economics_2) +
  geom_line(aes(x = date, y = value, colour = variable)) +  #,size = 10 increase line thickness
  scale_colour_viridis_d(option = "plasma" ,
                         labels = c("Personal consumption expenditures", 
                                  "Total population", 
                                  "Personal savings rate", 
                                  "Median duration of unemployment", 
                                  "Number of unemployed"))  +
  theme(legend.position = "bottom",
        # Center align and increase Title size
        plot.title = element_text(hjust = 0.5, size = 15),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        plot.background = element_rect("light blue")) + 
  labs(title = "US economy over the years",
       subtitle = "normalised factors over the years (1968 - 2016)",
       x = "Years", 
       y = "Value")


#==== 3.2 The axis labels on the following plot are not very clear =============================================
#https://stackoverflow.com/questions/1330989/rotating-and-spacing-axis-labels-in-ggplot2

mpg %>% 
  ggplot(aes(manufacturer)) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
  #scale_x_discrete(guide = guide_axis(n.dodge = 1))

#==== 4.1 - Use {geomtextpath} to add labels directly to the lines in the following plot. Remove the colour legend too as this will no longer be needed ====

ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_textdensity(size = 2, fontface = 3, hjust = 0.4, vjust = 0.2)+
  xlim(55, 70) +
  theme(legend.position = "none")
  
#==== 4.2 - Use {ggpointdensity} to improve the following plot: ================

txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +
  scale_color_viridis(option = "plasma") 

#==== 4.3 - Use {ggthemes} to change the appearances of the previous two plots ====

plot_diamonds <- ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_textdensity(size = 2, fontface = 3, hjust = 0.4, vjust = 0.2)+
  xlim(55, 70) +
  theme(legend.position = "none") +
  theme_dark()

plot_housing <- txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +
  scale_color_viridis(option = "plasma") +
  theme_stata()


#==== 4.3 - Use {patchwork} to combine the previous two plots into a single image ====
plot_diamonds + plot_housing

#==== 5.1 - We want a plot of the diamonds dataset showing carat/price. We want the points to be blue, but the following code isn't working quite right: ====
#ggplot(diamonds, aes(carat, price, colour = "blue")) +
# geom_point()

#Putting colour = "blue" in a different place
ggplot(diamonds, aes(carat, price)) +
  geom_point(colour="blue")
# does not produce a legend 

#Adding a (appropriately configured) call to scale_colour_manual()
ggplot(diamonds, aes(carat, price, color = "blue")) +
  geom_point() +
  scale_color_manual(values = c("points" = "blue"))
# produces a legend - may be handy for multple points/manually identifying colours?

#Adding a call to scale_colour_identity()
ggplot(diamonds, aes(carat, price, color = "blue")) +
  geom_point() +
  scale_colour_identity()
# does not produce legend but able to set colour within AES


#==== 5.2 - The group aesthetic is usually not needed, but is good to be aware of. Try creating a line-plot of the following data. You should get an error - try to fix this using the group aesthetic ==== 

df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)
ggplot(df, aes(x, y, group =  )) +
  geom_line()
# X consists of strings and has one observation, consequently gets grouped. Setting this allows to create the plot


#==== 5.3 - Re-create the plot from part 2 without using the group aesthetic. Do this by first applying an appropriate mutate() to the x variable in df ==== 

df2 <- df %>% 
  mutate(x = as.numeric(x))
ggplot(df2, aes(x, y)) +
  geom_line()


#==== 5.4 - Why doesn't the following code work? Find 3 ways to fix it. ==== 

ggplot(mpg, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_d()
# scale_colour_viridis_d requires discrete scale where as cyl is continuous(uses integers)?

#1 using continous scale instead of discrete
ggplot(mpg, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_c() 

#2 using factor for cyl
#https://statisticsglobe.com/r-error-continuous-value-supplied-to-discrete-scale
ggplot(mpg, aes(displ, manufacturer, colour = factor(cyl))) +
  geom_jitter() +
  scale_colour_viridis_d() 


#3 using factor before plotting
mpg2 <- mpg %>% 
  mutate(cyl = factor(cyl))
ggplot(mpg2, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_d() 


#==== 5.5 - The following plot is not very space-efficient. Create a version of the plot with no empty panels. ==== 
# using wrap instead of grid. 
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  #facet_grid(cyl ~ class, scales = "free", space = "free") +
  facet_wrap(cyl ~ class)
  theme(legend.position = "bottom")
