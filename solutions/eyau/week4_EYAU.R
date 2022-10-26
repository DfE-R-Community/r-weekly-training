# ---- Week 4 R Training -------------------------------------------------------
# This week's training exercises was quite difficult - It was hard to understand
# what the questions wanted. Some questions sound the same and some just didn't 
# make sense.


# ---- Load Libraries ----------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))

# ---- 1.1 ---------------------------------------------------------------------
# data we are using = storms

prop_na <- function(x){
  # proportion of `NA` values for x
  return(sum(is.na(x)) / length(x))
}

var_coeff <- function(y){
  # Coefficients of Variation for wind and pressure
  return(sd(y, na.rm = TRUE)/ mean(y, na.rm=TRUE))
}

storms %>% 
  group_by(status) %>% 
  summarise(
    
    # Proportions of `NA` values for ts_diameter and hu_diameter
    ts_diameter_prop_na = prop_na(ts_diameter),
    hu_diameter_prop_na = prop_na(hu_diameter),
    
    # Coefficients of variation for wind and pressure
    wind_var_coeff      = var_coeff(wind),
    pressure_var_coeff  = var_coeff(pressure),
    
    .groups = "drop"
    
  )

# ---- 1.2 ---------------------------------------------------------------------
storms %>%
  group_by(status) %>%
  summarise(
    across(c(ts_diameter, hu_diameter), prop_na, .names = "{.fn}.{.col}"),
    across(c(wind, pressure), var_coeff, .names = "{.fn}.{.col}")
  ,
  .groups = "drop")

# ---- 1.3 ---------------------------------------------------------------------

# Some less-than-ideally formatted dates
dates1 <- c("20220103", "20220415", "20220418")
dates2 <- c("Mon, May 02 2022", "Thu, Jun 02 2022", "Fri, Jun 03 2022")
dates3 <- c("29 August 22", "26 December 22", "27 December 22")

parse_and_format_time <- function(x, parse_format, std_format){
 
  return_list <- list()
  return_list$parsed <- strptime(x, parse_format)
  return_list$standardised <- strftime(return_list$parsed, std_format)
  return(return_list)
}

parse_and_format_time(dates1, "%Y%m%d", "%Y-%m-%d")
parse_and_format_time(dates2, "%a, %b %d %Y", "%Y-%m-%d")
parse_and_format_time(dates3, "%d %B %y", "%Y-%m-%d")


# ---- 1.4 ---------------------------------------------------------------------
# use the same function as earlier

parse_and_format_time(dates1, "%Y%m%d", "%d %B %y")
parse_and_format_time(dates2, "%Y%m%d", "%d %B %y")


# ---- 2.1 ---------------------------------------------------------------------
# I didn't really understand the question, where does Quiet come from?
    
print_info <- function(data, quiet){
  if(quiet == TRUE) return(NULL)
  data %>%
    summarise(Rows = nrow(data), Columns = ncol(data), Total = nrow(data)*ncol(data))
}    
  
print_info(starwars, TRUE)
print_info(starwars, FALSE)

# ---- 2.2 ---------------------------------------------------------------------
gsub2 <- function(string,value, replacement){
  gsub(value, replacement, string)
}
c("string 1", "string 2") %>%
  gsub2("ing", "")

# ---- 2.3 ---------------------------------------------------------------------

gsub2 <- function(string1, string2, value, replacement){
  strings <- paste(string1, string2) 
  strings %>%
    {gsub( value, replacement, ., fixed=TRUE)}
}
gsub2("String 1", "String 2", "ing", " ")

# ---- 3.1 ---------------------------------------------------------------------

either <- function(x,y){
  if(length(x) > 0){
    return(x)
  }else{
    return(y)
  }
}


# ---- 3.2 ---------------------------------------------------------------------

'%or%' <- function(x,y){
  if(length(x) > 0){
    return(x)
  }else{
    return(y)
  }
}

x = c(1,2)
y = c(7,8)
x %or% y

# ---- 3.3 ---------------------------------------------------------------------
x %or% y
x %||% y

x = integer()
x %||% y #returns integer(0)
x %or% y #returns y

x = NULL
x %||% y #returns y
x %or% y #returns y
# ---- 3.4 ---------------------------------------------------------------------

'%splice%' <- function(x,y){
  if(length(x) != length(y)){
    return("They are not the same length!")
  }else{
    c(rbind(x,y))
  }
}

1:3 %splice% 11:13


# ---- 4.1 ---------------------------------------------------------------------

as_text <- function(df, na){
  # 2. Looping over each column in the data, transform the column
  #    to character format, then replace any `"NA"` values with `""`
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
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
  
  all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
  
  return(all_text)
}

df <- dplyr::starwars

as_text(df,"")

# ---- 4.2 ---------------------------------------------------------------------
as_text <- function(df, na, headers = TRUE){
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]])
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
    
  }
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  if (headers == TRUE){
    headers_text <- paste(colnames(df), collapse = "\t")
    all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
  }else{
    all_text <-paste(body_text, collapse = "\r\n")
  }
  return(all_text)
}

as_text(df,"",FALSE)

# ---- 4.3 ---------------------------------------------------------------------
as_text <- function(df, na, headers, ...){
  for (col_name in colnames(df)) {
    
    col_formatted   <- format(df[[col_name]], ...)
    col_na_replaced <- ifelse(col_formatted == "NA", na, col_formatted)
    
    df[[col_name]] <- col_na_replaced
    
  }
  body_text <- do.call(paste, args = c(
    df, sep = "\t", collapse = "\r\n"
  ))
  if (headers == TRUE){
    headers_text <- paste(colnames(df), collapse = "\t")
    all_text <- paste(c(headers_text, body_text), collapse = "\r\n")
  }else{
    all_text <-paste(body_text, collapse = "\r\n")
  }
  return(all_text)
}


# ---- 4.4 ---------------------------------------------------------------------
to_clipboard <- function(df, na, headers, ...){
  astext <- as_text(df,na,headers = headers ,...)
    writeClipboard(astext)
    cat("The clipboard has been updated")
    invisible(df)
}
to_clipboard(starwars, "", headers =FALSE)

# ---- 5.1 ---------------------------------------------------------------------
aggregate <- function(data, ..., .cols, .func = sum){
  data %>%
    group_by(...) %>%
    summarise(across({{.cols}}, .func), .groups = "drop")
}

aggregate(starwars, name, species, .cols = c(mass, height))

# ---- 5.2 ---------------------------------------------------------------------
disaggregate <- function(data, ..., .cols, .func = sum){
  data %>%
    group_by(!select(...)) %>%
    summarise(across({{.cols}},.func) , .groups= "drop")
}

# ---- 5.3 ---------------------------------------------------------------------
bar_plot <- function(data, x, y, fil = NULL, fn = mean){
  aggregate(data, {{y}}, {{fil}}, .cols={{x}}, .func = fn)%>%
    ggplot(aes({{x}}, {{y}}, fill = {{fil}})) +
    geom_col(position = "dodge")
}

bar_plot(diamonds, price, cut, fil = color, fn= mean)

# ---- 5.4 ---------------------------------------------------------------------
bar_plot2 <- function(data, x, y, fil = NULL, fn = mean, facet = NULL, position = "dodge"){
  aggregate(data, {{y}}, {{facet}},{{fil}}, .cols={{x}}, .func = fn)%>%
    ggplot(aes({{x}}, {{y}}, fill = {{fil}})) +
    geom_col(position = position) +
    facet_wrap(vars({{facet}}))
}

bar_plot2(diamonds, price, cut, color, mean, clarity, "dodge")

# ---- 6.1 ---------------------------------------------------------------------
# Haven't had time to do this one
# Will come back to it