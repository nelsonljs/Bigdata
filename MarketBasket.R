pacman::p_load(tidyverse, neo4r, igraph, visNetwork, arules, arulesViz)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
recipes_ingredients = read.csv('sampledf.csv', as.is = TRUE)

mydf = recipes_ingredients[,c(5:15)]
write.csv(mydf,"mybaskets.csv")

#### Start Market basket analysis
# Require a csv of items bought(ingredients used), each row is a transaction (recipe)

tr <- read.transactions('mybaskets.csv', format = 'basket', sep=',', skip = 1)

tr
summary(tr)

itemFrequencyPlot(tr, topN=20, type='absolute')

rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8))
rules <- sort(rules, by='confidence', decreasing = TRUE)
summary(rules)
inspect(rules[1:10])

topRules <- rules[1:10]
plot(topRules)
plot(topRules, method="graph")

myvect = as.vector(t(as.matrix(mydf)))

#######
# Using igraph
#######

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

#########
# Using visNetwork
#########

#nodes is a dataframe with columns: id, label, group, value (size), shape, title, color, shadow
mynodes = data.frame(id = 1:length(unique(myvect)),
                   label = unique(myvect))
nodes = nodes %>%
  mutate(group = case_when(label %in% mydf$Recipe ~ "Recipe",
                           TRUE ~ "Ingredient")) %>%
  mutate(value = case_when(group == "Recipe" ~ 2,
                           TRUE ~ 1),
         shape = case_when(group == "Recipe" ~ "square",
                           TRUE ~ "circle"),
         title = label,
         color = case_when(group == "Recipe" ~ "darkblue",
                           TRUE ~ "yellow"),
         shadow = case_when(group == "Recipe" ~ TRUE,
                            TRUE ~ FALSE))

mydf2 = left_join(mydf, mynodes, by = c("Recipe" = "label"))
mydf2 = left_join(mydf2, mynodes, by = c("Ingredient" = "label"))
edges = mydf2 %>%
  select(id.x, id.y) %>%
  `colnames<-`(c("from","to"))

visNetwork(nodes, edges, height = "1000px", width = "100%")
