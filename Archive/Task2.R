# Load necessary libraries
library(tidyverse)

# Read data files
portfolio <- read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/portfolio.csv")
stress_test_output <- read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/stress_test_output.csv")

# Calculate Expected Loss: Expected Loss = lgd * pd_shock * exposure
calculation_dataframe <- stress_test_output %>%
  left_join(portfolio, by = c("company_name", "company_id", "ald_sector", "ald_business_unit")) %>%
  mutate(ExpectedLoss = loss_given_default * pd_shock * exposure_usd) %>%
  filter(!is.na(ExpectedLoss))

# Summary statistics by sector
ELperALDsector <- calculation_dataframe %>%
  select(ald_sector, ExpectedLoss) %>%
  group_by(ald_sector) %>%
  summarise(
    median_loss = median(ExpectedLoss),
    q1_loss = quantile(ExpectedLoss, 0.25),
    q3_loss = quantile(ExpectedLoss, 0.75),
    mean_loss = mean(ExpectedLoss),
    error = sd(ExpectedLoss) / sqrt(n()),
    count = n()
  )

# Summary statistics by business unit
ELperALDbusiness_unit <- calculation_dataframe %>%
  select(ald_business_unit, ExpectedLoss) %>%
  group_by(ald_business_unit) %>%
  summarise(
    median_loss = median(ExpectedLoss),
    q1_loss = quantile(ExpectedLoss, 0.25),
    q3_loss = quantile(ExpectedLoss, 0.75),
    mean_loss = mean(ExpectedLoss),
    error = sd(ExpectedLoss) / sqrt(n()),
    count = n()
  )
ELperALDbusiness_unit$error[is.na(ELperALDbusiness_unit$error)] = 1

# Define a soft color palette with 9 colors
soft_palette <- c("#8dd3c7", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#fccde5", "#d9d9d9", "#bc80bd")

# Mean Expected Loss Analysis by Sector
ggplot(ELperALDsector, aes(x = ald_sector)) +
  geom_bar(aes(y = mean_loss, fill = ald_sector), stat = "identity", position = "dodge") +
  geom_errorbar(aes(ymin = mean_loss - error, ymax = mean_loss + error), width = 0.25, position = position_dodge(width = 0.8)) +
  geom_text(aes(y = mean_loss + error + 50, label = count), position = position_dodge(width = 0.8), vjust = -0.5) +
  # Customize the plot
  labs(title = "Mean Expected Loss Analysis by Sector",
       x = "ALD Sector",
       y = "Mean Loss [USD]") +
  scale_fill_manual(values = soft_palette) +
  theme_minimal() +
  guides(fill = FALSE)

# Median, Q1, and Q3 Expected Loss Analysis by Sector
ggplot(ELperALDsector, aes(x = ald_sector)) +
  geom_bar(aes(y = median_loss, fill = ald_sector), stat = "identity", position = "dodge") +
  geom_linerange(aes(ymin = q1_loss, ymax = q3_loss), position = position_dodge(width = 0.8), color = "black", size = 1) +
  geom_point(aes(y = median_loss), color = "red", size = 3, position = position_dodge(width = 0.8)) +
  # Customize the plot
  labs(title = "Median, Q1, and Q3 Expected Loss Analysis by Sector",
       x = "ALD Sector",
       y = "Loss [USD]") +
  scale_fill_manual(values = soft_palette) +
  theme_minimal() +
  guides(fill = FALSE)

# Mean Expected Loss Analysis by Business Unit
ggplot(ELperALDbusiness_unit, aes(x = ald_business_unit)) +
  geom_bar(aes(y = mean_loss, fill = ald_business_unit), stat = "identity", position = "dodge") +
  geom_errorbar(aes(ymin = mean_loss - error, ymax = mean_loss + error), width = 0.25, position = position_dodge(width = 0.8)) +
  geom_text(aes(y = mean_loss + error + 50, label = count), position = position_dodge(width = 0.8), vjust = -0.5) +
  # Customize the plot
  labs(title = "Mean Expected Loss Analysis by Business Unit",
       x = "ALD Business Unit",
       y = "Mean Loss [USD]") +
  scale_fill_manual(values = soft_palette) +
  theme_minimal() +
  guides(fill = FALSE)

# Median, Q1, and Q3 Expected Loss Analysis by Business Unit
ggplot(ELperALDbusiness_unit, aes(x = ald_business_unit)) +
  geom_bar(aes(y = median_loss, fill = ald_business_unit), stat = "identity", position = "dodge") +
  geom_linerange(aes(ymin = q1_loss, ymax = q3_loss), position = position_dodge(width = 0.8), color = "black", size = 1) +
  geom_point(aes(y = median_loss), color = "red", size = 3, position = position_dodge(width = 0.8)) +
  # Customize the plot
  labs(title = "Median, Q1, and Q3 Expected Loss Analysis by Business Unit",
       x = "ALD Business Unit",
       y = "Loss [USD]") +
  scale_fill_manual(values = soft_palette) +
  theme_minimal() +
  guides(fill = FALSE)