# Load necessary libraries
library(shiny)
library(tidyverse)
library(ggplot2)
source("./Task2.R")
# Read data files
portfolio          = read.csv("data/portfolio.csv")
stress_test_output = read.csv("data/stress_test_output.csv")

# UI definition
ui <- fluidPage(
  titlePanel("Expected Loss Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      # Dropdown menu for selecting x-axis variable
      selectInput("x_var", "Select X-Axis Variable", choices = c("ald_sector", "ald_business_unit"), selected = "ald_sector"),
      # Radio buttons for selecting plot type
      radioButtons("plot_type", "Select Plot Type", choices = c("Mean", "Median"), selected = "Mean")
    ),
    
    mainPanel(
      # Output for the plot
      plotOutput("expected_loss_plot")
    )
  )
)

# Server definition
server <- function(input, output) {
  # Reactive function to generate the plot based on user input
  expected_loss_plot <- reactive({
    generate_expected_loss_plot(input$x_var, input$plot_type, portfolio, stress_test_output)
  })
  
  # Render the plot
  output$expected_loss_plot <- renderPlot({
    plot_list <- expected_loss_plot()
    plot <- plot_list$selected_plot
    plot
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
