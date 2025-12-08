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
You can open the notebook directly on GitHub or run it in Google Colab.

To load the dataset via GitHub in Colab:

```python
url =(https://raw.githubusercontent.com/AlalehRiahi/Ala-Riahi-data-analytics-portfolio/refs/heads/main/project2_ai-assistant-statistical-analysis/data/Daily_AI_Assistant_Usage_Behavior_Dataset.csv)
df = pd.read_csv(url)
df['timestamp'] = pd.to_datetime(df['timestamp'])
