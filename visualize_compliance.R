#visualize_compliance.R - Rather than reading timestamps from an dataframe to assess trial compliance, 
#this script offers a neat visual alternative.

###ACTION ITEMS: 
#Install and load the required packages
#Set your working directory
#Enter the name of your *.CSV input file
#Rename the upsit and odor scores based on the month of interest

setwd("~/")
library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)
library(readxl)
library(ggforce)

#Read in timestamps
compliancex <- read_excel("complianceIdentify.xlsx")

#Address edge case which did not format correctly
compliancex[150,3] <- "2021-03-25" 

#Parse the all variables 
#(i.e., patient identifier (type = factor); 
#enrollment date (type = date); 
#timestamps (type = date))
compliancex$"Record ID" <- as.factor(as.character(compliancex$"Record ID"))
compliancex$`0` <- as.Date(compliancex$`0`)

col_max = ncol(compliancex)
col_max2 = col_max - 2
compliancex_parse <- compliancex %>% 
  select(4:col_max2)

#Write function to select characters 5 through 15 of each string. Then parse as a date variable.
parser <- function(data) {
  for (i in seq_along(data)) {
    data[[i]] <- str_sub(data[[i]], 5, 15)
    data[[i]] <- parse_date(data[[i]], "%b %d %Y")
  }
  data
}

compliancex_pivot <- tibble(id = compliancex$"Record ID", `0` = compliancex$`0`, parser(compliancex_parse))

#Pivot the dataframe to longer
col_max <- ncol(compliancex_pivot)
compliancex_adherence <- compliancex_pivot %>%
  pivot_longer(c(2:col_max), names_to = "observation", values_to = "date")

#New column, represents the duration of smell training in minutes 
row_max = nrow(compliancex_adherence)
vector_duration = rep(2.5, row_max)
compliancex_adherence$duration <- vector_duration

#Remove empty cells (NA)
compliancex_adherence <- compliancex_adherence %>% na.omit()

#ggplot2 to create compliance plot
compliancex_adherence$weekday <- wday(compliancex_adherence$date, label = TRUE)
compliancex_plot <- ggplot(compliancex_adherence, aes(x = date, y = duration, group = weekday, fill = weekday))
x <- compliancex_plot + geom_col() + facet_wrap_paginate(~ id, nrow = 8, ncol = 8, page = 1) + coord_cartesian(ylim = c(0, 5)) + theme_bw() + ylab("Duration") + xlab("Date") + theme(legend.position="none")
x <- x + scale_x_date(breaks=date_breaks("14 days"), date_labels="%b %d")  

y <- compliancex_plot + geom_col() + facet_wrap_paginate(~ id, nrow = 8, ncol = 8, page = 2) + coord_cartesian(ylim = c(0, 5)) + theme_bw() + ylab("Duration") + xlab("Date") + theme(legend.position="none")
y <- y + scale_x_date(breaks=date_breaks("14 days"), date_labels="%b %d")  

z <- compliancex_plot + geom_col() + facet_wrap_paginate(~ id, nrow = 8, ncol = 8, page = 3) + coord_cartesian(ylim = c(0, 5)) + theme_bw() + ylab("Duration") + xlab("Date") + theme(legend.position="none")
z <- z + scale_x_date(breaks=date_breaks("14 days"), date_labels="%b %d") 

k <- compliancex_plot + geom_col() + facet_wrap_paginate(~ id, nrow = 8, ncol = 8, page = 4) + coord_cartesian(ylim = c(0, 5)) + theme_bw() + ylab("Duration") + xlab("Date") + theme(legend.position="none")
k <- k + scale_x_date(breaks=date_breaks("14 days"), date_labels="%b %d")