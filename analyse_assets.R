library(tidyverse)

assets             = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/assets.csv")
company_activities = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/company_activities.csv")
company_emissions  = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/company_emissions.csv")
portfolio          = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/portfolio.csv")
stress_test_output = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/stress_test_output.csv")

business_units = unique(assets$ald_business_unit)
assets_coal = assets %>% 
  filter(ald_business_unit=="Coal") %>% 
  pivot_wider(names_from = c(year,ald_business_unit), values_from = c(plan_tech_prod,plan_emission_factor))


power = assets %>% 
  filter(ald_sector=="Power")
coal = assets %>% 
  filter(ald_sector=="Coal")
power_hydro = power %>% 
  filter(ald_business_unit=="HydroCap") %>% 
  pivot_wider(names_from = c(year), values_from = c(plan_tech_prod,plan_emission_factor))
power_nuclear = power %>% 
  filter(ald_business_unit=="NuclearCap") %>% 
  pivot_wider(names_from = c(year), values_from = c(plan_tech_prod,plan_emission_factor))
power_gas = power %>% 
  filter(ald_business_unit=="GasCap") %>% 
  pivot_wider(names_from = c(year), values_from = c(plan_tech_prod,plan_emission_factor))
power_oil = power %>% 
  filter(ald_business_unit=="OilCap") %>% 
  pivot_wider(names_from = c(year), values_from = c(plan_tech_prod,plan_emission_factor))
power_coalcap = power %>% 
  filter(ald_business_unit=="CoalCap") %>% 
  pivot_wider(names_from = c(year), values_from = c(plan_tech_prod,plan_emission_factor))
power_Renewables = power %>% 
  filter(ald_business_unit=="RenewablesCap") %>% 
  pivot_wider(names_from = c(year), values_from = c(plan_tech_prod,plan_emission_factor))



plan_tech_prod = power %>%
  ggplot(aes(x = year, y = plan_tech_prod, color = ald_business_unit)) +
  stat_summary(fun = "mean", geom = "line", size = 1) +
  stat_summary(fun.data = "mean_se", geom = "ribbon", alpha = 0.2, fill = "gray") +
  labs(title = "Mean Line and Error Bars for plan_tech_prod",
       x = "Year",
       y = "plan_tech_prod",
       color = "Business Unit") +
  theme_minimal()

plan_emission_factor = power %>%
  ggplot(aes(x = year, y = plan_emission_factor, color = ald_business_unit)) +
  stat_summary(fun = "mean", geom = "line", size = 1) +
  stat_summary(fun.data = "mean_se", geom = "ribbon", alpha = 0.2, fill = "gray") +
  labs(title = "Mean Line and Error Bars for plan_emission_factor",
       x = "Year",
       y = "plan_emission_factor",
       color = "Business Unit") +
  theme_minimal()

coal %>%
  ggplot(aes(x = year, y = plan_tech_prod, color = ald_business_unit)) +
  stat_summary(fun = "mean", geom = "line", size = 1) +
  stat_summary(fun.data = "mean_se", geom = "ribbon", alpha = 0.2, fill = "gray") +
  labs(title = "Mean Line and Error Bars for plan_tech_prod",
       x = "Year",
       y = "plan_tech_prod",
       color = "Business Unit") +
  theme_minimal()

