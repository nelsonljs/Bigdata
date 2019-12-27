pacman::p_load(igraph, visNetwork, tidyverse, ggraph, tidygraph, networkD3, lsa)

#df = read.csv("C:/Users/KE/Desktop/Ing.csv", stringsAsFactors = FALSE)
dfE = read.csv("C:/Users/KE/Documents/GitHub/NUS/Bigdata/final/igraph KE/Ing.csv", stringsAsFactors = FALSE, encoding = "UTF-8")

dfE <- dfE %>%
  filter(!grepl(pattern = 'John*', Recipe))


#df1 <- head(dfE, 100)
df1 <- dfE



df1 %>%
  filter(Ingredient %in% c('thyme')) %>%
  distinct(Recipe) -> Query_Rec; df1 %>%
  filter(Recipe %in% Query_Rec$Recipe)%>%
  distinct(Ingredient) -> Query_Ing; df1 %>%
  filter(Ingredient %in% Query_Ing$Ingredient) %>%
  distinct(Recipe) %>%
  count()


####Recipe and Ingredients####
nodes <- data.frame(id = c(unique(df1$Recipe), unique(df1$Ingredient)), group = c(rep("Recipe", length(unique(df1$Recipe))), rep("Ingredients", length(unique(df1$Ingredient)))))
edges <- data.frame(from = df1$Recipe, to = df1$Ingredient)


g <- graph_from_data_frame(df1, directed = F)
data <- toVisNetworkData(g)

#visNetwork(data$nodes, data$edges) %>%
visNetwork(nodes, edges) %>%
  visGroups(groupname = "Recipe", color = list(background = "darkseagreen", border = "darkslategray")) %>%
  visNodes(color = list(highlight = "red")) %>%
  visEdges(color = list(highlight = "red")) %>%
  #visIgraphLayout(type = "full") %>%
  #visIgraphLayout(layout = "layout_in_circle") %>%
  #visIgraphLayout(layout = "layout_with_sugiyama") %>% 
  visInteraction(hover = TRUE, selectConnectedEdges = TRUE, navigationButtons = TRUE) %>%
  visOptions(highlightNearest = list(enabled = TRUE, degree = 2, hideColor = 'rgba(200,200,200,0)', labelOnly = FALSE), nodesIdSelection = TRUE) %>% #, selectedBy = "group") %>%
  visPhysics(solver = "forceAtlas2Based", forceAtlas2Based = list(gravitationalConstant = -10))
  #visPhysics(stabilization = TRUE)
  #visPhysics(solver = "repulsion")
  #visClusteringByHubsize()


#  visConfigure(enabled = TRUE)

# var options = {
#   "nodes": {
#     "color": {
#       "border": "rgba(76,156,233,1)",
#       "highlight": {
#         "border": "rgba(233,20,50,1)",
#         "background": "rgba(255,121,152,1)"
#       },
#       "hover": {
#         "border": "rgba(255,143,0,1)",
#         "background": "rgba(255,204,73,1)"
#       }
#     },
#     "shape": "dot"
#   },
#   "edges": {
#     "color": {
#       "color": "rgba(59,128,132,1)",
#       "highlight": "rgba(132,119,46,1)",
#       "inherit": false
#     },
#     "smooth": {
#       "forceDirection": "none"
#     }
#   },
#   "physics": {
#     "minVelocity": 0.75
#   }
# }



# ggraph(tbl_graph(df1, directed = F), layout = "graphopt") + 
#   geom_node_point() +
#   geom_edge_link(alpha = 0.8) + 
#   scale_edge_width(range = c(0.2, 2)) +
#   geom_node_text(aes(label = df1$Ingredient), repel = TRUE) +
#   labs(edge_width = "phone.call") +
#   theme_graph()


simpleNetwork(df1, height="100px", width="100px", charge = -100, zoom = T)



b <- as.data.frame(betweenness(g))



plot(edge.betweenness.community(g), g, layout = layout_with_dh, vertex.size = 3, vertex.label.dist = 0.5, vertex.label = ifelse(V(g)$name %in% V(g)$name[1:12], V(g)$name, NA))

plot(leading.eigenvector.community(g), g, layout = layout_with_dh, vertex.size = 3, vertex.label.dist = 0.5, vertex.label = ifelse(V(g)$name %in% V(g)$name[1:12], V(g)$name, NA))

plot(walktrap.community(g), g, layout = layout_with_dh, vertex.size = 3, vertex.label.dist = 0.5, vertex.label = ifelse(V(g)$name %in% V(g)$name[1:12], V(g)$name, NA))






# # Make a correlation matrix:
# mat <- cor(t(mtcars[,c(1,3:6)]))
# # Keep only high correlations
# mat[mat<0.995] <- 0
# 
# # Make an Igraph object from this matrix:
# network <- graph_from_adjacency_matrix( mat, weighted=T, mode="undirected", diag=F)
# 
# # Basic chart
# plot(network)


####Cluster####

graph <- graph.data.frame(df1, directed = F)
graph <- simplify(graph)

gc <- fastgreedy.community(graph)
gc <- edge.betweenness.community(graph)
#gc = cluster_optimal(graph)
modularity(gc)
#membership(gc)

V(graph)$community <- gc$membership

nodes <- data.frame(id = V(graph)$name, 
                    title = V(graph)$name, 
                    community = V(graph)$community, 
                    group = c(rep("Recipe", length(unique(df1$Source))), rep("Ingredients", length(unique(df1$Target))))
                    )

nodes <- nodes[order(nodes$id, decreasing = F),]
edges <- get.data.frame(graph, what = "edges")[1:2]


visNetwork(nodes, edges) %>%
  visGroups(groupname = "Recipe", color = list(background = "darkseagreen", border = "darkslategray")) %>%
  #visClusteringByColor(colors = V(graph)$community) %>%
  #visClusteringByConnection(nodes = 9) %>%
  #visClusteringByGroup(groups = V(graph)$community, label = "Group : ", shape = "ellipse", color = "blue", force = F) %>%
  
  visNodes(color = list(highlight = "red")) %>%
  visEdges(color = list(highlight = "red")) %>%
  
  #visIgraphLayout(type = "full") %>%
  #visIgraphLayout(layout = "layout_in_circle") %>%
  #visIgraphLayout(layout = "layout_with_sugiyama") %>% 
  visInteraction(hover = TRUE, selectConnectedEdges = TRUE, navigationButtons = TRUE) %>%
  visOptions(highlightNearest = list(enabled = TRUE, degree = 2, hideColor = 'rgba(200, 200, 200, 0.3)', labelOnly = FALSE), nodesIdSelection = TRUE) %>% #, selectedBy = "group") %>%
  visPhysics(solver = "forceAtlas2Based", forceAtlas2Based = list(gravitationalConstant = -10))
#visPhysics(stabilization = TRUE)
#visPhysics(solver = "repulsion")
#visClusteringByHubsize()





####Cluster####

graph <- graph.data.frame(df1, directed = F)
graph <- simplify(graph)

gc <- edge.betweenness.community(graph)
gc <- leading.eigenvector.community(graph)
gc <- walktrap.community(graph)
#gc <- fastgreedy.community(graph)

#gc = cluster_optimal(graph)
modularity(gc)
#membership(gc)

V(graph)$community <- gc$membership
V(graph)$name

graph_comm <- as.data.frame(cbind(V(graph)$name, V(graph)$community))
colnames(graph_comm) <- c("Ingredient", "group")

graph_comm <- full_join(dfE, graph_comm)


graph_comm %>%
  filter(Ingredient == 'cardamom') %>%
  select(group) %>%
  distinct() -> Query_Group; graph_comm %>%
  filter(group == Query_Group$group & Recipe != "NA") %>%
  distinct(Recipe)


nodes1 <- data.frame(id = V(graph)$name, 
                    title = V(graph)$name,
                    group = V(graph)$community, 
                    group = c(rep("Recipe", length(unique(df1$Recipe))), rep("Ingredients", length(unique(df1$Ingredient)))))


nodes1 <- nodes1[order(nodes1$id, decreasing = F),]
edges <- get.data.frame(graph, what = "edges")[1:2]


visNetwork(nodes1, edges) %>%
  visGroups(groupname = "Recipe", shape = "triangle") %>%
  visNodes(color = list(highlight = "red")) %>%
  visEdges(color = list(highlight = "red")) %>%
  
  #visIgraphLayout(type = "full") %>%
  #visIgraphLayout(layout = "layout_in_circle") %>%
  #visIgraphLayout(layout = "layout_with_sugiyama") %>% 
  visInteraction(hover = TRUE, selectConnectedEdges = TRUE, navigationButtons = TRUE) %>%
  visOptions(highlightNearest = list(enabled = TRUE, degree = 2, hideColor = 'rgba(200, 200, 200, 0.3)', labelOnly = FALSE), nodesIdSelection = TRUE) %>% #, selectedBy = "group") %>%
  visPhysics(solver = "forceAtlas2Based", forceAtlas2Based = list(gravitationalConstant = -10))
#visPhysics(stabilization = TRUE)
#visPhysics(solver = "repulsion")
#visClusteringByHubsize()


centr_degree(graph)
closeness(graph)
max(closeness(graph))

library(CINNA)

calculate_centralities(zachary, include = proper_centralities(graph)[1:5])


