library(tidyverse)

#load the relevant files for this task
company_activities = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/company_activities.csv")
company_emissions  = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/company_emissions.csv")
assets             = read.csv("C:/Users/maxim.oweyssi/OneDrive - Energy Saving Trust/Documents/1in1000 Data Scientist Technical Test 2024/data/assets.csv")

#cutoff this year as per instructions
cutoff_year = 2024

company_activities_long = company_activities %>%
  #pivot company_activities longer to get the year column
  pivot_longer(cols = starts_with("Equity.Ownership."),
               names_to = "Year",
               values_to = "Equity.Ownership") %>% 
  mutate(Year = as.numeric(substr(Year, nchar(Year) - 3, nchar(Year)))) %>% 
  #apply cutoff year
  filter(Year>=cutoff_year) %>%
  #sum across geographies
  group_by(company_id, company_name, ald_sector, ald_business_unit, activity_unit, Year) %>%
  summarize(Activities.Equity.Ownership = sum(Equity.Ownership, na.rm = TRUE)) %>%
  ungroup()

#Split the dataframe into two depending if unit is capacity or energy
company_activities_MWh_tcoal = company_activities_long %>% 
  filter(activity_unit=="MWh"|activity_unit=="t coal")
company_activities_MW= company_activities_long %>% 
  filter(activity_unit=="MW")

#Same pivot_longer operation as the activities dataframe
company_emissions_long = company_emissions %>%
  #pivot company_emissions longer to get the year column
  pivot_longer(cols = starts_with("Equity.Ownership."),
               names_to = "Year",
               values_to = "Equity.Ownership") %>% 
  mutate(Year = as.numeric(substr(Year, nchar(Year) - 3, nchar(Year)))) %>% 
  #apply cutoff year
  filter(Year>=cutoff_year) %>%
  #sum across geographies
  group_by(company_id, company_name, ald_sector, ald_business_unit, activity_unit, Year) %>%
  summarize(Emissions.Equity.Ownership = sum(Equity.Ownership, na.rm = TRUE)) %>%
  ungroup()

#Join all three dataframes together, perform column operations and rename
assets_new = company_activities_MWh_tcoal %>% 
  left_join(company_activities_MW,
            by=c("company_id","company_name","ald_sector","ald_business_unit","Year"),
            suffix=c("_MWh_tcoal","_MW")) %>% 
  select(Year,everything()) %>% 
  left_join(company_emissions_long,
            by=c("company_id","company_name","ald_sector","ald_business_unit","Year")) %>% 
  mutate(emissions_factor_unit = paste0(activity_unit,"/",activity_unit_MWh_tcoal),
         plan_emission_factor = Emissions.Equity.Ownership/Activities.Equity.Ownership_MWh_tcoal, #this is what creates the Inf values. They are due to missing MWh_tcoal data which is 0 instead of NA
         scenario_geography = "Global",                                                           #as per previous summarize part of code
         ald_production_unit = case_when(
           activity_unit_MWh_tcoal == "t coal"~"t coal",
           T~"MW"
         )) %>%  
  rename(plan_tech_prod = Activities.Equity.Ownership_MW,
         year = Year) %>% 
  select(names(assets)) %>% 
  mutate(record_ID = paste(year,company_id,ald_sector,ald_business_unit,ald_production_unit,emissions_factor_unit,scenario_geography,sep="__"))

#Filter correct year range of the reference data for comparison
assets_old_correct_range = assets %>% 
  filter(year<=2026 & year>=2024) %>% 
  mutate(record_ID = paste(year,company_id,ald_sector,ald_business_unit,ald_production_unit,emissions_factor_unit,scenario_geography,sep="__"))

#This df is showing that all the 48 extra values from assets_new were 0 or NaN so can just filter these out
mismatching_values = assets_new %>% 
  left_join(assets_old_correct_range,by="record_ID",suffix=c(".new",".old"))%>%
  filter(is.na(scenario_geography.old))

value_comparison_df = assets_new %>% 
  left_join(assets_old_correct_range,by="record_ID",suffix=c(".new",".old"))%>%
  filter(!is.na(scenario_geography.old)) %>% 
  mutate(plan_tech_prod_delta = plan_tech_prod.new-plan_tech_prod.old,
         plan_tech_prod_delta_perc = (plan_tech_prod.new-plan_tech_prod.old)/plan_tech_prod.old,
         plan_emission_factor_delta = plan_emission_factor.new-plan_emission_factor.old,
         plan_emission_factor_delta_perc = (plan_emission_factor.new-plan_emission_factor.old)/plan_emission_factor.old) %>% 
  select(c(record_ID,
           plan_tech_prod.old,
           plan_tech_prod.new,
           plan_tech_prod_delta,
           plan_tech_prod_delta_perc,
           plan_emission_factor.old,
           plan_emission_factor.new,
           plan_emission_factor_delta,
           plan_emission_factor_delta_perc)) %>% 
  filter()
#Issues:
#There is an issue with the computation of the plan emissions factor
         