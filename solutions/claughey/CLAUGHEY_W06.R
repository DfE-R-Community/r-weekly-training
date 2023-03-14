library(tidyverse)


# -------- Q1 Pattern detection in strings ------------
# Whichs fruits in the fruit dataset contain the word 'berry'
str_subset(fruit, "berry")

# From these find the fruits where berry is not its own word
str_subset(fruit, "\\Sberry") # \S matches any non-whitespace character

# Find fruits that start with an a, b or c and end with an x, y or z
str_subset(fruit, "^[abc].*[xyz]$") # .* matches any character besdies newline 0+ times

# Find all the strings in the sentences dataset which contain words with 10 or more characters
str_subset(sentences, "\\w{10,}") # \w matches any word character, {10,} means 10 or more instances

# Extract those words
word_list <- str_extract(sentences, "\\w{10,}")
word_list[!is.na(word_list)] # remove the NA values from the resulting list

# find all the words in the sentences dataset that start and end with vowels.
vowel_word_list <- str_extract(sentences, "\\b[aeiou]\\w*[aeiou]\\b") # \\b matches the beginning or end of a word
vowel_word_list[!is.na(vowel_word_list)]



# ----------- Q2. Some nice {stringr} features --------------
# Replace all instances of the word ‘berry’ in the fruits dataset with "\033[31mberry\033[39m"
fruit_altered <- str_replace(fruit, "berry", "\033[31mberry\033[39m")
fruit_altered %>% cat(sep = "\n") # Cool, 'berry' turns red

# Apply the transformation from part 1 to the first word in every sentence from sentences
sentences_highlighted <- str_replace_all(sentences,
                                         "^(\\w+)\\b",          # find string that starts with a word character and ends with a space
                                         "\033[31m\\1\033[39m") # \\1 is whatever is in the brackets above

sentences_highlighted %>% cat(sep = "\n")  # First word turns red

# Make the first word of every sentence in the sentences dataset upper-case
sentences_capitalised <- str_replace_all(sentences, 
                                         "^\\w+\\b",
                                         toupper)
sentences_capitalised %>% cat(sep = "\n")


# Lazy sentence
lazy_sentence <- paste(
  "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
  "They served respectively as 41st & 43rd presidents of the USA."
)
# Replace all these abbreviations by supplying a named character vector
pattern <- c(Sr.="Senior", MA.="Massachusetts", Jr.="Junior", CT.="Connecticut")
str_replace_all(lazy_sentence, pattern)


# CLean with messy sentence
messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "

clean_sentence <- messy_sentence %>%
  str_squish() %>%                   # removes whitespace
  str_to_sentence() %>%              # converts to sentence case
  str_wrap(width = 10) %>%           # wraps to lines of 10 characters or less
  str_split("\n", simplify = T) %>%  # Convert lines to vector
  str_pad(10, side = "right") %>%    # Adds whitspaces to make vector 10 spaces long
  str_c(collapse = "\n")             # Combine to single string with line breaks on 10th space

cat(clean_sentence)
 

# -------- Q3. Creating custom functions ----------
# Create a function that takes a string and returns TRUE/FALSE to indicate whether it is a valid password.
validate_password <- function(string) {
  
  if(str_length(string)<8) {
    return(FALSE)
    } 
  
  else if(str_count(string, "[:upper:]")<2 || str_count(string, "[:lower:]")<2) {
    return(FALSE)
    } 
  
  else if(str_count(string, "[:punct:]")<1) {
    return(FALSE)
    }
  
  else if(str_count(string, "[\\/]")>0) {
    return(FALSE)
  }
  
  else {
    return(TRUE)
  }
}

validate_password(string= "AweWrsdfns") # False


# Convert camel case to snake case
str_to_snake <- function(string){
  string %>% 
    str_replace_all("([:upper:])", "_\\1") %>% # Add in the underscore where there's an uppercase
    str_to_lower() # convert to lowercase
}
  
str_to_snake(c("thisIsStringOne", "anotherAwkwardString"))


# ----------- q4. Regex good practice ------------
# Make the following regex readable by adding comments
email_regex <- "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$"

# Difficult to read using (?#..) commenting ...
email_regex_commented <- "^([^\\s@])+(?#match single character at least once)@[^\\s@]+\\.[^\\s@]+$"

# Better with regex(comments= True)
email_regex_commented2 <- regex("
                                ^             # asserts first position in line
                                ([^\\s@])+    # match non-whitespace and non-@ at least once, 
                                @             # @ character
                                [^\\s@]+      # match non-whitespace and non-@ at least once,
                                \\.           # matches . character
                                [^\\s@]+      # match non-whitespace and non-@ at least once,
                                $             # asserts last position in line
                                ", comments=TRUE)

# GOing to leave it there today, got a bit lost with the final part tbh
