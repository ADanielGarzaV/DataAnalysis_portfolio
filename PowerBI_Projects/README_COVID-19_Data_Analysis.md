🌍 COVID-19 Data Analysis
PostgreSQL + Power BI Visualization

This project analyzes global COVID-19 data to explore infection rates, death percentages, and vaccination progress.
Data was processed using SQL and visualized through Power BI dashboards for insight-driven reporting.

🧾 Raw Data
Public COVID-19 dataset (cases, deaths, vaccinations per country and date)
Fields: location, date, new_cases, total_cases, new_deaths, total_deaths, population, vaccinations

🧹 Data Cleaning
Performed in PostgreSQL:
Converted text to numeric and date types
Removed null or zero-population entries
Calculated daily and cumulative growth
Joined tables for cases → deaths → vaccinations

📈 Analysis Highlights
Metric	Description
Death Rate	total_deaths / total_cases
Infection Rate	total_cases / population
Vaccination Coverage	people_vaccinated / population

💡 Key Insights
Europe & North America had the highest infection ratios
Countries with higher vaccination rates showed lower mortality
Global vaccination coverage improved dramatically after 2021

📊 Visualization (Power BI)
Dashboard includes:
Global map of infections and vaccinations
Time-series trends by continent
Mortality KPI cards
Interactive filters for year and region

🧠 Skills Demonstrated
SQL Aggregations · CTEs · Joins · Power BI DAX · Data Modeling · KPI Visualization
