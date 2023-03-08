library(tidyverse)
library(rlang)

# ---- 1 ----

# --- 1.1 ---
## Create function to compute the proportion of values in a vector which are NA
prop_na <- function(x) {
sum(is.na(x)/length(x))
}

## Create function to calculate the coefficient of variation
var_coeff <- function(x, na.rm = FALSE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}

## Use functions for original code
storms |> 
  group_by(status) |> 
  summarise(
    
    ts_diameter_prop_na = prop_na(ts_diameter),
    hu_diameter_prop_na = prop_na(hu_diameter),
    
    wind_var_coeff      = var_coeff(wind, na.rm = TRUE),
    pressure_var_coeff  = var_coeff(pressure, na.rm = TRUE),
    
    .groups = "drop"
  )


# --- 1.2 --- 
## Use dplyr::across() to apply a function to multiple columns 
storms |> 
  group_by(status) |> 
  summarise(
    
    across(c(ts_diameter, hu_diameter), prop_na, .names = "{.col}_prop_na"),
    across(c(wind, pressure), ~ var_coeff(.x, na.rm = TRUE), .names = "{.col}_var_coeff"),
    
    .groups = "drop"
  )


# --- 1.3 --- 
## Set the dates
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")

# -- From here onwards is the code to simplify ------------------------

dates1_parsed       <- strptime(dates1, "%Y%m%d")
dates1_standardised <- strftime(dates1_parsed, "%Y-%m-%d") 

dates2_parsed       <- strptime(dates2, "%a, %b %d %Y")
dates2_standardised <- strftime(dates2_parsed, "%Y-%m-%d") 

dates3_parsed       <- strptime(dates3, "%d %B %y")
dates3_standardised <- strftime(dates3_parsed, "%Y-%m-%d") 


## create function to both parse and standardise in one step 
parsed_standardised <- function(x, y) { 
  strftime(strptime(x, y),"%Y-%m-%d")
  }

## input the original dates to check function works
parsed_standardised(dates1, "%Y%m%d")
parsed_standardised(dates2, "%a, %b %d %Y")
parsed_standardised(dates3, "%d %B %y")


# --- 1.4 ---
## Change the format of the output of the function
parsed_standardised2 <- function(x, y) { 
  strftime(strptime(x, y),"%d %B %y")
}

parsed_standardised2(dates1, "%Y%m%d")
parsed_standardised2(dates2, "%a, %b %d %Y")



# ---- 2 ----

# --- 2.1 ---
## Look at the original function 

print_info <- function(quiet = FALSE, df, ...) {
  if (!quiet) {
    cat(
      ...,
      paste("Rows:       ", nrow(df)),
      paste("Columns:    ", ncol(df)),
      paste("Total cells:", nrow(df) * ncol(df)),
      sep = "\n"
    )
  }
  invisible(NULL)
}

print_info(quiet = FALSE, starwars)


## Change function so df is first to enable pipe to be used 
## and add df to invisible clause 
print_info <- function(df, quiet = FALSE, ...){
  if (!quiet) {
    cat(
      ...,
      paste("Rows:       ", nrow(df)),
      paste("Columns:    ", ncol(df)),
      paste("Total cells:", nrow(df) * ncol(df)),
      sep = "\n"
    )
  }
  invisible(df)
}

## Run check
starwars |> 
  print_info() |> 
  count(homeworld, species) |> 
  print_info()


# --- 2.2 ---
## gsub syntax gsub(search_term, replacement_term, string_searched)
## need to change order for pipe to work

gsub2 <- function(x,y,z) {
  gsub(y,z,x)
}

## Test
c("string 1", "string 2") |> 
  gsub2("ing", "")

  
# --- 2.3 ---
## Use a . to tell the function to place the strings in the position 
## of the third argument
c("string 1", "string 2") |> 
  gsub("ing", "", .)



# --- 3 ---

# --- 3.1 --- 
## Write function that returns x if the length of x is greater that 0
## or y otherwise 
either <- function(x,y) {
  if( length(x) > 0) {x}
  else{y}
}

## Tests
x = c(1,2,3)
y = c(4,5,6)
either(x,y)

x = c()
y = c()
either(x,y)

x = c()
y = c(1)
either(x,y)


# --- 3.2 ---
## Create infix function
'%or%' <- function(x,y){
  if( length(x) > 0) {x}
  else{y}
}

## Test
x = c(1,2,3)
y = c(4,5,6)

x %or% y



# --- 3.3 ---
## Test differences

x = c(1,2,3)
y = c(4,5,6)
x %||% y
x %or% y

x = integer()
y = c(4,5,6)
x %||% y
x %or% y

x = c()
y = c()
x %||% y
x %or% y

## Difference is centered around when x is of length 0 and not null
## in this situation %||% returns x and %or% returns y.
## Therefore %||% returns x unless it is null
## whereas %or% returns x unless it is null or of length 0


# --- 3.4 --- 
## Create function
'%splice%' <- function(x,y) {
  if( length(x) == length(y) ){z <- c() 
                                     for(i in 1:length(x)){z[i] <- cat(x[i], y[i], " ", sep = " ")}
                                      print(z)}
  else{"Error - vector lengths do not match"}}

1:3 %splice% 11:13


# --- 3.5 ---
# Create infix function
'%|e|%' <- function(x,y){
  z <- (x %splice% y)
  if(is.character(z)){
    return(y)
  } else{
    return(x)
  }
}

#Test
x %|e|% y


# --- 4 ---

# --- 4.1 ---
## Create function that wraps the code including df and na arguments
as_text <- function(df, na) {
my_starwars <- df

for (col_name in colnames(my_starwars)) {
  col_formatted   <- format(my_starwars[[col_name]])
  col_na_replaced <- ifelse(col_formatted == "NA", "na", col_formatted)
  my_starwars[[col_name]] <- col_na_replaced
}

body_text <- do.call(paste, args = c(
  my_starwars, sep = "\t", collapse = "\r\n"
))
headers_text <- paste(colnames(my_starwars), collapse = "\t")
all_text <- paste(c(headers_text, body_text), collapse = "\r\n") 
}

## Test
starwars = dplyr::starwars
as_text(starwars, "")


# --- 4.2 ---
## Rewrite function with addition of headers argument 
as_text <- function(df, na, header = TRUE) {
  my_starwars <- df
  
  for (col_name in colnames(my_starwars)) {
    col_formatted   <- format(my_starwars[[col_name]])
    col_na_replaced <- ifelse(col_formatted == "NA", "na", col_formatted)
    my_starwars[[col_name]] <- col_na_replaced
  }
  
  body_text <- do.call(paste, args = c(
    my_starwars, sep = "\t", collapse = "\r\n"
  ))
  
  if(header == TRUE) {
  headers_text <- paste(colnames(my_starwars), collapse = "\t")
  all_text <- paste(c(headers_text, body_text), collapse = "\r\n") 

  }
  
  else {all_text <- paste(body_text, collapse = "\r\n")}
}

## Test
starwars = dplyr::starwars
as_text(starwars, "", header = TRUE)
as_text(starwars, "", header = FALSE)


# --- 4.3 ---
## Rewrite function with addition of ... argument 
as_text <- function(df, na, header = TRUE, ...) {
  my_starwars <- df
  
  for (col_name in colnames(my_starwars)) {
    col_formatted   <- format(my_starwars[[col_name]], ...)
    col_na_replaced <- ifelse(col_formatted == "NA", "na", col_formatted)
    my_starwars[[col_name]] <- col_na_replaced
  }
  
  body_text <- do.call(paste, args = c(
    my_starwars, sep = "\t", collapse = "\r\n"
  ))
  
  if(header == TRUE) {
    headers_text <- paste(colnames(my_starwars), collapse = "\t")
    all_text <- paste(c(headers_text, body_text), collapse = "\r\n") 
  }else {all_text <- paste(body_text, collapse = "\r\n")}
}



# --- 4.4 --- 
## Create new function which wraps previous function with addition of adding to 
## Clipboard and sending message 

to_clipboard = function(df, na, header, ...) { 
  text = as_text(df, na, header = header, ...)
  writeClipboard(text)
  cat("Clipboard has been updated.", "Character vector with", nchar(text), "entries copied")
  invisible(df)  
  }
to_clipboard(starwars, "", header = FALSE)


# --- 5 --- 

# --- 5.1 ---
## Create aggregate function 
aggregate <- function(df, ..., .cols, .fn = sum){
  df |>
    group_by(...) |>
    summarise(
      across({{.cols}}, .fn), 
      .groups = "drop")
}

## Test
aggregate(starwars, name, species, .cols = c(mass, height))
starwars

# --- 5.2 ---
## Adapting function for it to dissaggregate
disaggregate <- function(df, ..., .cols, .fn = sum){
  df |>
    group_by(across(!c(... , {{ .cols }}))) |>
    summarise(
      across({{.cols}}, .fn), 
      .groups = "drop")
}

## Test
disaggregate(starwars, name, species, .cols = c(mass, height))


# --- 5.3 ---
## Look at original code
diamonds |> 
  group_by(cut, color, clarity) |> 
  summarise(across(price, mean), .groups = "drop") |> 
  ggplot(aes(price, cut, fill = color)) +
  facet_wrap(vars(clarity)) +
  geom_col(position = "dodge")

## Create new function to generalise this code using previously created aggregate function
bar_plot <- function(data, x, y, fill = NULL, fn = mean) {
  aggregate(data, {{y}}, {{fill}}, .cols = {{x}}, .fn = fn) |>
    ggplot(aes({{x}}, {{y}}, fill = {{fill}})) +
    geom_col(position = "dodge")
}

## Test
bar_plot(diamonds, price, cut, fill = color, fn = mean)


# --- 5.4 ---
## Add in facet and position arguments to bar_plot function
bar_plot <- function(data, x, y, fill = NULL, fn = mean, 
                     facet = NULL, position = "dodge") {
  aggregate(data, {{y}}, {{facet}}, {{fill}}, .cols = {{x}}, .fn = fn) |>
    ggplot(aes({{x}}, {{y}}, fill = {{fill}})) +
    geom_col(position = position) + 
    facet_wrap(vars({{facet}}))
}

## Test
bar_plot(diamonds, price, cut, fill = color, fn = mean, facet = clarity, position = "dodge")



# --- 6 --- 

# -- 6.1 --- 
## Create function that search's a file on a user's PC 

search_up = function(file, dir = getwd()) {
if(file %in% list.files(dir)) {
  print(dir)
} else {
  dir2 = dirname(dir) 
  if (dir2 == dir) {
    stop("file not found")
  } else {
      search_up(file, dir2)
    }
}
  }


## Tests 
search_up("shiny example.R")  
search_up("not a file")  
