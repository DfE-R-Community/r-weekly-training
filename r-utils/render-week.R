# Render the Rmd files for a set of weeks. These will be rendered
# as `README.md` so they display nicely in Azure DevOps
render_week <- function(week = 0:100, format = "md_document", quiet = TRUE, ...) {
  
  files <- list.files(pattern = paste(
    sprintf("^week-%02.f", week), 
    collapse = "|"
  ))
  
  out <- sapply(files, USE.NAMES = FALSE, FUN = function(week) {
    
    message("Rendering ", week)
    
    rmd <- list.files(week, pattern = "[.]Rmd$", full.names = TRUE)
    
    if (length(rmd) == 0) {
      message("  No .Rmd file to render. Skipping...")
      return(NULL)
    }
    
    if (length(rmd) > 1) {
      message("  Multiple .Rmd files found. Skipping...")
      return(NULL)
    }
    
    rmarkdown::render(rmd, quiet = quiet, output_format = format, ...)
    
  })
  
  invisible(out)
  
}