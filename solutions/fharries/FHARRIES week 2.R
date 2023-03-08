
# 1 -----------------------------------------------------------------------

# Load packages
library(tidyverse) 

# Load data
course_details <- readr::read_csv("week-02-data-wrangling/course_details.csv")
starts <- readr::read_csv("week-02-data-wrangling/starts.csv")
ofsted <- readr::read_csv("week-02-data-wrangling/ofsted.csv")
ofsted_scores <- readr::read_csv("week-02-data-wrangling/ofsted_scores.csv")


# 2 -----------------------------------------------------------------------


# 2.1

# Count each unique value and filter any if count != 1
ofsted |> 
  count(provider_name) |> 
  filter(n != 1)

# Health Education England appears twice
ofsted |>
  filter(provider_name == "Health Education England")

# Provider types are different
# Leave in and ensure to use ukprn number going forward


# 2.2

# Check for missing values
sum(is.na(ofsted$ukprn))

# Check each value is unique
ofsted |> 
  count(ukprn) |> 
  filter(n != 1)


# 2.3

 # Find proportion of 'Independent specialist colleges'
ofsted |> 
  group_by(provider_type) |> 
  summarise(provider_count = n(), .groups = 'drop') |> 
  mutate(proportion = scales::percent(proportions(provider_count), 
                                      accuracy = 0.01)) |> 
  filter(provider_type == "Independent specialist college")


# 2.4 

# Join tables where inspection number matches inspection ID
ofsted_combined <- left_join(
  ofsted, 
  ofsted_scores, 
  by = c("inspection_number" = "inspection_id")
  )


# Find proportion of providers with ineffective safeguarding 
ofsted_combined |> 
  filter(inspection_category == "Is safeguarding effective") |> 
  group_by(score_description) |> 
  summarise(score_count = n(), .groups = 'drop') |> 
  mutate(proportion = scales::percent(prop.table(score_count), 
                                      accuracy = 0.01)) |> 
  filter(score_description =="No")


# 2.5

# Set inspection_date to date format
ofsted_combined <- ofsted_combined |> 
  mutate(inspection_date = lubridate::ymd(inspection_date))

# Add new column with the day of inspection
ofsted_combined <- ofsted_combined |> 
  mutate(week_day = lubridate::wday(inspection_date, label = TRUE))

# Find most common days for inspection
common_days <- ofsted_combined |> 
  distinct(ukprn, week_day, inspection_type) |> 
  count(week_day, inspection_type) |> 
  filter(week_day != is.na(week_day))

common_days

# Overall most common days for inspection
# Tuesday most common day
ggplot(common_days, aes(x = week_day, y = n)) +
  geom_col() +
  ggtitle("Inspections conducted on each day") +
  labs(x = "", y = "")


# Most common days for full inspection
# Tuesday 

# Most common days for short inspection
# Wednesday

ggplot(common_days, aes(x = week_day, y = n)) +
  geom_col() +
  ggtitle("Inspections conducted on each day") +
  labs(x = "", y = "") +
  facet_wrap(~inspection_type)


# 3 -----------------------------------------------------------------------


# 3.1

# Table with proportions of inspection scores by provider type
performance_lookup <- ofsted_combined |> 
  filter(inspection_category %in% c('Apprenticeships')) |> 
  group_by(provider_group, score_description) |> 
  summarise(n = n(), .groups = 'drop')


# Filter to find provider type with most outstanding scores
performance_lookup |> 
  group_by(provider_group) |> 
  summarise(
    score_description, 
    proportion = n / sum(n), 
    .groups = 'drop'
  ) |> 
  filter(score_description %in% c('Outstanding')) |> 
  slice_max(proportion)
  

# 3.2

# Format performance table into look up table
performance_lookup <- performance_lookup |> 
  group_by(provider_group) |> 
  summarise(
    score_description, 
    proportion = n / sum(n), 
    .groups = 'drop'
  ) |> 
  pivot_wider(
    names_from = score_description, 
    values_from = proportion, 
    values_fill = 0
  )


performance_lookup


# 3.3 

# Join starts table
ofsted_starts_combined <- left_join(
  ofsted_combined, 
  starts, 
  by = c("ukprn"),
  suffix = c("", "_ofsted")
)


# Number of starts associated with each score for overall effectiveness 
osc_overall <- ofsted_starts_combined |> 
  filter(inspection_category == 'Overall effectiveness') |> 
  group_by(score_description) |> 
  summarise(
    total_starts = sum(starts, na.rm = TRUE), 
    .groups = 'drop'
  )


# 3.4

# Number of starts associated with each score for apprenticeships
osc_apprenticeships <- ofsted_starts_combined |> 
  filter(inspection_category %in% c('Apprenticeships')) |> 
  group_by(score_description) |> 
  summarise(
    total_starts = sum(starts, na.rm = TRUE), 
    .groups = 'drop'
  )

# Combine into one table
starts_comparison <- bind_rows(
  Overall = osc_overall, 
  Apprenticeships = osc_apprenticeships, 
  .id = "category"
  )

# Order the score descriptions
starts_comparison <- 
  starts_comparison |> 
  mutate(score_description = fct_relevel(score_description, 
                                         "Outstanding", 
                                         "Good", 
                                         "Requires improvement", 
                                         "Inadequate")
         )

ggplot(starts_comparison, aes(
  x = score_description, 
  y = total_starts, 
  fill = category
  )) +
  geom_col(position = 'dodge') +
  ggtitle("Apprenticeship starts associated with each Ofsted score") +
  labs(x = "", y = "Thousand") +
  scale_y_continuous(
    labels = scales::unit_format(unit = "", scale = 1e-3)
  )
            
# From the plot, providers tend to perform less well at apprenticeships
# than they do overall, with lower starts associated with 'outstanding' and 'good'
# and higher with 'requires improvement'
# Although to note, not all providers seem to have been assessed in the 
# apprenticeships category, which could have an impact on this pattern 


# 4 -----------------------------------------------------------------------

# 4.1

# Join course details table
ofsted_starts_course <-  left_join(
  ofsted_starts_combined, 
  course_details, 
  by = c("std_fwk_code")
)

# Create table indicating risk of closure 
closure_risk <- ofsted_starts_course |> 
  filter(inspection_category == "Overall effectiveness") |> 
  group_by(std_fwk_flag, delivery_region, score_description) |> 
  summarise(total_starts = sum(starts), .groups = 'drop_last') |> 
  mutate(
    risk_factor = scales::percent(total_starts / sum(total_starts),
                                  accuracy = 0.01)
  ) |> 
  ungroup() |> 
  filter(score_description == "Inadequate") |> 
  select(std_fwk_flag, delivery_region, risk_factor) 

closure_risk

#4.2

# Same as above but including inspection category
closure_category <- ofsted_starts_course |> 
  mutate_at(
    vars(score_description), 
    ~ifelse(score_description == 'No', 'Inadequate', .)
  ) |> 
  group_by(
    inspection_category,
    std_fwk_flag, 
    delivery_region,
    score_description
  ) |> 
  summarise(starts = sum(starts), .groups = "drop_last") |> 
  mutate(
    risk_factor = scales::percent(starts / sum(starts),
                                  accuracy = 0.01)
  ) |> 
  filter(score_description %in% c("Inadequate")) |> 
  pivot_wider(names_from = inspection_category, values_from = risk_factor) |> 
  select(!c(starts, score_description))

print(closure_category, n = 100)

# 4.3

# Same as above but with many more breakdown columns 
closure_detailed <- ofsted_starts_course |> 
  mutate_at(
    vars(score_description), 
    ~ifelse(score_description == 'No', 'Inadequate', .)
  ) |> 
  group_by(
    inspection_category,
    provider_type_ofsted,
    provider_group,
    route,
    apps_level,
    std_fwk_flag, 
    delivery_region, 
    score_description
  ) |> 
  summarise(starts = sum(starts), .groups = "drop_last") |> 
  mutate(
    risk_factor = scales::percent(starts / sum(starts),
                                  accuracy = 0.01)
  ) |> 
  ungroup() |> 
  filter(score_description %in% c("Inadequate")) |> 
  rename(risk_category = inspection_category) |> 
  select(!c(starts, score_description))


closure_detailed$risk_factor

# 4.4

closure_detailed <- closure_detailed |> 
  complete(
    risk_category, 
    provider_type_ofsted,
    provider_group,
    route,
    apps_level,
    std_fwk_flag, 
    delivery_region)

# 4.5



# 4.6

# Created the calculate closure risk function which takes in the data
# and a number of different 'breakdowns' as optional arguments 
# it also takes an optional category which you can filter by

calculate_closure_risk <- function(data, ..., category = NULL) {
  if(!is.null(category)){
    data <- data |> 
    filter(inspection_category == category)
  }
  
  data |> 
    mutate_at(
      vars(score_description), 
      ~ifelse(score_description == 'No', 'Inadequate', .)
    ) |> 
    group_by(...) |> 
    summarise(starts = sum(starts), .groups = 'drop_last') |> 
    mutate(
      risk_factor = scales::percent(starts / sum(starts), 
                                    accuracy = 0.01)
    ) |> 
    ungroup() |> 
    filter(score_description == "Inadequate") |> 
    #rename(risk_category = {{inspection_category}}) |> 
    select(!c(starts, score_description))
    
  
}

# Example below, can amend the argumets to get the data you want

calculate_closure_risk(
  ofsted_starts_course, 
  inspection_category,
  provider_type_ofsted,
  provider_group,
  route,
  std_fwk_flag, 
  delivery_region,
  score_description
)
