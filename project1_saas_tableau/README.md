# Project 1 – Improving 30-Day Retention in an Adaptive Learning SaaS

## 1. Project Summary

**Goal:** Analyze how new users behave in the first 30 days after signup in an adaptive learning platform and identify actions to improve activation and retention.

**Key themes:**
- Customer journey & lifecycle analytics
- Cohort and retention analysis
- Behavioral segmentation (e.g., “fast starters” vs “slow starters”)
- Tableau dashboards for storytelling
- SQL for data modeling & aggregation
- Conceptual GenAI assistant for conversational analytics

---

## 2. Business Context & Questions

Imagine an adaptive learning SaaS platform (similar in spirit to Duolingo, but focused on life skills and wellness). New users are signing up, but many stop using the product after only a few sessions.

The key business questions:

1. **Activation:**  
   How many new users become “activated” (i.e., complete at least 2 lessons) within 48 hours of signup?

2. **Retention:**  
   What percentage of users are still active after 7 days and after 30 days?

3. **Behavioral segments:**  
   How do different user groups (e.g. “fast starters”, “notification ON vs OFF”) differ in their retention?

4. **Drop-off points:**  
   At which modules/lessons in the learning journey do users tend to drop off?

5. **Product levers:**  
   Which product changes could realistically improve activation and 30-day retention?

---

## 3. Data Model & Tools

This is a **conceptual project** using a realistic but simulated data model.  
The focus is on how I structure the analysis rather than on real company data.

### 3.1. Tables (simulated schema)

**`users`**
- `user_id` (string / int) – unique user identifier  
- `signup_date` (date) – when the user registered  
- `signup_channel` (string) – e.g. “organic”, “ads”, “referral”  
- `country` (string) – user country  
- `notifications_enabled` (boolean) – whether in-app reminders are on  

**`sessions`**
- `user_id`  
- `session_id`  
- `session_start` (timestamp)  
- `session_end` (timestamp)  
- `device_type` (string) – e.g. “mobile”, “desktop”

**`lesson_progress`**
- `user_id`  
- `lesson_id`  
- `module_number` (int) – module in the learning path  
- `completed` (boolean)  
- `completion_time_sec` (int) – time spent before marking complete  
- `completion_date` (date)

**`subscriptions`**
- `user_id`  
- `event_type` (string) – e.g. “trial_start”, “trial_end”, “upgrade_paid”, “cancel”  
- `event_date` (date)  
- `plan_type` (string) – e.g. “free”, “trial”, “basic_paid”, “premium_paid”

**`feedback`**
- `user_id`  
- `nps_score` (int, 0–10)  
- `submitted_at` (date)

> Later, I will generate synthetic CSV files based on this schema for use in SQL and Tableau.

### 3.2. Tools

- **Database / queries:** PostgreSQL (simulated) + SQL  
- **Visualization & dashboards:** Tableau  
- **Exploration (optional):** Python / Jupyter for sanity checks  
- **Conceptual:** GenAI assistant (LLM) to answer natural-language questions with SQL + summaries

---

## 4. Analytical Approach

### 4.1. Define key metrics

- **Activation:**  
  User completed **≥ 2 lessons** within 48 hours of signup.
- **7-day retention:**  
  User had **≥ 1 session** on days 2–7 after signup.
- **30-day retention:**  
  User had **≥ 1 session** on days 8–30 after signup.
- **Engagement depth (first 30 days):**  
  Total number of completed lessons.
- **Conversion:**  
  Free/trial user upgraded to a paid plan within 30 days.

### 4.2. Example SQL – Cohort & retention table

```sql
-- Build user-level activity + engagement summary for first 30 days
WITH user_activity AS (
  SELECT
    u.user_id,
    u.signup_date::date AS signup_date,
    date_trunc('week', u.signup_date)::date AS signup_week,
    MIN(s.session_start)::date AS first_session_date,
    COUNT(DISTINCT s.session_start::date) AS active_days_30
  FROM users u
  LEFT JOIN sessions s 
    ON u.user_id = s.user_id
   AND s.session_start::date <= u.signup_date::date + 30
  GROUP BY 1,2,3
),
engagement AS (
  SELECT
    l.user_id,
    COUNT(*) FILTER (WHERE l.completed = true) AS lessons_30,
    COUNT(*) FILTER (
      WHERE l.completed = true 
        AND l.completion_date <= u.signup_date::date + 2
    ) AS lessons_first_48h
  FROM users u
  LEFT JOIN lesson_progress l 
    ON u.user_id = l.user_id
   AND l.completion_date <= u.signup_date::date + 30
  GROUP BY l.user_id, u.signup_date
)
SELECT
  ua.signup_week,
  COUNT(*) AS users_in_cohort,
  AVG(CASE WHEN e.lessons_first_48h >= 2 THEN 1 ELSE 0 END) AS activation_rate,
  AVG(CASE WHEN ua.active_days_30 >= 2 THEN 1 ELSE 0 END) AS retention_7d,
  AVG(CASE WHEN ua.active_days_30 >= 3 THEN 1 ELSE 0 END) AS retention_30d
FROM user_activity ua
LEFT JOIN engagement e 
  ON ua.user_id = e.user_id
GROUP BY ua.signup_week
ORDER BY ua.signup_week;
