# 🏦 MySQL Banking Fraud Analytics Project

A data analytics project using MySQL to analyze customer transactions, detect fraudulent activity, and gain insights into financial patterns.


# 🚀 Project Overview

Banks handle millions of customer transactions daily, making fraud detection a critical part of financial security.
This project simulates a banking system and provides SQL-based insights such as:

 1. Fraud detection
 2. High-risk customers & locations
 3. Transaction patterns
 4. Revenue analysis
 5. Data modelling (ERD + schema)


## 📊 Key Insights
- Detected top customers with repeated fraud patterns
- Identified high-risk transaction types and locations
- Generated monthly transaction and fraud summary reports

## 🧱 Tech Stack
- MySQL
- SQL Joins, CTEs, Window Functions, Subqueries
- Data Cleaning & Aggregation
- CSV-based sample datasets



## 🚀 How to Run
1. Run `create_tables.sql` in MySQL Workbench.
2. Import CSV files or run `insert_data.sql`.
3. Execute `analysis_queries.sql` to generate insights.

## Sample Queries Generated:

1.Top Customers with Frequent Fraud Alerts:

SELECT c.customer_id, c.full_name, COUNT(fr.fraud_id) AS fraud_count
FROM fraud_reports fr
JOIN transactions t ON fr.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY fraud_count DESC
LIMIT 10;

2.Recent suspicious activity per city:

SELECT l.city, COUNT(*) AS flagged_txns, ROUND(SUM(t.amount),2) AS flagged_volume
FROM fraud_reports fr
JOIN transactions t ON fr.transaction_id = t.transaction_id
JOIN locations l ON t.location_id = l.location_id
GROUP BY l.city ORDER BY flagged_volume DESC;

3. accounts with high-risk score:

SELECT a.account_id, c.full_name,
       COUNT(fr.fraud_id) AS fraud_reports,
       SUM(CASE WHEN t.amount>100000 THEN 1 ELSE 0 END) AS high_value_txns,
       COUNT(CASE WHEN t.status='declined' THEN 1 END) AS declined_count
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
LEFT JOIN fraud_reports fr ON t.transaction_id = fr.transaction_id
GROUP BY a.account_id, c.full_name
ORDER BY fraud_reports DESC, high_value_txns DESC LIMIT 50;

# Conclusion:

This project demonstrates a complete end-to-end workflow for analyzing banking transactions and detecting fraud using pure SQL. By designing a normalized database schema, loading structured data, and executing analytical and fraud-detection queries, this project replicates the kind of work performed by real-world data analysts in the financial sector.

Through this project, I showcased my ability to:

Model relational datasets

Clean and prepare data using SQL

Apply analytical logic to identify trends and anomalies

Detect suspicious patterns in customer activity

Generate meaningful business insights for decision-making

Overall, this project highlights strong SQL proficiency, analytical thinking, and the ability to solve real business problems—skills essential for Data Analyst and Business Intelligence roles.





















