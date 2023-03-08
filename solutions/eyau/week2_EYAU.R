#---- Load libraries ----
library("tidyverse")
library("dplyr")
library("lubridate")

#---- Load CSV files ----
course_details <- read_csv("course_details.csv")
starts <- read_csv("starts.csv")
ofsted <- read_csv("ofsted.csv")
ofsted_scores <- read_csv("ofsted_scores.csv")

#---- 2.1 ----
# need to verify that each provider only has one recorded inspection
ofsted <- as.data.frame(ofsted)

verify_count <- ofsted |>
  # count the number of times a provider appears
  count(provider_name) |>
  # arrange that count in descending order
  arrange(desc(n))
# Health Education England has 2 entries under the same name but they have two different
# UKPRNs so that's fine

#---- 2.2 ----
dim(ofsted)  # 2053 rows of data
# look at how many unique ukprns there are, should be equal to the number of rows of data 
num_unique_ukprn <- length(unique(ofsted$ukprn)) 

#---- 2.3 ----
proportion_ISC <- ofsted |>
  # group by provider type
  group_by(provider_type) |>
  # count the number of times each provider appears
  summarise(n=n()) |>
  # calculate the percentage or proportion of each provider type
  mutate("proportion%" = n/sum(n)*100)

# The proportion of Independent specialist colleges is 5.62%

#---- 2.4 ----  
# left join on ofsted and ofsted_scores data by inspection_number and inspection_id
joined_ofsted <- left_join(ofsted,ofsted_scores, by=c("inspection_number"="inspection_id"))

joined_ofsted <- joined_ofsted |>
  # group the data by categoryand score
  group_by(inspection_category,score_description) |>
  # count for each combination
  summarise(n1=n()) |>
  # percentage for occurance for each combination
  mutate(percent=n1/sum(n1)*100)

# the percentage of providers with ineffective safeguarding is 0.685%

#---- 2.5 ----
# Make sure that the dates are formatted as dates
ofsted$inspection_date <- as_date(ofsted$inspection_date)
ofsted_dates <- ofsted |>
  # omit the any NA's
  na.omit() |>
  # Add new column for the days of the week
  mutate(day = wday(inspection_date, label= TRUE, abbr = FALSE)) |>
  # group data by the days of the week
  group_by(day)

# collect the days and count how many for each day
summarise(ofsted_dates,day_num = n())
# A large majority of the inspections take place on a Tuesday.

ofsted_dates2 <- ofsted_dates |>
  group_by(inspection_type, day) |>
  summarise(day_num = n(), .groups="drop")

# Full inspections mainly happen on a tuesday, short inspections mainly happen on a wednesday

#---- 3.1 ----
#Do the same thing in 2.4 but include the provider group
joined_ofsted <- left_join(ofsted,ofsted_scores, by=c("inspection_number"="inspection_id"))

joined_ofsted2 <- joined_ofsted |>
  # group the data by category and score
  group_by(inspection_category,score_description, provider_group) |>
  # filter by apprenticeships with the outstanding score
  filter(inspection_category == "Apprenticeships" & score_description == "Outstanding") |>
  # count for each combination
  summarise(n2=n()) |>
  # percentage for occurance for each combination
  mutate(percent=n2/sum(n2)*100)

# The provider group with the highest proportion of "outstanding" scores for apprenticeships is:
# Independent learning providers with 59%.
# i.e 59% of outstanding scores are from independent learning providers

#---- 3.2 ----
outstanding_appre <- joined_ofsted |>
  filter(inspection_category == "Apprenticeships") |>
  group_by(score_description, provider_group) |>
  summarise(n3=n()) |>
  # percentage for occurance for each combination
  mutate(percent=n3/sum(n3))

wider_outstanding_appre <- outstanding_appre |>
  # select the columns you want
  select(score_description, provider_group, percent) |>
  # pivot the table to a wider format with the column names as score description and values from the percent column
  pivot_wider(names_from = score_description, values_from = percent) |>
  janitor::clean_names()

#---- 3.3 ----
#starts, ofsted, oftsed_scores
joined_ofsted <- left_join(ofsted,ofsted_scores, by=c("inspection_number"="inspection_id"))
ofsted_starts <- left_join(joined_ofsted,starts, by = c("ukprn"))

starts_effect <- ofsted_starts |>
  # filter by category
  filter(inspection_category == "Overall effectiveness") |>
  # group it by the score
  group_by(score) |>
  # remove any NA values
  na.omit() 

# summary table with the data and the total number of starts for each score
summarise(starts_effect, total_starts = sum(starts))

#---- 3.4 ----
starts_apprenticeship <- ofsted_starts |>
  # filter by apprenticeships
  filter(inspection_category == "Apprenticeships") |>
  # group by score
  group_by(score) |>
  # remove any NA values
  na.omit()

# Summary table with the data and the total number of starts for each score for apprenticeships 
summarise(starts_apprenticeship, total_starts = sum(starts))

# There is a large majority of the providers with good overall effectiveness but the score for 
# apprenticeships are more between good and requires improvement.
          
#---- 4.1 ----

inad_join <- left_join(course_details,starts_effect, by=c("std_fwk_code"))
inad_join2 <- inad_join |>
  # group by region, std_fwk_flag and score description
  group_by(delivery_region, std_fwk_flag, score_description) |>
  # create a column with the number of occurrences for each combo
  summarise(num=n()) |>
  # percentage for occurance for each combination
  mutate(risk_factor=num/sum(num)*100) |>
  # filter to look at those with the score inadequate
  filter(score_description == "Inadequate")

# Not had enough time to fully tackle the next few questions so i just left them for now
