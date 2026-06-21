-- Create the main table
CREATE TABLE retail_raw (
    invoice       TEXT,
    stock_code    TEXT,
    description   TEXT,
    quantity      INTEGER,
    invoice_date  TEXT,
    unit_price    REAL,
    customer_id   TEXT,
    country       TEXT
);

-- After importing the CSV, clean the data
CREATE TABLE retail_clean AS
SELECT
    invoice,
    stock_code,
    TRIM(description)                        AS description,
    quantity,
    DATE(invoice_date)                       AS invoice_date,
    unit_price,
    customer_id,
    country,
    ROUND(quantity * unit_price, 2)          AS revenue
FROM retail_raw
WHERE
    quantity      > 0          -- remove returns/cancellations
    AND unit_price > 0          -- remove free/error items
    AND customer_id IS NOT NULL -- only identified customers
    AND invoice NOT LIKE 'C%';  -- C prefix = cancelled orders
