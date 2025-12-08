# Project 2: Statistical Analysis of AI Assistant User Behavior

This project analyzes a dataset of AI assistant interactions using Python. The goal is to 
explore behavioral patterns, compare model performance, and evaluate whether factors such 
as device type, session length, prompt length, or token usage influence user satisfaction.

## Project Contents
- **notebook/** — Jupyter/Colab notebook containing the full analysis  
- **data/** — Dataset used for statistical testing  


## Methods
The project uses:
- Exploratory data analysis (EDA)
- Visualization (Matplotlib, Seaborn)
- ANOVA for comparing groups
- Pearson correlation tests for numeric relationships
- Statistical interpretation of p-values and effect sizes

## Key Findings
- Satisfaction does not differ significantly by device or assistant model  
- Token usage does not meaningfully differ across models  
- No significant correlations between prompt length, session duration, tokens, or satisfaction  
- User experience appears stable and consistent across multiple dimensions  

## How to Run
You can view the notebook on GitHub or open it directly in Google Colab.

### Dataset Source
The dataset used in this project is stored in the GitHub repository 
**Ala-Riahi-data-analytics-portfolio**.  
The notebook loads the data automatically from the following raw URL:

https://raw.githubusercontent.com/AlalehRiahi/Ala-Riahi-data-analytics-portfolio/main/project2_ai-assistant-statistical-analysis/data/Daily_AI_Assistant_Usage_Behavior_Dataset.csv

## Open the Notebook in Google Colab

You can run the full analysis directly in Colab:

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/AlalehRiahi/Ala-Riahi-data-analytics-portfolio/blob/main/project2_ai-assistant-statistical-analysis/notebooks/ai_assistant_behavior_analysis.ipynb)
