
# Meta --------------------------------------------------------------------

## Title:         Physician Race Concordance and Referrals
## Author:        Swati Asnani & Ian McCarthy
## Date Created:  9/9/2021
## Date Edited:   9/9/2021
## Description:   This file calls all analysis scripts in the relevant order


# Preliminaries -----------------------------------------------------------
if (!require("pacman")) renv::install('pacman')
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stargazer, knitr, kableExtra,
               fixest, modelsummary, broom, tidymodels, data.table, RPostgres, DBI)


# Connect to PostgreSQL ---------------------------------------------------
source('analysis/paths_home.R')
db.connect <- dbConnect(RPostgres::Postgres(), dbname = db, 
                 host=host_db, port=db_port, 
                 user=db_user, password=db_password)
dbListTables(db.connect)


# Import and clean data ---------------------------------------------------

nppes.data <- dbReadTable(db.connect,'nppes_main')
nppes.data <- as_tibble(nppes.data)
