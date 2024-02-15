library(shiny)

# Define UI
ui <- fluidPage(
  tags$div(class="h1", "Hello World")
)

# Define server logic
server <- function(input, output) { }

# Run the application
shinyApp(ui = ui, server = server)
