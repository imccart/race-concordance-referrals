
# Meta --------------------------------------------------------------------

## Title:         Physician Race Concordance and Referrals
## Author:        Swati Asnani & Ian McCarthy
## Date Created:  9/9/2021
## Date Edited:   1/10/2022
## Description:   This file calls all analysis scripts in the relevant order


# Preliminaries -----------------------------------------------------------
if (!require("pacman")) renv::install('pacman')
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stargazer, knitr, kableExtra,
               fixest, modelsummary, broom, tidymodels, data.table, RPostgres, DBI,
               httr, jsonlite, janitor)



# Build data --------------------------------------------------------------
source("data-code/nameprism.R")


# Clean race data ---------------------------------------------------------
final.dat <- read_csv(file="data/race-dat1.csv",
                      col_names=c("nameprism","firstname","lastname")) %>%
  separate(nameprism, sep="\n", into=c("two_race","hispanic","api","black","indian","white")) %>%
  separate(two_race, sep=",", into=c("cat1","two_race")) %>%
  separate(hispanic, sep=",", into=c("cat2","hispanic")) %>%
  separate(api, sep=",", into=c("cat3","api")) %>%
  separate(black, sep=",", into=c("cat4","black")) %>%
  separate(indian, sep=",", into=c("cat5","indian")) %>%
  separate(white, sep=",", into=c("cat6","white")) %>%
  select(lastname, firstname, two_race, hispanic, api, black, indian, white)

final.dat <- final.dat %>% 
  mutate(across(c("two_race","hispanic","api","black","indian","white"), as.numeric)) %>%
  mutate(
    black_5=case_when(
      black>.05 ~ 1,
      TRUE ~ 0),
    black_10=case_when(
      black>=0.1 ~ 1,
      TRUE ~ 0),
    black_25=case_when(
      black>=0.25 ~ 1,
      TRUE ~ 0))


sumtable(final.dat, vars=c("hispanic","api","black","indian","white"),
         summ=c('notNA(x)','countNA(x)','mean(x)','sd(x)','pctile(x)[10]',
                           'pctile(x)[20]','pctile(x)[30]','pctile(x)[40]','pctile(x)[50]',
                           'pctile(x)[60]','pctile(x)[70]','pctile(x)[80]','pctile(x)[90]'))

sumtable(final.dat, vars=c("black","black_5","black_10","black_25"),
         summ=c('notNA(x)','countNA(x)','mean(x)'))

ggplot(data=final.dat, aes(x=black)) +
  geom_histogram(aes(y=..density..), colour="black", fill="grey45") +
  geom_density(col="blue", size=.5) + theme_bw()

ggplot(data=final.dat) +
  geom_density(aes(x=black), col="blue", size=.5) + 
  geom_density(aes(x=black_10), col="red", size=.5) + theme_bw()

