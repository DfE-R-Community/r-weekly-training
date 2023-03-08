library(stringr)

# ---- 1.1 ---------------------------------------------------------------------
# fruits containing the word "berry"
str_subset(fruit, "berry")

# ---- 1.2 ---------------------------------------------------------------------
# Fruits where the word "berry" standing alone
str_subset(fruit, "[^\\s] berry")

# ---- 1.3 ---------------------------------------------------------------------
# find fruit that start with a, b or c and end with x,y or z
fruit |>
  str_subset("^[abc]\\w*[xyz]$")
# ^[abc] start with abc
# \\w matches any word character
# * 0 or more pattern matches
# [xyz]$ ends with xyz

# ---- 1.4 ---------------------------------------------------------------------
fruit |>
  # find words that have 10 characters or more
  str_subset("\\w{10}") |>
  # extract those words with 10 characters
  str_extract("\\w{10}")

# ---- 1.5 ---------------------------------------------------------------------
#head(sentences)
# \\b is boundary of words  -  start or end of word
# need to find all of the words that start and end with a vowel
sentences |>
  str_subset("\\b[aeiou]\\w*[aeiou]\\b") |>
  str_extract_all("\\b[aeiou]\\w*[aeiou]\\b")


# ---- 2.1.1 -------------------------------------------------------------------
fruit |>
  str_replace_all("berry", "\033[31mberry\033[39m") |>
  cat(sep = "\n")

# ---- 2.1.2 -------------------------------------------------------------------
sentences |>
  str_replace_all("(i)", "!\\1!") |>
  head()
head(sentences)
# testing the hint: puts ! around all of the i's

sentences |>
  # replace the first word of every sentence, with the red version of it
  str_replace_all("^(\\w+)","\033[31m\\1\033[39m") |>
  cat(sep = "\n") #|>
  #head()

# ---- 2.1.3 -------------------------------------------------------------------
sentences |>
  # change all of the first words to be upper case
  str_replace_all("^(\\w+)", toupper)
  
# ---- 2.1.4 -------------------------------------------------------------------
lazy_sentence <- paste(
  "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
  "They served respectively as 41st & 43rd presidents of the USA."
)
lazy_sentence |>
  str_replace_all("Sr.", "Senior") |>
  str_replace_all("Jr.", "Junior") |>
  str_replace_all("MA.", "Massachusetts") |>
  str_replace_all("&", "and") |>
  str_replace_all("CT.", "Connecticut.") |>
  str_replace_all("USA", "United States of America")

# ---- 2.2 ---------------------------------------------------------------------
messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "
messy_sentence |>
  # remove all the unnecessary white space
  str_squish() |>
  # convert to sentence-case
  str_to_sentence() |>
  # wraps the sentence to be displayed in lines of 10 or less characters
  str_wrap(10) |>
  # break the string up to give a character vector where breaks occur wherever there is a linebreak
  str_split("\\n", simplify = TRUE) |>
  # pad eahc line so that each line is exactly 10 characters
  str_pad(10, side="both") |>
  # collapse the vector back into single string, re-adding linebreaks in the process
  str_c("\n")|>
  cat("\n")

# ---- 3.1 ---------------------------------------------------------------------
validate_password <- function(password) {
  # needs to have 8 characters and 1 punctuation character
  if ( nchar(password) > 8 && #needs at least a character length of 9
    str_count(password,"[a-z]") >= 2 && # at least 2 lower cases
    str_count(password, "[A-Z]") >= 2 && # at least 2 upper cases
    str_count(password, "[:punct:]") >= 1 &&
    str_count(password, "\\\\") == 0 &&
    str_count(password, "/") == 0) {
    TRUE
  } else {
    FALSE
  }
}

validate_password("emilyyau")
validate_password('Emily.Yau')

# ---- 3.2 ---------------------------------------------------------------------

str_to_snake <- function(string){
  string|> 
    # replace all capital letters with a _ infront of it
    str_replace_all("([A-Z])", "_\\1") |>
    # replace the all words to have lower case
    str_replace_all("^(\\w+)", str_to_lower)
}
str_to_snake(c("thisIsStringOne", "anotherAwkwardString"))



# ---- 4.1 ---------------------------------------------------------------------
email_regex <- "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$(? #matches emails"

# ---- 4.2 ---------------------------------------------------------------------
email_regex <- regex("
                     ^([^\\s@])+ # no empty spaces at the start
                     @[^\\s@]+ # no empty spaces or double @
                     \\. # must have a full stop
                     [^\\s@]+$ # make sure it doesnt end with a space or an @",
                     comments = TRUE)

# ---- 4.3 ---------------------------------------------------------------------
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


date_checker_regex <- glue::glue(
  "^(?i){day_lab}?", # start with a date label?
  "{separator}?", # maybe have a separator
  "{separator}?", # maybe have a separator middle value has two separators
  "{day_num}", # day number
  "{separator}?", # possibly another separator
  "{month_lab}", # month labels
  "{year}?" # possible year
)
str_detect(should_match, date_checker_regex)
str_detect(should_not_match, date_checker_regex)
