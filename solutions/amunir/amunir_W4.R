library(tidyverse)
library(dplyr)

#storms |> 
#  group_by(status) |> 
#  summarise(
    
    # Proportions of `NA` values for ts_diameter and hu_diameter
#    ts_diameter_prop_na = sum(is.na(ts_diameter)) / length(ts_diameter),
#    hu_diameter_prop_na = sum(is.na(hu_diameter)) / length(hu_diameter),
    
    # Coefficients of variation for wind and pressure
#    wind_var_coeff      = sd(wind,     na.rm = TRUE) / mean(wind,     na.rm = TRUE),
#    pressure_var_coeff  = sd(pressure, na.rm = TRUE) / mean(pressure, na.rm = TRUE),
    
#    .groups = "drop"
    
#  )


#-----------Q1) 1--------------------------

#Function created to give the proportions
prop_na <- function(x){
 return(sum(is.na(x))/ length(x))
}

#function created to get the coefficient of variation
var_coeff <- function(x){
  return(sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE))
}

#using storm dataset
storms |>
  group_by(status)|>
  summarise(

    #calls function for hu_diameter and ts_diameter
    ts_diameter_prop_na <- prop_na(ts_diameter),
    hu_diameter_prop_na <- prop_na(hu_diameter),
    
    #function called for wind and pressure
    wind_var_coeff <- var_coeff(wind),
    pressure_var_coeff <- var_coeff(pressure),
    
    .groups = "drop" 

  )


#-------------Q1) 2---------------------------------

#across used to simplify and transform columns

storms |>
  group_by(status) |>
  summarise(
    across(c(ts_diameter, hu_diameter), prop_na),
    across(c(wind, pressure), var_coeff),
    .groups = "drop")





#-----------Q1) 3-----------------------------------

# Some less-than-ideally formatted dates
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")

# -- From here onwards is the code to simplify ------------------------

#Created single function for parsed and standardized dates
dates_func_1_3 <- function(x,y){
  dates_parsed <- (strptime(x,y))
  return(strftime(dates_parsed, "%Y-%m-%d"))
}

#dates1_parsed       <- strptime(dates1, "%Y%m%d")
#dates1_standardised <- strftime(dates1_parsed, "%Y-%m-%d") 

#dates2_parsed       <- strptime(dates2, "%a, %b %d %Y")
#dates2_standardised <- strftime(dates2_parsed, "%Y-%m-%d") 

#dates3_parsed       <- strptime(dates3, "%d %B %y")
#dates3_standardised <- strftime(dates3_parsed, "%Y-%m-%d")

#Using this data to see the output is correct
dates1_standardised <- dates_func_1_3(dates1, "%Y%m%d")
dates2_standardised <- dates_func_1_3(dates2, "%a, %b %d %Y")
dates3_standardised <- dates_func_1_3(dates3, "%d %B %y")



#----------------Q1) 4------------------------
#



#---------------Q2) 1------------------------------
#changed to make sure the dataset will be inputed in first
#before quiet
print_info <- function(df, quiet = FALSE ) {
  quiet = FALSE
  if (!quiet) {
    cat(
      paste("Rows:       ", nrow(df)),
      paste("Columns:    ", ncol(df)),
      paste("Total cells:", nrow(df) * ncol(df)),
      sep = "\n"
    )
  }
  invisible(df) #changed from NULL to data
}


starwars |> 
  print_info(quiet = FALSE) |> 
  count(homeworld, species) |> 
  print_info(quiet = TRUE)


#-----------Q2) 2----------------------------------
#Function which wraps gsub()
#change order so it is compatible with a |>
gsub2 <- function (a, b, c){
  gsub(b, c, a)
}


c("string 1", "string 2") |> 
  gsub2("ing", "")

#---------Q2) 3------------------------------------

#using a . to allow it to work with a normal gsub
c("string 1", "string 2") |> 
  gsub("ing", "", .)


#-------------Q3) 1--------------------------------
#Function which checks if the length x is larger than 0 using
#conditions. else if smaller then zero outputs y
either <- function(x,y){
  if(length(x) > 0){
    return(x) 
  }
  else if(length(x) <= 0 ){
    return(y)
  }
  
}

#test to see if the code works
x = c(3,4,6,7)
y = (4)

x = c()
y = (7)
either(x,y)


#--------Q3) 2------------------------------------
#Creating an infix function
#almost identical to previous function
'%or%' <- function (x,y){
  if(length(x) > 0){
    return(x) 
  }
else if(length(x) <= 0 ){
  return(y)
}

}

#test to see if the code works
x = c(3,4,6,7)
y = (4)

x = c()
y = (7)

x %or% y


#------Q3) 3-----------------------------------
#Using previous test values but both gave the same outputs
#so used integer when set to x gave %or% and %||% different answers
x = c(3,4,6,7)
y = (4)

x %or% y
x %||% y


x = c()
y = (7)
x %or% y
x %||% y

x = integer() ##Shows different results 
y = (7)
x %or% y  #Outputs y
x %||% y  #Outputs x

x = c(4,5,6)
y = integer()
x %or% y
x %||% y


#Unsure why 
#----------Q3) 4----------------------

#Splice function


#---------Q4)1-----------------------------------------------------------

#dplyr::starwars
#df
#na = ""

#created as_text function to wrap the given code
#changing the  my_starwars to df to avoid confusion 
as_text <- function(df, na =""){
 
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
    col_na_replaced <- ifelse(col_formatted == "NA", "", col_formatted)
    
    df[[col_name]] <- col_na_replaced
  }

body_text <- do.call(paste, args = c(
  df, sep = "\t", collapse = "\r\n"
))
headers_text <- paste(colnames(df), collapse = "\t")

all_text <- paste(c(headers_text, body_text), collapse = "\r\n")

}


starwars |>
  as_text()

#--------Q4)2----------------------------------------------

#used if statements to change what is returned. If true then headers text included
#else just the body text
##used an else if
as_text <- function(df, na ="", headers = TRUE){

  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
    col_na_replaced <- ifelse(col_formatted == "NA", "", col_formatted)
    
    df[[col_name]] <- col_na_replaced
  }
  
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  
  if (headers == TRUE){
  
  headers_text <- paste(colnames(df), collapse = "\t")
  all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
  return(all_text)}
  
  else if (headers == FALSE){
  all_text <- paste(c(body_text), collapse = "\r\n")
  return(all_text) }
  }


starwars |>
  as_text()


#-----------Q4)3-----------------------------------------
# added ... as an argument 
as_text <- function(df, na ="", headers = TRUE, ...){
  
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
    col_na_replaced <- ifelse(col_formatted == "NA", "", col_formatted)
    
    df[[col_name]] <- col_na_replaced
  }
  
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  
  if (headers == TRUE){
    
    headers_text <- paste(colnames(df), collapse = "\t")
    all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
    return(all_text)}
  
  else if (headers == FALSE){
    all_text <- paste(c(body_text), collapse = "\r\n")
    return(all_text) }
}


starwars |>
  as_text()

#---------Q4)4--------------------------------------------
#created a function to wrap as_text. it also outputs 
#a message using cat()
to_clipboard <- function(df, na = "", headers = FALSE, ...){
  as_text_2 <- as_text(df, na="", headers = FALSE, ...)
  writeClipboard(as_text_2)
  
  cat("Clipboard Status: Updated")
  invisible(df)
}

starwars|>
to_clipboard()


#-----Q5)1----------------------------------------------
aggregate <- function(df, ..., .cols, .fn){
  
  df |> 
    group_by(...) |> 
    summarise(
      across(({{.cols }}), .fn), 
      .groups = "drop"
    )

}
#----Q5) 2-------------------------------------------
#disaggregate <- function(df, ..., .cols, .fn ){
  
  
#}
#------------------------------------------------------
#Will continue and will finish the rest within the
#next week or so
