####----Install packages----####
#install.packages("pacman")
pacman::p_load(dplyr, shiny, shinythemes, shinyjs, shinycssloaders, DT, visNetwork, sergeant, tidyverse)

# library(dplyr)
# library(shiny)
# library(shinythemes)
# library(shinyjs)
# library(shinycssloaders)
# library(DT)
# library(visNetwork)




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


db_Ing <- tbl(db_conn,
                  "hdfs.food.`Ing`") %>%
  as.data.frame() 

names(db_Ing)[names(db_Ing) == "Ingredient"] <- "ingredients"

#recipes_id = read.csv("small_sample.csv", header = TRUE, stringsAsFactors = FALSE) %>%
recipes_id = db_food #%>%
#select(-X)
recipeList = recipes_id %>% pull(title) %>% sort()

# Ingredientslist = as.data.frame(c('salt', 'sugar', 'pepper')) %>%
#   `colnames<-`('Ingredients')


Ingredientslist = read.delim("Overall_Master.txt", stringsAsFactors = FALSE, header = FALSE) %>%
  `colnames<-`('Ingredients')

######
fluidPage(theme = "bootstrap.css", #theme = shinytheme("yeti"), # yeti 
          
          br(),
          titlePanel("Recipes Recommender"),
          br(),
          # Setting up app defaults.
          
          useShinyjs(),
          inlineCSS(list("table" = "font-size: 12px")),
          id = "selection-panel",
          
          ######
          # First tab
          tabsetPanel(id = "main",
                      type = "pills",
                      tabPanel("User Selection",
                               br(),
                               column(6,
                                      fluidRow(
                                        column(7,
                                               column(12,
                                                      wellPanel(
                                                        #this is the top left panel,
                                                        h3(print("Pantry IoT")),
                                                        br(),
                                                        tags$div(class = 'custom-checkbox',
                                                                 tags$input(type = 'checkbox',
                                                                            class ="custom-control-input",
                                                                            id = 'useIOT'),
                                                                 tags$label(class = "custom-control-label",
                                                                            style = "font-size:12px",
                                                                            'for' = "useIOT",
                                                                            HTML('Use Ingredients in your pantry'))),
                                                        br(),
                                                        div(DT::dataTableOutput('IOTTable'),
                                                            style = "height:200px; overflow-y: scroll;"),
                                                        selectizeInput("IngredientsInput",
                                                                       label = "",
                                                                       choices = Ingredientslist,
                                                                       selected = NULL,
                                                                       options = list(
                                                                         maxOptions = 5,
                                                                         maxItems = 2,
                                                                         placeholder = 'Pick up to two Ingredients you want to cook with, eg. Cinnamon, Pork, ...',
                                                                         onInitialize = I('function() { this.setValue(""); }')
                                                                       ))
                                                      ))
                                        ),
                                        column(5,
                                               #this is the top right panel
                                               wellPanel(
                                                 h4(print("Recipe Tags")),
                                                 tags$div(class = 'custom-switch',
                                                          tags$input(type = 'checkbox',
                                                                     class ="custom-control-input",
                                                                     id = 'isVegan'),
                                                          tags$label(class = "custom-control-label",
                                                                     style = "font-size:12px",
                                                                     'for' = "isVegan",
                                                                     HTML('Vegetarian Only'))),
                                                 tags$div(class = 'custom-switch',
                                                          tags$input(type = 'checkbox',
                                                                     class ="custom-control-input",
                                                                     id = 'isNuts'),
                                                          tags$label(class = "custom-control-label",
                                                                     style = "font-size:12px",
                                                                     'for' = "isNuts",
                                                                     HTML('No Nut Allergen'))),
                                                 tags$div(class = 'custom-switch',
                                                          tags$input(type = 'checkbox',
                                                                     class ="custom-control-input",
                                                                     id = 'isDairy'),
                                                          tags$label(class = "custom-control-label",
                                                                     style = "font-size:12px",
                                                                     'for' = "isDairy",
                                                                     HTML('No Dairy Products'))),
                                                 tags$div(class = 'custom-switch',
                                                          tags$input(type = 'checkbox',
                                                                     class ="custom-control-input",
                                                                     id = 'isSeafood'),
                                                          tags$label(class = "custom-control-label",
                                                                     style = "font-size:12px",
                                                                     'for' = "isSeafood",
                                                                     HTML('No Seafood-allergens')))
                                               )
                                        )),
                                      fluidRow(
                                        column(6,
                                               actionButton("updateRecipes", "Update Recipes", class = "btn btn-outline-primary")),
                                        column(6,
                                               actionButton("randomRecipe", "Change Recipes (Randomise)", class = "btn btn-outline-danger"))),
                                      br(),
                                      
                                      fluidRow(
                                        column(12,
                                               wellPanel(
                                                 h4(print("Search for a recipe that you fancy!")),
                                                   selectInput(inputId = 'ManualSelect',
                                                               label = '',
                                                               choices = c('', recipeList),
                                                               selected = ''),
                                                 actionButton("RecipeButton", "Go to Selected Recipe", class = "btn btn-outline-info")
                                               ))),
                                      fluidRow(
                                        column(12,
                                               actionButton("Reset", "Reset Inputs")))
                               ),
                               column(6,
                                      wellPanel(
                                        fluidRow(
                                          column(6, align = "center",
                                                 wellPanel(
                                                   htmlOutput("imgurl1"),
                                                   htmlOutput("recipename1"),
                                                   actionButton("selectRecipe1","Go to Recipe", class = "btn btn-outline-info"))
                                                   ),
                                          column(6, align = "center",
                                                 wellPanel(
                                                   htmlOutput("imgurl2"),
                                                   htmlOutput("recipename2"),
                                                   actionButton("selectRecipe2","Go to Recipe", class = "btn btn-outline-info"))
                                          )
                                        ),
                                        fluidRow(
                                          column(6, align = "center",
                                                 wellPanel(
                                                   htmlOutput("imgurl3"),
                                                   htmlOutput("recipename3"),
                                                   actionButton("selectRecipe3","Go to Recipe", class = "btn btn-outline-info"))
                                          ),
                                          column(6, align = "center",
                                                 wellPanel(
                                                   htmlOutput("imgurl4"),
                                                   htmlOutput("recipename4"),
                                                   actionButton("selectRecipe4","Go to Recipe", class = "btn btn-outline-info"))
                                          )
                                        ),
                                        fluidRow(
                                          column(6, align = "center",
                                                 wellPanel(
                                                   htmlOutput("imgurl5"),
                                                   htmlOutput("recipename5"),
                                                   actionButton("selectRecipe5","Go to Recipe", class = "btn btn-outline-info"))
                                          ),
                                          column(6, align = "center",
                                                 wellPanel(
                                                   htmlOutput("imgurl6"),
                                                   htmlOutput("recipename6"),
                                                   actionButton("selectRecipe6","Go to Recipe", class = "btn btn-outline-info"))
                                          ))
                                      ))),
                      tabPanel("Recommendations",
                               br(),
                               fluidRow(
                                 column(4,
                                        h3("These are your Recommendations.")),
                                 column(2,
                                        actionButton("Return", "Return to Selection", class = "btn btn-info"))),
                                br(),
                                fluidRow(
                                column(6,
                                       #Top left Panel
                                       # tags$ul(
                                       #   htmlOutput("ingredients1", container = tags$li, class = "custom-li-output")
                                       # )
                                       DT::dataTableOutput("recipetable")
                                ),
                                column(6,
                                       wellPanel(
                                       #top right panel
                                       htmlOutput("img") %>% withSpinner((type = 1)))
                                )),
                                fluidRow(
                                  column(6,
                                         DT::dataTableOutput("ingredients")),
                                  column(6,
                                         DT::dataTableOutput("instructions"))
                                )),
                      tabPanel("Relational Analysis",
                               br(),
                               visNetworkOutput("mygraph", width = "1000px", height = "800px")
                      )
           )
)
