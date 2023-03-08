# Graduate R training week 5 - MAITCHISON

# Load in required packages needed for the week 5 exercises 
library(tidyverse)
library(scales)
library(geomtextpath)
library(ggpointdensity)
library(ggthemes)
library(patchwork)


# ---- Q1.1 ----

# View all distinct cities in data set to get an idea of what the question wants
View(distinct(txhousing, city))

# Create new data set only including cities with "County" in the name
txhousing_county <- txhousing |>
  filter(grepl("County", city))

# ---- Q1.2 ----

# Create a plot of median house price against time (date)
ggplot(data = txhousing_county, mapping = aes(x = date, y = median)) + 
  
  # Differentiate counties using different colours
  geom_line(mapping = aes(colour = city))
  

# ---- Q1.3 ----

# Create a data set which includes all cities without "County" in the name
# (we will use two separate data sets to create the plot for this question)
txhousing_not_county <- txhousing |>
  filter(!grepl("County", city))

# Create axes which plot median and time (date)  
ggplot(data = txhousing_county, mapping = aes(x = date, y = median)) +
  
  # Add line plot layer using the non-county data with group aesthetic to plot by city
  geom_line(txhousing_not_county, mapping = aes(group = city),colour = "grey") +
  
  # Add line plot layer using the county data
  geom_line(mapping = aes(colour = city)) 
  
# ---- Q1.4 ----

ggplot(data = txhousing_county, mapping = aes(x = date, y = median)) +
  
  # Set y-axis to have units of dollars
  scale_y_continuous(labels=scales::label_dollar()) + 
  
  geom_line(txhousing_not_county, mapping = aes(group = city),colour = "grey") +
  
  #Use a colourblind friendly palette
  scale_colour_brewer(palette = "Set1") + 
  
  geom_line(mapping = aes(colour = city)) + 
  
  # Use the light theme to create a more user friendly aesthetic 
  theme_light() +
  
  # Set x axis label, y axis label, legend label and graph title
  labs(
    x = "Time (Date)",
    y = "Median (dollars)",
    colour = "County",
    title = "The increase in median house price with time"
  )


# ---- Q2.1 ----

# Initialise rescaling function as stated in question
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

# Create a new data set which will contain the new rescaled columns
economics_rescaled <- economics

# Apply rescaling function sequentially to each column in the new data set
economics_rescaled$pce <- rescale01(economics$pce)
economics_rescaled$pop <- rescale01(economics$pop)
economics_rescaled$psavert <- rescale01(economics$psavert)
economics_rescaled$uempmed <- rescale01(economics$uempmed)
economics_rescaled$unemploy <- rescale01(economics$unemploy)

# ---- Q2.2 ----

# Create plot by initialising a geom_smooth layer for each column of data set
ggplot(data = economics_rescaled) + 
  geom_smooth( mapping = aes(x = date, y = pce, color='pce')) +
  geom_smooth( mapping = aes(x = date, y = pop , color='pop')) +
  geom_smooth( mapping = aes(x = date, y = psavert, color='psavert')) +
  geom_smooth( mapping = aes(x = date, y = uempmed, color='uempmed')) +
  geom_smooth( mapping = aes(x = date, y = unemploy, color='unemploy')) + 
  
  # Set colour of the variables manually 
  scale_color_manual(name='Variable',
                     breaks=c('pce', 'pop', 'psavert', 'uempmed', 'unemploy'),
                     values=c('pce'='pink', 'pop'='blue', 'psavert'='purple', 
                              'uempmed' = 'red', 'unemploy' = 'green')) +
  
  # Set y axis label as it is currently "pce" which is 1 of the 5 variables
  labs(
    y = "Normalised value"
  )


# ---- Q2.3 ----

# Create new data set for simplified method introduced by this question
economics_rescaled_grouped <- economics_rescaled |>
  
  # Merge the 5 columns into one "variable" column with a "value" column for their values
  pivot_longer(c('pce', 'pop', 'psavert', 'uempmed', 'unemploy'), 
               names_to = "variable", values_to = "value") |>
  
  # Group by variable and create new column for rescaled values
  group_by(variable) |>
  mutate(value01 = rescale01(value)) |>
  ungroup() 


# ---- Q2.4 ----

# Use data set from previous question to create desired plot
ggplot(data = economics_rescaled_grouped) +
  
  #Use value01 for y axis values, and group by variable column
  geom_smooth(mapping = aes(x = date, y = value01, colour = variable))

# ---- Q3.1 ----

# Format previous plot according to the question
ggplot(data = economics_rescaled_grouped) +
  
  # Increase line thickness 
  geom_smooth(mapping = aes(x = date, y = value01, colour = variable), size = 3) + 
  
  # Make plot background light blue 
  theme(panel.background = element_rect(fill = 'lightblue', color = 'purple'),
        
        # Move colour legend to bottom of the plot
        legend.position = "bottom") +
  
  # Choose appropriate labels for title, subtitle, legend and axis
  labs(title = "Increase in future",
       subtitle = "All values increase",
       legend = "Different categories",
       x = "Variable",
       y= "values") +
  
  # Increase title size and center title above plot
  theme(plot.title = element_text(hjust = 0.5, size=20)) +
  
  # Remove y axis values and ticks
  scale_y_continuous(labels = NULL, breaks = NULL) +
  
  # Use a colourblind friendly palette for the variable categories
  scale_colour_brewer(palette = "Set1")

# ---- Q3.2 ----

# Make axis labels clearer 
mpg |> 
  ggplot(aes(manufacturer)) +
  geom_bar() + 
  
  # Stagger axis labels using code inspired from user "wurli" from stackoverflow link
  scale_x_discrete(guide = ggplot2::guide_axis(n.dodge = 3), 
                   labels = function(x) stringr::str_wrap(x, width = 20))


# ---- Q4.1 ----

# Use "geomtextpath" extension to add labels directly onto the lines of the plot
ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_density(show.legend = FALSE) +
  xlim(55, 70) + 
  
  # Add label near peak of each plot -inspired from "Controlling text position" section of the following link:
  # https://allancameron.github.io/geomtextpath/
  geom_textdensity(size = 2.5, fontface = 2, spacing = 50,
                   vjust = -0.2, text_smoothing = 40) +
  
  # Remove redundant legend
  theme(legend.position = "none")


# ---- Q4.2 ----

# Use "ggpointdesnity" extension to improve clarity of plot
txhousing |> 
  ggplot(aes(log(sales), log(listings))) +
  
  # Use "geom_pointdesnity" to colour points by density of points in that location of plot
  geom_pointdensity()

# ---- Q4.3 ----

# Use the "themes" extension to add additional plot themes

ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_density(show.legend = FALSE) +
  xlim(55, 70) + 
  geom_textdensity(size = 2.5, fontface = 2, spacing = 50,
                   vjust = -0.2, text_smoothing = 40) +
  
  # Use the "dark" theme relating to the plot from Q4.2
  theme_dark() + 
  theme(legend.position = "none") 
  

txhousing |> 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +
  
  # Use the "excel" theme for the plot relating to Q4.1
  theme_excel()

# ---- Q4.4 ----

# Use the patchwork extension to combine the previous two plots

# Assign the plot relating to Q4.2 to the variable "p1"
p1 <- ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_density(show.legend = FALSE) +
  xlim(55, 70) + 
  geom_textdensity(size = 2.5, fontface = 2, spacing = 50,
                   vjust = -0.2, text_smoothing = 40) +
  theme_dark() + 
  theme(legend.position = "none")

# Assign the plot relating to Q4.2 to the variable "p2"
p2 <- txhousing |> 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity() +
  theme_excel()

# "patchwork" allows the addition of the above two variables to combine the plots
p1 + p2

# ---- Q5.1 ----

# We want the below code to show blue points but currently does not do this. We 
# try the following three solutions
ggplot(diamonds, aes(carat, price, colour = "blue")) +
  geom_point()

# 1) Place colour = "blue" inside geom_point
ggplot(diamonds, aes(carat, price)) +
  geom_point(colour = "blue")

# 2) Set point colour manually using same method as in Q2.2
ggplot(diamonds, aes(carat, price, color = "points")) +
  geom_point() +
  scale_color_manual(name = "color",
                     breaks = c("points"),
                     values = c("points" = "blue"))

# 3) Use a call to "scale_colour_identity" to correct the data point colour
ggplot(diamonds, aes(carat, price, colour = "blue")) +
  geom_point() + 
  scale_color_identity()

# ---- Q5.2 ----

# Initialise required data
df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)

# It is required to set the group aesthetic to NA as each group consists of only
# one observation. This is because the x column is formatted as strings
ggplot(data = df) +
  geom_line(mapping = aes(x = x, y = y, group = NA))


# ---- Q5.3 ----

# Create a new data set for this questions where the x column is set to contain
# numeric values instead of strings
df2 <- df |>
  mutate(x = as.numeric(x)) 

# Plot the data without the need for the group aesthetic 
ggplot(data = df2) +
  geom_line(mapping = aes(x = x, y = y))

# ---- Q5.4 ----

# I believe the issue is that "scale_fill_viridis_d" requires discrete data
# to fill by, whilst cyl is an integer and is classed as continuous. Is this correct?
ggplot(mpg, aes(y = manufacturer, fill = cyl)) +
  geom_bar() +
  scale_fill_viridis_d()


# 1) I am currently unsure how to correct this graph using the scale function, I found
# that removing the scale function allows for the visual to be plotted, but I don't 
# believe this is the intended solution
ggplot(mpg, aes(y = manufacturer, fill = cyl)) +
  geom_bar()
  
# 2) Convert cyl to categorical data by using the factor data type in the fill aesthetic
ggplot(mpg, aes(y = manufacturer, fill = factor(cyl))) +
  geom_bar()

# 3) Create new data set which converts cyl to a character, and use this new data type
# to create the plot
mpg2 <- mpg |>
  mutate(cyl = as.character(cyl))
ggplot(mpg2, aes(y = manufacturer, fill = cyl)) +
  geom_bar() +
  scale_fill_viridis_d()

# ---- Q5.5 ----

# The below code is not very space efficient
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_grid(cyl ~ class) +
  theme(legend.position = "bottom")

# Replace "facet_grid" with "facet_wrap" which excludes visuals without data
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_wrap(cyl ~ class) +
  theme(legend.position = "bottom")

