library(shiny)

# Define UI ----
ui <- fluidPage(
  titlePanel("Select"),
  
  fluidRow(
    column(1,
           selectInput("select", label = ("Select box"), 
                       choices = c("A")),
  )),
  mainPanel(
    textOutput("selected_var"),
    textOutput("dflist")
  )
)

# Define server logic ----
server <- function(input, output) {
  
  
  #Load csv
  path = 'C:/Users/KE/Desktop/RI.csv'
  df = read.csv(path)
  
  #Search query
  query = c("salt", "sugar")
  
  df %>%
    filter(Ingredients %in% query)
  
  
  output$dflist <- renderDataTable({
    as.list(as.data.frame(df["Recipe"]))
  })
  
  output$selected_var <- renderText({ 
    paste("You have selected", input$select)
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
