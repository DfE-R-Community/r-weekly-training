suppressPackageStartupMessages(library(tidyverse))


# 1) Writing Basic Functions ----------------------------------------------

# 1),2)

# Computes the proportion of values in a vector which are NA
prop_na <- function(x) sum(is.na(x))/length(x)
# Calculates the coefficient of variation
var_coeff <- function(x) sd(x,na.rm = TRUE)/mean(x,na.rm = TRUE)

storms |> 
  group_by(status) |> 
  summarise(
    
    # Proportions of `NA` values for ts_diameter and hu_diameter
    across(c(ts_diameter, hu_diameter), prop_na, .names = "{.col}_prop_na"),
    
    # Coefficients of variation for wind and pressure
    across(c(wind, pressure), var_coeff, .names = "{.col}_var_coeff"),
    
    .groups = "drop"
    
  )

# 3)

# Some less-than-ideally formatted dates
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")

strpftime <- function(date_string, input_format, output_format){
  date_string_parsed <- strptime(date_string, input_format)
  date_string_formatted <- strftime(date_string_parsed, output_format)
  date_string_formatted
}


# 4)

dates1_formatted <- strpftime(dates1, "%Y%m%d", "%d %B %y")
dates2_formatted <- strpftime(dates2, "%a, %b %d %Y", "%d %B %y")

# 2) Pipeable functions --------------------------------------------------

# 1)
print_info <- function(df, quiet = FALSE, ...) {
  if (!quiet) {
    cat(...,
        paste("Rows:       ", nrow(df)),
        paste("Columns:    ", ncol(df)),
        paste("Total cells:", nrow(df) * ncol(df)),
        sep = "\n")
  }
  invisible(df)
}

# 2)

gsub2 <- function(x, pattern, replacement, ...){
  gsub(pattern, replacement, x, ...)
}
c("string 1", "string 2") |>
  gsub2("ing", "")

# 3)
c("string 1", "string 2") |>
  gsub("ing", "", .)

# 3) Infix functions ------------------------------------------------------

# 1)

# Function which displays x if x is length > 0 and y if not
either <- function(x,y) ifelse(length(x) > 0, return(x), return(y))

# If we didn't include the 'return', only the first element of x/y will
# be returned if their length is > 1

# 2)

`%or%` <- function(x,y) ifelse(length(x) > 0, return(x), return(y))

# 3)

x <- integer(0)
y <- 5

# Since %||% only returns y when x is NULL, having x be another value that's
# not NULL but still length 0, such as integer(0), will produce a different
# results for %or%

# 4)

`%splice%` <- function(x,y){
  
  if(length(x)==length(y)){
    
    spliced <- lapply(
      1:(length(x)*2),
      function(s){
        ifelse(s%%2, x[(s+1)/2], y[s/2])
      }
    )
    
    unlist(spliced)
  
  }else{
    
    stop("x and y must be two vectors of the same length")
    
  }
}

# 5)

`%|e|%` <- function(x,y){
  out <- tryCatch(
    x,
    error = function(cond) {
      message("There is an issue with your x that's causing an error:")
      message(cond)
      message("\nreturning y...")
      y
    },
    warning = function(cond) {
      message("Your x caused a warning:")
      message(cond)
      message("\nreturning y...")
      y
    }
  )    
  out
}

# 4) Creating a handy utility function ------------------------------------


as_text <- function(df, na = "", headers = TRUE, ...){
  
  # Looping over each column in the data, transform the column
  # to character format, then replace any `"NA"` values with `""`
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]], ...)
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
  
  }
  
  # Create text representations of the table body and headers. `"\t"` 
  # means 'new cell' and `"\r\n"` means 'new row'
  body_text <- do.call(
    paste,
    args = c(df, sep = "\t", collapse = "\r\n")
    )
  
  if (headers){
    headers_text <- paste(colnames(df), collapse = "\t")
    all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
  }else{
    all_text <- body_text
  }
  
  all_text
}

to_clipboard <- function(df, na = "", headers = TRUE, ...){
  as_text(df, na, headers, ...) |> writeClipboard()
  cat(
    "The formatted data frame (", nrow(df)," x ", ncol(df),
    ") has been copied to the clipboard ",
    ifelse(headers ,"", "(no headers)"),
    sep = ""
    )
  invisible(df)
}


# 5) Programming with the tidyverse ---------------------------------------

# 1)

aggregate <- function(df, .cols, ..., .fn = sum){
  df |> 
  group_by(...) |> 
  summarise(
    across({{.cols}}, .fn), 
    .groups = "drop"
  )
}


# 2)


disaggregate <- function(df, .cols, ..., .fn = sum){
  df |> 
    group_by(across(-c(.cols, ...))) |> 
    summarise(
      across({{.cols}}, .fn), 
      .groups = "drop"
    )
}

# 3),4)


bar_plot <- function(data,
                     x,
                     y,
                     fill = NULL,
                     fn = mean,
                     facet = NULL,
                     position = "dodge"){
  data |>
    aggregate(.cols = {{y}}, {{fill}}, {{x}}, .fn = fn) |>
    ggplot(aes({{y}}, {{x}}, fill = {{fill}})) +
    geom_col(position = position) +
    facet_wrap(vars({{facet}}))
}


# 5) Recursive Functions --------------------------------------------------

search_up <- function(file, dir = getwd()){
  if(`%in%`(file,list.files(dir))){
    paste(dir,file,sep = "")
  }else{
    if(dirname(dir) == dir){
      NULL
    }else{
      search_up(file, dir = dirname(dir))
    }
  }
}
