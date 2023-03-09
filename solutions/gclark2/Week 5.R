# Week 5 Training

# Load packages 
library(tidyverse)
library(scales)
library(geomtextpath)
library(ggpointdensity)
library(ggthemes)
library(patchwork)
library(viridis)
library(viridisLite)

# --- 1.1 ---
# View all distinct cities and filter to just ones with county in the name
txhousing %>% 
  distinct(city) %>%
  view()

txhousing_counties <- txhousing %>%
  filter(grepl('County', city) )

# --- 1.2 --- 
# Plot median house price for each county over time
txhousing_counties %>%
  ggplot(aes(x = date, y = median, colour = city)) + 
  geom_line()

# --- 1.3 ---
# Plot all cities on previous plot
txhousing_counties %>%
  ggplot(aes(x = date, y = median, colour = city)) + 
  geom_line(txhousing, mapping = aes(group = city), colour = "grey") +
  geom_line()

# --- 1.4 ---
# Improve appearance 
txhousing_counties %>%
  ggplot(aes(x = date, y = median, colour = city)) + 
  geom_line(txhousing, mapping = aes(group = city), colour = "grey") +
  geom_line()+
  scale_color_viridis_d() +
  scale_y_continuous(labels=label_dollar()) +
  labs(title = 'House Prices for Each County',
       y = 'Median (Dollars)',
       x = 'Date',
       colour = NULL) +
  theme_minimal()

# --- 2.1 ---
# Rescale all variables other than date
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

economics_rescaled <- economics %>%
  mutate(pce = rescale01(pce),
         pop = rescale01(pop), 
         psavert = rescale01(psavert), 
         uempmed = rescale01(uempmed),
         unemploy = rescale01(unemploy)
         )

# --- 2.2 ---
# Plot each varibale as a separate line 
economics_rescaled %>%
  ggplot() + 
  geom_line( mapping = aes(x = date, y = pce, color = 'pce')) +
  geom_line( mapping = aes(x = date, y = pop , color = 'pop')) +
  geom_line( mapping = aes(x = date, y = psavert, color = 'psavert')) +
  geom_line( mapping = aes(x = date, y = uempmed, color = 'uempmed')) +
  geom_line( mapping = aes(x = date, y = unemploy, color = 'unemploy'))+
  scale_color_viridis_d() +
  ylab('normalised value')

# --- 2.3 ---
# Create longer dataset
economics_rescaled_2 <- economics_rescaled %>%
  pivot_longer(c('pce', 'pop', 'psavert', 'uempmed', 'unemploy'), 
               names_to = "variable", 
               values_to = "value") %>%
  group_by(variable) %>%
  mutate(value01 = rescale01(value)) %>%
  ungroup() 

# --- 2.4 ---
# Plot new dataset
economics_rescaled_2 %>%
  ggplot() + 
  geom_line(mapping = aes(x = date, y = value, color = variable)) +
    scale_color_viridis_d() +
    ylab('normalised value')

# --- 3.1 --- 
# Improve appearance of plot
economics_rescaled_2 %>%
  ggplot() + 
  geom_line(mapping = aes(x = date, y = value, color = variable)) +
  scale_color_viridis_d() +
  ylab('normalised value') +
  theme(panel.background = element_rect(fill = 'lightblue'), 
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5, size=15)) +
  scale_y_continuous(labels = NULL, breaks = NULL) +
  labs(title = 'US Economic Time Series',
       subtitle = 'Normalised Values for Each of the Economic Data Variables',
       x = 'Date',
       y = 'Value',
       color = NULL) 

# --- 3.2 ---
# Improve readability of axis labels
mpg %>% 
  ggplot(aes(manufacturer)) +
  geom_bar() + 
  theme(axis.text.x = element_text(angle = 90)) 
  
# --- 4.1 ---
# Add labels to plot
ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_density(show.legend = FALSE) +
  xlim(55, 70) + 
  geom_textdensity(size = 3, 
                   fontface = 2,
                   vjust = -0.5,
                   hjust = 0.3,
                   text_smoothing = 20) +
  theme(legend.position = "none")

# --- 4.2 ---
# Plot using geom_pointdensity to show the density of points in a 
# particular area of the plot
txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_point() +
  geom_pointdensity() +
  scale_color_viridis()

# --- 4.3 ---
# Change theme of previous plots
ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_density(show.legend = FALSE) +
  xlim(55, 70) + 
  geom_textdensity(size = 3, 
                   fontface = 2,
                   vjust = -0.5,
                   hjust = 0.3,
                   text_smoothing = 20) +
  theme_economist() + 
  scale_colour_economist() +
  theme(legend.position = "none") 


txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_point() +
  geom_pointdensity() +
  theme_excel()


# --- 4.4 ---
# Combine the plots
plot1 <- ggplot(diamonds, aes(depth, colour = cut, label = cut)) +
  geom_density(show.legend = FALSE) +
  xlim(55, 70) + 
  geom_textdensity(size = 3, 
                   fontface = 2,
                   vjust = -0.5,
                   hjust = 0.3,
                   text_smoothing = 20) +
  theme_economist() + 
  scale_colour_economist() +
  theme(legend.position = "none") 

plot2 <- txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_point() +
  geom_pointdensity() +
  theme_economist()+
  theme(legend.position = "right") 

plot1 + plot2

# --- 5.1 ---
# Try different methods of changing colour of points 
# Method 1  
ggplot(diamonds, aes(carat, price)) +
  geom_point(color = 'blue')

# Method 2
ggplot(diamonds, aes(carat, price, color = "points")) +
  geom_point() +
  scale_color_manual(values = c("points" = "blue")) +
  theme(legend.position = "none")

# Method 3 
ggplot(diamonds, aes(carat, price, colour = "blue")) +
  geom_point() + 
  scale_color_identity()

# --- 5.2 ---
# Set group asthetic to NA since each group consists of only one observation
# Plot line-plot 
df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)
ggplot(data = df) +
  geom_line(aes(x = x, y = y, group = NA))

# --- 5.3 ---
# Change character strings to numeric before plotting
df %>%
  mutate(x = as.numeric(x)) %>%
  ggplot() +
  geom_line(aes(x = x, y = y))

# --- 5.4 ---
# This doesn't work because it is trying to apply a continuous scale to a 
# discrete variable
mpg %>% 
  ggplot(aes(y = manufacturer, fill = cyl)) +
  geom_bar() +
  scale_fill_viridis_d()

# Solution one - make cyl a factor
mpg %>% 
  ggplot(aes(y = manufacturer, fill = as.factor(cyl))) +
  geom_bar() +
  scale_fill_viridis_d()

# Solution two - change the data before plotting
mpg %>%
  mutate(across("cyl", ~factor(.x, levels = c('4', '5', '6', '7', '8')))) %>%
  ggplot(aes(y = manufacturer, fill = cyl)) +
  geom_bar() +
  scale_fill_viridis_d()

# Solution three - change the scale on viridis palette (DOESN'T WORK)
mpg %>%
  ggplot(aes(y = manufacturer, fill = cyl)) +
  geom_bar() +
  scale_fill_viridis_c()

# --- 5.5 ---
# Use facet_wrap instead of facet_grid
ggplot(mpg, aes(y = fl, fill = factor(year))) +
  geom_bar() +
  facet_wrap(cyl ~ class, as.table = TRUE, drop = TRUE) +
  theme(legend.position = "bottom")
