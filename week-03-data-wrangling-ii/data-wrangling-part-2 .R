library(nycflights13)
library(tidyverse)


#3.1 Brainstorm as many ways as possible to select `dep_time`,
#`dep_delay`, `arr_time`, and `arr_delay` from flights.

flights %>% select(dep_time,dep_delay,arr_time,arr_delay)

flights %>%  select(1,2) 

# or 

flights %>% select(c(1:2))

#3.2 What happens if you include the name of a variable multiple
#times in a `select()` call?

flights %>%  select(dest,dest)
  
#3.3 What does the `any_of()` function do? Why might it be helpful in
#conjunction with this vector?
  
vars <- c("year", "month", "day", "dep_delay", "arr_delay")

flights %>% select(any_of(vars))

#3.4 Does the result of running the following code surprise you? How
#do the select helpers deal with case by default? How can you change
#that default?
  
flights %>% select(contains("TIME"))

flights %>% select(contains("time"))

# 4. `mutate()`
#   
#   4.1 Create a flag for flights that departure was delayed using
# `mutate()` and `if_else()`.

View(flights %>% mutate(depature_delay = if_else(dep_delay < 0, 1, 0)))

flights %>%  filter(is.na(dep_delay))

# 
# 4.2 Calculate the speed of each plane in mph using `mutate()`.

flights %>%  mutate(speed_mph =((distance / air_time) * 60))


# 
# 4.3 Long haul flight are defined as flights that took longer than
# seven hours. Create a flag for long haul flights. To answer this you
# could use `if_else()`, several `mutate()` s or `case_when()` or
# something else!

long_haul_1 <- flights %>%  mutate(travel_time_hrs = air_time/60,
                    long_haul_flight =  case_when(travel_time_hrs > 7 ~ 1,
                                                  TRUE ~ 0))


long_haul_2 <-flights %>%  mutate(travel_time_hrs = air_time/60,
                    long_haul_flight =  if_else(travel_time_hrs > 7, 1,0))

long_haul_1 %>%  count(long_haul_flight)

long_haul_2 %>%  count(long_haul_flight)



#   
#   4.4 If you have finished these you can look at [R for Data
#                                                   Science](https://r4ds.had.co.nz/transform.html) 5.5.2 Exercises\
# 
# 5.  **`group_by()`**
#   
#   5.1 Use `group_by`, `summarise()` and `mean()` to calculate the mean
# travel time to each airport.

flights %>%  group_by(dest) %>% summarise(mean_trvl_time = mean(air_time, na.rm =T) )

# 
# *(Optional join on the actual names of the data airports using
#   left_join and the data-set `airports`)*
#   

#   5.2 Use either `group_by` and `summarise()` or `count()` to see how
# many flights where delayed?

flight_delays <- flights %>%  mutate(flight_delayed = if_else(dep_delay > 0,1,0)) %>% count(flight_delayed)


#   
#   5.3 Use either `group_by` and `summarise()` or `count()` to see how
# many flights where long haul?


long_haul_2 <-flights %>%  mutate(travel_time_hrs = air_time/60,
                                  long_haul_flight =  if_else(travel_time_hrs > 7, 1,0))

long_haul_2 %>%  count(long_haul_flight)

#   
#   5.4 Add a new column to the data set that says how many flights departure was
# delayed for each airport? Which airport had the most delays in departure the
# data-set?

flights %>% group_by(origin) %>%   mutate(flight_delayed_airport = if_else(dep_delay > 0,1,0)) %>% count(flight_delayed_airport) %>%  filter(flight_delayed_airport  == 1)

#   
#   5.5 Which airline had the most flights depart from JFK? (Many ways
#                                                            to do this)
flights %>% filter(!is.na(air_time) & origin == "JFK") %>%  group_by(carrier) %>%  count()


# 
# 5.6 If you have finished these you can look at [R for Data
#                                                 Science](https://r4ds.had.co.nz/transform.html) 5.6.7 Exercises\
# 
# 6.  **`left_join()`**
#   
#   6.1 Create a table that shows how many delays each airline had the
# least delays and make sure we have the full name for the airline.

flights %>% 
  mutate(flight_delayed = if_else(dep_delay > 0,1,0)) %>%
  left_join(airlines, by = "carrier") %>%
  filter(flight_delayed  == 1) %>% 
  count(flight_delayed,name)


# 
# 6.2 Create a table that shows which airline had the most delays from
# an individual airport. We want the full name for both the airlines
# and the airports.

flights %>% 
  mutate(flight_delayed = if_else(dep_delay > 0,1,0)) %>%
  left_join(airlines, by = "carrier") %>%
  left_join(airports, by = c("dest" = "faa")) %>%
  filter(flight_delayed  == 1) %>% 
  count(flight_delayed,name.y)

# 
# 6.3 Read section on joins [R for Data science section joins]
# (<https://r4ds.had.co.nz/relational-data.html?q=joins#understanding-joins>)
#   and try and answer the exercises.
#   
#   7.  **\`pivot_wider() and pivot_longer()**
#     
#     7.1 Read the [R for Data Science section
#                   12](https://r4ds.had.co.nz/tidy-data.html?q=pivot#tidy-data)
#                       
#                       We will cover "Tidy data" further in a later session.
#                       

# #flights_edit <-flights %>% mutate( long_haul = if_else(air_time > (60*7),1,0))
# 
# 
# #flights_edit %>% group_by(long_haul) %>%  summarise(count = n()) 
# 
# 
# 
# #popular_dests <- flights %>% 
#  # group_by(dest) %>% 
#   #filter(n() > 365)
# 
# 
#  jfk_most_flights <- flights %>% 
#   group_by(origin,carrier) %>% 
#   summarise(count_flights = n()) %>%
#   filter(origin == "JFK")
# 
#  
#  flight_delay <- flights %>% mutate(total_delay = dep_delay + arr_delay)
#  
#  flight_delay %>% mutate(refund = if_else(total_delay < -30, 1, 0))
#  
#  flight_delay %>% mutate(refund_groups = case_when (total_delay < -60 ~ 1,
#                                                     total_delay < -30 ~ 2,
#                                                     total_delay < 0 ~ 3,
#                                                     TRUE ~ 0 ,)) %>% count(refund_groups)
# 
#  
#  flights %>% group_by(dest) %>%  summarise(delayed_flights = sum(if_else(dep_delay < 0,1,0), na.rm = T))
#  
#  
#  
#  flights %>%
#    left_join(airports %>% select(faa,name), by = c("dest" = "faa")) %>%
#    rename(dest_airport = name)
# a <- flights %>%
#   left_join(airports %>% select(faa,name), by = c("dest" = "faa")) %>%
#   rename(dest_airport = name) 
