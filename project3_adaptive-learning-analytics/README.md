#  Adaptive Learning Behavior Analysis in Python  
### Exploring learner engagement, performance, and behavioral patterns in an adaptive chemistry learning system

---

##  Project Overview

This project analyzes a synthetic but realistically structured dataset modeling interactions within an **adaptive online learning system**. The goal is to understand how learners behave, how they respond to different types of content, and which factors influence performance.

The analysis simulates the workflow of a **mid-level data analyst or learning-analytics researcher**, including:

- Exploratory data analysis (EDA)  
- Visualization of behavioral and performance patterns  
- Statistical hypothesis testing (ANOVA, Kruskal–Wallis, Pearson, Chi-square)  
- Interpretation of results in the context of adaptive learning platforms  
- Actionable recommendations for personalization and content strategy  

Although the dataset is synthetic, its schema reflects real e-learning environments and allows for meaningful behavioral analysis.

---

##  Dataset Description

The dataset represents interactions between learners and chemistry modules in an adaptive learning environment.

### **Learner Profiles**
- `learner_id`  
- `prior_knowledge_level`  
- `learning_style`  
- `baseline_quiz_score`  

### **Content Metadata**
- `module_id`  
- `topic`  
- `difficulty_level`  
- `content_type`  
- `estimated_time`  

### **Interaction Behaviors**
- `time_spent`  
- `attempts`  
- `clicks`  
- `engagement_score`  

### **Performance Outcomes**
- `quiz_score`  
- `mastery_level`  
- `retention_score`  
- `reward` (RL-style signal)  

This structure supports research in adaptive learning, reinforcement learning, learner modeling, and performance analytics.

---

##  Analysis Steps

### **1. Data Overview**
Inspection of structure, missing values, distributions, and data integrity.

### **2. Exploratory Data Visualization**
Visualization of:

- Behavioral distributions  
- Learning style comparisons  
- Difficulty vs performance/time  
- Content type differences  
- Topic-level performance  
- Correlation heatmap  

These lay the foundation for inferential testing.

---

### **3. Statistical Hypothesis Testing**

Performed with SciPy:

- **One-way ANOVA**  
  - Learning style → quiz_score  
  - Difficulty → quiz_score  
  - Difficulty → time_spent  
- **Kruskal–Wallis**  
  - Content type → engagement_score  
- **Pearson correlation**  
  - engagement_score ↔ quiz_score  
- **Chi-square**  
  - prior_knowledge_level ↔ mastery_level  

Effect sizes (η², r², Cramér’s V) assess practical significance.

---

##  Key Findings

- **Learning style does not predict performance**, consistent with modern educational research.  
- **Moderate difficulty levels (3–4) produce the best performance**, suggesting a cognitive sweet spot.  
- **Multimedia formats increase engagement**, but do not necessarily improve quiz performance.  
- **Performance metrics cluster tightly**, indicating they measure the same underlying concept (mastery).  
- **Behavior metrics form a second cluster** (time, clicks, engagement).  
- No single variable strongly predicts performance → learning outcomes are multi-factorial.

---

## 🧭 Recommendations for an Adaptive Learning System

1. Avoid using learning styles for personalization — signal is weak.  
2. Personalize based on *behavioral clusters* (engagement, clicks, time spent).  
3. Maintain difficulty in the moderate range unless mastery is demonstrated.  
4. Deploy multimedia content for engagement, not necessarily performance.  
5. Implement scaffolding for learners who exert high effort but score low.  
6. Choose one mastery metric to avoid multicollinearity.  
7. Use multi-signal modeling rather than rule-based heuristics.  

These insights align with established instructional design and learning-science principles.

---

---

##  How to Run

You can open the notebook directly on GitHub or run it in Google Colab.

### **Dataset Source**
The notebook loads the dataset automatically from the raw GitHub link:


https://raw.githubusercontent.com/AlalehRiahi/Ala-Riahi-data-analytics-portfolio/refs/heads/main/project3_adaptive-learning-analytics/data/chemistry_learning_dataset.csv


