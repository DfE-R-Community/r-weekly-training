#Graduate R Training - Week 6 Exercises 

# I have attempted question Q2.2 and Q3.1 but do not believe I have completed these 
# correctly. I have provided more detail of the queries regarding these questions
# in the relevant sections of this file. Any feedback/guidance on these would be appreciated.

# I have additionally not attempted the bonus questions (Q3.3 and Q4.4 due to time constraints),
# any comments on these questions would also be greatly appreciated :)

# Load the packages needed for this exercise sheet
library(tidyverse)
library(glue)

# ---- Q1.1 ----

# The second argument will search for the word "berry"
str_subset(fruit, "berry")

# ---- Q1.2 ----

# "[^\\s]berry" identifies all cases where there is no whitespace before the word berry 
str_subset(fruit, "[^\\s]berry") 
  
# ---- Q1.3 ----

# "^[abc]" finds all words which start with a,b or c
# "\\w*" matches any word character which can repeat 0 or more times
# "[xyz]$" finds all words which end with x,y or z
str_subset(fruit, "^[abc]\\w*[xyz]$") 

# ---- Q1.4 ----

# Find the sentences containing words with 10 or more letters
large_words <- str_subset(sentences, "\\w{10,}")

# Extract the words from the sentences contained in large_words
extract_large_words <- str_extract(large_words, "\\w{10,}")

# Print all words that have been extracted
extract_large_words

# ---- Q1.5 ---- 

# The regex used for this can be split into the following sections:
# "\\b[aeiou]" finds words which start with a vowel 
# "\\w*" finds any word character that repeats 0 or more times
# "[aeiou]\\b" finds words that end in a vowel
# "|\\ba\\b" includes a logical 'or' which searches for the letter "a", this is 
# needed because the previous regex finds words of a minimum length of two characters
# Ignore_case allows for the beginning word, which is capitalised, to be considered
str_extract_all(sentences, regex("\\b[aeiou]\\w*[aeiou]\\b|\\ba\\b", ignore_case = TRUE))


# ---- Q2.1.1 ----

# The second argument contains the word which will be replaced, and the third argument
# is the regex which will replace the word
my_result <- str_replace_all(fruit, "berry", "\033[31mberry\033[39m")

# Display the result of the above code to find it converts the word "berry" to red text
my_result |> cat(sep = "\n")

# ---- Q2.1.2 ----

# The hint from the question uses the idea of backreferences to replace "i" with "!i!"
str_replace_all("string", "(i)", "!\\1!")

# "^([\\w]+)" identifies the first word in the sentence up to the first whitespace.
# Use backreferencing to colour this first word red using parentheses and "\\1"
my_result2 <- str_replace_all(sentences, "^([\\w]+)", "\033[31m\\1\033[39m")

# Display the result of the above code
my_result2 |> cat(sep = "\n")

# ---- Q2.1.3 ----

# Like Q2.1.2, use "^([\\w]+)" to identify the first word of each sentence
# Use the function str_to_upper to convert the first word to upper case
str_replace_all(sentences, "^([\\w]+)", str_to_upper)

# ---- Q2.1.4 ----

# This is the unabbreviated version of the text 
lazy_sentence <- paste(
  "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
  "They served respectively as 41st & 43rd presidents of the USA."
)

# Use a named character vector to manually replace, "Sr.", "MA.", "Jr." and "CT."
# with their full versions
str_replace_all(lazy_sentence, c("Sr." = "senior", "MA." = "Massachusetts", 
                             "Jr." = "junior", "CT." = "Connecticut"))

# ---- Q2.2 ---- 

# Note, my final answer produces 5 lines, where lines 2-5 are slightly indented. Is this correct?
# Does "cat()" treat the text as a paragraph whereby following lines are indented? 
# I would be thankful for any insight :)

# Here is the unedited text 
messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "

# This is the list of functions I will use in order
str_squish()
str_to_sentence()
str_wrap()
str_split()
str_pad()
str_c()

# Use str_squish to remove unnecessary whitespace from text
step_1_squish <- str_squish(messy_sentence)

# Use str_to_sentence to convert text to sentence case
step_2_sentence <- str_to_sentence(step_1_squish)

# Use str_wrap to wrap the text into lines of 10 or less characters
step_3_wrap <- str_wrap(step_2_sentence, width = 10)

# Use str_split to split the text into separate strings where there is a line break
step_4_split <- str_split(step_3_wrap, "\\n", simplify =  TRUE)

# Use str_pad to pad strings with whitespace so they are 10 characters long (add whitespace
# to the right of the text)
step_5_pad <- str_pad(step_4_split, 10, "right")

# Use str_c to collapse vector of strings back to a single string, re-adding line breaks
step_6_c <- str_c(step_5_pad, "\n")

# Print final result
cat(step_6_c, "\n")

# ---- Q3.1 ----

# I am not sure if this answer is working perfectly. If I wanted to test a potential password which
# included a single "\", I would actually need to write "\\" due to regex syntax. Is there 
# anyway to avoid this? Thanks for your help again :)

# Initialise function
validate_password <- function(x) {
  
      # Check string has at least 8 characters
  if (str_count(x) > 7 && 
      
      # Check string has at least 2 upper case and 2 lower case characters
      str_count(x,"[A-Z]") > 1 && str_count(x,"[a-z]") > 1 && 
      
      # Check string contains at least 1 punctuation character
      str_count(x,"[:punct:]") > 0 && 
      
      # Check string does not contain any / or \
      !str_count(x,"/") && !str_count(x,"\\\\") ) {
    
    TRUE
    
  } else {
    
    FALSE
    
  }
}

# A test which should return TRUE
validate_password("llAlBllqw!yh")

# A test which should return FALSE
validate_password("llAlB")

# ---- Q3.2 ----

# Initialise function
str_to_snake <- function(x) {
  
  # Insert an underscore before any uppercase letters
  insert_underscore <- str_replace_all(x, "([A-Z])", "_\\1")
  
  # Replace any uppercase letters with lowercase
  str_replace_all(insert_underscore, "([A-Z])", str_to_lower)
}

# Test function based on example from question sheet
y <- c("thisIsStringOne", "anotherAwkwardString")

str_to_snake(y)

# ---- Q3.3 ----

# I haven't had time to complete this question yet. Can you provide any insight into this please?

# ---- Q4.1 ----

# This is the uncommented code from the question sheet
email_regex <- "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$"

# Add a comment using the "(?...)" style 
email_regex <- "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$(?#this ensures the email syntax is correct)"

# ---- Q4.2 ----

# Now add comments using the regex(comments = TRUE) style
email_regex <- regex("
  ^([^\\s@])+ # excludes cases where beggining of email starts with whitespace or @
  @[^\\s@]+   # excludes email addresses  including whitespace or another @ after the first @
  \\.         # must then include a .
  [^\\s@]+$   # excludes email addresses ending in whitespace or @
  ", comments = TRUE)

# ---- Q4.3 ----

# The following is the code supplied in the question sheet

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

# Initialise regex parameter
re <- glue::glue(
  "^(?i){day_lab}?", # Maybe start with day label. Allow upper or lower case
  "{separator}?",    # Maybe a separator
  "{separator}?",    # Maybe another separator
  "{day_num}",       # Then include day number
  "{separator}",     # Then include a separator
  "(?i){month_lab}", # Then a month label. Allow upper or lower case
  "{separator}?",    # Maybe a separator 
  "{year}?$"         # Maybe end in year
)


# Test the above regex parameter

# This matches
str_detect(should_match, re)

#This does not match
str_detect(should_not_match, re)

# ---- Q4.4 ----

# I haven't had time to complete this question yet. Can you provide any insight into this please?


