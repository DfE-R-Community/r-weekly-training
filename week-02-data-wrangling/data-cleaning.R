# == 0. Load packages ==========================================================

library(tidyverse)



# == 1. Define URLs ============================================================

apps_starts_url <- paste0(
  "https://content.explore-education-statistics.service.gov.uk/",
  "api/releases/a90f4fdf-7b32-43c0-ab4e-3d7efd4fc0df/files/",
  "d15a0301-7e41-4c20-0c2c-08d9a8d450d5"
)



# See https://www.gov.uk/government/statistics/further-education-and-skills-inspections-and-outcomes-as-at-31-august-2021
# Note that inspection dashes mean 'not judged'
ofsted_url <- paste0(
  # "https://assets.publishing.service.gov.uk/",
  # "government/uploads/system/uploads/attachment_data/file/1035180/",
  # "Further_education_and_skills_-_inspection_data_as_at_31_August_2021.csv"
  
  "https://assets.publishing.service.gov.uk/",
  "government/uploads/system/uploads/attachment_data/file/1040051/",
  "Further_education_and_skills_-_inspection_data_as_at_31_August_2021.csv"
)



# == 2. Read the data ==========================================================

## Starts data ----
# 1. Read the .zip file to a temporary location
# 2. Read the .csv file from the zipped archive
# 3. Filter the dataset down to the latest year
apps_starts_file   <- curl::curl_download(apps_starts_url, tempfile(fileext = ".zip"))
apps_starts_raw    <- read_csv(lazy = FALSE, apps_starts_file)
apps_starts_latest <- filter(apps_starts_raw, year == max(year))



## Ofsted data ----
ofsted_raw <- read_csv(ofsted_url, lazy = FALSE)



# == 3. Data cleaning ==========================================================

## `ofsted` ---- 
ofsted_clean <- ofsted_raw %>% 
  
  # 1. re-format column names
  janitor::clean_names() %>% 
  
  # 2. select/rename relevant columns
  select(
    ukprn = provider_ukprn,
    provider_name,
    provider_type,
    provider_group,
    inspection_number,
    inspection_type,
    first_day_of_inspection,
    last_day_of_inspection,
    score_is_safeguarding_effective = is_safeguarding_effective,
    score_overall_effectiveness     = overall_effectiveness,
    score_quality_of_education      = quality_of_education,
    score_behaviour_and_attitudes   = behaviour_and_attitudes,
    score_personal_development      = personal_development,
    score_leadership_and_management = leadership_and_management,
    score_apprenticeships           = apprenticeships,
    -providers_with_an_apprenticeship_judgement
  ) %>% 
  
  # 3. re-format date and score columns
  mutate(
    
    across(matches("^(first|last)_day"), ~lubridate::dmy(ifelse(. == "NULL", NA_character_, .))),
    inspection_length_in_days = as.numeric(last_day_of_inspection - first_day_of_inspection, units = "days"),
    
    score_is_safeguarding_effective = case_when(
      score_is_safeguarding_effective == "Yes" ~ 1,
      score_is_safeguarding_effective == "No" ~ 0,
      TRUE ~ NA_real_
    ),
    
    across(starts_with("score"), ~suppressWarnings(as.numeric(.)))
  
  ) %>% 
  
  # 4. transform inspection date back to (re-formatted) character
  select(-last_day_of_inspection) %>% 
  rename(inspection_date = first_day_of_inspection) %>% 
  mutate(inspection_date = format(inspection_date, "%Y.%m.%d")) 
  
ofsted <- ofsted_clean %>% 
  select(-starts_with("score"))

ofsted_scores <- ofsted_clean %>% 
  
  # Select only id cols and cols giving scores
  select(inspection_number, starts_with("score")) %>% 

  # Pivot the data into long format
  pivot_longer(
    starts_with("score"), 
    names_to = "inspection_category", 
    values_to = "score", 
    names_prefix = "score_"
  ) %>% 
  
  # Make `inspection_category` a bit nicer
  mutate(
    inspection_category = inspection_category %>% 
      str_replace_all("_", " ") %>% 
      str_to_sentence()
  ) %>% 
  
  # Add a score description based on google (https://www.gov.uk/guidance/glossary-of-terms-ofsted-statistics#FESglossary)
  mutate(score_description = case_when(
    inspection_category == "Is safeguarding effective" & score == 0 ~ "No",
    inspection_category == "Is safeguarding effective" & score == 1 ~ "Yes",
    score == 1 ~ "Outstanding",
    score == 2 ~ "Good",
    score == 3 ~ "Requires improvement",
    score == 4 ~ "Inadequate"
  ), .after = score) %>% 
  
  # Remove useless rows
  filter(!is.na(score)) %>% 
  
  # Throw a curveball
  rename(inspection_id = inspection_number)



## `starts` ----
starts <- apps_starts_raw %>% 
  group_by(ukprn, provider_name, provider_type, delivery_region, std_fwk_code) %>% 
  summarise(starts = sum(starts), .groups = "drop")



## `course_details` ----
course_details <- apps_starts_latest %>% 
  distinct(across(matches(c(
    "^(std?|fwk|std?_fwk)_(code|flag|name)$", 
    "^apps", "^ssa", "^stem$", "^route$", "^apps_degree$"
  )))) %>% 
  relocate(matches("^(std?|fwk|std?_fwk)_(code|flag|name)$"))




# == 4. Write data =============================================================

mget(c("ofsted", "ofsted_scores", "starts", "course_details")) %>% 
  set_names(~glue::glue("week-02-data-wrangling/{.}.csv")) %>% 
  iwalk(write_csv)
