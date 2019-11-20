#Load packages
install.packages("pacman", dependencies = TRUE)
library(pacman)
pacman::p_load(shiny, shinyWidgets, shinythemes, DT, tidyverse, dplyr)

library(shiny)
library(shinyWidgets)
library(shinythemes)
library(DT)
library(tidyverse)
library(dplyr)

############################################################################
#Load csv
path = '/home/cloudera/Desktop/RI.csv'
df = read.csv(path, stringsAsFactors = FALSE)
# df_Ing = df %>%
#   select(Ingredients) %>%
#   distinct() %>%
#   arrange(Ingredients)


#Display list all ingredients
df_Ing = df %>%
  dplyr::select(Ingredient) %>%
  dplyr::group_by(Ingredient) %>%
  dplyr::summarize(count = n()) %>% 
  dplyr::arrange(desc(count), Ingredient) %>% #Sorted by most common then alphabetical
  dplyr::select(Ingredient)
  

############################################################################
# Define Shiny UI ----
#ui <- fluidPage(theme = shinytheme("slate / superhero "),
#https://rstudio.github.io/shinythemes/
ui <- fluidPage(theme = shinytheme("yeti"),
  titlePanel("Select"),
  fluidRow(
    pickerInput("Ing_select",
                 label = ("Your Current Ingredient(s):"),
                 width = 300,
                 choices = df_Ing, 
                 options = pickerOptions(
                   title = ("Select your current ingredient(s):"),
                   dropdownAlignRight = TRUE,
                   actionsBox = TRUE, 
                   liveSearch = TRUE,
                   liveSearchNormalize = TRUE,
                   size = 10
                 ), 
                 multiple = TRUE),
           
    actionButton("Ing_submit", "Submit")
  
  ),
  
  
  mainPanel(
     textOutput("Ing_selected"),
    
    column(12, align = "center", tableOutput("RecipeResults"))
    #column(12, align = "center", DTOutput("RecipeResults", width = '100%'))
  )
  
  
)


############################################################################
# Define Shiny server logic ----
server <- function(input, output) {
  
  #Search only when button Ing_submit is pressed
  observeEvent(input$Ing_submit, {
    #Retrieve search query
    query = input$Ing_select
    
    #Display table of results
    
    output$RecipeResults <- renderTable({
    #output$RecipeResults <- renderDT({
      #Select all Recipes with ANY of Ingredients
      results = df %>%
        dplyr::filter(Ingredient %in% query) %>%
        dplyr::arrange(Ingredient)
      
      #Select all Recipes with ALL of Ingredients
      results = df %>%
        dplyr::unique() %>%
        dplyr::filter(Ingredient %in% query) %>%
        dplyr::count(Recipe, name = 'num') %>%
        dplyr::filter(num == length(query)) %>%
        dplyr::select(Recipe) #%>%
        #join(df)
    }
    # },
    # #Table format
    # striped = TRUE,
    # hover = TRUE
    )

  })

}

# Run the app ----
shinyApp(ui = ui, server = server)
