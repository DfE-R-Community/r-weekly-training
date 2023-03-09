library(ggplot2)
library(RColorBrewer)
library(scales)
library(dplyr)
library(tidyverse)

# ---- 1.1 ---------------------------------------------------------------------
# Look at the data to unique cities and counties
unique(txhousing$city)
# create a subset with only the counties
counties <- subset(txhousing, grepl("County", txhousing$city))

# ---- 1.2 ---------------------------------------------------------------------
county_plot <- counties %>%
  # using counties data, plot the median house prices against date
  # as.factor(city) groups the data by county
  ggplot(aes(date, median, colour = as.factor(city)))+
  # plot lines
  geom_line()+
  # change the legend title
  labs(colour = "County")

# ---- 1.3 ---------------------------------------------------------------------
cities <- subset(txhousing, !grepl("County", txhousing$city))
# creates a subset of the data that doesnt contain the word "county"
# i.e all the cities
county_plot +
  geom_line(data = cities, aes(date, median, group = city), colour = "grey")
# groups the cities so that they get individual lines and colours them grey

# ---- 1.4 ---------------------------------------------------------------------
county_plot +
  geom_line(data = cities, aes(date, median, group = city), colour = "grey") +
  # Changes the palette to a colourblind friendly one
  scale_color_brewer(palette = "Dark2") +
  # changes the y axis to have a money format
  scale_y_continuous(labels = scales::dollar_format()) +
  # Changes the labels and title
  labs(x = "Date", y = "Median House Price", title = "Median House Prices over time") +
  # gives a new theme
  theme_bw()

# ---- 2.1 ---------------------------------------------------------------------
#head(economics)

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

rescaled_eco <- economics %>%
  mutate(pce = rescale01(economics$pce), pop = rescale01(economics$pop), 
         psavert = rescale01(economics$psavert), uempmed = rescale01(economics$uempmed), 
         unemploy = rescale01(economics$unemploy))
#head(rescaled_eco)

# ---- 2.2 ---------------------------------------------------------------------
ggplot(rescaled_eco)+
  geom_line(aes(x=date, y=pce, color = "pce"))+
  geom_line(aes(x=date, y=pop, color = "pop"))+
  geom_line(aes(x=date, y=psavert, color = "psavert"))+
  geom_line(aes(x=date, y=uempmed, color = "uempmed"))+
  geom_line(aes(x=date, y=unemploy, color = "unemploy"))+
  labs(x = "Date", y = "Value", color = "Key")

# ---- 2.3 ---------------------------------------------------------------------

longer_economics <- economics %>%
  pivot_longer(cols = !date, names_to = "variables", values_to = "value")%>%
  group_by(variables) %>%
  mutate(value01 = rescale01(value)) %>%
  ungroup()
# grouping the data by date returns NaN values but found that you don't need to group it

# ---- 2.4 ---------------------------------------------------------------------

ggplot(longer_economics, aes(x=date, y=value01, color= variables))+
  geom_line()          

# ---- 3.1 ---------------------------------------------------------------------
ggplot(longer_economics, aes(x=date, y=value01, color= variables))+
  geom_line(size = 0.75)+
  # move legend
  theme(legend.position = "bottom")+
  # add labels
  labs(title = "Plot of Economic Rates", subtitle = "(Using rescaled values)")+
  # change title size and centre - i would normally put all the themes together but 
  #for the sake of the steps in the question, i have separated them
  theme(plot.title = element_text(size=20, hjust =0.5))+
  #remove axis ticks 
  theme(axis.ticks.x=element_blank(), axis.ticks.y=element_blank()) +
  #colour blind friendly theme
  scale_color_brewer(palette = "Dark2")+
  # plot background to lightblue
  theme(plot.background = element_rect(fill = "lightblue"))
  
# ---- 3.2 ---------------------------------------------------------------------
mpg %>% 
  ggplot(aes(manufacturer)) +
  geom_bar()+
  theme(axis.text.x = element_text(angle = 45))

# ---- 4.1 ---------------------------------------------------------------------
library(geomtextpath)
ggplot(diamonds, aes(depth, colour = cut)) +
  #geom_density() +
  geom_textdensity(aes(group = cut,label = cut), hjust = 0.3, vjust =  0.3)+
  xlim(55, 70) +
  theme(legend.position = "none")

# ---- 4.2 ---------------------------------------------------------------------
library(ggpointdensity)

txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity()

# ---- 4.3 ---------------------------------------------------------------------
library(ggthemes)

# change the theme from graph in question 4.1
ggplot(diamonds, aes(depth, colour = cut)) +
  #geom_density() +
  geom_textdensity(aes(group = cut,label = cut), hjust = 0.3, vjust =  0.3)+
  xlim(55, 70) +
  theme_economist()+
  theme(legend.position = "none") 

# change the theme from graph in question 4.2
txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity()+
  theme_stata()

# ---- 4.4 ---------------------------------------------------------------------
library(patchwork)
d <- ggplot(diamonds, aes(depth, colour = cut)) +
  #geom_density() +
  geom_textdensity(aes(group = cut,label = cut), hjust = 0.3, vjust =  0.3)+
  xlim(55, 70) +
  theme_economist()+
  theme(legend.position = "none") 

t <- txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity()+
  theme_stata()

d + t

# ---- 5.1 ---------------------------------------------------------------------
ggplot(diamonds, aes(carat, price)) +
  geom_point(colour = "blue")

ggplot(diamonds, aes(carat, price, color = cut))+
  scale_colour_manual(values =c("#4E84C4","#4E84C4","#4E84C4","#4E84C4","#4E84C4"))+
  geom_point()+
  theme(legend.position = "none")
# To use scale_color_manual you need multiple groups and colours

# ggplot(diamonds, aes(carat, price)) +
#   geom_point() +
#   scale_color_identity()
# can't figure out how to make this work for only one colour group

# the best method is the first method: moving the colour to inside the geom_point()
# the other methods are for multiple colours but in our case we are only looking at setting
# all of the points to one colour

# ---- 5.2 ---------------------------------------------------------------------
df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)
ggplot(df, aes(x,y, group = 1))+
  geom_line()

# ---- 5.3 ---------------------------------------------------------------------
df <- df %>%
  mutate(group = 1)

ggplot(df, aes(x,y))+
  geom_line(aes(group = group))

# ---- 5.4 ---------------------------------------------------------------------
#mtcars
ggplot(mpg, aes(displ, manufacturer, colour = cyl)) +
  geom_point() #+
 # scale_colour_viridis_d()

ggplot(mpg, aes(displ, manufacturer, colour = as.factor(cyl))) +
  geom_jitter(aes(colour = as.factor(cyl))) +
  scale_colour_viridis_d()

# ---- 5.5 ---------------------------------------------------------------------
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_wrap(cyl ~ class) +
  theme(legend.position = "bottom")
