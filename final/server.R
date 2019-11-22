####----Install packages----####
#install.packages("pacman")
pacman::p_load(tidyverse, shiny, shinyjs, stringr, DT, visNetwork, rjson, sergeant, sparkR)

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
db_results <- tbl(db_conn,
    "hdfs.food.`food`") %>%
  as.data.frame() 



####----Retrieval from database----####
# query_star = 4.5
# 
# query = str_replace_all(
#   string = (paste0('SELECT * FROM `food` 
#                 GROUP BY title 
#                 HAVING time_scraped=MAX(time_scraped) 
#                 AND rating_stars >', query_star)),
#   pattern = "\n",
#   replacement = "")


# results <- sqldf(x = query)


##Display list all ingredients
# IoTpantry = as.data.frame(c('egg','basil','lobster','poppy seed','mustard','apple','blueberry','prawn','fish')) %>%
#   `colnames<-`('Ingredients')

IoTpantry = db_results %>%
  dplyr::select(ingredients) %>%
  dplyr::group_by(ingredients) %>%
  dplyr::summarize(count = n()) %>% 
  dplyr::arrange(desc(count), ingredients) %>% #Sorted by most common then alphabetical
  dplyr::select(ingredients) %>%
  `colnames<-`('Ingredients')


#recipes_id = read.csv("small_sample.csv", header = TRUE, stringsAsFactors = FALSE) %>%
recipes_id = db_results #%>%
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
  })
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
  
  observeEvent(input$Return, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "User Selection")
  })
  observeEvent(c(input$randomRecipe, input$updateRecipes), {
    rvs$myrecipes = recipes_id %>% 
      pull(title) %>% 
      sample(6)
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "User Selection")
  })
  
  observeEvent(input$updateRecipes, {
    ###### DRILL QUERY HERE
    #recipes_id <<- read.csv("small_sample.csv", header = TRUE, stringsAsFactors = FALSE) %>%
    recipes_id = db_results #%>%
      #select(-X)
    ######
    updateSelectInput(session, 'ManualSelect', choices = c('',recipes_id %>% pull(title)))
  })
  #when the Reset button is clicked, remove all input values
  observeEvent(input$Reset, {
    shinyjs::reset("selection-panel")
  })
  output$IOTTable = DT::renderDataTable(IoTpantry, rownames = FALSE,
                                        class = "table-success",
                                        options = list(dom = 't',
                                                       paging = FALSE))

  output$myquery = renderText(paste("SELECT * FROM food WHERE",
                                    "MIN RATING >", input$MinRecipeRating, ",",
                                    "MIN RATING COUNT >", input$MinRatingCount, ",",
                                    "ISVEGAN is", input$isVegan, ",",
                                    "ISNUTS is", !input$isNuts, ",",
                                    "ISSEAFOOD is", !input$isSeafood, ",",
                                    "ISBAKE is", !input$isBake, ",",
                                    "ISDEEPFRY is", !input$isDeepfry, ","
                              ))
  output$imgurl1 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[1]) %>% pull(photo_url),'"width="100" height="100">')})
  output$imgurl2 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[2]) %>% pull(photo_url),'"width="100" height="100">')})
  output$imgurl3 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[3]) %>% pull(photo_url),'"width="100" height="100">')})
  output$imgurl4 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[4]) %>% pull(photo_url),'"width="100" height="100">')})
  output$imgurl5 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[5]) %>% pull(photo_url),'"width="100" height="100">')})
  output$imgurl6 = renderText({c('<img src="',recipes_id %>%
                                   filter(title == rvs$myrecipes[6]) %>% pull(photo_url),'"width="100" height="100">')})

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
  
  output$test = renderText(input$RecipeButton)
}

