#Load packages
#pacman::p_load(shiny, shinyWidgets, shinythemes, DT, tidyverse)
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(DT)
library(tidyverse)

############################################################################
#Load csv
path = 'RI.csv'
df = read.csv(path, stringsAsFactors = FALSE)
# df_Ing = df %>%
#   select(Ingredients) %>%
#   distinct() %>%
#   arrange(Ingredients)


#Display list all ingredients
df_Ing = df %>%
  select(Ingredients) %>%
  group_by(Ingredients) %>%
  dplyr::summarize(count = n()) %>% 
  arrange(desc(count), Ingredients) %>% #Sorted by most common then alphabetical
  select(Ingredients)
  

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
    # textOutput("Ing_selected"),
    
    #column(1, align = "center", tableOutput("RecipeResults"))
    column(12, align = "center", DTOutput("RecipeResults", width = '100%'))
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
    
    #output$RecipeResults <- renderTable({
    output$RecipeResults <- renderDT({
      #Select all Recipes with ANY of Ingredients
      results = df %>%
        filter(Ingredients %in% query) %>%
        arrange(Ingredients)
      
      #Select all Recipes with ALL of Ingredients
      results = df %>%
        unique() %>%
        filter(Ingredients %in% query) %>%
        dplyr::count(Recipe, name = 'num') %>%
        filter(num == length(query)) %>%
        select(Recipe) #%>%
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
