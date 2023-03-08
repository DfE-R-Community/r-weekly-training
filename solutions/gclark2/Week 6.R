# Week 6 training 

# Load packages
library(tidyverse)
library(glue)
library(rex)

# --- 1.1 ---
# Find fruits containing the word 'berry'
fruit |>
  str_subset("berry")

# --- 1.2 --- 
# Find fruits where berry is inside the word only
fruit |> 
  str_subset("[^\\s]berry") 

# --- 1.3 ---
# Find fruits that start with a, b or c and end with x, y or z
# Both work since they are all one word but the first would rule out any fruits 
# that are two words
fruit |>
  str_subset("^[abc][A-Za-z]*[xyz]$") 
fruit |>
  str_subset("^[abc]\\w*[xyz]$") 

# --- 1.4 --- 
# Find sentences that have a word with 10 or more characters then extract those 
# words
sentences |>
  str_subset("\\w{10,}") |>
  str_extract("\\w{10}" )

# --- 1.5 ---
# Find all words that start and end with vowels including single letter words 
sentences |>
  str_extract_all("\\b[aeiou]\\b|\\b[aeiou][A-Za-z]*[aeiou]\\b")

# --- 2.1.1 ---
# Replace the word berry with "\033[31mberry\033[39m" and then concat
fruit |>
  str_replace_all("berry", "\033[31mberry\033[39m") |> 
  cat(sep = '\n')

# --- 2.1.2 ---
# Test the hint given 
str_replace_all("string", "(i)", "!\\1!")

# Replace the first word in every sentence with the first word surround by 
# "\033[31m \033[39m"
# Then concat to highlight every first word in red
sentences |> 
  str_replace_all("^(\\w+)", "\033[31m\\1\033[39m") |> 
  cat(sep = "\n")

# --- 2.1.3 --- 
# Convert every first word to upper case
sentences |> 
  str_replace_all("^(\\w+)", str_to_upper)

# --- 2.1.4 --- 
# Create character vectors
Abbreviations <- c("Sr." = "Senior", "MA." = "Massachusetts", "Jr." = "junior", 
                   "CT." = "Connecticut")

lazy_sentence <- paste(
  "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
  "They served respectively as 41st & 43rd presidents of the USA."
)

# Replace abbreviations in the lazy sentence
str_replace_all(lazy_sentence, Abbreviations)

# --- 2.2 --- 
# Create sentence
messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "

# Tidy the sentence
tidy_sentence <- messy_sentence |>
  str_squish() |>  
  str_to_sentence() |>
  str_wrap(width = 10) |>
  str_split('\\n', simplify = TRUE) |>
  str_pad(10, side = "both") |>
  str_c("\n") |>
  cat("\n")

# --- 3.1 --- 
# Create function that checks conditions of password
validate_password <- function(password) { 
  if(str_length(password) > 10 &&
     str_count(password, "[A-Z]") >= 2 &&
     str_count(password, "[a-z]") >= 2 &&
     str_count(password, "[:punct:]") >= 1 &&
     str_count(password, "/") == 0 &&
     str_count(password, "\\\\") == 0) {
    TRUE
  } else {
    FALSE
  }
}

# Tests 
validate_password('Grace_Clark')  
validate_password('Grace\\Clark')

# --- 3.2 --- 
# Create function to change camelCase to snake_case

str_to_snake <- function(string) {
  string |>
  str_replace_all("([A-Z])", "_\\1") |>
  str_replace_all("^(\\w+)", str_to_lower)
  
}

# Test
str_to_snake(c("thisIsStringOne", "anotherAwkwardString"))

# --- 4.1 ---
# Add a comment to regular expression matching email addresses
email_regex_comment <- 
  "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$(?#this matches email addresses)"

# --- 4.2 ---
# Add a comment to the same regex using the regex(comments = TRUE) style
email_regex_comment <- regex("
                            ^([^\\s@])+ # Ensure no starting with empty space 
                            @[^\\s@]+ # Ensure no having whitespace or another @ an @
                            \\. # Ensure there is a full stop
                            [^\\s@]+$ # Ensure no ending in whitespace or an @
                            ", comments = TRUE)


# --- 4.3 --- 
# Read regex's from question
# Helpers: 
# 1. Join inputs together using "|"
# 2. Surround inputs with parentheses
collapse  <- function(...) paste(..., sep = "|", collapse = "|")
group     <- function(...) paste0("(", ..., ")")

# Regexes for years, month numbers and day numbers
year      <- group("\\d{4}")
month_num <- paste0("(0?", group(collapse(1:12)), ")") # Possible leading zeros 
day_num   <- paste0("(0?", group(collapse(1:31)), ")") # Possible leading zeros

# Regex for full and abbreviated month labels
month_lab <- group(collapse(
  "Jan(uary)?", "Feb(ruary)?",    "Mar(ch)?",    "Apr(il)?",         
  "May",     "Jun(e)?",     "Jul(y)?",   "Aug(ust)?", 
  "Sep(tember)?",  "Oct(ober)?", "Nov(ember)?", "Dec(ember)?"
))

# Regex for full and abbreviated day labels
day_lab   <- group(collapse(
  "Sun(day)?", "Mon(day)?",  "Tue(sday)?", "Wed(nesday)?", 
  "Thu(rsday)?", "Fri(day)?", "Sat(urday)?"
))

# Regex for allowed separators
separator <- "[\\s.,-/]"


# -- Checking your solution ------------------------------------------------
# Any solution which matches/doesn't match the following strings will be 
# accepted:
should_match     <- c("01.Jan.1991", "wed, 03 february 2002", "31-Jun")
should_not_match <- c("25122022", "2002, 03 Feb", "  Jan 1 2020")

# Create a regex that checks dates
reg_expression <- glue(
  "^(?i){day_lab}?", # Could start with a date label with upper or lower case
  "{separator}?", # Could then have separator
  "{separator}?", # Could have another separator
  "{day_num}", # Then has the day number
  "{separator}", # Then has a separator
  "(?i){month_lab}", # Then has a month label with upper or lower case
  "{separator}?", # Could then have a separator
  "{year}?$" # Could end in the year
)

# Tests
str_detect(should_match, reg_expression)  
str_detect(should_not_match, reg_expression)  
  

