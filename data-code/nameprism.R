


# Establish postgreSQL connection -----------------------------------------

source('analysis/paths_home.R')
db.connect <- dbConnect(RPostgres::Postgres(), dbname = db, 
                 host=host_db, port=db_port, 
                 user=db_user, password=db_password)
dbListTables(db.connect)


# Import and scrape data ---------------------------------------------------

nppes.data <- dbGetQuery(db.connect,"SELECT DISTINCT lastname, firstname FROM nppes_main")
nppes.data <- nppes.data %>%
  clean_names()

clean.names <- nppes.data %>% select(lastname, firstname) %>%
  filter(lastname!="" & !is.na(lastname))

getURL <- function(api, name) {
  root <- "http://www.name-prism.com/api_token/eth/csv/"
  u <- paste0(root, api, "/", name)
  return(URLencode(u))
}

start=3511358
for (i in start:nrow(clean.names)) {
  first.name <- clean.names$firstname[i]
  last.name <- clean.names$lastname[i]
  last.name <- str_replace(last.name, "04/21/1970","")
  last.name <- str_replace(last.name, "D/B/A MASSAGE MATTERS","")
  name <- paste(first.name, str_replace(last.name, "/", ""), sep=" ")
  url <- getURL(api, name)
  json.dat <- GET(url)
  data.pull <- str_replace(rawToChar(json.dat$content), "2PRACE", "RACE2")
  new.row <- as_tibble(data.pull) %>%
    mutate(firstname=first.name, lastname=last.name)
  write_csv(new.row,file="data/race-dat1.csv",append=TRUE)
  print(i)
  Sys.sleep(0.5)  
}

  
