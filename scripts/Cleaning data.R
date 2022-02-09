#### Preamble ####
# Purpose: Clean Toronto Shelter System Flow data from open data Toronto
# Author: Yahui Zhang
# Date: 6 February 2022
# Contact: yahui.zhang@mail.utoronto.ca
# License: MIT
# Pre-requisites: None

#### Workspace setup ####
install.packages("tidyverse")
install.packages("opendatatoronto")
install.packages("knitr")
install.packages("here")
install.packages("tinytex")
library(tidyverse)
library(opendatatoronto)
library(dplyr)
library(readr)
library(knitr)
library(ggplot2)
library(stringr)
library(here)
library(tinytex)

#### data from open data Toronto ####
# get Toronto Shelter System Flow package
package <- show_package("ac77f532-f18b-427c-905c-4ae87ce69c93")
package

# get all package resources
resources <- list_package_resources("ac77f532-f18b-427c-905c-4ae87ce69c93")

# identify datastore resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv'))

# load the first datastore resource as a sample
data <- filter(datastore_resources, row_number()==1) %>% get_resource()
data

#### Save raw data ####
write_csv(data, "inputs/data/Toronto_Shelter_System_Flow_data.csv")
Toronto_Shelter_System_Flow_data <- read.csv("inputs/data/Toronto_Shelter_System_Flow_data.csv")

#### Data cleaning ####
# remove the id column
Toronto_Shelter_System_Flow_data <- Toronto_Shelter_System_Flow_data[-c(1)]

# remove data collected in the year of 2020 due to missing Indigenous data
Toronto_Shelter_System_Flow_data <-
  Toronto_Shelter_System_Flow_data %>%
  filter(str_detect(date.mmm.yy., '21'))

# change col name for easier read
colnames(Toronto_Shelter_System_Flow_data)[1] <- "month_year"

# remove columns not needed
Toronto_Shelter_System_Flow_data <- Toronto_Shelter_System_Flow_data[-c(3,4,5,7,10,11,12,13,14,15,16)]

# add new variables for the data set
# add percentage of under 16 in the data set
Toronto_Shelter_System_Flow_data <- mutate(Toronto_Shelter_System_Flow_data, percentage_of_under_16 = ageunder16/actively_homeless*100)

# add percentage of moved to housing in the data set
Toronto_Shelter_System_Flow_data <- mutate(Toronto_Shelter_System_Flow_data, percentage_moved_to_housing = moved_to_housing/actively_homeless*100)

# reduce decimal points to a comfortable range 
Toronto_Shelter_System_Flow_data <-
  Toronto_Shelter_System_Flow_data %>%
  mutate_if(is.numeric, round, digits = 1)

#### Save clean data ####
write_csv(Toronto_Shelter_System_Flow_data, "inputs/data/clean_data.csv")