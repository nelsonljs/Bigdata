pacman::p_load(neo4r, magrittr, dplyr, tidyverse, r2d3, readr)
#devtools::install_github("nicolewhite/RNeo4j") #RNeo4j

#Connect to neo4j
con <- neo4j_api$new(
  url = "http://localhost:11009", #7474
  user = "neo4j", 
  password = "test"
)

#Return connection status
ifelse(con$ping(), 
       "Connected to neo4j")

#Load csv
path = 'C:/Users/KE/Desktop/RI.csv'
df = read.csv(path, stringsAsFactors = FALSE)


#Search query
query = c("salt", "sugar")

df %>%
  filter(Ingredients %in% query)

df %>%
  #filter(Ingredients %in% query) %>%
  arrange(Ingredients) %>%
  summarize_at(vars(starts_with("string")))


#To delete existing graph
"MATCH (n) DETACH DELETE (n)" %>%
  call_neo4j(con)

####To edit 411 nodes with 1795 relationships
upload = "CREATE (n: Recipe), (m: Ingredients) 
SET m = row,
n.Recipe = toString(row.Recipe), 
m.Ingredients = toString(row.Ingredients)
MERGE (r:Recipe {name:row.Recipe})
MERGE (i:Ingredients {name:row.Ingredients})
MERGE (r)-[c:contains]->(i);"


load_csv(url = 'file:/Users/KE/Desktop/RI.csv', con = con, header = TRUE, periodic_commit = 50, as = "row", on_load = upload)

#format_csv(df, col_names = TRUE, quote_escape = 'none')

# LOAD CSV WITH HEADERS FROM "file:///C:/Users/KE/Desktop/RI.csv" AS row
# MERGE (r:Recipe {name:row.Recipe})
# MERGE (i:ingredients {name:row.Ingredients})
# MERGE (r)-[c:CONTAINS]->(i);

# MATCH (a:recipes)-[c:CONTAINS]->(b:ingredients)
# RETURN a as recipe, b as ingredients

con$get_labels()
con$get_relationships()

query = "Babka I"
paste("MATCH (r:Recipe {name:'", query, "'})-[:CONTAINS]->(Ingredients) RETURN Ingredients.name LIMIT 25", sep = "") %>%
  call_neo4j(con, type = "row", output = "r")


