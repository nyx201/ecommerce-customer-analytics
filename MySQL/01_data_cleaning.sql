-- ============================================
-- ECOMMERCE ANALYTICS - COMPLETE SQL SCRIPT
-- Dataset: Olist Brazilian E-Commerce
-- ============================================

-- Step 1: Create and select database
CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

-- ============================================
-- Step 2: Create raw tables
-- ============================================

CREATE TABLE IF NOT EXISTS olist_customers_dataset (
    customer_id               VARCHAR(50),
    customer_unique_id        VARCHAR(50),
    customer_zip_code_prefix  VARCHAR(20),
    customer_city             VARCHAR(100),
    customer_state            VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS olist_orders_dataset (
    order_id                      VARCHAR(50),
    customer_id                   VARCHAR(50),
    order_status                  VARCHAR(20),
    order_purchase_timestamp      VARCHAR(50),
    order_approved_at             VARCHAR(50),
    order_delivered_carrier_date  VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS olist_order_items_dataset (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date VARCHAR(50),
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS olist_order_payments_dataset (
    order_id             VARCHAR(50),
    payment_sequential   INT,
    payment_type         VARCHAR(30),
    payment_installments INT,
    payment_value        DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS olist_products_dataset (
    product_id                 VARCHAR(50),
    product_category_name      VARCHAR(100),
    product_name_lenght        VARCHAR(20),
    product_description_lenght VARCHAR(20),
    product_photos_qty         VARCHAR(20),
    product_weight_g           VARCHAR(20),
    product_length_cm          VARCHAR(20),
    product_height_cm          VARCHAR(20),
    product_width_cm           VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS olist_sellers_dataset (
    seller_id        VARCHAR(50),
    seller_zip_code  VARCHAR(20),
    seller_city      VARCHAR(100),
    seller_state     VARCHAR(10)
);

-- ============================================
-- Step 3: Verify raw data loaded correctly
-- ============================================

SELECT 'customers' AS tbl, COUNT(*) AS total FROM olist_customers_dataset UNION ALL
SELECT 'orders',    COUNT(*) FROM olist_orders_dataset UNION ALL
SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset UNION ALL
SELECT 'payments',  COUNT(*) FROM olist_order_payments_dataset UNION ALL
SELECT 'products',  COUNT(*) FROM olist_products_dataset UNION ALL
SELECT 'sellers',   COUNT(*) FROM olist_sellers_dataset;

-- Expected results:
-- customers   99441
-- orders      99441
-- order_items 118291
-- payments    103886
-- products    32340
-- sellers     3095

-- ============================================
-- Step 4: Data Cleaning
-- ============================================

-- Fix for datetime error
SET sql_mode = '';

-- Clean orders: keep only delivered orders with valid dates
DROP TABLE IF EXISTS orders_clean;

CREATE TABLE orders_clean AS
SELECT
    order_id,
    customer_id,
    order_status,
    CASE
        WHEN order_purchase_timestamp = '' THEN NULL
        ELSE STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
    END AS order_date,
    CASE
        WHEN order_delivered_customer_date = '' THEN NULL
        ELSE STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')
    END AS delivery_date,
    CASE
        WHEN order_estimated_delivery_date = '' THEN NULL
        ELSE STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')
    END AS estimated_date
FROM olist_orders_dataset
WHERE order_status = 'delivered'
AND order_purchase_timestamp != ''
AND order_delivered_customer_date != '';

-- Verify: should return 96470
SELECT COUNT(*) AS clean_orders FROM orders_clean;

-- Clean order items: only keep items from delivered orders
DROP TABLE IF EXISTS order_items_clean;

CREATE TABLE order_items_clean AS
SELECT
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    ROUND(oi.price + oi.freight_value, 2) AS total_value
FROM olist_order_items_dataset oi
INNER JOIN orders_clean o ON oi.order_id = o.order_id;

-- Verify: should return around 115000+
SELECT COUNT(*) AS clean_items FROM order_items_clean;

-- ============================================
-- Step 5: Business Metrics Tables
-- ============================================

-- Monthly revenue trend
DROP TABLE IF EXISTS monthly_revenue;

CREATE TABLE monthly_revenue AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    COUNT(DISTINCT o.customer_id)       AS unique_customers,
    ROUND(SUM(oi.price), 2)             AS total_revenue,
    ROUND(AVG(oi.price), 2)             AS avg_order_value
FROM orders_clean o
INNER JOIN order_items_clean oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- Revenue by product category
DROP TABLE IF EXISTS category_revenue;

CREATE TABLE category_revenue AS
SELECT
    p.product_category_name             AS category,
    COUNT(DISTINCT oi.order_id)         AS total_orders,
    ROUND(SUM(oi.price), 2)             AS total_revenue,
    ROUND(AVG(oi.price), 2)             AS avg_price
FROM order_items_clean oi
INNER JOIN olist_products_dataset p ON oi.product_id = p.product_id
WHERE p.product_category_name != ''
GROUP BY category
ORDER BY total_revenue DESC;

-- Revenue by seller state
DROP TABLE IF EXISTS seller_performance;

CREATE TABLE seller_performance AS
SELECT
    s.seller_state,
    COUNT(DISTINCT oi.seller_id)        AS total_sellers,
    COUNT(DISTINCT oi.order_id)         AS total_orders,
    ROUND(SUM(oi.price), 2)             AS total_revenue
FROM order_items_clean oi
INNER JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

-- Payment analysis
DROP TABLE IF EXISTS payment_analysis;

CREATE TABLE payment_analysis AS
SELECT
    payment_type,
    COUNT(*)                            AS total_transactions,
    ROUND(SUM(payment_value), 2)        AS total_value,
    ROUND(AVG(payment_value), 2)        AS avg_value,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM olist_order_payments_dataset
WHERE payment_type != ''
GROUP BY payment_type
ORDER BY total_value DESC;

-- ============================================
-- Step 6: Final verification
-- ============================================

SELECT 'orders_clean' AS tbl, COUNT(*) AS total FROM orders_clean UNION ALL
SELECT 'order_items_clean', COUNT(*) FROM order_items_clean UNION ALL
SELECT 'monthly_revenue',   COUNT(*) FROM monthly_revenue UNION ALL
SELECT 'category_revenue',  COUNT(*) FROM category_revenue UNION ALL
SELECT 'seller_performance', COUNT(*) FROM seller_performance UNION ALL
SELECT 'payment_analysis',  COUNT(*) FROM payment_analysis;

-- Expected:
-- orders_clean      96470
-- order_items_clean 115718
-- monthly_revenue   23
-- category_revenue  73
-- seller_performance 22
-- payment_analysis  5

-- ============================================
-- Step 7: Export these tables as CSV for Python
-- Run each SELECT, then export via Workbench
-- ============================================

SELECT * FROM orders_clean;
SELECT * FROM order_items_clean;
SELECT * FROM monthly_revenue;
SELECT * FROM category_revenue;
SELECT * FROM payment_analysis;
