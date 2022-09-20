<!-- Please edit README.Rmd - not README.md -->

# Week 00: Getting Started

This is a preliminary week to guide you through the steps needed to get
going with R/RStudio on your DfE laptop. If you’ve already done this you
can feel free to skip this - although it might be a good idea to check
your installations are up to date if you haven’t used the software for a
few months.

# Installing R/RStudio

R and RStudio are distinct pieces of software. R is the language, while
RStudio is an *Integrated Development Environment* or *IDE* which is
designed to work very well with R, although it has some support for
other languages. There are other IDEs available, and it is even possible
to run R from your machine console without using an IDE at all. However,
RStudio is the most widely used platform for R for very good reasons,
and we strongly recommend you start there.

## Download from the Software Centre

To download R and RStudio, simply open the Software Centre (this should
be an existing app on your PC) and download from there. If for any
reason you can’t see R or RStudio available, you’ll need to make a
[service
request](https://dfe.service-now.com/serviceportal?id=sc_category&catalog_id=-1)
to get access to the software.

# Navigating RStudio

Note: For more tips on how to make the most of RStudio see the [RStudio
website](https://www.rstudio.com/products/rstudio/).

## RStudio Layout

When opening RStudio for the first time, you should see something like
this: ![RStudio Window](/week-00-setup/rstudio-layout.PNG)

### Top Left

-   Source - This is the pane you may not see on initial opening. This
    is where you work on files.

### Top Right

-   Environment - This is where you can see objects in the loadspace
    (functions, dataframes etc.).
-   History - A record of any commands you have used
-   Connections - Any connections to SQL databases you have made.

### Bottom Left

-   Console - This is where you enter your R code.
-   Terminal - This is where you can enter secure shell commands.

### Bottom Right

-   Files - Any files in your current working directory.
-   Plots - Any graphs you make in ‘Console’ appear here.
-   Packages - Any packages you have installed to R.
-   Help - Support on any package/function you don’t understand. A place
    without judgement.
-   Viewer - A place for viewing local web content.

# Running Code

Running code means telling RStudio to carry out the actions you have
specified in your script. ‘Run Selected Line(s)’ under ‘Code’ runs any
lines your cursor highlights. There is also a button on the ‘Source’
pane titled ‘Run’ that does this, as does the shortcut Ctrl + Shift +
Enter (Mac ⇧⌘↩). There are many options for running different chunks of
code under ‘Run Region’ under ‘Code’:

-   Run from beginning to line - If your cursor was on line 17, it would
    run to that line inclusive - Ctrl + Alt + B (Mac ⌥⌘B).
-   Run from line to end - If your cursor was on line 17, it would run
    from that line to the end.
-   Run function definition - If your cursor is on a function, it runs
    that function - Ctrl + Alt + F (Mac ⌥⌘F).
-   Run code section - R runs the section your cursor is currently
    within - Ctrl + Alt + T (Mac ⌥⌘T).
-   Run All - Runs the whole document - Ctrl + Alt + R (Mac ⌥⌘R). Code
    that is run appears in the ‘Console’ pane and any variables created
    in the ‘Environment’ pane. ![RStudio
    Console](/week-00-setup/rstudio-console-environment.PNG)

# Changing the Theme

The default RStudio theme is very white and a bit blinding, but there
are lots of alternative themes available which are a bit easier on the
eyes. Go to ‘Tools’ -&gt; ‘Global Options’ -&gt; ‘Appearance’ to change
the theme. My favourite is ‘Cobalt’ :)

# Installing Packages

Packages are the mechanism by which users can extend R and make the
features they add available to others. Certain packages are extremely
widely used, so it’s good to know how to download them. Try installing
dplyr by running the following in your RStudio console

    install.packages("dplyr")

If this went okay you may want to install the whole tidyverse - this is
a suite of packages that is very widely used, so installing it now will
probably save you time later (though it takes a few minutes):

    install.packages("tidyverse")

**Note:** As a general rule you should never include
`install.packages()` in an R *script*. This is so that others (including
future you) who run your code don’t accidentally end up changing the
software on their own PC, which could have unintended consequences. If
you want to install a package, do so from the console (the bottom-left
window), not from the ‘source’ (top-left) window.
