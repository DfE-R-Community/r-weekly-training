library(tidyverse)
library(lubridate)

# == 02. Load data =============================================================
course_details <- read_csv("course_details.csv")
starts         <- read_csv("starts.csv")
ofsted         <- read_csv("ofsted.csv")
ofsted_scores  <- read_csv("ofsted_scores.csv")



#-------Exercise 2)1---------

#using count to count how many of each provider there are
#arranging in descending order as any above 1 would appear first
#NOTE: One repeated twice but had two different ukprn so
#I classed them as different places
ofsted_count <- as_tibble(ofsted) %>%
  count (provider_name) %>%
  arrange(desc(n))

#--------- Exercise 2)2--------

#Similar to 2.1 I used count to total up each ukprn
#putting them in descending would have pointed out if any 
#were not unique
ofsted_ukprn <- as_tibble(ofsted) %>%
  count (ukprn) %>%
  arrange(desc(n))

#--------- Exercise 2)3--------

#I first counted every provider group that was an Independent specialist colleges
#using the column indicated as TRUE (how many I S colleges) and the total provider
#groups (adding each cell for TRUE & FALSE) to get a proportion
ofsted_Inde <- as_tibble(ofsted) %>%
  count (provider_group == "Independent specialist colleges")

x <- ofsted_Inde [2,2] / (ofsted_Inde [2,2] + ofsted_Inde [1,2])
print(x)

#-------- Exercise 2)4---------
#by renaming a column name so each table had one set of values in connection 
#I combined the columns using left join. by counting the ineffective safeguarding's
#I found the proportion by using the cell values and multiplying by 100 to get the
#percentage

ofsted_2 <- ofsted%>%
  rename(inspection_id = inspection_number)

combined_ofsted <- left_join(ofsted_2, ofsted_scores, by="inspection_id" ) %>%
 count(inspection_category == "Is safeguarding effective", 
  score_description == "No")


percentage_safeG <- (combined_ofsted [3,3] / (combined_ofsted [2,3] + combined_ofsted [3,3]) * 100)
 print(paste(percentage_safeG, "%"))
  

#------ Exercise 2)5---------

#replacing the inspection date into date format
#created a new column which uses wday to find the day of week the date
#presented. Grouping day of week and inspection type allows to see which inspections
#are on what day and counting them.
 #It is mainly on a Tuesday and is mostly a full inspection 
 
 
ofsted$inspection_date <- as_date(ofsted$inspection_date)
 
ofsted_week <- ofsted %>%
   mutate (day_of_week = wday(inspection_date, label= TRUE, abbr=FALSE)) %>%
  group_by(day_of_week, inspection_type)%>%
  summarise(count = n())
  
#count(day_of_week == "Monday", day_of_week == "Tuesday", day_of_week == "Wednesday",
# day_of_week == "Thursday", day_of_week == "Friday" )


#----- Exercise 3)1----------

#combined both data sets together
#using score description and provider name, for each different combination of both
#counted how many there are of each. then found the proportion of each
combined_ofsted_2 <- left_join(ofsted_2, ofsted_scores, by="inspection_id" )

combined_ofsted_app <- combined_ofsted_2%>%
  group_by(score_description, provider_group)%>%
  summarise(count = n())%>%
mutate(Proportion_freq_3_1 = count / sum(count)) %>%
  ungroup()
combined_ofsted_app <- as_tibble(combined_ofsted_app)


#Independent learning provider has the highest  proportion of outstanding scores

#------- Exercise 3)2--------
#NOTE: I could not figure out how to only have the proportion values without count values
#using pivot wider it has become clearer to see. Each column for proportion, should
#sum to 1.

combined_ofsted_app_3_2 <- combined_ofsted_app %>%
  group_by(score_description, provider_group, Proportion_freq_3_1 )%>%
  pivot_wider(names_from = score_description, values_from = c(Proportion_freq_3_1,
              count),
              values_fill = 0)



#------3)3---------

#combining combined_ofsted_2 (ofsted & ofsted_scores combined) to starts using
#the ukprn. group by necessary columns including inspection category for overall
#effectiveness. Sums for each different combination
combined_ofsted_scores_starts_3_3 <- left_join(combined_ofsted_2, starts, by="ukprn" )%>%
  group_by(starts, score, inspection_category == "Overall effectiveness")%>%
  summarise(count = n())


#------3)4----------
#NOTE: I am not sure this is the best approach, given it a go.
#Similar to 3.3 I have carried out the same process but only counted for inspection
#category "apprenticeships". 

combined_ofsted_scores_starts_3_4 <- left_join(combined_ofsted_2, starts, by="ukprn" )%>%
  group_by(starts, score, inspection_category == "Apprenticeships")%>%
  summarise(count = n())


#For Apprenticeships
#There are more scenarios of lower starts than higher starts especially when the
#score is 2. The same pattern is followed for the Overall effectiveness.
#I have concluded the performance is very similar between both categories.

  

