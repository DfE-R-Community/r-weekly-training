# Load Packages
library(tidyverse)
library(ggplot2)
library(scales)

# -------- Q1. Plotting --------------
# Create subset of txhousing includes counties
# unique(txhousing$city)  # conclude counties contain the string 'County' in the city field
txhousing_counties <- txhousing %>% 
  filter(grepl('County', city))

# Plot median price against time
# Use a colour blind firendly palette
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create two sets of line plots from the two datasets
ggplot(mapping = aes(x=date, y=median)) + # put common aethetics up here
  geom_line(aes(group=city),              # grey lines at the back so state first
            color = "light grey",
            data = txhousing) + 
  geom_line(aes(color = city),
            data = txhousing_counties) +
  
  # Change the labels
  labs(x = "Date",
       y = "Median Price",
       color = "County",
       title = "Growth of Median House Price from 2000 to 2015 by County") +
  
  # Set plot theme
  scale_color_manual(values=cbbPalette) +
  scale_y_continuous(labels=label_dollar(prefix="$")) +
  theme_minimal()




# ------- Q2. Why ‘tidy’ data? -----------
# Create version of economics where some variables are rescaled between 0 and 1
# Rescale function
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

economics_rescaled <- economics %>%
  mutate(across(!date, rescale01))
  
# Plot rescaled data
ggplot(mapping = aes(x=date), data = economics_rescaled) +
  geom_line(aes(y=pce), color=cbbPalette[1]) +
  geom_line(aes(y=pop), color=cbbPalette[2]) +
  geom_line(aes(y=psavert), color=cbbPalette[3]) +
  geom_line(aes(y=uempmed), color=cbbPalette[4]) +
  geom_line(aes(y=unemploy), color=cbbPalette[5]) +
  
  # Set theme and labels
  labs(x = "Date",
       y = "Rescaled Value") +
  theme_minimal()

# Create a new economics dataset for easier plotting
economics_tidied <- economics %>%
  pivot_longer(
    cols = pce:unemploy, 
    names_to = "variable", 
    values_to = "value", 
    values_drop_na = TRUE  # Just in case
  ) %>%
  group_by(variable) %>%
  mutate(value01 = rescale01(value))

# Now the corresponding plot should be beautiful
my_plot <- ggplot(data = economics_tidied) +
  geom_line(aes(x=date, y=value01, color=variable), 
            size=0.8) +
  
  # Set theme and labels
  labs(x = "Date",
       y = "Rescaled Value",
       color = "Variable",
       title = "Change of Economic Factors from 1968 to 2016") +
  scale_color_manual(values=cbbPalette) +
  theme_minimal()

my_plot




# ---------Q3: Changing plot appearance -------------
my_plot +
  theme(legend.position = "bottom",
        axis.line.y = element_blank(), # removes the y axis line and ticks
        plot.background = element_rect(fill = "lightblue"),
        plot.title = element_text (hjust = 0.5, # Centre title
                                   size=16)) + # Changes font size
  
  labs(subtitle = "Change of Economic Factors from 1968 to 2016",
       title = "How Has the US Economy Changed in the Past 50 Years?")
  
# How I would present this mpg data
mpg %>% 
  group_by(manufacturer) %>% # group and summarise to get counts for ordering the plot
  summarise(count = n()) %>% 
  ggplot(aes(x = reorder(manufacturer, count), y=count)) +
    geom_bar(stat = 'identity') +
    labs(x = "Manufacturer") +
    coord_flip() 
  


              
# -------- Q4: Using extensions ------------
# Use geomtextpath to add labels directly to lines
library(geomtextpath)
library(ggpointdensity)
library(ggthemes)
library(patchwork)

diamonds_plot <- ggplot(diamonds, aes(x = depth, label=cut, color=cut)) +
  geom_textdensity(size = 4, 
                   fontface = 2, 
                   hjust = 0.3,  # Adjust to move text along the density line
                   vjust = 0.3) +
  theme_few()  +
  xlim(55, 70) +
  theme(legend.position = "none")


# Use ggpointdensity to improve the log-log graph
housing_plot <- txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +  # avoid the issue of overlapping data points
  theme_par()

# Use the patchwork package to combine
diamonds_plot + housing_plot


# ---------- Q5 Some {ggplot2} subtleties ------------
# Plot price against price in the diamonds dataset
ggplot(diamonds, aes(carat, price, colour="blue")) +
  geom_point() +
  scale_colour_manual(values="blue") + # Good for specifying one colour
  scale_colour_identity() # good you have a column of colours in string format

# Cretae a line plot from the tibble
df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)

# group aesthetic needed to remove the default grouping of the x varibale, as it is categorical
# which will not create a line graph, set group to anything
ggplot(df, aes(x, y, group=93203)) +
  geom_line()


# Recreate this plot by using mutate
df %>% 
  mutate(across(x, as.numeric)) %>% # what we learned in a previous week
  ggplot(aes(x,y)) +
  geom_line()


# This doesn't work 
ggplot(mpg, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_d()  # discrete colour scale, cyl is numeric so requires a continuous scale

# Alternatively could do, (but number of cylinders are discrete) 
ggplot(mpg, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_c() 

# Alternatively could do (bins the colours)
ggplot(mpg, aes(displ, manufacturer, color = cyl)) +
  geom_jitter() +
  scale_colour_viridis_d() +
  scale_color_binned()

# Finally could use an alternative to colour aesthetic
ggplot(mpg, aes(displ, manufacturer, color = factor(cyl))) +
  geom_jitter() +
  scale_colour_viridis_d()
  

# Lastly, create a version of the plot with no empty panels
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_wrap(cyl ~ class) + # change to facet_wrap
  theme(legend.position = "bottom")
