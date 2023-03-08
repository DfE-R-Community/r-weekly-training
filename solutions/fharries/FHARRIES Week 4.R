library(tidyverse)

# Q1 ----------------------------------------------------------------------

# 1.1 & 1.2

# Calculates proportion of NA values 
prop_na <- function(x) {
  
  sum(is.na(x)) / length(x)
  
}

# Calculates coefficient of variation
var_coeff <- function(x) {
  
  sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
  
}

storms |> 
  group_by(status) |> 
  summarise(
    
  # Proportions of `NA` values for ts_diameter and hu_diameter
  across(.cols = c(ts_diameter, hu_diameter) ,prop_na, .names = "{.col}_prop"),

  # Coefficients of variation for wind and pressure
  across(.cols = c(wind, pressure), var_coeff, .names = "{.col}_var_coeff"),

  .groups = "drop"
  )

# 1.3
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")

# Returns datetime object if output = Null
# If output not null returns string with output format
date_parser <-  function(date, input, output = NULL) {

  if(is.null(output)){
    strptime(date, input)

  } else {
    
    date <- strptime(date, input)
    strftime(date, output)
  }
}

# 1.4 

date_parser(dates1, "%Y%m%d", output = "%d %B %y")

date_parser(dates2, "%a, %b %d %Y", "%d %B %y")

# Q2 ----------------------------------------------------------------------

# 2.1

# Updated function to invisibly return df
print_info <- function(df, quiet = FALSE) {
  if (quiet == FALSE) {
    cat(
      paste("Rows:       ", nrow(df)),
      paste("Columns:    ", ncol(df)),
      paste("Total cells:", nrow(df) * ncol(df)),
      sep = "\n"
    )
  }
  invisible(df)
}

starwars |>
  print_info() |> 
  count(homeworld, species) |> 
  print_info()

# 2.2 

# Wrapped gsub function to work with pipe
gsub2 <-  function(string, old_text, new_text) {
  
  print(gsub(old_text, new_text, string))

  invisible(string)

}

c("string 1", "string 2") |> 
  gsub2("ing", "") |> 
  gsub2("st", "")

# 2.3

c("string 1", "string 2") |> 
  gsub("ing", "", .)

# Q3 ----------------------------------------------------------------------

# 3.1

# Returns x if length greater than zero
either <- function(x = NULL, y){
  if (length(x) > 0){
    x
  } else {
    y
  }
}

either(x = "x" , y = "y")

either(x = , y = "y")

# 3.2

"%or%" <- function(x = NULL, y) if (length(x) > 0) x else y

"x" %or% "y"
NULL %or% "y"
NA %or% "y"

# 3.3 

# Not sure when we would see different results here?

"x" %||% "y"
NULL %||% "y"
NA %||% "y"

# 3.4

# Returns spliced vectors 

"%splice%" <- function(x, y){

  if(length(x) == length(y)){
    
    z = c()

    for(i in 1:length(x)){

      temp = c(x[i], y[i])

      z = c(z, temp)

    }
    
    z
    
  } else{
    
    print("Input vectors need to be the same length")

  }
  
} 

1:10 %splice% 10:1
1:10 %splice% 10:3

# 3.5

# Returns LHS unless error, then returns RHS

"%|e|%" <- function(x, y){
  tryCatch(x,
           error = function(e)
           y)
}

"x" %|e|% "y"
. %|e|% "y"

# Q4 ----------------------------------------------------------------------

# 4.1 & 4.2 & 4.3

# Returns df as text 
as_text <- function(df, ..., na = "", headers = TRUE){

  # 1. Create a copy of df to be transformed to text
  
  my_df <- df

  # 2. Looping over each column in the data, transform the column
  #    to character format, then replace any `"NA"` values with na = ""
 
  for (col_name in colnames(my_df)) {
 
    col_formatted   <- format(my_df[[col_name]], ...)
    col_na_replaced <- ifelse(
      grepl("NA", col_formatted, fixed = TRUE), 
      na, 
      col_formatted
    )
    my_df[[col_name]] <- col_na_replaced
  }
  
  # 3. Create text representations of the table body and headers. `"\t"` 
  #    means 'new cell' and `"\r\n"` means 'new row'. Don't worry about
  #    `do.call()` - this might be covered in a future week.
  body_text <- do.call(paste, args = c(
    my_df, sep = "\t", collapse = "\r\n"
  ))
  headers_text <- paste(colnames(my_df), collapse = "\t")
  
  # 4. Combine headers and body

  if (headers == FALSE){
    
    paste(body_text, collapse = "\r\n")
    
  } else{

    paste(c(headers_text, body_text), collapse = "\r\n")

  }

}

as_text(starwars)

# 4.4


# Wraps as_text function and copies text to clipboard
to_clipboard <- function(df, ..., na = "", headers = TRUE){

  new_df <- as_text(df, ..., na = na, headers = headers)

  writeClipboard(new_df)

  cat(

    paste("Table copied to clipboard"),

    paste("Rows:       ", nrow(df)),

    paste("Columns:    ", ncol(df)),

    sep = "\n"
  )
  
  invisible(df)

}


to_clipboard(starwars, headers = FALSE)

# Q5 ----------------------------------------------------------------------

# 5.1
# Summarise across selected columns

aggregate <- function(df, ..., .cols, .fn = sum){

  df |> 
  group_by(...) |> 
  summarise(
    across( {{ .cols }} , .fn), 
    .groups = "drop"
  )
}

aggregate(starwars, name, hair_color, .cols = height)

# 5.2

# Summarise across all columns except selected columns
disaggregate <- function(df, ..., .cols, .fn = sum){

  df |> 
  group_by(across(-c(..., {{ .cols }} ))) |> 
  summarise(
    across( {{ .cols }} , .fn), 
    .groups = "drop"
  )
}

disaggregate(starwars, name, hair_color, .cols = c(height, mass))

# 5.3


bar_plot <- function(data, x, y, fill = NULL, fn = mean, facet = NULL, position = "dodge"){
  data |> 
  aggregate({{ y }}, {{ fill }}, .cols = {{ x }}, .fn = fn) |> 
  ggplot(aes( {{ x }} , {{ y }}, fill = {{ fill }} )) +
  geom_col(position = position) +
  facet_wrap(vars( {{ facet }} ))
}

bar_plot(diamonds, price, cut, fill = color)

bar_plot(diamonds, price, cut, fill = color, position = "dodge2")

bar_plot(diamonds, price, cut, fill = color, facet = color)

# Q6 ----------------------------------------------------------------------

# Returns location of input file
search_up <- function(file, dir = getwd()){
  if (file %in% list.files(dir)){
    print(dir)

  } else{
    parent = dir <- dirname(dir)
    search_up(file, dir = parent)
  }
}

search_up("Documents")
