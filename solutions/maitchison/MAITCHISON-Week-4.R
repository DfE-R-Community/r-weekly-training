#Week 4 Exercises

library(tidyverse)
library(rlang)

#This is a version which replaces all my previous answers with their corrected
# counterparts. Note, I have not completed 3.5.

# ---- Q1.1 ----

# Function to replicate proportion of NA calculation, x = ts_diameter or hu_diameter
# convention is to leave space between function and {}
prop_na <- function(x) {
  sum(is.na(x)) / length(x)
}

# Function to replicate coefficient of variation calculation, x = wind or pressure
var_coeff <- function(x) {
  sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
}

# Code now using new functions 
storms %>% 
  group_by(status) %>% 
  summarise(
    
    # Proportions of `NA` values using new function
    ts_diameter_prop_na = prop_na(ts_diameter),
    hu_diameter_prop_na = prop_na(hu_diameter),
    
    # Coefficients of variation using new function
    wind_var_coeff      = var_coeff(wind),
    pressure_var_coeff  = var_coeff(pressure),
    
    .groups = "drop"
    
  )

# ---- Q1.2 ----

# across() can be used to apply the same function across multiple columns

storms %>% 
  group_by(status) %>% 
  summarise(
    
    # Proportions of `NA` values using across() to apply new function to both columns in one line
    across(c(ts_diameter, hu_diameter), prop_na, .names = "{.col}_prop_na"),
    
    # Coefficients of variation using across() to apply new function to both columns in one line
    across(c(wind, pressure), var_coeff, .names = "{.col}_var_coeff"),
    
    .groups = "drop"
    
  )

# ---- Q1.3 ---- 

# Some less-than-ideally formatted dates
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")

# --  here is the code to simplify ------------------------
dates1_parsed       <- strptime(dates1, "%Y%m%d")
dates1_standardised <- strftime(dates1_parsed, "%Y-%m-%d") 

dates2_parsed       <- strptime(dates2, "%a, %b %d %Y")
dates2_standardised <- strftime(dates2_parsed, "%Y-%m-%d") 

dates3_parsed       <- strptime(dates3, "%d %B %y")
dates3_standardised <- strftime(dates3_parsed, "%Y-%m-%d")

# Function returns the 'standardised' version of the dates, by first calculating the 
# 'parsed' version and nesting this into the code for the 'standardised' version.
# x = date, y = date format of x
standardise <- function(x, y){
 strftime(strptime(x, y), "%Y-%m-%d") 
}

#Checks to see if function works
standardise(dates1, "%Y%m%d")
standardise(dates2, "%a, %b %d %Y")
standardise(dates3, "%d %B %y")

# ---- Q1.4 ---- 


#Here, abstract out the output format into another argument
reformat <- function(x, in_format = "%Y-%m-%d", out_format = "%d %B %y") {
  x %>% strptime(in_format) %>% strftime(out_format)
}

#Checks to see if function works
reformat(dates1, "%Y%m%d")
reformat(dates2, "%a, %b %d %Y")

# ---- Q2.1 ---- 


# Swap the arguments around in function as df will be stated at start of pipe
print_info <- function( df, quiet = FALSE, ...) {
  if (!quiet) {
    cat(
      ...,
      paste("Rows:       ", nrow(df)),
      paste("Columns:    ", ncol(df)),
      paste("Total cells:", nrow(df) * ncol(df)),
      sep = "\n"
    )
  }
  # Include an invisible version of df which will be passed through to next part of pipe
  invisible(df)
}

# Check to see if function works
print_info(quiet = FALSE,starwars)

#Check to see if function works in pipe
starwars %>% 
  print_info() %>% 
  count(homeworld, species) %>% 
  print_info()

# ---- Q2.2 ---- 

# Define gsub2 to swap arguments around in gsub allowing compatibility with pipe
gsub2 <- function(x,y,z){
  gsub(y,z,x)
}

# Check to see if function works
c("string 1", "string 2") %>% 
  gsub2("ing", "")

# ---- Q2.3 ---- 

# Use '.' to indicate to insert the vector of strings in the third argument position instead of first
c("string 1", "string 2") %>%
  gsub("ing", "", .)

# ---- Q3.1 ---- 

# Function has two arguments which can be vectors
either <- function(x, y){
  # See if x's  length is > 0, return x
  if(length(x) > 0){
    x
  # If x's length is 0, return y  
  } else{
    y
  } 
}

# Argument values to test function
x <- c(1,2,3)
x <- c()
y=7

# Run function to test it
either(x,y)

# ---- Q3.2 ---- 

#Modify function name using infix syntax, keeping the remaining code bulk the same
'%or%' <- function(x, y) either(x, y)

# Test function
x %or% y

# ---- Q3.3 ---- 

# If x is NULL, it will return y, otherwise returns x, as opposed to above function 
# which returns y only when x is of length 0 (which is different to being NULL)
x %||% y 

# ---- Q3.4 ---- 

# Load variable values to test function
x = c(1,1,1)
y = c(3,3,3)
y = c(3,3)

'%splice%' <- function(x, y) {
  
  # Error if vector lengths do not match using stop()
  if (length(x) != length(y)) {
    stop("Failure - the vector sizes do not match")
  }
  
  # A more concise error might be:
  # stopifnot(length(x) == length(y))
  
  # Set up the output - should be 2x the length of `x`
  out <- vector(mode(x), 2 * length(x))
  
  for (i in seq_along(x)) {
    out[2 * i - 1] <- x[i]
    out[2 * i]     <- y[i]
  }
  
  out
}

x %splice% y

# ---- Q3.5 ---- 

# Use infix syntax to initialise function
'%|e|%' <- function(x,y) {
  tryCatch(               
    # Specify the expression
    expr = {                     
      x
    },
    # Specify the error message
    error = function(e){         
      y
    }
  )
}

#Check function works
stop("an error") %|e|% sqrt("not a number") %|e|% "this works" %|e|% "this also works" %|e|% stop("oh no")
# ---- Q4.1 ---- 

as_text <- function(df, na = ""){
  
  # 2. Looping over each column in the data, transform the column
  #    to character format, then replace any `"NA"` values with na argument
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
    #Replace "" with na argument
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
    
  }
  
  # 3. Create text representations of the table body and headers. `"\t"` 
  #    means 'new cell' and `"\r\n"` means 'new row'. Don't worry about
  #    `do.call()` - this might be covered in a future week.
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  headers_text <- paste(colnames(df), collapse = "\t")
  
  # 4. Combine headers and body
  out <- paste(c(headers_text, body_text), collapse = "\r\n")
  out
}

# Check function works using appropriate arguments
as_text(dplyr::starwars, "")


# ---- Q4.2 ---- 

# if (headers) would be better, and it's not obvious what function returns. the below
# code works as if (headers) will return NULL if headers == FALSE, and c(NULL, x) is the same as c(x)

as_text <- function(df, na = "", headers = TRUE){
  
  # 2. Looping over each column in the data, transform the column
  #    to character format, then replace any `"NA"` values with na argument
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
    #Replace "" with na argument
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
    
  }
  
  # 3. Create text representations of the table body and headers. `"\t"` 
  #    means 'new cell' and `"\r\n"` means 'new row'. Don't worry about
  #    `do.call()` - this might be covered in a future week.
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  # If statement checking value of headers
  # If TRUE, include headers in table
  headers_text <- if (headers) paste(colnames(df), collapse = "\t")
  out <- paste(c(headers_text, body_text), collapse = "\r\n")
  out
}

as_text(dplyr::starwars, "", headers = TRUE)
as_text(dplyr::starwars, "", headers = FALSE)

# ---- Q4.3 ---- 

as_text <- function(df, na = "", headers = TRUE, ...){
  
  # 2. Looping over each column in the data, transform the column
  #    to character format, then replace any `"NA"` values with na argument
  for (col_name in colnames(df)) {
    #include ... in arugment of format
    col_formatted   <- format(df[[col_name]], ...)
    #Replace "" with na argument
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
    
  }
  
  # 3. Create text representations of the table body and headers. `"\t"` 
  #    means 'new cell' and `"\r\n"` means 'new row'. Don't worry about
  #    `do.call()` - this might be covered in a future week.
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  headers_text <- if (headers) paste(colnames(df), collapse = "\t")
  out <- paste(c(headers_text, body_text), collapse = "\r\n")
  out
}

as_text(dplyr::starwars, "", headers = TRUE)
as_text(dplyr::starwars, "", headers = FALSE)

# ---- Q4.4 ---- 

# The following is the code given in the feedback
to_clipboard <- function(df, na, headers = TRUE, ...){
  all_text <- as_text(df, na, headers, ...)
  writeClipboard(all_text)
  cat('Your table has been copied.', 'It contains', nrow(df), 'rows and', ncol(df),
      'columns')
  invisible(all_text)
}

to_clipboard(dplyr::starwars, "", headers = TRUE)
to_clipboard(dplyr::starwars, "", headers = FALSE)

# ---- Q5.1 ----

#Initialise function with desired arguments, setting .fn to have a default of sum
aggregate1 <- function(df, ..., .cols, .fn = sum){
  df %>%
    # '...' does not need to be wraped with '{{'
    group_by(...) %>%
    #Wrap .cols with '{{' so that R knows it is refering to the data in df
    summarise(across({{ .cols }}, .fn), .groups = "drop")
}

# Run function to test it
aggregate1(mtcars, cyl, gear, .cols = c(mpg, hp))


  
# ---- Q5.2 ----

# Initialise function with same argments as before
disaggregate <- function(df, ..., .cols, .fn = sum){
  df %>%
    # Use the '-' to indicate to group by everything but selected arguments
    # Use c() to include .cols and ...
    # Wrap .cols in '{{' to refer to data df
    group_by(across(-c({{.cols}}, ...))) %>%
    summarise(across({{ .cols }}, .fn), .groups = "drop")
}

# Test function
disaggregate(mtcars, cyl, gear, .cols = c(mpg, hp))
 

# ---- Q5.3 ----

#Solution provided in feedback
bar_plot <- function(data, x, y, fill = NULL, fn = mean){
  # Wrap y, fill and x in '{{' to refer to data
  aggregate1(data, {{ y }}, {{ fill }}, .cols = {{ x }}, .fn = fn) %>%
    ggplot(aes({{ x }},{{ y }}, fill = {{ fill }})) +
    geom_col(position = "dodge")
}

# Test function
bar_plot(data = diamonds, x = price, y = cut, fill = color, fn = mean)

# ---- Q5.4 ----


#Solution provided in feedback 
bar_plot <- function(data, x, y, fill = NULL, fn = mean, facet = NULL, position = "dodge"){
  aggregate1(data, {{ y }}, {{ facet }}, {{ fill }}, .cols = {{ x }}, .fn = mean) %>%
    ggplot(mapping = aes({{ x }},{{ y }}, fill = {{ fill }})) +
    geom_col(position = position) +
    facet_wrap(vars({{ facet }}))
}

bar_plot(data = diamonds, x = price, y = cut, fill = color, fn = mean, facet = NULL, position = "dodge")

# ---- Q6 ---- 

#In this question, i mistakenly started using = instead of <-, so be carefull with that.
# My if/else statements arent chained correctly, here the corrected version
search_up = function(file, dir = getwd()){
  # Check if file is in current directory, if so return the directory
  if(file %in% list.files(dir)){
    return(dir)
  }
  # Check if in upper most directory and return NULL to avoid infinite loop if so
  else if(dir == "C:/"){
    return(NULL)
  }
  # Otherwise go up one directory level, and use recursion to repeat steps
  else{
    dir <-  dirname(dir)
    search_up(file, dir)
  }
}


# Test to see if function works, these are specific to my workspace and may need to be changed
search_up("MAITCHISON-Week-4.R")
search_up("test.txt")
search_up("lol")
dirname(getwd())



