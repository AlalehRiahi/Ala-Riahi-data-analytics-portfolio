# Project 4 – Brazilian E-Commerce (Olist) Intelligence

**Goal:** Use the Brazilian Olist E-commerce dataset to understand  
how delivery performance and operational factors drive **customer satisfaction**.

This project is intentionally designed to showcase an **end-to-end analytics workflow**
across multiple tools:

- **SQL** – Data modeling, cleaning, feature tables, KPI aggregates  
- **Excel** – Business-friendly KPI dashboard  
- **Python (Statistics)** – Exploratory data analysis and hypothesis testing  
- **Python (Modeling)** – Predictive models for review score and delivery delay  
- **Tableau** – Executive-level storytelling and interactive dashboards  

---

## 1. Business Questions

1. How do **delivery times and delays** affect customer review scores?  
2. Which **product categories** and **sellers** are associated with more late deliveries?  
3. Are there **geographical patterns** in delivery performance and satisfaction?  
4. Can we **predict**:
   - the probability of a low review (e.g., 1–2 stars)?
   - expected delivery delay in days?

---

## 2. Data

Dataset: **Olist Brazilian E-commerce Public Dataset**  
Tables used:

- `olist_orders_dataset`
- `olist_order_items_dataset`
- `olist_order_payments_dataset`
- `olist_order_reviews_dataset`
- `olist_customers_dataset`
- `olist_sellers_dataset`
- `olist_products_dataset`
- `olist_geolocation_dataset`
- `product_category_name_translation`

All original CSV files are stored under [`data/raw`](./data/raw).

Processed / analysis-ready tables (dim/fact style) will be stored under [`data/processed`](./data/processed).

---

## 3. Project Structure

```text
data/           # raw + processed data
sql/            # schema, cleaning, feature tables, KPI queries
excel/          # Excel dashboard and design notes
notebooks/      # Python analysis and modeling
tableau/        # Tableau workbook + story notes
reports/        # written case study + exported figures
docs/           # longer-form markdown booklet