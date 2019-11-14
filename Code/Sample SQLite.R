pacman::p_load(dplyr, tidyverse, ggplot2, reshape2, RSQLite, stringr, rjson)

#set wd to this R file's current folder.
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(DBI)
# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), dbname = "billboard-200.db")

dbListTables(con)
dbListFields(con, "acoustic_features")

abc = dbReadTable(con, "acoustic_features")
def = dbReadTable(con, "albums")
head(abc)
# You can fetch all results:
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)

dbClearResult(res)

# Or a chunk at a time
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
while(!dbHasCompleted(res)){
  chunk <- dbFetch(res, n = 5)
  print(nrow(chunk))
}

# Clear the result
dbClearResult(res)

# Disconnect from the database
dbDisconnect(con)

#reading csvs
abc = read.csv("ratings_Toys_and_Games.csv", as.is = TRUE)

#reading json
result = paste(readLines("amazon_games_reviews.json", n=3000), collapse = ",")
result = sprintf("[%s]", result)
result <- fromJSON(result)
result = cbind(select(result,-helpful), helpful = do.call(rbind,result$helpful))
#write.csv(result, file = "amazon-video-game-sample-3000.csv")

result2 = readLines("meta_Video_Games.json", n=50)
result2 = str_replace_all(result2, "\\'","\"")
data_raw <- sapply(result2, fromJSON)
data3 = rjson::fromJSON(result2[[2]])
result2 <- fromJSON(result2)
