#  Load packages
library(tidyverse)
library(lubridate)
library(ggplot2)
library(janitor)

# Load data 
course_details <- read_csv("course_details.csv")
starts         <- read_csv("starts.csv")
ofsted         <- read_csv("ofsted.csv")
ofsted_scores  <- read_csv("ofsted_scores.csv")


# -------- Basic Wrangling -----------

# Verify that each provider in ofsted has only one recorded inspection in the data
# Sort counts of provider_name in dataset showing largest groups first, all should be 1.
count(ofsted, provider_name, sort = TRUE)   # Not all unique, now look at UKPRNs
count(ofsted, ukprn, sort = TRUE)           # All UKPRNs are unique, use as identifier

# Proportion of providers are 'Independent specialist colleges'?
no_providers  <- nrow(ofsted)
ISC_ratio     <- sum(ofsted$provider_type == 'Independent specialist college') / no_providers

# % of providers that have ineffective safeguarding
# Join ofsted to ofsted scores using inspection_id as primary key, this eliminates uninspected providers
ofsted_combined <- ofsted_scores |> 
  left_join(ofsted, by = c("inspection_id" = "inspection_number")) |>
  filter(inspection_category == "Is safeguarding effective")

# Calculate proportion of inspected providers with a safeguarding score of 3 or higher (my definition of ineffective)
no_inspected_providers          <- nrow(ofsted_combined) 
ineffective_safeguarding_ratio  <- sum(ofsted_combined$score >= 3) / no_inpsected_providers

# Convert inspection dates to date format
ofsted <- ofsted |> 
  mutate(inspection_date = ymd(inspection_date))

# Create column telling the day of the week the inspection was carried out
ofsted$day_of_the_week <- wday(ofsted$inspection_date)

# Create plot to anlayse how OFSTED choose the days to inspect
plot <- ggplot(data = subset(ofsted, !is.na(day_of_the_week)), 
               aes(x=factor(day_of_the_week))) +
  geom_bar(stat='count') +
  labs(title = "When do OFSTED Carry Out Their Inspections?",
       caption = "Inspections typically occur on Tuesday if it is a full inspection and Wednesday if it is a short inpsection",
       x = "Day of the Week",
       y = "Number of Inpsections") +
  facet_grid(rows=vars(inspection_type), scales = "free") 

plot + theme_bw()



# -------- Tricky Wrangling -----------
# Which provider group has the highest proportion of 'outstanding' scores for apprenticeships.
# Join dfs again and filter to consider those that are inspected on Apprenticeships
ofsted_combined2 <- ofsted_scores |> 
  left_join(ofsted, by = c("inspection_id" = "inspection_number")) |>
  filter(inspection_category == "Apprenticeships")

# table function counts occurrence of each score for each provider type
# prop.table converts these into proportions wrt provider type (margin=1)
lookup_table <- prop.table(table("Provider Type" = ofsted_combined2$provider_type, 
                                 "Score" = ofsted_combined2$score_description), 
                           margin = 1)

# Clean column headings
lookup_table <- clean_names(as.data.frame.matrix(lookup_table))


# Find total number of apprenticeships starts associated with each score for overall effectiveness
ofsted_combined3 <- ofsted_scores |>
  left_join(ofsted, by = c("inspection_id" = "inspection_number")) |>      # left join to include all inspections
  inner_join(starts, by = c("ukprn" = "ukprn")) |>                         # inner join to avoid non-inspected providers in starts.csv
  filter(inspection_category == "Overall effectiveness") |>
  group_by(score_description) |>
  summarise(apprentice_starts = sum(starts))

# Find total number of apprenticeships starts associated with each score for apprenticeships
ofsted_combined4 <- ofsted_scores |>
  left_join(ofsted, by = c("inspection_id" = "inspection_number")) |>      # left join to include all inspections
  inner_join(starts, by = c("ukprn" = "ukprn")) |>                         # inner join to avoid non-inspected providers in starts.csv
  filter(inspection_category == "Apprenticeships") |>
  group_by(score_description) |>
  summarise(apprentice_starts = sum(starts))

# There are more apprentices at providers with a positive OFSTED rating (Good or Outstanding) for Overall Effectiveness than for a positive OFSTED rating in Apprenticeships





# -------- Challenging Wrangling -------------
#Create a dataset which gives the percentage of starts which are at risk
closing_risk <- ofsted_scores |>
  left_join(ofsted, by = c("inspection_id" = "inspection_number")) |>
  inner_join(starts, by = c("ukprn" = "ukprn")) |>
  inner_join(course_details, by = c("std_fwk_code" = "std_fwk_code")) |>
  group_by(delivery_region, std_fwk_flag) |>
  summarise(risk_starts = sum(starts[inspection_category == "Overall effectiveness" & score == 4]),
            sum_starts = sum(starts),
            risk_factor = risk_starts / sum_starts)

# Same but now starts are at risk if any inspection category is inadequate or they have ineffective safeguarding
closing_risk2 <- ofsted_scores |>
  left_join(ofsted, by = c("inspection_id" = "inspection_number")) |>
  inner_join(starts, by = c("ukprn" = "ukprn")) |>
  inner_join(course_details, by = c("std_fwk_code" = "std_fwk_code")) |>
  group_by(delivery_region, std_fwk_flag, inspection_category) |>
  summarise(risk_starts = sum(starts[(inspection_category == "Is safeguarding effective" & score == 3) | (score ==4)]),
            sum_starts = sum(starts),
            risk_factor = risk_starts / sum_starts)



  
