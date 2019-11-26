#install.packages('rsconnect')
#to deploy the app
#library(rsconnect)
#deployApp()
#terminateApp()

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(pacman)
pacman::p_load(tidyverse, shiny, shinyjs, stringr, DT, visNetwork, RSQLite, sergeant)

find_ing = function(mystr, mylist) {
  for (item in mylist) {
    print(item)
  }
}

##### THIS CSV IS TO SIMULATE DRILL TABLE, COMMENT THIS OUT IF USING ACTUAL DRILL TABLE.
#mydbconn = dbConnect(RSQLite::SQLite(), "Recipes.db")
#dbListFields(mydbconn,'Recipes_ID')

##### INSERT DRILL QUERY HERE
# I will take a sample of 1000 as a base.
#myrecipes = dbGetQuery(mydbconn, "SELECT * FROM RIGraph ")
mydbconn = drill_connection("localhost")


myrecipes <- drill_query(mydbconn,
                 "SELECT * FROM hdfs.food.`Recipe` LIMIT 1000") %>%
as.data.frame() 
  
recList = myrecipes$ID

query <- paste0("SELECT * FROM hdfs.food.`Ing` WHERE CAST (ID AS INT) IN (", paste0(recList, collapse = ","), ");")
#RIGraph = dbGetQuery(mydbconn, query)

RIGraph = drill_query(mydbconn, query) %>%
  as.data.frame() 


flavourslist = unique(RIGraph$Ingredient)
# SELECT * FROM datatable LIMIT 1000 ...(MORE DRILL STUFF)
#####

cleanstr = function(mystr) {
  #split string from python.
  mystr = str_replace(mystr, '\\[','')
  mystr = str_replace(mystr, '\\]','')
  str_extract_all(mystr, "'(.*?)'")
}

updatePage = function(chosenRecipe) {
  myDT = myrecipes %>%
    filter(ID == chosenRecipe)
  
  recipetable = DT::datatable(
      myDT %>%
        select(title, description, rating_stars, review_count, url, total_time_minutes) %>%
        `colnames<-`(c('Recipe','Description','Average Rating','Number of Ratings','URL', 'Preparation Time')) %>%
        gather("Properties",""),
      class = "table-primary",
      options = list(dom = 't',
                     pageLength = 10),
      rownames = FALSE
    )
  recipeimg = c('<img src="', myrecipes %>%
                               filter(ID == chosenRecipe) %>% pull(photo_url),'"width="380" height="300">')
  
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
  #default labels
  veggie = 0
  hasnuts = 1
  hasdairy = 1
  hasseafood = 1
  ######
  
  if (input$isVegan) {
    veggie = 1
  }
  if (input$isNuts) {
    hasnuts = 0
  }
  if (input$isDairy) {
    hasdairy = 0
  }
  if (input$isSeafood) {
    hasseafood = 0
  }
  ##### USE DRILL QUERY TO OBTAIN UPDATED LIST FROM MAIN TABLE
  # SELECT * FROM datatable WHERE VEGETARIAN >= veggie LIMIT 1000, blah blah
  ######
  # myrecipes <<- dbGetQuery(mydbconn, 'SELECT * FROM Recipes_ID 
  #                    WHERE vegetarian_label >= ? AND 
  #                    nut_label <= ? AND
  #                    lactose <= ? AND
  #                    seafood <= ? LIMIT 1000', params = c(veggie, hasnuts, hasdairy, hasseafood))
  
  
  search_query = paste0('SELECT * FROM hdfs.food.`Recipe` WHERE',
                        ' vegetarian_label >= ', veggie,
                        ' AND nut_label <= ', hasnuts,
                        ' AND lactose <= ', hasdairy,
                        ' AND seafood <= ', hasseafood,
                        ';')
  
  myrecipes <<- drill_query(mydbconn, search_query)
  
  recList = myrecipes$ID
  query <- paste0("SELECT * FROM hdfs.food.`Ing` WHERE CAST (ID AS INT) IN (", paste0(recList, collapse = ","), ")")
  
  #RIGraph <<- dbGetQuery(mydbconn, query)
  RIGraph <<- drill_query(mydbconn, query)
  flavourslist <<- unique(RIGraph$Ingredient)
  
}

function(input, output, session) {
  rvs = reactiveValues(recipes = NULL,
                       ingredients = NULL,
                       recrecipes = myrecipes %>% sample_n(6) %>% pull(ID),
                       recipetable = NULL,
                       recipeimg = NULL,
                       recipeIngredients = NULL,
                       recipeInstructions = NULL,
                       IoTpantry = as.data.frame(c('blueberry','basil','lobster','poppy seed','mustard','apple')) %>%
                         `colnames<-`('Pantry'),
                       recIngredient = "salmon",
                       recIngredient2 = "basil")
######
# When the Apply button is clicked, Compute the graph
  observeEvent(input$updateRecipes, {
    shinyjs::enable('selectRecipe1')
    shinyjs::enable('selectRecipe2')
    shinyjs::enable('selectRecipe3')
    shinyjs::enable('selectRecipe4')
    shinyjs::enable('selectRecipe5')
    shinyjs::enable('selectRecipe6')
    
    updaterecipes(input)
    updateSelectInput(session, 'ManualSelect', choices = c('', myrecipes$title))
    rvs$recrecipes = myrecipes$ID %>%
      sample(6)
    output$test = renderText(nrow(myrecipes))
    updateSelectizeInput(session,
                         inputId = "IngredientsInput",
                         choices = flavourslist,
                         selected = "",
                         options = list()
    )
    output$recommendationText = NULL
    output$recommendationText2 = NULL
  }) #Update recipes button
  
  observeEvent(input$selectRecipe1, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$recrecipes[1])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  }) # Individual buttons below the relevant recipes. To update recommendations tab.
  observeEvent(input$selectRecipe2, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$recrecipes[2])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe3, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$recrecipes[3])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe4, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$recrecipes[4])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe5, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$recrecipes[5])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$selectRecipe6, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(rvs$recrecipes[6])
    rvs$recipetable = stuff[[1]]
    rvs$recipeimg = stuff[[2]]
    rvs$recipeIngredients = stuff[[3]]
    rvs$recipeInstructions = stuff[[4]]
  })
  observeEvent(input$RecipeButton, {
    updateTabsetPanel(session,
                      inputId = "main",
                      selected = "Recommendations")
    stuff = updatePage(myrecipes %>% filter(title == input$ManualSelect) %>% pull(ID))
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
  
  observeEvent(input$getRecommendations, { #GetRecommendations based on the ingredients he picked.
    shinyjs::enable('selectRecipe1')
    shinyjs::enable('selectRecipe2')
    shinyjs::enable('selectRecipe3')
    shinyjs::enable('selectRecipe4')
    shinyjs::enable('selectRecipe5')
    shinyjs::enable('selectRecipe6')
    
    availablerecipes = RIGraph %>%
      filter(Ingredient %in% input$IngredientsInput) %>%
      pull(ID)
    
    rvs$recrecipes = sample(availablerecipes)[1:6]
    output$recommendationText = renderText({c('<p style="font-size: 14px; color: royalblue; white-space: normal;">',
                                              input$IngredientsInput[1], 'is often cooked with', rvs$recIngredient, '</p>')})
    if (length(input$IngredientsInput) > 1) {
      output$recommendationText2 = renderText({c('<p style="font-size: 14px; color: royalblue; white-space: normal;">',
                                                 input$IngredientsInput[2], 'is often cooked with',rvs$recIngredient2, '</p>')})
    }
    if (is.na(rvs$recrecipes[2])) {
      shinyjs::disable("selectRecipe2")
    }
    if (is.na(rvs$recrecipes[3])) {
      shinyjs::disable("selectRecipe3")
    }
    if (is.na(rvs$recrecipes[4])) {
      shinyjs::disable("selectRecipe4")
    }
    if (is.na(rvs$recrecipes[5])) {
      shinyjs::disable("selectRecipe5")
    }
    if (is.na(rvs$recrecipes[6])) {
      shinyjs::disable("selectRecipe6")
    }

  }) #Randomise input. This is for testing.
  
  observeEvent(input$randomRecipe, {
    shinyjs::enable('selectRecipe1')
    shinyjs::enable('selectRecipe2')
    shinyjs::enable('selectRecipe3')
    shinyjs::enable('selectRecipe4')
    shinyjs::enable('selectRecipe5')
    shinyjs::enable('selectRecipe6')
    
    rvs$recrecipes = myrecipes$ID %>%
      sample(6)
    updateSelectizeInput(session,
                         inputId = "IngredientsInput",
                         selected = "",
                         options = list()
                         )
    output$recommendationText = NULL
    output$recommendationText2 = NULL
  }) #Randomise input. This is for testing.

  
  observeEvent(input$Reset, {
    shinyjs::reset("selection-panel")
  })   #when the Reset button is clicked, remove all input values

  output$imgurl1 = renderText({c('<img src="',myrecipes %>%
                                   filter(ID == rvs$recrecipes[1]) %>% pull(photo_url),'"width="150" height="150">')}) #Update the pictures of all recipes.
  output$imgurl2 = renderText({c('<img src="',myrecipes %>%
                                   filter(ID == rvs$recrecipes[2]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl3 = renderText({c('<img src="',myrecipes %>%
                                   filter(ID == rvs$recrecipes[3]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl4 = renderText({c('<img src="',myrecipes %>%
                                   filter(ID == rvs$recrecipes[4]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl5 = renderText({c('<img src="',myrecipes %>%
                                   filter(ID == rvs$recrecipes[5]) %>% pull(photo_url),'"width="150" height="150">')})
  output$imgurl6 = renderText({c('<img src="',myrecipes %>%
                                   filter(ID == rvs$recrecipes[6]) %>% pull(photo_url),'"width="150" height="150">')})

  output$recipename1 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',myrecipes %>%
                                       filter(ID == rvs$recrecipes[1]) %>% pull(title), '</p>')})
  output$recipename2 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',myrecipes %>%
                                       filter(ID == rvs$recrecipes[2]) %>% pull(title), '</p>')})
  output$recipename3 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',myrecipes %>%
                                       filter(ID == rvs$recrecipes[3]) %>% pull(title), '</p>')})
  output$recipename4 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',myrecipes %>%
                                       filter(ID == rvs$recrecipes[4]) %>% pull(title), '</p>')})
  output$recipename5 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',myrecipes %>%
                                       filter(ID == rvs$recrecipes[5]) %>% pull(title), '</p>')})
  output$recipename6 = renderText({c('<p style="font-size: 14px; width: 150px; white-space: normal;">',myrecipes %>%
                                       filter(ID == rvs$recrecipes[6]) %>% pull(title), '</p>')})
  
  output$recipetable = DT::renderDataTable(rvs$recipetable)
  output$img = renderText(rvs$recipeimg)
  output$instructions = DT::renderDataTable(rvs$recipeInstructions)
  output$ingredients = DT::renderDataTable(rvs$recipeIngredients)
  output$recommendationText = NULL
  output$recommendationText2 = NULL
  
  output$IOTTable = DT::renderDataTable(rvs$IoTpantry, rownames = FALSE,
                                        class = "table-borderless",
                                        options = list(dom = 't',
                                                       paging = FALSE))
  output$mygraph = renderVisNetwork({
    # minimal example
    mydf = myrecipes %>%
      filter(ID %in% rvs$recrecipes) %>%
      select(title,ingredients)
    
    myedges = data.frame(from = character(),
                         to = character())
    
    ingredients = myrecipes %>%
      filter(ID %in% rvs$recrecipes) %>%
      pull(ingredients)
    for (i in 1:6) {
      a = str_match(mydf[i,2],flavourslist)
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
  output$test = renderText(nrow(myrecipes))
}

