# Week 10: S3 Classes

Introduce S3 classes and how these can be used to help with bigger/more
complex programming tasks. Not completely sure if this chapter is needed
or not… But I think you can get a lot of easy-wins with these concepts.
E.g.

    library(dplyr, warn.conflicts = FALSE)

    my_cars <- as_tibble(mtcars)
    class(my_cars) <- c("my_tibble", class(my_cars))

    print.my_tibble <- function(x, ...) {
      cat("A data.frame with the following column summaries:\n\n")
      print(summary(x))
      invisible(x)
    }

    my_cars

    #> # A tibble: 32 x 11
    #>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
    #>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    #>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
    #>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
    #>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
    #>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
    #>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
    #>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
    #>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
    #>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
    #>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
    #> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
    #> # ... with 22 more rows
