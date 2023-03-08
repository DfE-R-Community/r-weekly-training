## Load packages
library(tidyverse)


# -------Q1 Writing basic functions ---------

# Define the funcitons prop_na and var_coeff
prop_na <- function(x)
  sum(is.na(x)) / length(x)

var_coeff <- function(x)
  sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)

storms |> 
  group_by(status) |> 
  summarise(
    
    # Proportions of `NA` values for ts_diameter and hu_diameter
    ts_diameter_prop_na = prop_na(ts_diameter),
    hu_diameter_prop_na = prop_na(hu_diameter),
    
    # Coefficients of variation for wind and pressure
    wind_var_coeff      = var_coeff(wind),
    pressure_var_coeff  = var_coeff(pressure),
    
    .groups = "drop"
    
  )

# Now use dplyr::across() to do the same, specifying a list of functions returns a field with "_{functionName}" appended 
storms |> 
  group_by(status) |> 
  summarise(
    across(c(ts_diameter, hu_diameter), list(prop_na = prop_na)),
    across(c(wind, pressure), list(var_coeff = var_coeff)),
    
    .groups = "drop"
  )


# Some less-than-ideally formatted dates
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")
  
# Define function using date vectors and formats as inputs
format_dates <- function(dates, old_format) {
  dates_parsed <- strptime(dates, format=old_format)
  return(strftime(dates_parsed, format = "%Y-%m-%d"))
  }

# Call the function. I would set up a for loop if there were more than 3
dates1_standardised <- format_dates(dates1, "%Y%m%d")
dates2_standardised <- format_dates(dates2, "%a, %b %d %Y")
dates3_standardised <- format_dates(dates3, "%d %B %y")

# Convert dates1 and dates2 to the same format as dates3. 
# Edit the above function as we are no longer standardising, keep same input variables
format_dates2 <- function(dates, old_format) {
  dates_parsed <- strptime(dates, format=old_format)
  return(strftime(dates_parsed, format = "%d %B %y"))
}

dates1_as_dates3 <- format_dates2(dates1, "%Y%m%d")
dates2_as_dates3 <- format_dates2(dates2, "%a, %b %d %Y")

# ---- Q2 Pipeline functions ---------
# The function needs to return an object of the same type as the input
print_info <- function(quiet=FALSE, df, ...) {
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
  df
}

starwars |> 
  print_info(quiet=FALSE) |> 
  count(homeworld, species) |> 
  print_info(quiet=FALSE)

# Create a function gsub2() which wraps gsub() to work well with the pipe. 
# gsub returns the same format with string subsitution applied.
gsub2 <- function(.data, str, str_rep) {
  gsub(str, str_rep, .data)
}
  
# Check
c("string 1", "string 2") |> 
  gsub2("ing", "")

# Alternatively you can call
c("string 1", "string 2") |> 
  gsub("ing", "", .)


# ------ Q3. Infix functions ---------
# Function to return x if it's length is greater than 0, and y otherwise
either <- function(x, y) {
  if (length(x)>0) {
    return(x)
  } else {
    return(y)
  }
}

# Same function as an infix function
'%or%' <- function(x, y) {
  if (length(x)>0) {
    return(x)
  } else {
    return(y)
  }
}

# %||% returns y if x is NULL and returns x otherwise. 
# One gets a different result to %or% when x is of length 0 and not NULL, e.g. integer(), character()


# Create an infix function %splice% which takes two vectors x and y and return a new vector z, 
# which takes the form c(x[1], y[1], x[2], y[2], ...)
'%splice%' <- function(x, y) {
  
  # Set up simple error handling
  if (length(x) != length(y)) {
    stop("Vectors must be of the same length", call. = FALSE)
  }
  
  # rbind seems to do the job
  return(c(rbind(x,y)))
}

# Try it out
1:3 %splice% 11:13

# Create a funciton which returns the LHS unless theres an error, then reutrns rhs
'%|e|%' <- function(x,y) {
  tryCatch(               
    # Specifying expression
    expr = {                     
      x
    },
    # Specifying error message
    error = function(e){         
      y
    }
  )
}

# Replacing the x with an unknown variable in the function above causing an error
1 %|e|% 2


# ------- Q4. Creating a handy utility function ----------

as_text <- function(df, na="", headers = TRUE, ...) {
  # Looping over each column in the data, transform the column
  # to character format, then replace any `"NA"` values with `""`
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]], ...)
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
  }  
  # Create text representations of the table body and headers.
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  headers_text <- paste(colnames(df), collapse = "\t")
  
  # Combine headers and body
  all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
  
  # Allows users to exclude the table headers with the function arguments
  if (headers) {
    return(all_text)
  }
  else {return(body_text)}
  
}

# Call the function, including the arguments for the format function: trim and justify
generated_text <- as_text(starwars, headers=FALSE, trim=FALSE, justify="right")


# Create function writing the generated text to the users clipboard, notifying them and making the funciton pipe compatible
to_clipboard <- function(df, header, ...) {
  txt <- as_text(starwars, headers = header, ...)
  writeClipboard(txt)
  
  # Get information about the table copied, using df as the output table should be of the same size
  rows = nrow(df)
  cols = ncol(df)
  
  # Send message to user
  cat("Generated text copied to clipboard with ", rows, "rows and ", cols, "columns \n")
  
  # keep the input and output of the same type for pipe function
  return(df)
}

to_clipboard(starwars, header=FALSE, trim=FALSE, justify="right")

# ------- Q5. Programming with the tidyverse ----------
# May come back to this another time
