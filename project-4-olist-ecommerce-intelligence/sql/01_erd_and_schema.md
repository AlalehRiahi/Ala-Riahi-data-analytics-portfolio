# Olist E-Commerce Dataset  
## Entity–Relationship Diagram (ERD) & Analytical Schema

This project is built on top of the **official Olist Brazilian E-commerce dataset**, a richly relational dataset describing the full lifecycle of an online purchase:  
customer → order → payment → items → seller → delivery → review.

The publisher provides a standard schema for these tables.  
To maintain transparency and reproducibility, this project **explicitly references and embeds that schema**, as required.

---

## 📊 Official Olist Data Schema

The diagram below represents the canonical relationships between all tables in the dataset.

> **Note:** If viewing this file on GitHub, the image will render inline.

![Olist ERD](../docs/olist_schema.jpeg)

---

## 🧱 Overview of Core Entities and Relationships

The schema connects operational, transactional, geographic, and satisfaction data.  
A quick overview:

### **olist_orders_dataset**  
Primary Key: `order_id`  
The central transactional table linking customers, items, payments, and reviews.

### **olist_order_items_dataset**  
Keys: (`order_id`, `order_item_id`)  
Each row represents a specific product within an order.  
Links to:
- product (`product_id`)  
- seller (`seller_id`)  
- order (`order_id`)

### **olist_order_payments_dataset**  
Keys: (`order_id`, `payment_sequential`)  
Captures payment methods and installments.

### **olist_order_reviews_dataset**  
Primary Key: `review_id`  
Links reviews (1–5 stars) back to a specific order.

### **olist_customers_dataset**  
Primary Key: `customer_id`  
Contains customer ZIP code prefixes for geographic mapping.

### **olist_sellers_dataset**  
Primary Key: `seller_id`  
Contains seller ZIP prefixes for shipping-distance calculations.

### **olist_geolocation_dataset**  
No unique key.  
Maps ZIP prefixes to latitude & longitude for distance modeling.

### **olist_products_dataset**  
Primary Key: `product_id`  
Product metadata: dimensions, weight, and category.

---

## 🔗 Foreign-Key Summary

| Child Table                     | Foreign Key                 | Parent Table                      |
|--------------------------------|-----------------------------|-----------------------------------|
| order_items                    | order_id                    | orders                            |
| order_items                    | product_id                  | products                          |
| order_items                    | seller_id                   | sellers                           |
| order_payments                 | order_id                    | orders                            |
| order_reviews                  | order_id                    | orders                            |
| customers                      | customer_zip_code_prefix    | geolocation (non-unique mapping)  |
| sellers                        | seller_zip_code_prefix      | geolocation (non-unique mapping)  |

---

## ⭐ Why This Schema Matters for the Project

The ERD supports a clear analytics architecture:

### **1. Delivery performance analysis**  
orders → items → sellers → geolocation  
→ distance, latency, delay features

### **2. Customer satisfaction modeling**  
orders → reviews → operational attributes  
→ predict low/high reviews

### **3. Business dashboards**  
categories, sellers, payments, customer regions  
→ Excel and Tableau storytelling

### **4. Clean ETL + SQL modeling**  
Supports creation of fact and dimension tables:
- `fact_orders`
- `fact_order_items`
- `fact_reviews`
- `dim_customers`
- `dim_products`
- `dim_sellers`
- `dim_geolocation`

---

## 📐 Next Step: Define the Analytical Star Schema

The next file, `02_logical_schema_and_tables.md`, will document the **analytics-friendly star schema**, the structure we’ll use for SQL modeling, Python analysis, Excel dashboards, and Tableau visualizations.

This will include:
- fact tables  
- dimension tables  
- engineered fields (delivery delay, shipping distance, review lag, etc.)  
- surrogate keys  
- relationships  

This ensures all downstream tools — Excel, SQL, Python, Tableau — use a consistent, curated data structure.

---