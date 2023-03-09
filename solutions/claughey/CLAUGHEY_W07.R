# Load packages
library(ggplot2, quietly = TRUE)
library(tidyverse, quietly = TRUE)
library(ggpointdensity, quietly = TRUE)
#install.packages("tidytuesdayR")

# The palette with black:
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# ---------- Data Load ------------------
# Load data from tidy tuesday repo
tuesdata <- tidytuesdayR::tt_load('2022-03-08')
tuesdata <- tidytuesdayR::tt_load(2022, week = 10)

erasmus <- tuesdata$erasmus

# See the data types and summary statistics for all variables
erasmus %>%
  summary()

# ------------- Data Wrangling ------------------
# Remove unwanted columns for this analysis 
erasmus_reduced <- erasmus %>%
  select(c(academic_year, mobility_duration, participant_nationality, participant_gender, participant_profile, participant_age, sending_country_code, receiving_country_code, participants, fewer_opportunities)) %>%
  filter(participant_age >4, participant_age < 60) %>% # Consider secondary school age upwards, also removes incorrect values (<0)
  uncount(participants)   

# ---------------- Visualisations ------------
# See the distribution of students age in Erasmus by year
plot1 <- erasmus_reduced %>%
  # Configure plot
  ggplot(aes(participant_age, fill = fewer_opportunities)) +
  geom_histogram() +
  
  # Change the labels
  labs(x = "Participant Age",
       y = "Count",
       title = "Students in the Erasmus Programme by Age and Financial Background",
       caption = "Showing data from 2014-2020 Erasmus Programmes.",
       fill = "Fewer Opportunities") +

  # Set colours
  scale_fill_manual(values=cbbPalette[c(2,6)]) +
  
  # Set plot theme
  theme_minimal()

plot1


# See which countries students move to
# Find top 10 countries that send the most students (limited for plotting purposes)
top_countries <- erasmus_reduced %>% 
  count(sending_country_code, sort = TRUE) %>%
  slice(1:10) %>%
  pull(sending_country_code)


# Plot movement of students
plot2 <- erasmus_reduced %>% 
  filter(receiving_country_code != sending_country_code) %>% # Exclude students travelling to same country
  filter(receiving_country_code %in% top_countries) %>% # only consider countries that send most students
  filter(sending_country_code %in% top_countries) %>%
  
  # Plot
  ggplot(aes(receiving_country_code, sending_country_code)) +
  geom_count() +
  scale_size_area(max_size = 8) +
  
  # Add a line to go over the points for a same country move, otherwise can be mistaken for 0.
  geom_abline(intercept = 0, slope = 1) +

  # Change the labels
  labs(x = "Receiving Country Code",
       y = "Sending Country Code",
       title = "Students' Movements Across the Erasmus Programme Network",
       caption = "Showing data from 2014-2020 for the Top 10 most involved countries\nin the Erasmus Programme.",
       size = "Number of Students") +
  
  # Set plot theme
  theme_minimal()

plot2


# Make a facet plot of the change in students by gender, year and country
plot3 <- erasmus_reduced %>%
  filter(participant_nationality %in% top_countries) %>% # only consider students from countries that send most students
  group_by(participant_nationality, academic_year, participant_gender) %>% 
  summarise(count = n(), .groups = "keep") %>%
  
  # Configure the plot
  ggplot(aes(x=academic_year, y=count, group=participant_gender, colour=participant_gender)) +
  geom_point(size=0.2) +
  geom_line() +
  facet_wrap(vars(participant_nationality), nrow=2, ncol=5) +
 
   # Set plot theme
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90)) +
  
  # Change the labels
  labs(x = "Academic Year",
       y = "Number of Students",
       title = "Participants in Erasmus Programme by Year, Gender and Country",
       caption = "Showing data from 2014-2020 for the Top 10 most involved countries in the Erasmus Programme.",
       color = "Participant Gender") +
  
  # Colourblind-friendly colours
  scale_colour_manual(values=cbbPalette)

  
plot3
