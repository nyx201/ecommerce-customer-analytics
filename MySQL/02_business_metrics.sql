-- Monthly revenue trend
CREATE VIEW monthly_revenue AS
SELECT
    STRFTIME('%Y-%m', invoice_date)     AS month,
    COUNT(DISTINCT invoice)              AS total_orders,
    COUNT(DISTINCT customer_id)          AS unique_customers,
    ROUND(SUM(revenue), 2)               AS total_revenue,
    ROUND(AVG(revenue), 2)               AS avg_order_value
FROM retail_clean
GROUP BY month
ORDER BY month;

-- Top 10 products by revenue
CREATE VIEW top_products AS
SELECT
    description,
    COUNT(DISTINCT invoice)   AS times_ordered,
    SUM(quantity)             AS units_sold,
    ROUND(SUM(revenue), 2)    AS total_revenue
FROM retail_clean
GROUP BY description
ORDER BY total_revenue DESC
LIMIT 10;

-- Country-wise revenue
CREATE VIEW country_revenue AS
SELECT
    country,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(revenue), 2)       AS total_revenue
FROM retail_clean
GROUP BY country
ORDER BY total_revenue DESC;

-- RFM base table (for Python to pick up)
CREATE VIEW rfm_base AS
SELECT
    customer_id,
    CAST(
        JULIANDAY('2011-12-10') - JULIANDAY(MAX(invoice_date))
    AS INTEGER)                                AS recency_days,
    COUNT(DISTINCT invoice)                    AS frequency,
    ROUND(SUM(revenue), 2)                     AS monetary
FROM retail_clean
GROUP BY customer_id;
