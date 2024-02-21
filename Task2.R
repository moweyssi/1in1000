library(tidyverse)

# Function to generate Expected Loss plots
generate_expected_loss_plot = function(x_var, plot_type, portfolio, stress_test_output) {
  
  # Calculate Expected Loss: Expected Loss = loss_given_default * pd_shock * exposure
  calculation_dataframe = stress_test_output %>%
    left_join(portfolio, by = c("company_name", "company_id", "ald_sector", "ald_business_unit")) %>%
    mutate(ExpectedLoss = loss_given_default * pd_shock * exposure_usd) %>%
    filter(!is.na(ExpectedLoss))
  
  # Summary statistics
  summary_stats = calculation_dataframe %>%
    select(!!rlang::sym(x_var), ExpectedLoss) %>%
    group_by(!!rlang::sym(x_var)) %>%
    summarise(
      median_loss = median(ExpectedLoss),
      q1_loss = quantile(ExpectedLoss, 0.25),
      q3_loss = quantile(ExpectedLoss, 0.75),
      mean_loss = mean(ExpectedLoss),
      error = sd(ExpectedLoss) / sqrt(n()),
      count = n()
    )
  
  summary_stats$error[is.na(summary_stats$error)] = 0
  View(summary_stats)
  
  # Define a soft color palette with 9 colors
  soft_palette <- c("#8dd3c7", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#fccde5", "#d9d9d9", "#bc80bd")
  
  # Plot based on plot_type
  if (plot_type == "Mean") {
    plot <- ggplot(summary_stats, aes(x = !!rlang::sym(x_var))) +
      geom_bar(aes(y = mean_loss, fill = !!rlang::sym(x_var)), stat = "identity", position = "dodge") +
      geom_errorbar(aes(ymin = mean_loss - error, ymax = mean_loss + error), width = 0.25, position = position_dodge(width = 0.8), size = 1) +
      geom_text(aes(y = mean_loss + error + 50, label = count), position = position_dodge(width = 0.8), vjust = -0.5) +
      
      # Customize the plot
      labs(title = paste("Mean Expected Loss by", x_var),
           x = ifelse(x_var == "ald_sector", "ALD Sector", "ALD Business Unit"),
           y = "Mean Loss [USD]") +
      scale_fill_manual(values = soft_palette) +
      theme_minimal() +
      guides(fill = "none")+
      ylim(0, 4000)
  } else {
    plot <- ggplot(summary_stats, aes(x = !!rlang::sym(x_var))) +
      geom_bar(aes(y = median_loss, fill = !!rlang::sym(x_var)), stat = "identity", position = "dodge") +
      geom_linerange(aes(ymin = q1_loss, ymax = q3_loss), position = position_dodge(width = 0.8), color = "black", size = 1) +
      geom_point(aes(y = median_loss), color = "red", size = 3, position = position_dodge(width = 0.8)) +
      
      # Customize the plot
      labs(title = paste("Median, Q1, and Q3 Expected Loss by", x_var),
           x = ifelse(x_var == "ald_sector", "ALD Sector", "ALD Business Unit"),
           y = "Median Loss [USD]") +
      scale_fill_manual(values = soft_palette) +
      theme_minimal() +
      guides(fill = "none") +
      ylim(0, 4000)
  }
  
  list(
    selected_plot = plot  # include the selected plot in the list
  )
}

#Uncomment this part of code to test individually
# Read data files
#portfolio          = read.csv("data/portfolio.csv")
#stress_test_output = read.csv("data/stress_test_output.csv")
## Generate plots
#sector_plot_mean          = generate_expected_loss_plot("ald_sector","Mean",portfolio,stress_test_output)
#sector_plot_median        = generate_expected_loss_plot("ald_sector","Median",portfolio,stress_test_output)
#business_unit_plot_mean   = generate_expected_loss_plot("ald_business_unit","Mean",portfolio,stress_test_output)
#business_unit_plot_median = generate_expected_loss_plot("ald_business_unit","Median",portfolio,stress_test_output)
## View plots
#sector_plot_mean
#sector_plot_median
#business_unit_plot_mean
#business_unit_plot_median
