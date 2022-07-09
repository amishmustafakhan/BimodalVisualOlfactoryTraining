# !/usr/bin/env Rscript
# VOLT_randomize.R - Automated scoring and categorization of pre/post UPSIT responses. 

###ACTION ITEMS: 
#Install and load the required packages
#Set your working directory
#Enter the name of your *.CSV input file
#Rename the upsit and odor scores based on the month of interest

setwd("~/")
library(tidyverse)
library(dplyr)
library(RCurl)
library(jsonlite)

volt <- postForm(
  uri='https://redcap.wustl.edu/redcap/api/',
  token='', #Redacted - Insert API token to access REDCap Project
  content='record',
  format='json',
  type='flat',
  rawOrLabel='raw',
  rawOrLabelHeaders='raw',
  exportCheckboxLabel='false',
  exportSurveyFields='true',
  exportDataAccessGroups='false',
  returnFormat='json'
)

volt <- fromJSON(volt) %>% as.data.frame

#Load comma delimited .CSV file from REDCap. Enter the name of your *.CSV file here. 
upsit_key <- c('2', '2', '4', '4', '3', '2', '1', '2', '3', '2', '3', '2', '1', '4', '2', '4', '1', '1', '2', '3', '1', '1', '2', '1', '2', '3', '4', '2', '2', '4', '4', '3', '3', '1', '4', '4', '1', '4', '2', '1')

#Change "0" (PRE) to "1" (POST) as needed
upsit_scores <- volt %>% 
  dplyr::select(upsit_1_0_v2:upsit_40_0_v2)

#Match participant answers to answer key, output is number of correct responses
mcq <- function(data, key) {
  bool <- vector("logical", length(data))
  for (i in seq_along(data)){
    bool[i] <- data[i] == key[i]
    upsit_result <- sum(bool)
  }
upsit_result  
}

#Iterate across all participants
upsit_result <- tibble(id = volt$record_id, upsit = apply(upsit_scores, 1, function(x) mcq(data = x, key = upsit_key)))
upsit_result[upsit_result==0] <- NA 
upsit_result <- upsit_result %>% na.omit()
    
#Group participants based on UPSIT scores
upsit_result %>% 
    mutate(
      class = ifelse(gender == 1,
      case_when(
        upsit <= 5 ~ "Malingering",
        upsit > 5 & upsit <= 18 ~ "Anosmic",
        upsit > 18 & upsit <= 25 ~ "Severe Hyposmic",
        upsit > 25 & upsit <= 29 ~ "Moderate Hyposmic",
        upsit > 29 & upsit <= 33 ~ "Mild Hyposmic",
        upsit > 33 ~ "Normosmic"
        ),
      case_when(
        upsit <= 5 ~ "Malingering",
        upsit > 5 & upsit <= 18 ~ "Anosmic",
        upsit > 18 & upsit <= 25 ~ "Severe Hyposmic",
        upsit > 25 & upsit <= 30 ~ "Moderate Hyposmic",
        upsit > 30 & upsit <= 34 ~ "Mild Hyposmic",
        upsit > 34 ~ "Normosmic"
        )
      )
    )

view(volt_result)
