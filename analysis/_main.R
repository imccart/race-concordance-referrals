
# Meta --------------------------------------------------------------------

## Title:         Physician Race Concordance and Referrals
## Author:        Swati Asnani & Ian McCarthy
## Date Created:  9/9/2021
## Date Edited:   9/9/2021
## Description:   This file calls all analysis scripts in the relevant order


# Preliminaries -----------------------------------------------------------
if (!require("pacman")) renv::install('pacman')
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stargazer, knitr, kableExtra,
               fixest, modelsummary, broom, tidymodels, data.table, RPostgres, DBI,
               httr, jsonlite, janitor)


# Connect to PostgreSQL ---------------------------------------------------
source('analysis/paths_home.R')
db.connect <- dbConnect(RPostgres::Postgres(), dbname = db, 
                 host=host_db, port=db_port, 
                 user=db_user, password=db_password)
dbListTables(db.connect)


# Import and clean data ---------------------------------------------------

nppes.data <- dbGetQuery(db.connect,"SELECT DISTINCT lastname, firstname FROM nppes_main")
nppes.data <- nppes.data %>%
  mutate(clean_lastname=lastname,
         clean_lastname = str_remove(clean_lastname, "\\s+[IVXLCM]+"),
         clean_lastname = str_remove(clean_lastname, "JR."),
         clean_lastname = str_remove_all(clean_lastname, "\\s+[[:punct:]]"),
         clean_lastname = str_remove_all(clean_lastname, "[[:punct:]]+")) %>%
  clean_names()

clean.names1 <- nppes.data %>% select(lastname, firstname) %>%
  filter(lastname!="" & !is.na(lastname))
clean.names2 <- nppes.data %>% select(lastname, firstname, clean_lastname) %>%
  filter(lastname!=clean_lastname) %>%
  select(clean_lastname, firstname) %>%
  rename(lastname=clean_lastname) %>%
  filter(lastname!="" & !is.na(lastname))


getURL <- function(api, name) {
  root <- "http://www.name-prism.com/api_token/eth/csv/"
  u <- paste0(root, api, "/", name)
  return(URLencode(u))
}

for (i in 1:nrow(clean.names1)) {
  first.name <- clean.names1$firstname[i]
  last.name <- clean.names1$lastname[i]
  name <- paste(first.name, last.name, sep=" ")
  url <- getURL(api, name)
  json.dat <- GET(url)
  data.pull <- fromJSON(rawToChar(json.dat$content))
  new.row <- as_tibble(data.pull) %>%
    mutate(firstname=first.name, lastname=last.name)
  if (i==1) {
    race.dat1 <- new.row
  } else {
    race.dat1 <- bind_rows(race.dat1, new.row)
  }
  Sys.sleep(1)
}


for (i in 1:nrow(clean.names2)) {
  first.name <- clean.names2$firstname[i]
  last.name <- clean.names2$lastname[i]
  name <- paste(first.name, last.name, sep=" ")
  url <- getURL(api, name)
  json.dat <- GET(url)
  data.pull <- fromJSON(rawToChar(json.dat$content))
  new.row <- as_tibble(data.pull) %>%
    mutate(firstname=first.name, lastname=last.name)
  if (i==1) {
    race.dat2 <- new.row
  } else {
    race.dat2 <- bind_rows(race.dat2, new.row)
  }
  Sys.sleep(1)
}
