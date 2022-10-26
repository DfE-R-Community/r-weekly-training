library(tidyverse)
library(ggthemes)
library(geomtextpath)
library(ggpointdensity)
library(patchwork)


# 1) Plotting txplotting --------------------------------------------------

# Create column that indicates which rows are counties
housing <- txhousing %>% mutate(is_county = grepl("County", city))

housing_plot <- ggplot() +
  # Plot grey lines with only non-county data
  geom_line(data = housing %>% filter(!is_county),
            aes(x = date, y = median, group = city),
            colour = "grey",
            alpha = 0.25) +
  # Plot line using county data on top of grey lines
  geom_line(data = housing %>% filter(is_county),
            aes(x = date, y = median, colour = city)) +
  theme_minimal() +
  scale_colour_colorblind() +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(x = "Date",
       y = "Median house price",
       colour = "Counties",
       title = "House prices of counties in Texas (2000-2015)")


# 2) Why 'tidy' data? -----------------------------------------------------

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

economics_plot <- economics %>%
  mutate(across(-date, rescale01)) %>%
  pivot_longer(!date, names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = date, y = value, colour = variable)) +
  geom_line(size = 1) + 
  scale_colour_colorblind() +
  labs(x = "Date",
       y = "Level",
       colour = "Economic factor",
       title = "Economics of the US (1967-2015)",
       subtitle = "Based off consumption expenditures, population, personal saving, duration of employment and unemployment") +
  theme(legend.position = "bottom",
        text = element_text(size = 10),
        plot.title = element_text (hjust = 0.5),
        plot.subtitle = element_text (hjust = 0.5),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.background = element_rect(fill = "lightblue"))


# 3) Changing plot appearance ---------------------------------------------

# 1) Seen in question 2

# 2)

# Chosen to wrap the x axis text with width so each word has a line of its own
# Also chosen to flip the coordinates

cars_plot <- mpg %>% 
  ggplot(aes(str_wrap(manufacturer, 1))) +
  geom_bar() +
  labs(x = "Car Manufacturer", y = "Count") +
  coord_flip()


# 4) Using extensions -----------------------------------------------------

# 1)

diamonds_plot <- diamonds %>%
  ggplot(aes(depth, colour = cut, label = cut)) +
  geom_textdensity(size = 6, fontface = 1, hjust = 0.35) +
  xlim(55, 70) +
  theme_clean() +
  theme(legend.position = "none")
  
# 2)

housing_point <- txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +
  theme_clean()

# Using the `|` allows for the plots to be printed side-by-side
print(diamonds_plot | housing_point)


# 5) Some ggplot2 subtleties ----------------------------------------------

# 1)

# This option works well and is self explanatory. I think this is the most
# suited for this situation where you want to change the colour of all
# points
diamonds %>%
  ggplot(aes(carat, price)) +
  geom_point(colour = "blue")

# Option `scale_colour_manual()` is a bit odd here since you generally use
# it when you want multiple colours for several intervals
diamonds %>%
  ggplot(aes(carat, price, colour = "Blue Point")) +
  geom_point() +
  scale_colour_manual(values = "blue")

# This option works fine here but it would probably be more suited for
# when you wanted to use multiple colours
diamonds %>%
  ggplot(aes(carat, price, colour = "blue")) +
  geom_point() +
  scale_colour_identity()

# 2)

df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)

# With a categoric x, groups must be defined so geom_line knows which points
# to join up to make a line. With one line, just putting `groups = 1` will
# suffice

df %>%
  ggplot(aes(x = x, y = y, group = 1)) +
  geom_line()

# 3)

# In the plot above, x is being recognised as categorical. If x is numeric
# instead, we can do a a general line plot without the grouping
line_plot <- df %>%
  mutate(x = as.numeric(x)) %>%
  ggplot(aes(x = x, y = y)) +
  geom_line()

# 4)


# The commented code below doesn't work since it wants a discrete fill whereas
# cyl is continuous

# ggplot(mpg, aes(y = manufacturer, fill = cyl)) +
#   geom_bar() +
#   scale_fill_viridis_d()


# You could make cyl discrete
mpg %>%
  ggplot(aes(y = manufacturer, fill = factor(cyl))) +
  geom_bar() +
  scale_fill_viridis_d()
# OR
mpg %>%
  # This way you won't have the `factor()` part in the legend
  mutate(cyl = factor(cyl)) %>%
  ggplot(aes(y = manufacturer, fill = cyl)) +
  geom_bar() +
  scale_fill_viridis_d()


# `scale_colour_viridis_c()` is the continuous version of its `_d` counterpart.
# This however doesn't colour bars that have stacks
mpg %>%
  ggplot(aes(y = manufacturer, fill = cyl)) +
  geom_bar(position = position_dodge()) +
  scale_colour_viridis_c()

# 5)
# Changing to a `facet_wrap` will ignore empty pairings and show
# the combinations just above the plots

car_facet <- ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_wrap(cyl ~ class, scales = "free") +
  theme(legend.position = "bottom")
