
-- Analysis Queries

-- 1. Count total transactions and total volume
SELECT COUNT(*) AS total_transactions, ROUND(SUM(amount),2) AS total_volume FROM transactions;

-- 2. Top 20 largest transactions
SELECT * FROM transactions ORDER BY amount DESC LIMIT 20;

-- 3. Transactions above 100,000 (high value)
SELECT * FROM transactions WHERE amount > 100000 ORDER BY amount DESC;

-- 4. Accounts with multiple high-value transactions (>50000)
SELECT account_id, COUNT(*) AS high_value_count, ROUND(SUM(amount),2) AS total_high_amount
FROM transactions
WHERE amount > 50000
GROUP BY account_id
HAVING high_value_count >= 2
ORDER BY total_high_amount DESC;

-- 5. Rapid transactions: same account, different locations within 60 minutes
SELECT t1.account_id, t1.transaction_id AS txn1, t1.transaction_time AS time1, l1.city AS city1,
       t2.transaction_id AS txn2, t2.transaction_time AS time2, l2.city AS city2,
       TIMESTAMPDIFF(MINUTE, t1.transaction_time, t2.transaction_time) AS minutes_diff
FROM transactions t1
JOIN transactions t2 ON t1.account_id = t2.account_id AND t1.transaction_id < t2.transaction_id
JOIN locations l1 ON t1.location_id = l1.location_id
JOIN locations l2 ON t2.location_id = l2.location_id
WHERE l1.city <> l2.city
  AND ABS(TIMESTAMPDIFF(MINUTE, t1.transaction_time, t2.transaction_time)) <= 60
ORDER BY minutes_diff ASC
LIMIT 200;

-- 6. Suspicious declined transactions
SELECT t.* FROM transactions t WHERE status = 'declined' ORDER BY transaction_time DESC;

-- 7. Fraud reports joined with transaction and customer info
SELECT fr.fraud_id, fr.fraud_type, fr.report_time, t.transaction_id, t.amount, t.transaction_time,
       a.account_id, c.customer_id, c.full_name, c.email, l.city
FROM fraud_reports fr
JOIN transactions t ON fr.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
JOIN locations l ON t.location_id = l.location_id
ORDER BY fr.report_time DESC;


-- 8. Top customers by flagged fraud count
SELECT c.customer_id, c.full_name, COUNT(fr.fraud_id) AS fraud_count
FROM fraud_reports fr
JOIN transactions t ON fr.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY fraud_count DESC LIMIT 20;


-- 9. Daily transaction volumes (count and sum)
SELECT DATE(transaction_time) AS txn_date, COUNT(*) AS txn_count, ROUND(SUM(amount),2) AS daily_volume
FROM transactions
GROUP BY txn_date
ORDER BY txn_date DESC LIMIT 60;


-- 10. Hourly pattern of declined transactions
SELECT HOUR(transaction_time) AS hour_of_day, COUNT(*) declined_count
FROM transactions WHERE status='declined'
GROUP BY hour_of_day ORDER BY declined_count DESC;


-- 11. Average transaction amount by type
SELECT transaction_type, ROUND(AVG(amount),2) AS avg_amount, COUNT(*) AS count_txn
FROM transactions GROUP BY transaction_type;


-- 12. Accounts with sudden balance drop (requires balance snapshots) - approximate using transactions
SELECT account_id, SUM(CASE WHEN transaction_type='withdrawal' THEN amount ELSE 0 END) AS total_withdrawals,
       SUM(CASE WHEN transaction_type='deposit' THEN amount ELSE 0 END) AS total_deposits
FROM transactions GROUP BY account_id HAVING total_withdrawals > total_deposits * 3
ORDER BY total_withdrawals DESC LIMIT 50;


-- 13. Transactions with multiple attempts (same amount repeatedly in short time)
SELECT t1.account_id, t1.amount, COUNT(*) AS attempts, MIN(t1.transaction_time) AS first_time, MAX(t1.transaction_time) AS last_time
FROM transactions t1
GROUP BY t1.account_id, t1.amount
HAVING COUNT(*) >= 3 AND TIMESTAMPDIFF(MINUTE, MIN(t1.transaction_time), MAX(t1.transaction_time)) <= 60
ORDER BY attempts DESC;


-- 14. Percentage of transactions flagged as fraud
SELECT ROUND(100 * COUNT(DISTINCT fr.transaction_id) / (SELECT COUNT(*) FROM transactions),2) AS pct_flagged
FROM fraud_reports fr;


-- 15. Recent suspicious activity per city
SELECT l.city, COUNT(*) AS flagged_txns, ROUND(SUM(t.amount),2) AS flagged_volume
FROM fraud_reports fr
JOIN transactions t ON fr.transaction_id = t.transaction_id
JOIN locations l ON t.location_id = l.location_id
GROUP BY l.city ORDER BY flagged_volume DESC;


-- 16. Window function: rolling sum of last 7 days per account (requires MySQL 8+)
WITH acct_txn AS (
  SELECT account_id, DATE(transaction_time) AS txn_date, ROUND(SUM(amount),2) AS day_total
  FROM transactions GROUP BY account_id, DATE(transaction_time)
)
SELECT account_id, txn_date,
       ROUND(SUM(day_total) OVER (PARTITION BY account_id ORDER BY txn_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS rolling_7day_total
FROM acct_txn ORDER BY account_id, txn_date;


-- 17. Accounts with most declined transactions
SELECT account_id, COUNT(*) AS declined_count
FROM transactions WHERE status='declined' GROUP BY account_id ORDER BY declined_count DESC LIMIT 20;


-- 18. Top 10 largest fraud amounts (join with fraud_reports)
SELECT t.transaction_id, t.account_id, t.amount, fr.fraud_type
FROM fraud_reports fr JOIN transactions t ON fr.transaction_id = t.transaction_id
ORDER BY t.amount DESC LIMIT 10;


-- 19. Time between transaction and fraud report (minutes)
SELECT fr.fraud_id, fr.transaction_id, TIMESTAMPDIFF(MINUTE, t.transaction_time, fr.report_time) AS minutes_to_report
FROM fraud_reports fr JOIN transactions t ON fr.transaction_id = t.transaction_id
ORDER BY minutes_to_report ASC LIMIT 50;


-- 20. Summary: accounts with high-risk score (simple heuristic)
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



















