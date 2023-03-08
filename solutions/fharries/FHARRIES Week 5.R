library(tidyverse)
library(lubridate)
library(ggplot2)
library(geomtextpath)
library(ggpointdensity)
library(ggthemes)
library(patchwork)

# Q1 ----------------------------------------------------------------------

# 1.1

# Create subset of txhousing, filtering to only include counties
txhousing_counties <- txhousing |> 
  filter(grepl("County", city))

# 1.2 & 1.3 & 1.4

# Combine year and month columns into date column
txhousing_counties <- txhousing_counties |> 
  mutate(date = make_date(year, month))

txhousing_with_date <- txhousing |> 
  mutate(date = make_date(year, month))

# Plot median for counties and cities 
med_price_plot <- ggplot() +
  geom_line(
    data = txhousing_with_date, 
    aes(x = date, y = median, group = city), 
    colour = 'light grey'
  ) +
  geom_line(
    data = txhousing_counties, 
    aes(x = date, y = median, colour = city), 
    size = 0.75
  ) +
  ggtitle("Median house prices for cities in Texas") +
  labs(x = NULL, y = NULL, colour = "County") +
  scale_y_continuous(labels = scales::label_dollar()) +
  theme_test() +
  scale_colour_brewer(palette="Dark2")

med_price_plot

# Q2 ----------------------------------------------------------------------

# 2.1 & 2.2

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

# Apply rescale01 function to economics dataset
economics_rescaled <- economics |> 
  mutate(across(2:6, rescale01))

# Plot all columns against date
economics_plot <- ggplot(economics_rescaled) +
  geom_line(aes(x = date, y = pce), colour = "#1B9E77") +
  geom_line(aes(x = date, y = pop), colour = "#D95F02") +
  geom_line(aes(x = date, y = psavert), colour = "#7570B3") +
  geom_line(aes(x = date, y = uempmed), colour = "#E7298A") +
  geom_line(aes(x = date, y = unemploy), colour = "#66A61E") +
  labs(x = NULL, y = "Value") +
  theme_test() 

economics_plot

# 2.3 & 2.4

# Reformat and rescale economics dataset 
economics_rescaled_2 <- economics |> 
  pivot_longer(!date, names_to = "variable", values_to = "value") |> 
  group_by(variable) |> 
  mutate(value = rescale01(value)) |> 
  ungroup()

# Plot all columns against date
economics_plot_2 <- ggplot(economics_rescaled_2) +
  geom_line(aes(x = date, y = value, colour = variable)) +
  scale_colour_brewer(palette="Dark2") +
  labs(x = NULL, y = "Value", colour = NULL) +
  theme_test() 

economics_plot_2


# Q3 ----------------------------------------------------------------------

# 3.1

# Update plot appearance 
economics_plot_2 <- ggplot(economics_rescaled_2) +
  geom_line(aes(x = date, y = value, colour = variable)) +
  scale_colour_brewer(
    palette="Dark2", 
    labels = c(
      "Personal consumption expenditures", 
      "Total population", 
      "Personal savings rate", 
      "Median duration of unemployment", 
      "Number of unemployed"
      )
  ) +
  theme_test() +
  ggtitle(
    "US economic time series data", 
    subtitle = "Economic markers plotted against time 1967-2015"
  ) +
  labs(x = NULL, y = "Value", colour = NULL) +
  theme(
    legend.position = "bottom", 
    legend.text = element_text(size=7),
    plot.title = element_text(size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 8, hjust = 0.5),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.background = element_rect(fill = "lightblue")
  )

economics_plot_2

# 3.2

# Flip plot to have manufacturer on y axis
mpg |> 
  ggplot(aes(manufacturer)) +
  geom_bar() +
  coord_flip()

# Q4 ----------------------------------------------------------------------

# 4.1

# Modify to add labels to line path
plot_1 <- ggplot(diamonds, aes(depth, label = cut, colour = cut)) +
  geom_textdensity(hjust = 0.40) +
  xlim(55, 70) +
  theme_stata() +
  theme(legend.position = "none") +
  labs(x = "Depth", y = "Density") 

plot_1

# Feel like the word placement isn't the best, not sure if there's a way
# to get them all in the same position relative to their peaks 

# 4.2

plot_2 <- txhousing |> 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +
  theme_stata()

# Use patchwork to display side by side
plot_1 + plot_2


# Q5 ----------------------------------------------------------------------

# 5.1

# Set colour outside of aes if it should be kept constant and without a legend
ggplot(diamonds, aes(carat, price)) +
  geom_point(colour = "blue")

# Use scale_colour_manual to recognise colour inside aes and produce a legend 
ggplot(diamonds, aes(carat, price, colour = "blue")) +
  geom_point()+
  scale_colour_manual(values = "blue")

# Use scale_clour_identity to recognise colour inside aes without producing a legend
ggplot(diamonds, aes(carat, price, colour = "blue")) +
  geom_point() +
  scale_colour_identity()

# 5.2

# x is a string, group partions the data into the correct groups to plot
df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)

df |> ggplot(aes(x = x, y = y, group = 1)) +
  geom_line()

# 5.3

# Setting x type to integer before plotting
df <- df |> 
  mutate(x = as.numeric(x))

df |> ggplot(aes(x = x, y = y)) +
  geom_line()

# 5.4 

# Use scale_colour_viridis_c (continuous) instead
ggplot(mpg, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_c()

# Use factor to treat cyl as discrete 
ggplot(mpg, aes(displ, manufacturer, colour = factor(cyl))) +
  geom_jitter() +
  scale_colour_viridis_d()

# Edit cyl data type to be factor before plotting
mpg_modified <- mpg |> 
  mutate(cyl = as.factor(cyl))

ggplot(mpg_modified, aes(displ, manufacturer, colour = cyl)) +
  geom_jitter() +
  scale_colour_viridis_d()

# 5.5

# Replace facet_grid with facet_wrap to remove empty panels
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_wrap(cyl ~ class) +
  theme(legend.position = "bottom") 
