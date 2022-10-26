library(tidyverse)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
display.brewer.all(colorblindFriendly = TRUE)
library(scales)
library(geomtextpath)
library(ggpointdensity)
library(ggthemes)
library(patchwork)
#----------Q1.1----------------------------------------------
#Storing data just to visualise better
txhousing2 <- txhousing
#shows only unique xcities to pick out the counties
  unique(txhousing$city)

#table filtered to only show the counties
Counties_1.1 <- txhousing%>%
  filter (city == c("Brazoria County", "Collin County", "Denton County","NE Tarrant County",
                    "Montgomery County"))


#---------Q1.2-----------------------------------------------

#Creating a line graph with only counties
ggplot(data = Counties_1.1, aes(x=date, y=median, color = city))+
  geom_line(linetype = "dotted")+ geom_point()

#-------Q1.3------------------------------------------------

#Mapping the whole group of cities within the table, thi includes
#all that are not counties
ggplot(data = Counties_1.1, 
       aes(x=date, y=median, colour = city))+
          geom_line(linetype = "dotted")+ 
          geom_line(txhousing2, mapping = aes(group = city),
          colour = "dark grey")+
          geom_point()

#-------Q1.4---------------------------------------------------

#colour brewer are colourblind friendly colour combinations
#Used labels for the Y axis
#applied theme_dark as apposed to theme grey
#created labels for the axis
ggplot(data = Counties_1.1, aes(x=date, y=median, colour = city))+
  geom_line(linetype = "dotted")+ 
  geom_line(txhousing2, mapping = aes(group = city),
                                            colour = "dark grey") + geom_point(size = 3)+
  scale_colour_brewer(palette = "Set2") + theme_dark()+
  scale_y_continuous(labels = label_dollar()) +
  labs(
    colour = "Counties",
    x = "Date",
    y = "Median",
    title = "Median house price for counties over time"
  )

#------Q2.1----------------------------------------------------

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
economics_View <- economics

#Tried with Summarise (could not figure out why it didn't work)
#economics_rescale_2.1 <- economics_View %>% 
#  summarise (pce = rescale01(pce),
#          pop = rescale01(pop),
#          psavert = rescale01(psavert),
#          uempmed = rescale01(uempmed),
#          unemploy = rescale01(unemploy))


#Used group by to group all columns and resize using the function above
economics_rescale_2.1 <- economics_View %>% 
  group_by (pce = rescale01(pce),
             pop = rescale01(pop),
             psavert = rescale01(psavert),
             uempmed = rescale01(uempmed),
             unemploy = rescale01(unemploy))

#------Q2.2--------------------------------------------------

#Each line represents a different column on the Y axis against th date. 
#Each line is a different colour
ggplot(data = economics_rescale_2.1) +
  geom_line( mapping = aes( x = date, y = pce), colour = 'blue') +
  geom_line( mapping = aes( x = date, y = pop), colour = 'pink') +
  geom_line( mapping = aes( x = date, y = unemploy), colour = 'green') +
  geom_line( mapping = aes( x = date, y = uempmed), colour = 'orange') +
  geom_line( mapping = aes( x = date, y = psavert), colour = 'yellow') 


#------Q2.3-------------------------------------------------

#using pivot longer to put all the columns into a a column called variable
#I have then created a new column with the re-scaled values
economics_reformat_2.3 <- economics_View %>%
  pivot_longer(c('pce', 'pop', 'psavert', 'uempmed', 'unemploy'), 
               names_to = "variable", values_to = "value") %>%
                group_by(variable)%>%
                mutate(value01 = rescale01(value))%>%
                ungroup()

#-------Q2.4-------------------------------------------------

# due to the columns being pivoted, cannot assign each column with a column 
#so setting the colour to each variable of the dataset
ggplot(data = economics_reformat_2.3) +
  geom_line( mapping = aes( x = date, y = value01, colour = variable))


#-------Q3.1-------------------------------------------------

#moved the colour legend
#titles and lables have been added
#Changing elements sizes
#colourblind friendly colours used
#light blue background used
ggplot(data = economics_reformat_2.3) +
  geom_line(mapping = aes( x = date, y = value01, colour = variable)) +
  
  scale_colour_brewer(palette = "Set2") + theme_dark()+
  labs(
    colour = "Counties",
    x = "Date",
    y = "Rescaled Value",
    title = "Rescaled values of variables over time",
    subtitle = "Rescaled values against Date")+
      theme ( legend.position = "bottom", 
              legend.background = element_rect(fil = "lightgrey"), 
              panel.background = element_rect(fil = "lightblue"), 
              plot.title = element_text(size = 17))


#------Q3.2----------------------------------------------------

#I changed the element_text size and angle to make the graph much clearer
suppressPackageStartupMessages(library(tidyverse))

mpg %>% 
  ggplot(aes(manufacturer)) +
  geom_bar() + theme(axis.text.x  = element_text(angle = 90, size = 12))


#-----Q4.1-----------------------------------------------------
#to view table more easily
diamonds_view <- diamonds

#using geomtextpath by first installing package
#I have added labels directly into ggplot
#I used geom_textdensity to add the text directly to the line graph
#I also changed the size to make the line text more clear
#I have used theme to remove the colour legend
ggplot(diamonds, aes(depth, label = cut, colour = cut)) +
  geom_density()+
  geom_textdensity(size = 3) +
  xlim(55, 70) +
  theme ( legend.position ="none")

#-----Q4.2-----------------------------------------------------

#Installed ggpointdensity package
#used geom_pointdensity to show a density gradient
#ALso changed the and shape of points to improve the look
txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity(size = 0.5, shape = 3, adjust = 2)+
  theme ( legend.position = "none")

#> Warning: Removed 1426 rows containing missing values (geom_point).


#---Q4.3--------------------------------------------------------

#Installed ggthemes package I then chose an appropriate theme 
#for each plot

#diamonds plot------------
diamonds_view <- diamonds
ggplot(diamonds, aes(depth, label = cut, colour = cut)) +
  geom_density()+
  geom_textdensity(size = 3) +
  xlim(55, 70) +
  theme ( legend.position = "none")+
  theme_calc()

#Txhousing plot----------
txhousing %>% 
  ggplot(aes(log(sales), log(listings))) +
  geom_pointdensity(size = 0.5, shape = 3, adjust = 2)+
  theme ( legend.position = "none")+
  theme_gdocs()

#----Q4.4--------------------------------------------------------

#Installed patchwork package
#Stored the Diamond plot
Plot1_Diamonds <- ggplot(diamonds, aes(depth, label = cut, colour = cut)) +
  geom_density()+
  geom_textdensity(size = 3) +
  xlim(55, 70) +
  theme ( legend.position = "none")+
  theme_calc()

#Stored the housing plot
Plot2_Housing <-   ggplot(txhousing, aes(log(sales), log(listings))) +
  geom_pointdensity(size = 0.5, shape = 3, adjust = 2)+
  theme ( legend.position = "none")+
  theme_gdocs()

#Output the Diamond plot above the Housing plot
Plot1_Diamonds / Plot2_Housing

#----Q5.1--------------------------------------------------------

#Putting the colour assignment within geom_plot which successfully
#Outputed the points the correct colour
ggplot(diamonds, aes(carat, price)) +
  geom_point(colour = "blue")


#ggplot(diamonds, aes(carat, price, colour = "blue")) +
# geom_point() + scale_colour_identity()

#----Q5.2---------------------------------------------------------

df <- tibble(x = c("1", "2", "3", "4", "5"), y = 1:5)

#Madegroup equal 1 and put inside geom_line
ggplot(df, aes(x=x, y=y) ) + geom_line(group = 0)

#---Q5.3---------------------------------------------------------
#Could not get to work
#df2 <- df%>%
 # mutate(x)

#ggplot(df2, aes(x=x, y=y) ) + geom_line(group = 0)
#----------------------------------------------------------------

#I struggled a bit with question 5 So I will go back to them and
#complete Q5.1, 3, 4 and 5