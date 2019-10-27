pacman::p_load(tidyverse, neo4r, igraph)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
recipes_ingredients = read.csv('Recipe_Ingredients_Graph.csv', as.is = TRUE)

mydf = recipes_ingredients %>%
  select(-X) %>%
  filter(Recipe %in% c("Orange Buns", "Dilly Bread"))

myvect = as.vector(t(as.matrix(mydf)))

g2 = graph_from_data_frame(mydf, directed = FALSE)
plot(g2)

#coerce our graph
myvertices = as_data_frame(g2, what = "vertices")
myvertices = myvertices %>%
  mutate(type = case_when(name %in% mydf$Recipe ~ "Recipe",
                          TRUE ~ "Ingredient"))

V(g2)$type = myvertices$type
V(g2)$size <- ifelse(V(g2)$type == "Recipe", 40,15)
V(g2)$color <- ifelse(V(g2)$type == "Recipe", "steel blue","yellow")
V(g2)$shape <- ifelse(V(g2)$type == "Recipe", "square","circle")
plot(g2, edge.arrow.size=.5, vertex.label.color="black")

##########
#Interfacing with neo4J,
#Make sure your neo4J is open, and the cluster is STARTED
library(neo4r)
con <- neo4j_api$new(
  url = "http://localhost:7474",
  user = "neo4j",
  password = "1234"
)

con$ping() #If 200, connection is alive.
con$get_labels()

'MATCH (u1:recipes {name:"Orange Buns"})--(i:ingredients) RETURN DISTINCT u1, i' %>%
  call_neo4j(con)

### Sample Cypher query
'MATCH (u1:recipes)--(i:ingredients {name:"white sugar"})--(u2:recipes)
MATCH (u1:recipes)--(i1:ingredients {name:"salt"})--(u2:recipes)
MATCH (u1:recipes)--(i2:ingredients {name:"active dry yeast"})--(u2:recipes)
RETURN DISTINCT u1, u2, i, i1, i2 LIMIT 25;' %>%
  call_neo4j(con) -> a1

##########
# To disconnecy
rm(con)
