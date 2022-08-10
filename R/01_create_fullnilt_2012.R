## Download and process NILT 2012 survey ##

# Date: 10/08/2022
# Author: Rafael Verduzco

# This code downloads and prepares the data to be used for the UG Quants assignment 2 (22/23)

# References  -----------------------------------------------------------------

# https://www.ark.ac.uk/teaching/
# 2012 Good relations: ARK. Northern Ireland Life and Times Survey Teaching Dataset 2012, Good relations [computer file]. ARK www.ark.ac.uk/nilt [distributor], March 2014.
# 2012 LGBT: ARK. Northern Ireland Life and Times Survey Teaching Dataset 2012, LGBT [computer file]. ARK www.ark.ac.uk/teaching [distributor], March 2014.

# Packages -------------------------------------------------------------------

# Install packages if missing
list.of.packages <- c("tidyverse", "moderndive", "jtools", "devtools", "vtable", "devtools")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# # Word count
# devtools::install_github("benmarwick/wordcountaddin", type = "source", dependencies = TRUE)

# Load packages
library(moderndive)
library(tidyverse)
library(haven)

### Download and read data ----------------------------------------------------

# create folder
dir.create('data')
#download data sets
download.file('https://www.ark.ac.uk/teaching/NILT2012GR.sav', 'data/nilt2012.sav', method='curl')
download.file('https://www.ark.ac.uk/teaching/NILT2012LGBT.sav', 'data/nilt2012_2.sav', method = "curl")
# read datasets
nilt_1 <- read_sav("data/nilt2012.sav")
nilt_2 <- read_sav("data/nilt2012_2.sav")

### Join datasets  ------------------------------------------------------------

# drop duplicated columns in nilt_2
nilt_2 <- select(nilt_2, -househld: -healthyr, -wtfactor)
# Join data sets in 1
nilt <- left_join(nilt_1, nilt_2, by = "serial")

# Coerce variables   ---------------------------------------------------------
# Identify numeric variables
unique_levels <- apply(nilt,2,FUN=function(x)length(na.omit(unique(x))) >= 8)
numeric_vars <- names(unique_levels)[unique_levels == TRUE]
# exceptions as numeric
exc_num <- c('highqual', 'tea', 'ansseca')
numeric_vars <- numeric_vars[!numeric_vars %in% exc_num]
numeric_vars <- c(numeric_vars, 'wtfactor')
# Coerce to their type
nilt <- nilt %>% mutate(across(all_of(numeric_vars), as.numeric))
nilt <- nilt %>% mutate(across(!all_of(numeric_vars), as_factor))
# drop unused levels
nilt <- droplevels(nilt)

# Save data ------------------------------------------------------------------
# save as rds
saveRDS(nilt, "data/fullnilt_2012.rds")
# clean global environment
rm(list=ls())

