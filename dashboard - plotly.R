# Load necessary libraries
library(shiny)
library(tidyverse)
library(plotly)  # Make sure to load plotly library

# Assuming that 'plotly.R' contains the generate_bar_plot_with_elements function
source("./Task2 - plotly.R")

# Read data files
portfolio <- read.csv("data/portfolio.csv")
stress_test_output <- read.csv("data/stress_test_output.csv")

# UI definition
ui <- fluidPage(
  titlePanel("Expected Loss Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      # Dropdown menu for selecting x-axis variable
      selectInput("x_var", "Select X-Axis Variable", choices = c("ald_sector", "ald_business_unit"), selected = "ald_sector"),
      # Radio buttons for selecting plot type
      radioButtons("plot_type", "Select Plot Type", choices = c("Mean", "Median"), selected = "Mean"),
      height = "800px"
    ),
    
    mainPanel(
      # Output for the plot
      plotlyOutput("expected_loss_plot", height = "600px")
    )
  )
)

# Server definition
server <- function(input, output) {
  # Reactive function to generate the plot based on user input
  expected_loss_plot <- reactive({
    # Generate the plots
    if (input$x_var == "ald_sector" && input$plot_type == "Mean") {
      plot <- generate_bar_plot_with_elements(ELperALDsector, 'ald_sector', 'mean_loss', 'ald_sector',
                                              "Mean Expected Loss Analysis by Sector", "ALD Sector", "Mean Loss [USD]",plot_type=input$plot_type)
    } else if (input$x_var == "ald_sector" && input$plot_type == "Median") {
      plot <- generate_bar_plot_with_elements(ELperALDsector, 'ald_sector', 'median_loss', 'ald_sector',
                                              "Median, Q1, and Q3 Expected Loss Analysis by Sector", "ALD Sector", "Loss [USD]",plot_type=input$plot_type)
    } else if (input$x_var == "ald_business_unit" && input$plot_type == "Mean") {
      plot <- generate_bar_plot_with_elements(ELperALDbusiness_unit, 'ald_business_unit', 'mean_loss', 'ald_business_unit',
                                              "Mean Expected Loss Analysis by Business Unit", "ALD Business Unit", "Mean Loss [USD]",plot_type=input$plot_type)
    } else if (input$x_var == "ald_business_unit" && input$plot_type == "Median") {
      plot <- generate_bar_plot_with_elements(ELperALDbusiness_unit, 'ald_business_unit', 'median_loss', 'ald_business_unit',
                                              "Median, Q1, and Q3 Expected Loss Analysis by Business Unit", "ALD Business Unit", "Loss [USD]",plot_type=input$plot_type)
    }
    
    return(list(
      selected_plot = plot
    ))
  })
  
  # Render the plot
  output$expected_loss_plot <- renderPlotly({
    plot_list <- expected_loss_plot()
    plot <- plot_list$selected_plot
    plot
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
