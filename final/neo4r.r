library("neo4r")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Create Neo4R connection
con <- neo4j_api$new(
  url = "http://localhost:7474",
  user = "neo4j",
  password = "1234"
)

#If 200, connection is alive.
con$ping() 


#let's try to load csv into neo4j, loading speed is slow
#remember to have file at this directory
#C:/dev/neo4jDatabases/database-4e41d0df-39cb-4ef9-ba9d-5f5e573f4ae2/installation-3.5.6/import
path <- "file:///graph_shared.csv"

a = c("salt", "sugar")

load_code <- paste("MERGE (r1:recipeA {name:line.recipeA})",
                   "MERGE (r2:recipeB {name:line.recipeB})",
                   "MERGE (r1)-[:SIMILAR]-(r2)",
                   "RETURN r1, r2", sep = " ")
load_csv(on_load = load_code, con = con, url = path, header = TRUE, as = "line")

tuning_code = paste("CREATE CONSTRAINT ON (r:recipe) ASSERT r.name IS UNIQUE",
                    "CREATE INDEX ON :recipe(name)"

# "MATCH (r1:recipe {name: "Jalapeno Cheese Bread"})
# MATCH (r2:recipe {name: "Sun Dried Tomato and Asiago Cheese Bread"})
# RETURN algo.linkprediction.commonNeighbors(r1, r2) AS score"
                    
load_code1 %>%.
  call_neo4j(con)
load_code2 %>% 
  call_neo4j(con)

con$get_labels()