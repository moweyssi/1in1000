# Load necessary libraries
library(tidyverse)
library(plotly)

# Read data files
portfolio <- read.csv("data/portfolio.csv")
stress_test_output <- read.csv("data/stress_test_output.csv")

# Calculate Expected Loss: Expected Loss = lgd * pd_shock * exposure
calculation_dataframe <- stress_test_output %>%
  left_join(portfolio, by = c("company_name", "company_id", "ald_sector", "ald_business_unit")) %>%
  mutate(ExpectedLoss = loss_given_default * pd_shock * exposure_usd) %>%
  filter(!is.na(ExpectedLoss))

# Summary statistics by sector
ELperALDsector <- calculation_dataframe %>%
  group_by(ald_sector) %>%
  summarise(
    mean_loss = median(ExpectedLoss),
    q1 = quantile(ExpectedLoss, 0.25),
    q3 = quantile(ExpectedLoss, 0.75),
    median_loss = mean(ExpectedLoss),
    error = sd(ExpectedLoss) / sqrt(n()),
    count = n()
  )

# Summary statistics by business unit
ELperALDbusiness_unit <- calculation_dataframe %>%
  group_by(ald_business_unit) %>%
  summarise(
    median_loss = median(ExpectedLoss),
    q1 = quantile(ExpectedLoss, 0.25),
    q3 = quantile(ExpectedLoss, 0.75),
    mean_loss = mean(ExpectedLoss),
    error = sd(ExpectedLoss) / sqrt(n()),
    count = n()
  )
ELperALDbusiness_unit$error[is.na(ELperALDbusiness_unit$error)] = 0


# Create a function for generating bar plots with error bars and additional elements
generate_bar_plot_with_elements <- function(data, x_var, y_var, color_var, title, x_label, y_label, plot_type = "Mean") {
  if (plot_type == "Mean") {
    # Plotting mean with error bars
    plot <- plot_ly(data, x = ~get(x_var), y = ~get(y_var), type = 'bar', color = ~get(color_var),
                    error_y = list(type = 'data', array = ~data$error, color = "black"),
                    text = ~paste('Count:', data$count),
                    hoverinfo = 'text') %>%
      layout(title = title, xaxis = list(title = x_label), yaxis = list(title = y_label, range = c(0, 4500)),
             showlegend = TRUE)
  } else if (plot_type == "Median") {
    # Plotting median with error bars to Q1 and Q3
    plot <- plot_ly(data, x = ~get(x_var), y = ~get(y_var), type = 'bar', color = ~get(color_var),
                    error_y = list(
                      type = 'data',
                      symmetric = FALSE,
                      arrayminus = ~data$q1,
                      array = ~data$q3,
                      color = "black"
                    ),
                    text = ~paste('Count:', data$count),
                    hoverinfo = 'text') %>%
      layout(title = title, xaxis = list(title = x_label), yaxis = list(title = y_label, range = c(0, 4500)),
             showlegend = TRUE)
  } else {
    stop("Invalid plot_type. Choose 'Mean' or 'Median'")
  }
  
  return(plot)
}