####----Install packages----####
#install.packages("pacman")
pacman::p_load(tidyverse, shiny, shinyjs, stringr, DT, visNetwork, rjson, sergeant)

#install.packages('rsconnect')
#to deploy the app
#library(rsconnect)
#deployApp()
#terminateApp()

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

####----Connection to Drill database----####
##Connection configuration##
db_conn <- src_drill("localhost")

####----Retrieval of data----####
##Retrieve from local file
#tbl(db_conn, "dfs.`/home/centos/BigData/03_ingestion/recipes*.json`")

##Retrieve all from hdfs
# db_results <- tbl(db_conn,
#                   "hdfs.food.`recipes*.json`") %>%
#   as.data.frame()%>%
#   head()

##Retrieve all from Drill database in HDFS
db_food <- tbl(db_conn,
               "hdfs.food.`Recipe`") %>%
  as.data.frame() 


flavourslist = read.delim("Overall_Master.txt", stringsAsFactors = FALSE, header = FALSE) %>%
  `colnames<-`('Ingredients')

db_Ing <- tbl(db_conn,
              "hdfs.food.`Ing`") %>%
  as.data.frame() 

names(db_Ing)[names(db_Ing) == "Ingredient"] <- "ingredients"

ing_results <- db_Ing %>%
  select(ingredients) %>%
  mutate(ingredients = strsplit(as.character(ingredients), ",")) %>% 
  unnest(ingredients) #%>%
#distinct()

##Display list all ingredients
# IoTpantry = as.data.frame(c('egg','basil','lobster','poppy seed','mustard','apple','blueberry','prawn','fish')) %>%
#   `colnames<-`('Ingredients')

IoTpantry = as.data.frame(c('apple','parsley','mint', 'sugar', 'salt')) %>%
  
#IoTpantry = as.data.frame(c('blueberry','basil','lobster','poppy seed','mustard','apple')) %>%
  `colnames<-`('Pantry')

#recipes_id = read.csv("small_sample.csv", header = TRUE, stringsAsFactors = FALSE) %>%
recipes_id = db_food #%>%
#select(-X)
# recipes_ingredients = read.csv('Recipe_Ingredients_Graph.csv', as.is = TRUE) #This is for graph recommendations
# recipes_ingredients = recipes_ingredients %>%
#   select(-X)
#####

cleanstr = function(mystr) {
  #split string from python.
  mystr = str_replace(mystr, '\\[','')
  mystr = str_replace(mystr, '\\]','')
  str_split(mystr,'\', ')
}

updatePage = function(chosenRecipe) {
  myDT = recipes_id %>%
    filter(title == chosenRecipe)
  
  recipetable = DT::datatable(
      myDT %>%
        select(title, description, rating_stars, review_count, url) %>%
        `colnames<-`(c('Recipe','Description','Average Rating','Number of Ratings','URL')) %>%
        gather("Properties",""),
      class = "table-primary",
      options = list(dom = 't',
                     pageLength = 10),
      rownames = FALSE
    )
  recipeimg = c('<img src="',recipes_id %>%
                               filter(title == chosenRecipe) %>% pull(photo_url),'"width="380" height="300">')
  
  recipeInstructions = DT::datatable(
      as.data.frame(cleanstr(myDT %>% pull(instructions))) %>%
        `colnames<-`('Instructions'),
      options = list(dom = 't',
                     pageLength = 20)
    )
  recipeIngredients = DT::datatable(
      as.data.frame(cleanstr(myDT %>% pull(ingredients))) %>%
        `colnames<-`('Ingredients'),
      options = list(dom = 't',
                     pageLength = 20),
      rownames = FALSE)
  return(list(recipetable, recipeimg, recipeIngredients, recipeInstructions))
}

updaterecipes = function(input) {
  ###### DRILL QUERY 
  db_conn <- src_drill("localhost")
  
  ##Retrieve all from Drill database in HDFS
  db_food <- tbl(db_conn,
                 "hdfs.food.`Recipe`") %>%
    as.data.frame() 
  
  dt = db_food
  
  #recipes_id = read.csv("labelled_df.csv", as.is = TRUE)

  if (input$isVegan) {
    dt = dt %>%
      filter(vegetarian_label == 1)
  }
  if (input$isNuts) {
    dt = dt %>%
      filter(nut_label == 0)
  }
  if (input$isDairy) {
    dt = dt %>%
      filter(lactose == 0)
  }
  if (input$isSeafood) {
    dt = dt %>%
      filter(seafood == 0)
  }
  return(dt)
}

function(input, output, session) {
  rvs = reactiveValues(recipes = NULL,
                       ingredients = NULL,
                       myrecipes = c('Zucchini Walnut Bread','Orange Buns','Dilly Bread',
                                     'Babka I',"Grandma Cornish's Whole Wheat Potato Bread","Honey White Bread"),
                       recipetable = NULL,
                       recipeimg = NULL,
                       recipeIngredients = NULL,
                       recipeInstructions = NULL)
######
# When the Apply button is clicked, Compute the graph
  observeEvent(input$selectRecipe1, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$myrecipes[1])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  }) # Individual buttons below the relevant recipes. To update recommendations tab.
  observeEvent(input$selectRecipe2, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$myrecipes[2])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe3, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$myrecipes[3])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe4, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$myrecipes[4])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe5, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$myrecipes[5])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe6, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$myrecipes[6])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$RecipeButton, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(input$ManualSelect)
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  
  observeEvent(input$useIOT, {
    if (input$useIOT) {
      shinyjs::show("IOTTable")
      shinyjs::disable("IngredientsInput")
    }
    else {
      shinyjs::hide("IOTTable")
      shinyjs::enable("IngredientsInput")}
  })
  
  observeEvent(input$Return, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "User Selection")
  }) #Button on the Recommendations page.
  
  observeEvent(c(input$randomRecipe, input$updateRecipes), {
    rvs$myrecipes = recipes_id %>% 
      pull(title) %>% 
      sample(6)
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "User Selection")
  }) #Randomise input. This is for testing.
  
  observeEvent(input$updateRecipes, {
    vegetarian_label = 0
    nut_label = 1
    lactose = 1
    seafood = 1
    if (input$isVegan) {
      vegetarian_label = 1
    }
    if (input$isNuts) {
      nut_label = 0
    }
    if (input$isDairy) {
      lactose = 0
    }
    if (input$isSeafood) {
      seafood = 0
    }
    # ####----Retrieval from database----####
    # # query_star = 4.5
    # # 
    # # query = str_replace_all(
    # #   string = (paste0('SELECT * FROM `Recipe` 
    # #                 GROUP BY title 
    # #                 HAVING time_scraped=MAX(time_scraped) 
    # #                 AND rating_stars >', query_star,
    # #                 'AND vegetarian_label >=', vegetarian_label,
    # #                 'AND nut_label <=', nut_label,
    # #                 'AND lactose <=', lactose,
    # #                 'AND seafood <=', seafood)),
    # #   pattern = "\n",
    # #   replacement = "")
    # 
    # 
    # # results <- sqldf(x = query)
    
    db_food <- tbl(db_conn,
                   "hdfs.food.`Recipe`") %>%
      as.data.frame() 
    
    recipes_id = db_food
    
    # recipes_id <<- read.csv("small_sample.csv", header = TRUE, stringsAsFactors = FALSE) %>%
    #   select(-X)
    
    ######
    recipes_id = updaterecipes(input)
    updateSelectInput(session, 'ManualSelect', choices = c('',recipes_id %>% pull(title)))
  }) #Update recipes button
  
  observeEvent(input$Reset, {
    shinyjs::reset("selection-panel")
  })   #when the Reset button is clicked, remove all input values
  output$IOTTable = DT::renderDataTable(IoTpantry, rownames = FALSE,
                                        class = "table-success",
                                        options = list(dom = 't',
                                                       paging = FALSE))

  output$myquery = renderText(paste("SELECT * FROM hdfs.food.`Recipe` WHERE",
                                    "MIN RATING >", input$MinRecipeRating, ",",
                                    "MIN RATING COUNT >", input$MinRatingCount, ",",
                                    "ISVEGAN is", input$isVegan, ",",
                                    "ISNUTS is", !input$isNuts, ",",
                                    "ISSEAFOOD is", !input$isSeafood, ",",
                                    "ISBAKE is", !input$isBake, ",",
                                    "ISDEEPFRY is", !input$isDeepfry, ","
                              ))
  
  output$imgurl1 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[1]) %>% pull(photo_url),'"width="150" height="150">')}) #Update the pictures of all recipes.
  output$imgurl2 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[2]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl3 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[3]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl4 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[4]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl5 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[5]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl6 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[6]) %>% pull(photo_url),'"width="150" height="150">')})

  output$recipename1 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',rvs$myrecipes[1], '</p>')})
  output$recipename2 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',rvs$myrecipes[2], '</p>')})
  output$recipename3 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',rvs$myrecipes[3], '</p>')})
  output$recipename4 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',rvs$myrecipes[4], '</p>')})
  output$recipename5 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',rvs$myrecipes[5], '</p>')})
  output$recipename6 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',rvs$myrecipes[6], '</p>')})
  
  output$recipetable = DT::renderDataTable(rvs$recipetable)
  output$img = renderText(rvs$recipeimg)
  output$instructions = DT::renderDataTable(rvs$recipeInstructions)
  output$ingredients = DT::renderDataTable(rvs$recipeIngredients)
  
  output$IOTTable = DT::renderDataTable(IoTpantry, rownames = FALSE,
                                        class = "table-borderless",
                                        options = list(dom = 't',
                                                       paging = FALSE))
  
  output$mygraph = renderVisNetwork({
    # minimal example
    mydf = recipes_id %>%
      filter(title %in% rvs$myrecipes) %>%
      select(title,ingredients)
    
    myedges = data.frame(from = character(),
                         to = character())
    
    ingredients = recipes_id %>%
      filter(title %in% rvs$myrecipes) %>%
      pull(ingredients)
    for (i in 1:6) {
      a = str_match(mydf[i,2], flavourslist$Ingredients)
      for (j in a[!is.na(a)]) {
        myedges = rbind(myedges, data.frame(from = mydf[i,1], to = j))
      }
    }
    myedges[,1] = as.character(myedges[,1])
    myedges[,2] = as.character(myedges[,2])
    nodes <- data.frame(id = as.character(unique(myedges %>% gather() %>% pull(value))),
                        label = as.character(unique(myedges %>% gather() %>% pull(value))))
    
    nodes[,"id"] = as.character(nodes[,"id"]) 
    nodes = nodes %>%
      mutate(group = case_when(label %in% mydf$title ~ "Recipe",
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
    
    visNetwork(nodes, myedges)
  })
  output$test = renderText(input$RecipeButton)
}

# 
# #Load packages
# #install.packages("pacman", dependencies = TRUE)
# library(pacman)
# pacman::p_load(DBI, rJava, RJDBC)
# 
# pacman::p_load(neo4r, magrittr, dplyr, tidyverse, r2d3, readr)
# #devtools::install_github("nicolewhite/RNeo4j") #RNeo4j
# 
# #Connect to neo4j
# con <- neo4j_api$new(
#   url = "http://localhost:7474", #11009", #7474
#   user = "food", 
#   password = "food"
# )
# 
# #Return connection status
# ifelse(con$ping(), 
#        "Connected to neo4j")
# 
# #Search query
# query = c("salt", "sugar")
# 
# db_Ing %>%
#   filter(ingredients %in% query)
# 
# 
# #To delete existing graph
# "MATCH (n) DETACH DELETE (n)" %>%
#   call_neo4j(con)
# 
# #Load graph to neo4j
# neo_csv_path = paste0('file:///home/centos/BigData/02_cleaning/', list.files("/home/centos/BigData/02_cleaning", pattern="Ing*", all.files=FALSE, full.names=FALSE))
# 
# neo_query =
#   paste("MERGE (r:recipe {name:row.Recipe})",
#         "MERGE (i:ingredient {name:row.Ingredient})",
#         "MERGE (r)-[:CONTAINS]-(i)",
#         "RETURN r, i", sep = " ")
# 
# load_csv(url = neo_csv_path, con = con, header = TRUE, periodic_commit = 50, as = "row", on_load = neo_query)
# 
# 
# #con$get_labels()
# #con$get_relationships()
# 
# 
# df_neo <- paste("MATCH (n) RETURN n", sep = "") %>%
#   call_neo4j(con, type = "row", output = "r") %>%
#   as.data.frame()
# 
# df_neo <- as.data.frame(df_neo)
# 
# # query = "Babka I"
# # paste("MATCH (r:Recipe {name:'", query, "'})-[:CONTAINS]->(Ingredient) RETURN Ingredient.name LIMIT 25", sep = "") %>%
# #   call_neo4j(con, type = "row", output = "r")
# 
# 
# 
# 
# 
# 
# ####----Retrieval from database----####
# # query_star = 4.5
# # 
# # query = str_replace_all(
# #   string = (paste0('SELECT * FROM `Recipe` 
# #                 GROUP BY title 
# #                 HAVING time_scraped=MAX(time_scraped) 
# #                 AND rating_stars >', query_star)),
# #   pattern = "\n",
# #   replacement = "")
# 
# 
# # results <- sqldf(x = query)