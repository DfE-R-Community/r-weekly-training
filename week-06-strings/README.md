<!-- Please edit README.Rmd - not README.md -->

# Week 06: Strings

Most simple tasks involving text manipulation in R can be done using
functions like `paste()`, `nchar()`, `substr()`, `strsplit()`,
`strrep()`, `nchar()` etc. However, sooner or later you’ll find yourself
needing to solve more complex problems which need more powerful tools.
This is where you’ll begin to need to use **regular expressions** -
often abbreviated to regexps or regexes. Regular expressions can at
first seem overly terse and unintuitive, however, with a bit of practice
you’ll begin to find yourself reaching for them much much more often
than you might think.

# Prerequisites / resouces

-   The [Strings chapter](https://r4ds.had.co.nz/strings.html) of R for
    Data Science gives a good introduction to regular expressions with
    `stringr`

-   The [`{stringr}`
    documentation](https://stringr.tidyverse.org/articles/regular-expressions.html)
    can also be a good reference - particularly if you run into issues
    caused by the use of the wrong regex ‘dialect’

    -   Like most tidyverse packages, `{stringr}` also has a handy
        [cheat
        sheet](https://github.com/rstudio/cheatsheets/blob/main/strings.pdf)
        which can be used as a quick reference.

-   [RegExr](https://regexr.com/) is one of many handy tools for you to
    test your regexes. It also has a ‘reference’ sidebar which can be
    used to quickly find the pattern you need.

-   [Regex Crossword](https://regexcrossword.com/) is a nice set of
    web-games to help cement some regex patterns in your memory

# A note on packages

R has native support for regular expressions with functions like
`grep()`, `grepl()`, `sub()`, `gsub()`, `regexpr()` etc. However, as
with the other problem sheets so far, this one will focus on functions
from the tidyverse, in this case from the `{stringr}` package. Please
try to use functions from `{stringr}` unless a problem states otherwise
:)

    # library(tidyverse) would work just as well
    library(stringr)

# Exercises

## 1. Pattern detection in strings

The `{stringr}` vignette
[“regular-expressions”](https://stringr.tidyverse.org/articles/regular-expressions.html#matching-multiple-characters)
may be useful for these questions, particularly the section on matching
multiple characters.

1.  Use `str_subset()` to find which fruits in the `fruit` dataset
    contain the word ‘berry’. Your code should look something like this:

        str_subset(fruit, "your-regular-expression-here")

2.  Now, adjust your regex to include only fruits where ‘berry’ is not
    its own word. E.g, your result should include `"blackberry"` but not
    `"goji berry"` (Hint: `"[^abc]"` matches any character *except* a, b
    or c)

3.  Create a new regex to find all fruits which start with an a, b or c
    *and* end with an x, y or z. (Hint: `"^"` matches the start of a
    string and `"$"` matches the end)

4.  Use `str_subset()` to find all the strings in the `sentences`
    dataset which contain words with 10 or more characters. Follow this
    by a call to `str_extract()` to extract just those words. (Hint:
    `"z{3}"` will match the string `"zzz"`)

5.  Use `str_extract_all()` to find all the words in the `sentences`
    dataset that start and end with vowels. (Hints: `"\\b"` can be used
    to detect the beginning or end of a word. `"a*"` matches 0 or more
    repeating ‘a’ characters, but `"a?"` only matches 0 or 1. You’ll
    also need to take care that your regular expression matches
    single-character words like ‘a’).

## 2. Some nice `{stringr}` features

1.  **Features of `str_replace()`**

    Before trying these questions, please read the documentation for
    `str_replace()` and look at the examples.

    1.  Use `str_replace_all()` to replace all instances of the word
        ‘berry’ in the `fruits` dataset with `"\033[31mberry\033[39m"`
        (to see why you might want to do this, try
        `your_result %>% cat(sep = "\n")`)

    2.  Now use `str_replace_all()` to apply the transformation from
        part 1 to the first word in every sentence from the `sentences`
        dataset. (Hint: see what this does:
        `str_replace_all("string", "(i)", "!\\1!")`)

    3.  Use `str_replace_all()` to make the first word of every sentence
        in the `sentences` dataset upper-case. (Hint:
        `str_replace_all()` can take a function as the `replacement`
        argument)

    4.  The following string uses lots of abbreviations. Use
        `str_replace_all()` to replace all these abbreviations by
        supplying a named character vector as the `pattern` argument:

            lazy_sentence <- paste(
              "Bush Sr. was born in Milton, MA. & Bush Jr. was born in New Haven, CT.",
              "They served respectively as 41st & 43rd presidents of the USA."
            )

2.  `{stringr}` has lots of convenience functions. Use `str_squish()`,
    `str_to_sentence()`, `str_wrap()`, `str_split()`, `str_pad()` and
    `str_c()` on the following string to:

    -   Remove unnecessary whitespace
    -   Convert to sentence-case
    -   ‘Wrap’ the string into lines of 10 or less characters
    -   Break the string up to give a character vector where breaks
        occur wherever there is a linebreak
    -   Pad each line with whitespace so that each line is exactly 10
        characters
    -   ‘Collapse’ the vector back into a single string, re-adding the
        linebreaks in the process.

    <!-- -->

        messy_sentence <- "  the  quick brown  FOx  jumps ovEr the Lazy  dog        "

    Once done, Use `cat()` to view the printed output.

## 3. Creating custom functions

1.  Create a function `validate_password()` that takes a string and
    returns `TRUE`/`FALSE` to indicate whether it is a valid password.
    It should check that the password:

    -   Has at least 8 characters
    -   Contains at least two upper-case and two lower-case characters
    -   Contains at least one punctuation character
    -   Does not contain `/` or `\`

    (Hint: You may find `str_count()` handy here)

2.  Using functions from `stringr()`, create a custom function
    `str_to_snake()` which converts camelCase strings to snake\_case.
    E.g. it should have the following behaviour:

        str_to_snake(c("thisIsStringOne", "anotherAwkwardString"))

        #> [1] "this_is_string_one"      "another_awkward_string"

3.  **Bonus Question** Create a function `my_glue()` that mimics the
    behaviour of `glue::glue()`. This question is fairly tough, but if
    you have the time it’s worth a shot as it covers lots of interesting
    and useful techniques.

    -   Your function will need to accept a string and extract anything
        in the string that falls within sets of `"{}"` curly brackets

    -   It should then evaluate these extracted chunks. You can do this
        using `eval()`. You’ll need to pass an appropriate *environment*
        for this to work reliably - have a look at how `glue::glue()`
        gets the environment to use.

    -   It should then reinsert the evaluated code chunks into the
        string and return this as the output.

    -   Once you’ve done this, see what extra features `glue::glue()`
        has and try and implement some of them. E.g. add `.open` and
        `.close` arguments, and maybe a `.transformer` argument.

    Here’s how `glue::glue()` works:

        x <- 1
        y <- 2
        glue::glue("The value of x is {x}, y is {y} and x + y is {x + y}")

        #> The value of x is 1, y is 2 and x + y is 3

## 4. Regex good practice

Even for seasoned regex veterans, deciphering regular expressions that
have already been written can be challenging. For this reason it’s worth
thinking about how you can make your regexes easier for other analysts,
including future you, to understand. This section will introduce some
techniques to help with this.

1.  The following regular expression matches email addresses\*:

        email_regex <- "^([^\\s@])+@[^\\s@]+\\.[^\\s@]+$"

    Read the ‘Comments’ section of
    [`vignette("regular-expressions", package = "stringr")`](https://stringr.tidyverse.org/articles/regular-expressions.html#comments)
    and create a documented version of `email_regex` using
    `"(?...)"`-style comments.

    \*Actually, this is massively simplified. You can find a real-world
    email regex
    [here](https://stackoverflow.com/questions/37703864/regular-expression-to-validate-an-email-in-perl)

2.  Do the same, but this time use the`regex(comments = TRUE)` method.

3.  A third option for writing clear regexes is to break them down using
    `glue::glue()` and add comments using normal R code. This also has
    the advantage of allowing you to interpolate other values into the
    string, allowing the reader to focus more on the pattern being
    specified and less on the syntax of the regex. A demonstration is as
    follows:

        # Regex that specifies some acceptable greetings
        greetings <- "\\((hello|hi|hey|howdy)!?\\)"

        re <- glue::glue(
          "^[abc]+" ,        # One or more 'a's, 'b's or 'c's at the start
          "[xyz]?" ,         # Maybe an 'x', 'y' or 'z'
          "\\.{greetings}",  # Then '.(hello!)' (this is string interpolation)
          "\\s?",            # Maybe a whitespace
          "(and goodbye)?$"  # Maybe 'and goodbye' then the end of the string
        )

        str_detect("aabbaacc.(howdy!)and goodbye", re)

        #> [1] TRUE

    Using this technique, combine the following strings into a regular
    expression that can be used to check whether dates conform to a
    certain standard. Make sure to comment your regex!

        # Helpers: 
        # 1. Join inputs together using "|"
        # 2. Surround inputs with parentheses
        collapse  <- function(...) paste(..., sep = "|", collapse = "|")
        group     <- function(...) paste0("(", ..., ")")

        # Regexes for years, month numbers and day numbers
        year      <- group("\\d{4}")
        month_num <- paste0("(0?", group(collapse(1:12)), ")") # Possible leading zeros 
        day_num   <- paste0("(0?", group(collapse(1:31)), ")") # Possible leading zeros

        # Regex for full and abbreviated month labels
        month_lab <- group(collapse(
            "Jan(uary)?", "Feb(ruary)?",    "Mar(ch)?",    "Apr(il)?",         
                   "May",     "Jun(e)?",     "Jul(y)?",   "Aug(ust)?", 
          "Sep(tember)?",  "Oct(ober)?", "Nov(ember)?", "Dec(ember)?"
        ))

        # Regex for full and abbreviated day labels
        day_lab   <- group(collapse(
            "Sun(day)?", "Mon(day)?",  "Tue(sday)?", "Wed(nesday)?", 
          "Thu(rsday)?", "Fri(day)?", "Sat(urday)?"
        ))

        # Regex for allowed separators
        separator <- "[\\s.,-/]"


        # -- Checking your solution ------------------------------------------------
        # Any solution which matches/doesn't match the following strings will be 
        # accepted:
        should_match     <- c("01.Jan.1991", "wed, 03 february 2002", "31-Jun")
        should_not_match <- c("25122022", "2002, 03 Feb", "  Jan 1 2020")

4.  **Bonus question**: [`{rex}`](https://rex.r-lib.org/index.html) is a
    package for creating regular expressions in a way which is designed
    to be much more readable/maintainable than what we’ve covered in
    these questions. Read through some of the documentation and try
    using `rex::rex()` to rewrite your solution to part 3.

<!-- 3.  The following vector of names does not follow a standardised formatting.  -->
<!--     Create a function `standardise_name()` which transforms each name into  -->
<!--     the format "(title if applicable) <last-name>, <intial 1>.<initial 2. if applicable>  <("nickname" if applicable)>". -->
<!--     E.g. 'Simpson, Homer Jay' would become 'Simpson, H.J.' and -->
<!--     'Simpson, Margaret \"Maggie\" Evelyn Lenny' would  -->
<!--     become 'Simpson, M.E.L ("Maggie")'. -->
<!--     ```{r} -->
<!--     characters <- c( -->
<!--       "Simpson, Homer Jay ", -->
<!--       "Simpson, Marge Jacqueline", -->
<!--       "Simpson, Bartholomew \"Bart\" JoJo  ", -->
<!--       "Simpson, Lisa Marie ", -->
<!--       "Simpson, Margaret \"Maggie\" Evelyn Lenny", -->
<!--       "Abraham Jebediah Simpson", -->
<!--       "Apu Nahasapeemapetilon", -->
<!--       "Barney Gumble", -->
<!--       "Chf. Clancy Wiggum", -->
<!--       "Dewey Largo", -->
<!--       "Carl Carlson", -->
<!--       "Lenny Leonard", -->
<!--       "Edna Krabappel", -->
<!--       "Powell, Janey", -->
<!--       "Jasper Beardly", -->
<!--       "Kent Brockman", -->
<!--       "Prince, Martin", -->
<!--       "Moe Szyslak", -->
<!--       "Van Houten, Milhouse", -->
<!--       "Dr. Nick Riviera" -->
<!--     ) -->
<!--     ``` -->
