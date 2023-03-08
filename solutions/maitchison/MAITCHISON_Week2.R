# ---- Question 1 ---- 

# Setup/Data Import

library(tidyverse) # Load Required Package

course_details <- read_csv("course_details.csv") # Load Required Data
starts         <- read_csv("starts.csv")
ofsted         <- read_csv("ofsted.csv")
ofsted_scores  <- read_csv("ofsted_scores.csv")

# ---- Question 2 ----

# Question 2.1 - Using count, verify each provider has only one recorded inspection

# To do this, we consider the ukprn column to be the primary key, therefore each 
# ukprn value should only appear once

ofsted |> 
  count(ukprn) |> # Count ukprn numbers
  filter(n > 1) # Filter ukprn numbers which appear more than once

# This code produces a tibble with no rows, therefore no ukprn number appears more
# than once

#Question 2.2 - Use the ukprn numbers to see if providers are uniquely names

ofsted |> 
 count(provider_name) |>  # Count the number of provider names
 filter(n > 1) # Filter out provider names which appear more than once

# The following code produces a code with 2 rows, each with provider name 
# 'Health Education England'. Note these are different establishments due to the
# unique ukprn number. We conclude that the providers are not uniquely named

#Question 2.3 - What proportion of providers are 'Independent specialist colleges'?

# Here we created an auxiliary column 'count_ILP', with entry '1' if it's an'Independent
#  specialist college', and '0' otherwise. We then sum this auxiliary column and divide
# by total number of entries  by using 'n()'

ofsted2.3 <- ofsted |> 
  mutate(count_ILP = ifelse(provider_type == "Independent specialist college", 1, 0)) |>
  summarise(sum(count_ILP)/n())
 
#Question 2.4 - Combine 'ofsted' and 'ofsted_scores' using 'left_join' and find percentage
# of providers with ineffective safeguarding.

#left join by using 'inspection_number' and 'inspection_id' column
# Since the word 'No' is only used in the score description column when safeguarding 
# is not effective, create the auxiliary column which contains '1' when score-description is
# 'No' and '0' otherwise.
# Sum this column and divide by total number of providers

ofsted2.4 <- ofsted |>
  left_join(ofsted_scores, by = c("inspection_number" = "inspection_id")) |> # Join tables
  mutate(count_no = ifelse(score_description == "No", 1, 0)) |> # Create auxiliary column to ineffective safeguarding
  summarise(sum(count_no, na.rm = TRUE)/n_distinct(ukprn)) #  Find percentage

#Question2.5 - Create a column giving the day of week of inspection, and from this
# infer if there is a pattern as to how ofsted chooses the day of inspection, and whether 
# this changes based on inspection type?

library(lubridate) # Load package

ofsted2.5a <- ofsted |>
  mutate(inspection_date = ymd(inspection_date), # Convert column to date format
         DoW = weekdays(inspection_date)) |> # Create weekday column using new date format
  filter(!(inspection_number == "NULL")) |> # Filter out entries which no recorded inspection
  group_by(DoW) |> # Group by days of the week
  summarise(n()) # Count number of entries for each day

#It can be seen that an inspection is most likely to occur on a Tuesday

# To comment on if the above conclusion changes based on inspection type, repeat above
# but group by both day of the week and inspection type

ofsted2.5b <- ofsted |>
  mutate(inspection_date = ymd(inspection_date),
         DoW = weekdays(inspection_date)) |>
  filter(!(inspection_number == "NULL")) |>
  group_by(DoW, inspection_type) |> # Repeat by DoW and inspection_type
  summarise(n())

# We conclude if a full inspection is most likely to occur on Tuesday, but a short 
# inspection conversion is most likely to occur on Wednesday

# ---- Question 3 ----

# Question 3.1 - Find the provider with the highest proportion of outstanding
# score for apprenticeships. Do this also for the inadequate score for provider type

# Note, I have completed this questions by creating two separate tables, not sure if this was intended
# to be included in a single table?

ofsted3.1a <- ofsted |>
  left_join(ofsted_scores, by = c("inspection_number" = "inspection_id")) |> # Join tables
  filter(inspection_category == "Apprenticeships") |> # Only show apprenticeships in inspection_category
  mutate(Outstanding_count = ifelse(score == 1, 1, 0)) |> # Auxiliary column to record if result is outstanding
  group_by(provider_group) |> # Group together provider groups
  summarise(Oustanding = sum(Outstanding_count, na.rm = TRUE)/n()) # Sum the number of outstanding results and divide by number in each group respectively
  
# Repeat above code but count inadequate scores and grouping by provider type
ofsted3.1b <- ofsted |> 
  left_join(ofsted_scores, by = c("inspection_number" = "inspection_id")) |>
  filter(inspection_category == "Apprenticeships") |>
  mutate(Outstanding_count = ifelse(score == 4, 1, 0)) |> # 4 represents inadequate score
  group_by(provider_type) |> # Group by provider type
  summarise(Inadequate = sum(Outstanding_count, na.rm = TRUE)/n())

# Question 3.2 - create the lookup table as shown in the exercise sheet

# I wasn't sure if a lookup table is a explicit type of object in R, so I tried to replicate the 
# exercise sheet by creating a normal table

#Repeat code from above, inserting additional columns in mutate and summarise to account for all score types
ofsted3.2 <- ofsted |>
  left_join(ofsted_scores, by = c("inspection_number" = "inspection_id")) |>
  filter(inspection_category == "Apprenticeships") |>
  mutate(Outstanding_count = ifelse(score == 1, 1, 0), # Outstanding score, identified by '1'
         Good_count = ifelse(score == 2, 1, 0), # Good score, identified by '2'
         improv_count = ifelse(score == 3, 1, 0),# Improvement Required, identified by '3'
         inadequate_count = ifelse(score == 4, 1, 0)) |> # Inadequate score, identified by '4'
  group_by(provider_group) |>
  summarise(Oustanding = sum(Outstanding_count, na.rm = TRUE)/n(), # Percentage value for Outstanding score
            Good = sum(Good_count, na.rm = TRUE)/n(), # Percentage value for Good score
            Requires_improvement = sum(improv_count, na.rm = TRUE)/n(), # Percentage value for Requires Improvement score
            Inadequate = sum(inadequate_count, na.rm = TRUE)/n()) # Percentage value for Inadequate score


# Question 3.3 - Using 'starts', 'ofsted' and 'ofsted_scores', work out the number of 
# apprenticeships start per overall effectiveness ofsted score

ofsted3.3 <- ofsted |>
  left_join(ofsted_scores, by = c("inspection_number" = "inspection_id")) |> # Join 'oftsed_score' table
  left_join(starts, by = c("ukprn" = "ukprn")) |> # Joint 'starts' table
  filter(inspection_category == "Overall effectiveness") |> # Filter to leave only rows relating to 'Overall effectiveness' 
  group_by(score_description) |> # Group by 'score_descrition'
  summarise(no_of_starts_by_overall_effectiveness = sum(starts, na.rm = TRUE)) # Sum the number of starts


#Question 3.4 - Find the number of apprenticeship starts per apprenticeship ofted score,
# and draw conclusions for how providers perform in apprenticeships to overall

# Repeat above code but selecting the inspection category to include only 'Apprenticeships'
ofsted3.4 <- ofsted |>
  left_join(ofsted_scores, by = c("inspection_number" = "inspection_id")) |>
  left_join(starts, by = c("ukprn" = "ukprn")) |>
  filter(inspection_category == "Apprenticeships") |> # Set 'inspection_category' to filter 'Apprenticeships'
  group_by(score_description) |>
  summarise(no_of_starts_by_apprenticeship_score = sum(starts, na.rm = TRUE)) |>
  left_join(ofsted3.3) # Join previous table onto this one

# From the 'oftsed14', you can see a direct correlation between the number of apprenticeship
# starts based on how a provider performs overall, and how they perform in apprenticeships


