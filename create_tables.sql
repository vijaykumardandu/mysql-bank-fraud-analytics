-- Banking Transactions Fraud Analytics - schema
CREATE DATABASE IF NOT EXISTS bank_fraud;
USE bank_fraud;

DROP TABLE IF EXISTS fraud_reports;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS locations;

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    city VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(50),
    amount DECIMAL(12,2),
    transaction_time DATETIME,
    location_id INT,
    status VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE fraud_reports (
    fraud_id INT PRIMARY KEY,
    transaction_id INT,
    fraud_type VARCHAR(255),
    report_time DATETIME,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
