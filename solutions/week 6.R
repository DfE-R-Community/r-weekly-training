# Q3.1 Can't seem to understand the behavior of the code. Appreciate any feedback/comment. 

# library(tidyverse) would work just as well
library(stringr)
library(glue)


#==== Q1.1 - Use str_subset() to find which fruits in the fruit dataset contain the word 'berry'====
str_subset(fruit, "berry")


#==== Q1.2 - Now, adjust your regex to include only fruits where 'berry' is not its own word. E.g, your result should include "blackberry" but not "goji berry"====
str_subset(fruit, "[^ ]berry")
str_subset(fruit, "\\Sberry") # Returns words including "berry" only
str_subset(fruit, "\\sberry") # Returns words including " berry" only


#==== Q1.3 - Create a new regex to find all fruits which start with an a, b or c and end with an x, y or z. ====
str_subset(fruit, "^[abc].*[xyz]$")


#==== Q1.4 - Use str_subset() to find all the strings in the sentences dataset which contain words with 10 or more characters. Follow this by a call to str_extract() to extract just those words. =====
large_word_sentences <- str_subset(sentences, "[A-z]{10,}")
large_words <- str_extract(large_word_sentences, "[A-z]{10,}")


#==== Q1.5 - Use str_extract_all() to find all the words in the sentences dataset that start and end with vowels. =====
words_list <- str_extract_all(sentences, "\\b[aeiou]\\w*[aeiou]\\b|\\b[aeiou]\\b")


#==== Q2.1.1 - Use str_extract_all() to find all the words in the sentences dataset that start and end with vowels. =====
my_result <- 
  str_replace_all(fruit,"berry", "\033[31mberry\033[39m") |>
  cat(sep = "\n")


#==== Q2.1.2 - Now use str_replace_all() to apply the transformation from part 1 to the first word in every sentence from the sentences dataset. (Hint: see what this does: str_replace_all("string", "(i)", "!\\1!")) =====
str_replace_all("string", "(i)", "!\\1!")

coloured_sentences <-
  str_replace_all(sentences, "(^\\w*)", "\033[31m\\1\033[39m") |>
  cat(sep = "\n")


#==== Q2.1.3 -Use str_replace_all() to make the first word of every sentence in the sentences dataset upper-case =====
first_word_upper <-
  str_replace_all(sentences, "(^\\w*)", toupper) |>
  cat(sep = "\n")


#==== Q2.1.4 - Use str_replace_all() to replace all these abbreviations by supplying a named character vector as the pattern argument: =====
lazy_sentence <- paste(
  "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
  "They served respectively as 41st & 43rd presidents of the USA."
)
lazy_sentence <- str_replace_all(
  lazy_sentence,
  c(
    "Sr." = "Senior",
    "MA." = "Massachusetts",
    "&"   = "and",
    "Jr." = "Junior",
    "CT." = "Connecticut",
    "USA."= "United States of America"
  )
)

#==== Q2.2 - {stringr} has lots of convenience functions. Use str_squish(), str_to_sentence(), str_wrap(), str_split(), str_pad() and str_c() =====
messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "

clean_sentence <- messy_sentence |>
  str_squish() |> #removes unnecessary space i.e. two or spaces to one 
  str_to_sentence() |> #Capitalizes first letter of the sentence 
  str_wrap(width = 10) |> #Converts long string to segments/paragraphs defined by width(10)
  str_split("\\n", simplify = TRUE) |># converts individual lines to a vector. TRUE returns character matrix
  str_pad(10, side = "both") |> #adds space. Side = where padding is added i.e both sides
  str_c("\n") # combines inputs to one. In this example, splits it/collapses the text. 

cat(clean_sentence)


#==== Q3.1 - Create a function validate_password() that takes a string and returns TRUE/FALSE to indicate whether it is a valid password. It should check that the password =====
#Has at least 8 characters
#Contains at least two upper-case and two lower-case characters
#Contains at least one punctuation character
#Does not contain / or \

#Don't know why this returns TRUE. 
#Start of confusion
validate_password <- function(password){
  str_count(password, "[:upper:]")
  
  if (str_count(password, "[:upper:]") > 2){return (TRUE)}
  if (str_count(password, "[:alpha:]") > 7){return (TRUE)}
  else{return (FALSE)}
}
validate_password("HOL")
#End of Confusion


validate_password <- function(password){
  if (str_count(password, "[:alpha:]") < 8){return (FALSE)}
  if (str_count(password, "[:upper:]") < 2){return (FALSE)}
  if (str_count(password, "[:lower:]") < 2){return (FALSE)}
  if (str_count(password, "[:punct:]") < 1){return (FALSE)}
  if (str_count(password, "[\\\\|/]")  > 0){return (FALSE)}
  else {return (TRUE)}
  
}
validate_password("HelloWorld.")

#==== Q3.2 - Using functions from stringr(), create a custom function str_to_snake() which converts camelCase strings to snake_case. =====
str_to_snake <- function(camel_case_string){
  camel_case_string |>
    str_replace_all("([A-Z])", "_\\1" ) |>
    str_replace_all("([A-Z])", str_to_lower)
}
str_to_snake(c("thisIsStringOne", "anotherAwkwardString"))


#==== Q4.1 -  create a documented version of email_regex using "(?...)"-style comments =====
email_regex <- "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$(?#email verification - ensuring email syntax is correct)"


#==== Q4.2 -   Same, but this time using the regex(comments = TRUE) method. =====
email_regex <- regex("
                     ^          # denotes the start/beginning 
                     ([^\\s@])+ # no whitespace in the beginning
                     +@[^\\s@]+ # single @ and no whitespace
                     \\.        # must include .
                     [^\\s@]+$  # no whitespace in the end or another @
                     ", comments = TRUE)


#==== Q4.3 -  Using this technique, combine the following strings into a regular expression that can be used to check whether dates conform to a certain standard.  =====
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

date_regex <- glue(
  "^(?i){day_lab}?", # may start with a day of week(text)
  "{separator}?",    # may include separator
  "{separator}?",    # may include another separator
  "{day_num}",       # must include day of the month (number)
  "{separator}",     # must include separator
  "{month_lab}",     # must include month
  "{separator}?",    # may include separator 
  "{year}?"          # may include the year
)

should_match     <- c("01.Jan.1991", "wed, 03 february 2002", "31-Jun")
should_not_match <- c("25122022", "2002, 03 Feb", "  Jan 1 2020")

str_detect(should_match, date_regex) 
str_detect(should_not_match, date_regex) 



