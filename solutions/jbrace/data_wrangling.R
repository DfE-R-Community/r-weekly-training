# Question 1 --------------------------------------------------------------
# Load packages
suppressPackageStartupMessages(library(tidyverse))
library(lubridate, warn.conflicts = FALSE)

# Load in data
course_details <- read_csv("course_details.csv", show_col_types = FALSE)
starts <- read_csv("starts.csv", show_col_types = FALSE)
ofsted <- read_csv("ofsted.csv", show_col_types = FALSE)
ofsted_scores <- read_csv("ofsted_scores.csv", show_col_types = FALSE)
# Functions ---------------------------------------------------------------

###########################################################################

# Question 2 --------------------------------------------------------------

# 1,2)



# Rename repeated provider name (appended with UKPRN)
ofsted <- ofsted %>%
  group_by(provider_name) %>%
  mutate(
    count = n()>1,
    provider_name = ifelse(count,paste(provider_name,ukprn),provider_name),
    count = NULL
  ) %>%
  ungroup()

# 3)
# Find proportions of each provider group
provider_group_count <- ofsted %>%
  count(provider_group) %>%
  mutate(n_prop = n/sum(n))

# Find count/proportion for Independent specialist college
ISC_count <- provider_group_count %>%
  filter(provider_group == "Independent specialist college")

# 4)
# Attach scores to ofsted data
ofsted_evaluation <- left_join(ofsted,
                               ofsted_scores,
                               by = c("inspection_number" = "inspection_id"))

# Find proportions of providers that have ineffective safeguarding
safeguarding_count <- ofsted_evaluation %>%
  filter(inspection_category == "Is safeguarding effective") %>%
  count(score_description) %>%
  mutate(n_prop = n/sum(n))

# Find count/proportion of providers with ineffective safeguarding
ineffective_prop <- safeguarding_count %>%
  filter(score_description == "No") %>%
  select(n_prop)

# 5)
# Convert dates accordingly and add new day of week column
ofsted_evaluation <- ofsted_evaluation %>%
  mutate(
    inspection_date = ymd(inspection_date),
    inspection_wday = wday(inspection_date)
  )

# Assess what days inspections happen
inspection_wday_count <- count(ofsted_evaluation, inspection_wday)

# This table shows that the 3rd day (Wednesday) is the most common day to inspect
# There are no inspections on Mondays according to this data

inspection_wday_bar <- ofsted_evaluation %>%
  ggplot(aes(inspection_wday, fill = inspection_type)) +
  geom_bar(position = position_dodge())
# The plot suggests that a short inspection is more likely to be on Thursday
# rather than Wednesday which full inspections dominate

# Question 3 --------------------------------------------------------------

# 1,2)
# Create look-up table to discover proportion of outstanding, good,
# requires improvement and inadequate each provider group has for
# apprenticeships

app_score_props <- ofsted_evaluation %>%
  filter(inspection_category == "Apprenticeships") %>% 
  count(provider_group, score_description) %>%
  group_by(provider_group) %>%
  mutate(
    n_providers = sum(n),
    score_prop = n/n_providers,
    n = NULL,
    n_providers = NULL
  ) %>%
  ungroup() %>%
  pivot_wider(
    names_from = score_description, 
    values_from = score_prop, 
    values_fill = 0
  ) %>%
  janitor::clean_names() %>%
  select(provider_group, outstanding, good, requires_improvement, inadequate) %>%
  arrange(desc(outstanding))

# 3)
# Join the ofsted evaluation and starts data and then remove repeats of columns 
ofsted_starts <- inner_join(
    ofsted_evaluation,
    starts, 
    by = "ukprn",
    suffix = c("",".")
  ) %>%
  select(-contains("."))

# Count start instances for each score for Overall effectiveness
starts_effectiveness <- ofsted_starts %>%
  filter(inspection_category == "Overall effectiveness") %>%
  group_by(score) %>%
  summarise(starts = sum(starts))

# Count start instances for each score for Apprenticeships
starts_apprenticeships <- ofsted_starts %>%
  filter(inspection_category == "Apprenticeships") %>%
  group_by(score) %>%
  summarise(starts = sum(starts))

# The scores for overall effectiveness for providers appears to be more
# positively skewed than their scores for apprenticeships i.e they are doing
# better for apprenticeships than overall

# Questions 4 -------------------------------------------------------------

# 1)
# Include course details into data to get std_fwk_flag

ofsted_detailed <- inner_join(
  ofsted_starts,
  course_details, 
  by = "std_fwk_code"
)

# Create a risk factor column to show how at risk a provider is based off their
# inadequate scores. This uses the proportion of starts in the inadequate scores
# to determine the risk factor
starts_risk <- ofsted_detailed %>%
  filter(inspection_category == "Overall effectiveness") %>%
  group_by(delivery_region, std_fwk_flag, score_description) %>%
  summarise(n_starts = sum(starts), .groups = "drop_last") %>%
  mutate(risk_factor = 100*n_starts/sum(n_starts)) %>%
  ungroup() %>%
  filter(score_description == "Inadequate") %>%
  select(-score_description, -n_starts)

# 2)
# Find if providers have bad safeguarding and/or inadequate scores and
# include risk_category column

starts_inspections_risks <- ofsted_detailed %>%
  mutate(inadequate = score_description %in% c("Inadequate", "No")) %>%
  group_by(delivery_region, std_fwk_flag, risk_category = inspection_category, inadequate) %>%
  summarise(n_starts = sum(starts), .groups = "drop_last") %>%
  mutate(risk_factor = 100*n_starts/sum(n_starts)) %>%
  ungroup() %>%
  filter(inadequate) %>%
  select(-inadequate, -n_starts)


# 3)
# Name breakdowns we want
breakdowns <- c(
  "risk_category", "delivery_region", "std_fwk_code", "provider_type", 
  "provider_group", "route", "apps_level"
)

# Show risk broken down for each of our breakdowns now
starts_risks_breakdown <- ofsted_detailed %>%
  mutate(inadequate = score_description %in% c("Inadequate", "No")) %>%
  rename(risk_category = inspection_category) %>%
  group_by(!!!syms(breakdowns), inadequate) %>%
  summarise(n_starts = sum(starts), .groups = "drop_last") %>%
  mutate(risk_factor = 100*n_starts/sum(n_starts)) %>%
  ungroup() %>%
  filter(inadequate) %>%
  select(-inadequate, -n_starts)

# 4)
# Unsure
complete_risks_breakdown <- starts_risks_breakdown %>%
  complete()
