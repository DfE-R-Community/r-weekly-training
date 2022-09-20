library(tidyverse)
library(lubridate)
library(janitor)
 
## 1. Read in the data
course_details = read_csv("course_details.csv")
starts = read_csv("starts.csv")
ofsted = read_csv("ofsted.csv")
ofsted_scores = read_csv("ofsted_scores.csv")


# ---- 2. Basic Wrangling ----


## 2.1. Making sure each provider only has one inspection recorded

### Compare the number of UKPRNs with the number of distinct UKPRNs to check they each only have one entry

length(ofsted$ukprn)
providercheck = ofsted %>% 
  summarise(count = n_distinct(ukprn))


## 2.2 Check the providers are uniquely named

### Compare the number of distinct UKPRNs with the number of distinct provider names

ofsted %>% 
  summarise(count = n_distinct(ukprn))
ofsted %>% 
  summarise(count = n_distinct(provider_name))

### Find the provider name which is associated with two different UKPRNs

notunique = ofsted %>% 
  group_by(provider_name) %>% 
  summarise(count = n_distinct(ukprn)) %>% 
  filter(count == 2)


## 2.3 Find proportion of providers that are Independent specialist colleges

ofsted %>% 
  filter(provider_type == "Independent specialist college") %>% 
  summarise(number = n()/providercheck) 

  

## 2.4 Look at Ineffective safeguarding

inspection_number = ofsted %>%
  count(inspection_number) %>%
  filter(n > 1) 

inspection_id = ofsted_scores %>%
  count(inspection_id) %>%
  filter(n > 1) 

### method 1 - rename variable and using left join

colnames(ofsted_scores) = c('inspection_number', 'inspection_category', 'score', 'score_description')
ofsted_join = left_join(ofsted, ofsted_scores, by = 'inspection_number')

### method 2 - tidy the data before combining

ofsted_scores2 = ofsted_scores %>% 
  unite(scores, score, score_description, sep = " - ")  %>% 
  pivot_wider(names_from = inspection_category, values_from = scores) %>%
  rename('inspection_number' = 'inspection_id', 'effective_safeguarding' = 'Is safeguarding effective')
tidy_join = left_join(ofsted, ofsted_scores2, by = 'inspection_number')

### find percentage that have ineffective safeguarding

ineffective = tidy_join %>% filter(effective_safeguarding == '0 - No') %>% 
  summarise(percentage_ineffective = 100* n() / nrow(tidy_join))



## 2.5 Change the date format 

tidy_join$inspection_date = ymd(tidy_join$inspection_date)

### Look at the patterns in day types

tidy_join_days = tidy_join %>% mutate(day = wday(inspection_date,  label = TRUE, abbr = FALSE))
tidy_join_days_patterns1 = tidy_join_days %>% 
  group_by(day) %>% summarise(n())
tidy_join_days_patterns2 = tidy_join_days %>% 
  group_by(day, inspection_type) %>% summarise(n()) %>% 
  pivot_wider(names_from = inspection_type, values_from = 'n()')

### inspections are mainly Monday- Wednesday with some falling on Thursday- Saturday
### Breaking it down by inspection type, full inspections take place Monday- Saturday, usually Monday - Wednesday, the most common day being Tuesday
### Short inspections are more rare and exclusively fall Monday - Thursday, most commonly Wednesday



# 3. --- Difficulty: Tricky ---

## 3.1. Create a table with proportions of score type for each provider type

tidy_join %>% 
  group_by(provider_group) %>% 
  summarise(Outstanding = sum(Apprenticeships == '1 - Outstanding', na.rm = TRUE)/sum(!is.na(Apprenticeships)),
                                                               Inadequate = sum(Apprenticeships == '4 - Inadequate', na.rm = TRUE)/sum(!is.na(Apprenticeships))) 

## 3.2 Create a look up table
proportions = tidy_join %>% 
  group_by(provider_group) %>% 
  summarise(Outstanding = sum(Apprenticeships == '1 - Outstanding', na.rm = TRUE)/sum(!is.na(Apprenticeships)),
                                                                   Good = sum(Apprenticeships == '2 - Good', na.rm = TRUE)/sum(!is.na(Apprenticeships)),
                                                                   Requires_improvement = sum(Apprenticeships == '3 - Requires improvement', na.rm = TRUE)/sum(!is.na(Apprenticeships)),
                                                                   Inadequate = sum(Apprenticeships == '4 - Inadequate', na.rm = TRUE)/sum(!is.na(Apprenticeships))) 

## 3.3 Find the total number of apprenticeship starts for each ofsted score for overall effectiveness 

triple_join = left_join(tidy_join, starts[,-c(2,3)], by = 'ukprn') %>% clean_names()
n_app_starts_eff = triple_join %>% 
  group_by(overall_effectiveness) %>% 
  summarise(effectiveness_n_starts = sum(starts, na.rm = TRUE)) %>% 
  rename(score = overall_effectiveness)

## 3.4 Find the total number of apprenticeship starts for each ofsted score for apprenticeships
n_app_starts_app = triple_join %>% 
  group_by(apprenticeships) %>% 
  summarise(apprenticeship_n_starts = sum(starts, na.rm = TRUE)) %>% rename(score = apprenticeships)

### Compare the performance in apprenticeships to performance overall
n_app_starts = left_join(n_app_starts_eff, n_app_starts_app, by = 'score')

### There are more overall outstanding or good starts than there are apprenticeship overall or good starts
### There are less overall requires improvement statrs than there are apprenticeship requires improvements starts
### You could say therefore that providers perform worse in apprenticeships, but there are less providers that have an apprenticeship score
### For more accurate comparison could look at proportions




# 4.--- Difficulty Challenging ---

## 4.1 Calculate risk factor for each delivery region and standard/framework flag

total_join = left_join(triple_join, course_details, by = 'std_fwk_code')
at_risk_1 = total_join %>% mutate(at_risk = (overall_effectiveness == '4 - Inadequate'))  %>% 
  group_by(delivery_region, std_fwk_flag) %>% 
  summarise(total = sum(starts), 
            at_risk = sum(at_risk == TRUE, na.rm = TRUE),
            risk_factor = 100* at_risk/ total)


## 4.2 Change the definition of at risk and add in risk category

at_risk_2 = total_join %>% 
  pivot_longer(c(overall_effectiveness, leadership_and_management, quality_of_education, behaviour_and_attitudes, personal_development, apprenticeships, effective_safeguarding), names_to = 'risk_category', values_to = 'score') %>%
  mutate(at_risk = case_when(score == '0 - No' ~ 'At Risk', score == '4 - Inadequate' ~ 'At Risk', score != '0 - No' ~ 'Not at Risk', score != '4 - Inadequate' ~ 'Not at Risk'))%>%
  group_by(delivery_region, std_fwk_flag, risk_category) %>%
  summarise(total = sum(starts), 
            at_risk = sum(at_risk == 'At Risk', na.rm = TRUE),
            risk_factor = 100* at_risk/ total)

 
## 4.3 Include more break downs

at_risk_3 = total_join %>% 
  pivot_longer(c(overall_effectiveness, leadership_and_management, quality_of_education, behaviour_and_attitudes, personal_development, apprenticeships, effective_safeguarding), names_to = 'risk_category', values_to = 'score') %>%
  mutate(at_risk = case_when(score == '0 - No' ~ 'At Risk', score == '4 - Inadequate' ~ 'At Risk', score != '0 - No' ~ 'Not at Risk', score != '4 - Inadequate' ~ 'Not at Risk'))%>%
  group_by(risk_category, delivery_region, std_fwk_flag,  provider_type, provider_group, route, apps_level) %>%
  summarise(total = sum(starts), 
            at_risk = sum(at_risk == 'At Risk', na.rm = TRUE),
            risk_factor = 100* at_risk/ total)

## 4.4 Turn explicit values implicit 

at_risk_4 = at_risk_3 %>% complete(risk_category, provider_type)
