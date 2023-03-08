library(tidyverse)

# Q1 ----------------------------------------------------------------------

# 1.1

str_subset(fruit, "berry")

# 1.2 

str_subset(fruit, "[^ ]berry")

# 1.3 

str_subset(fruit, "^[abc].*[xyz]$")

# 1.4 

fruit |> 
  str_subset("[a-z]{10}") |> 
  str_extract("[a-z]{10,}")

# 1.5 

str_extract_all(
  sentences, 
  "\\b(?i)[aeiou](\\w*[aeiou])?\\b", 
  simplify = TRUE
)


# Q2 ----------------------------------------------------------------------

# 2.1.1

str_replace_all(fruit, "berry", "\033[31mberry\033[39m") |> 
  cat(sep = "\n")

# 2.1.2

str_replace_all(sentences, "(^\\w+)", "\033[31m\\1\033[39m") |> 
  cat(sep = "\n")

# 2.1.3

str_replace_all(sentences, "(^\\w+)", toupper)

# 2.1.4

lazy_sentence <- paste(
  "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
  "They served respectively as 41st & 43rd presidents of the USA."
)

str_replace_all(lazy_sentence, c(
  "Sr." = "Senior", 
  "Jr." = "Junior",
  "MA" = "Massachusetts",
  "CT" = "Connecticut"
))

# 2.2

messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "

tidy_sentence <- messy_sentence |> 
  str_squish() |> 
  str_to_sentence() |> 
  str_wrap(width = 10) |> 
  str_split("\n", simplify = TRUE) |> 
  str_pad(width = 10, side = "right") |> 
  str_c(collapse = "\n")

cat(tidy_sentence)

# Q3 ----------------------------------------------------------------------

# 3.1

# Check count of required characters, return FALSE if less than required
# count, else return TRUE
validate_password <- function(password){
  if (str_count(password, "[:alpha:]") < 8){return(FALSE)}
  if (str_count(password, "[:upper:]") < 2){return(FALSE)}
  if (str_count(password, "[:lower:]") < 2){return(FALSE)}
  if (str_count(password, "[:punct:]") < 1){return(FALSE)}
  if (str_count(password, "[:punct:]") < 1){return(FALSE)}
  if (str_detect(password, "[\\\\/]") == TRUE){return(FALSE)}
  return(TRUE)
}
  
validate_password("PIneapple!")

# 3.2

str_to_snake <- function(string){
  str_replace_all(string, "([:upper:])", "_\\1") |> 
  str_to_lower()
}

str_to_snake(c("thisIsStringOne", "anotherAwkwardString"))
  
# 3.3 

# Will come back to this later

# Q4 ----------------------------------------------------------------------

# 4.1

email_regex <- "^([^\\s@])(?#User name)+@[^\\s@](?#Domain name)+\\.[^\\s@](?#Domain)+$"

str_detect("ffion@gmail.com", email_regex)

# 4.2

email_regex <- regex("
  ^([^\\s@])+    # User name (no whitespace or @)
  @            # @ symbol
  [^\\s@]+       # Domain name
  \\.[^\\s@]+   # Domain 
  $", comments = TRUE)

# 4.3

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

date_regex <- glue::glue(
  "^(?i){day_lab}?",    # Could start with written day
  "{separator}?",       # Followed by a separator
  "{separator}?",       # Followed by another optional separator
  "{day_num}",          # Must include numeric day
  "{separator}",        # Followed by a separator
  "(?i){month_lab}",    # Followed by written month
  "{separator}?",       # Followed by optional separator
  "{year}?$"            # Followed by optional year
)

should_match     <- c("01.Jan.1991", "wed, 03 february 2002", "31-Jun")
should_not_match <- c("25122022", "2002, 03 Feb", "  Jan 1 2020")

str_detect(should_match, date_regex)
str_detect(should_not_match, date_regex)
