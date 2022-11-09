<!-- Please edit README.Rmd - not README.md -->

# Week 02.5: Data Wrangling Part 2

This week we’ll be building on what was covered last week, using `tidyr`
and `dplyr` to perform some more data wrangling, again using
`nycflights13` data.

Some of the exercises and examples are from [R for Data
Science](https://r4ds.had.co.nz/transform.html)

# Resources

-   See chapter 5 for adding columns with `mutate()` and aggregating
    with `group_by()` and `summarise()`
-   See chapter 12 for ‘pivoting’, dealing with missing values and
    columns which have multiple observations per cell.
-   See chapter 13 for joins.

# Exercises

1.  **Setup/Data import and library(s)**

        library(nycflights13)
        library(tidyverse)

2.  **Content**

    Today we will aim to cover and mainly focus on:

    `select()`,
    `mutate()`,`group_by()`,`summarise()`,`count()`,`rename()`
    `if_else()`, and`case_when()`

    If we have time / those who want can delve a bit deeper and look at

    `left_join()`, `pivot_wider()` and `pivot_longer()`

    We will answer the following questions using the **`nycflights13`**
    dataset.

3.  **`select()`**

    3.1 Brainstorm as many ways as possible to select `dep_time`,
    `dep_delay`, `arr_time`, and `arr_delay` from flights.

    3.2 What happens if you include the name of a variable multiple
    times in a `select()` call?

    3.3 What does the `any_of()` function do? Why might it be helpful in
    conjunction with this vector?

    `vars \<- c("year", "month", "day", "dep_delay", "arr_delay")`

    3.4 Does the result of running the following code surprise you? How
    do the select helpers deal with case by default? How can you change
    that default?

    `select(flights, contains("TIME"))`

4.  **`mutate()`**

    4.1 Create a flag for flights that departure was delayed using
    `mutate()` and `if_else()`.

    4.2 Calculate the speed of each plane in mph using `mutate()`.

    4.3 Long haul flight are defined as flights that took longer than
    seven hours. Create a flag for long haul flights. To answer this you
    could use `if_else()`, `mutate()` , `case_when()` or something else!

    4.4 If you have finished these you can look at [R for Data
    Science](https://r4ds.had.co.nz/transform.html) 5.5.2 Exercises  

5.  **`group_by()`**

    5.1 Use `group_by`, `summarise()` and `mean()` to calculate the mean
    travel time to each airport.

    *(Optional join on the actual names of the data airports using
    left\_join and the dataset `airports`)*

    5.2 Use either `group_by` and `summarise()` or `count()` to see how
    many flights were delayed in departure?

    5.3 Use either `group_by` and `summarise()` or `count()` to see how
    many flights where long haul?

    5.4 Add a new column to the data set that says how many flights
    departure was delayed for each airport? Which airport had the most
    delays in departure the data-set?

    5.5 Which airline had the most flights depart from JFK? (Many ways
    to do this)

    5.6 If you have finished these you can look at [R for Data
    Science](https://r4ds.had.co.nz/transform.html) 5.6.7 Exercises  

6.  **`left_join()`**

    6.1 Create a table that shows how many delays each airline had and
    which had the least delays. Join data to make sure we have the full
    name for the airline.

    6.2 Create a table that shows which airline had the most delays from
    an individual airport. We want the full name for both the airlines
    and the airports.

    6.3 Read section on joins [R for Data science section
    joins](https://r4ds.had.co.nz/relational-data.html?q=joins#understanding-joins)
    and try and answer the exercises.

7.  **`pivot_wider()` and `pivot_longer()`**

    7.1 Read the [R for Data Science section
    12](https://r4ds.had.co.nz/tidy-data.html?q=pivot#tidy-data)

    We will cover “Tidy data” further in a later session.
