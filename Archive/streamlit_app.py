import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go


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
fig = px.line(merged_data, x='year', y=f'{variable}_mean', color='ald_business_unit',
              title=f'Connected Lines and Areas for {variable}',
              labels={'year': 'Year', f'{variable}_mean': variable, 'ald_business_unit': 'Business Unit'},
              line_shape='linear')  # Specify 'linear' line shape for connected lines

# Add filled areas for error bars using go.Figure
for unit in merged_data['ald_business_unit'].unique():
    subset = merged_data[merged_data['ald_business_unit'] == unit]
    fig.add_trace(go.Scatter(
        x=subset['year'],
        y=subset[f'{variable}_mean'],
        mode='lines',
        line=dict(width=0),
        stackgroup='one',
        name=unit,
        hoverinfo='skip'
    ))
    fig.add_trace(go.Scatter(
        x=pd.concat([subset['year'], subset['year'][::-1]]),
        y=pd.concat([subset[f'{variable}_mean'] - subset[f'{variable}_std'],
                     (subset[f'{variable}_mean'] + subset[f'{variable}_std']).iloc[::-1]]),
        fill='toself',
        fillcolor='rgba(0,100,80,0.2)',
        line=dict(color='rgba(255,255,255,0)'),
        showlegend=False,
        hoverinfo='skip'
    ))

# Display the plot in Streamlit
st.plotly_chart(fig)