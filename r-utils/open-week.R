# Helper function to open a particular week/weeks in RStudio. This can otherwise
# be a slight pain, particularly if you need to make the same edit to every
# file
open_week <- function(week = 0:100, open = TRUE) {
  
  files <- list.files(pattern = paste(
    sprintf("^week-%02.f", week), 
    collapse = "|"
  ))
  
  rmds <- sort(sapply(
    files, list.files, pattern = "[.]Rmd$", full.names = TRUE, USE.NAMES = FALSE
  ))
  
  if (length(rmds) > 0 && open) lapply(rmds, file.edit)
  
  if (open) invisible(rmds) else rmds
  
}