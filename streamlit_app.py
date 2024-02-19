import streamlit as st
import pandas as pd
import plotly.express as px

assets              = pd.read_csv("data/assets.csv")
company_activities  = pd.read_csv("data/company_activities.csv")
company_emissions   = pd.read_csv("data/company_emissions.csv")
portfolio           = pd.read_csv("data/portfolio.csv")
stress_test_output  = pd.read_csv("data/stress_test_output.csv")

df = assets
# Streamlit app
st.title("Streamlit App with Plotly")

# Sidebar with variable selection
variable = st.sidebar.selectbox("Select variable to plot", ['plan_tech_prod', 'plan_emission_factor'])

# Calculate mean and standard deviation for error bars
mean_data = df.groupby(['year', 'ald_business_unit'])[variable].mean().reset_index()
std_data = df.groupby(['year', 'ald_business_unit'])[variable].std().reset_index()

# Merge mean and std data
merged_data = pd.merge(mean_data, std_data, on=['year', 'ald_business_unit'], suffixes=('_mean', '_std'))

# Plot using Plotly Express
fig = px.scatter(merged_data, x='year', y=f'{variable}_mean', color='ald_business_unit',
                 error_y=f'{variable}_std', title=f'Mean Line and Error Bars for {variable}',
                 labels={'year': 'Year', f'{variable}_mean': variable, 'ald_business_unit': 'Business Unit'})

# Display the plot in Streamlit
st.plotly_chart(fig)